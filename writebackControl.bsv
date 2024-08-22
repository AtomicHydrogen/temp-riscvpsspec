/*
The writeback_control module h&les 16 different operations, including 
16-bit equality check, minimum, & maximum functions; 
 8-bit equality check, minimum, & maximum functions; 
32-bit sign extender, saturator, minimum, & maximum functions; 
& 5 packing instructions identified as 810, 820, 830, 831, & 832. 

Explanation of writeback:
    Bit#(64) rs1   - Original RS1 without mods
    Bit#(64) rs2   - Original RS2 without mods
    WBCtrlSgn ctrl - Control Signal
    Bit#(4) e16    - EQ16 relevant zero flags
    Bit#(8) e8     - EQ8 relevant zero flags
    Bit#(4) m16    - MIN16 relevant MSBS
    Bit#(4) x16    - MAX16 relevant MSBS
    Bit#(8) m8     - MIN8  relevant MSBS
    Bit#(8) x8     - MAX8  relevant MSBS
    Bit#(2) m2     - MIN32 relevant MSBS //Poorly named
    Bit#(2) x2     - MAX32 relevant MSBS //Poorly named
    Bit#(64) upd   - unpackUnit's output
    Bit#(32) ex    - SE32 inputs from the multiplier 
    Bit#(64) alu3  - Should be ALU3's output, for now ALU2/Mult
*/

package writebackControl;
export writebackControl::*;
import decoder::*;
    
    function Bit#(64) writeback(Bit#(64) rs1, Bit#(64) rs2, WbCtrlSgn ctrl,
                                Bit#(4 ) e16, Bit#(8)  e8 , Bit#(4) m16, Bit#(4) x16, Bit#(8) m8, Bit#(8) x8,Bit#(2) m2, Bit#(2) x2, 
                                Bit#(64) upd, Bit#(32) ex , Bit#(64) alu3);
        Bit#(64) rd = 0;
        //Bit#(1) ov;

        case(ctrl) matches

        EQ16: begin 
            rd[15:0]  = 16'hffff & signExtend(e16[0]);
            rd[31:16] = 16'hffff & signExtend(e16[1]);
            rd[47:32] = 16'hffff & signExtend(e16[2]);
            rd[63:48] = 16'hffff & signExtend(e16[3]);
        end
        EQ8: begin 
            rd[7:0]   = 8'hff & signExtend(e8[0]);
            rd[15:8]  = 8'hff & signExtend(e8[1]);
            rd[23:16] = 8'hff & signExtend(e8[2]);
            rd[31:24] = 8'hff & signExtend(e8[3]);
            rd[39:32] = 8'hff & signExtend(e8[4]);
            rd[47:40] = 8'hff & signExtend(e8[5]);
            rd[55:48] = 8'hff & signExtend(e8[6]);
            rd[63:56] = 8'hff & signExtend(e8[7]);
        end

        MIN16: begin

            for(Integer i = 0; i < 4; i = i + 1) begin
                if(m16[i] ==1) begin//IF HIGH, RS1 IS MINIMUM
                    Bit#(16) slicedBits = rs1[15 + 16*i : 16*i];
                    rd[15 + 16*i : 16*i] = slicedBits;
                end
                else begin
                    Bit#(16) slicedBits = rs2[15 + 16*i : 16*i];
                    rd[15 + 16*i : 16*i] = slicedBits;
                end
            end
        end

        MAX16: begin

            for(Integer i = 0; i < 4; i = i + 1) begin
                if(x16[i] ==1) begin//IF HIGH, RS2 IS MAXIMUM
                    Bit#(16) slicedBits = rs2[15 + 16*i : 16*i];
                    rd[15 + 16*i : 16*i] = slicedBits;
                end
                else begin
                    Bit#(16) slicedBits = rs1[15 + 16*i : 16*i];
                    rd[15 + 16*i : 16*i] = slicedBits;
                end
            end
        end

        MIN8: begin

            for(Integer i = 0; i < 8; i = i + 1) begin
                if(m8[i] ==1) begin//IF HIGH, RS1 IS MINIMUM
                    Bit#(8) slicedBits = rs1[7 + 8*i : 8*i];
                    rd[7 + 8*i : 8*i] = slicedBits;
                end
                else begin
                    Bit#(8) slicedBits = rs2[7 + 8*i : 8*i];
                    rd[7 + 8*i : 8*i] = slicedBits;
                end
            end
        end

        MAX8: begin

            for(Integer i = 0; i < 8; i = i + 1) begin
                if(x8[i] ==1) begin//IF HIGH, RS2 IS MAXIMUM
                    Bit#(8) slicedBits = rs2[7 + 8*i : 8*i];
                    rd[7 + 8*i : 8*i] = slicedBits;
                end
                else begin
                    Bit#(8) slicedBits = rs1[7 + 8*i : 8*i];
                    rd[7 + 8*i : 8*i] = slicedBits;
                end
            end
        end

        MIN32: begin

            for(Integer i = 0; i < 2; i = i + 1) begin
                if(m2[i] ==1) begin//IF HIGH, RS1 IS MINIMUM
                    Bit#(32) slicedBits = rs1[31 + 32*i : 32*i];
                    rd[31 + 32*i : 32*i] = slicedBits;
                end
                else begin
                    Bit#(32) slicedBits = rs2[31 + 32*i : 32*i];
                    rd[31 + 32*i : 32*i] = slicedBits;
                end
            end
        end

        MAX32: begin

            for(Integer i = 0; i < 2; i = i + 1) begin
                if(x2[i] ==1) begin
                //IF HIGH, RS2 IS MINIMUM
                    Bit#(32) slicedBits = rs2[31 + 32*i : 32*i];
                    rd[31 + 32*i : 32*i] = slicedBits;
                end
                else begin
                    Bit#(32) slicedBits = rs1[31 + 32*i : 32*i];
                    rd[31 + 32*i : 32*i] = slicedBits;
                end
            end
        end

        /*QSAT31: begin

            if(((~ acc[31]) & (~ mu[31]) & (alu1[31])) | ((acc[31]) & (mu[31]) & (~ alu1[31]))) begin
                ov = 1;
                if (alu1[31] == 0) begin
                    alu1[31:0] = 2^31 - 1;
                end
                else begin
                    alu1[31:0] = -2^31;
                end
            end

            if(((~ acc[63]) & (~ mu[63]) & (alu1[63])) | ((acc[63]) & (mu[63]) & (~ alu1[63]))) begin
                ov = 1;
                if (alu1[63] == 0) begin
                    alu1[63:32] = 32'd 2147483647;
                end
                else begin
                    alu1[63:32] = -2^31;
                end
            end
        end*/
        
        SE32: begin

            rd[31:0]= signExtend(ex[15:0]);
            rd[63:32]= signExtend(ex[31:16]);
            
        end

        P810: rd[63:0] = upd[63:0];

        P820: rd[63:0] = upd[63:0];

        P830: rd[63:0] = upd[63:0];

        P831: rd[63:0] = upd[63:0];

        P832: rd[63:0] = upd[63:0];


        
        default: rd[63:0] = alu3[63:0];

        endcase
        return rd;

endfunction

endpackage