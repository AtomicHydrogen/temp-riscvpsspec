package pBoxTB;
    `include "decoder.defines"
    import topLevelMod::*;
    import decoder::*;

    typedef enum {READY, RUN, END} State deriving (Bits, Eq);


    (*synthesize*)
    module mkTb (Empty);

        Reg#(State) tbState <- mkReg(READY);
        Reg#(int)      ctr  <- mkReg(0);
        Reg#(Bool)    dispT <- mkReg(True);
        PBoxIfc dut <- mkPBox;


        rule start(tbState == READY);
            Bit#(10) instr = `CMPEQ16;
            Bit#(64) rs1 = 0, rs2 = 0;
            case(ctr) matches
            0: begin 
                 instr = `CMPEQ16;
                rs1 = {16'd2,-16'd15, -16'd3, 16'd2};
                rs2 = {16'd2,-16'd15, 16'd3, -16'd4};
                dispT       <= True; end
            1: begin
                 instr = `SCMPLT16;
                rs1 = {16'd2,16'd2, 16'h8000, 16'd8000};
                rs2 = {16'd2,-16'd10, 16'h7FFF, 16'h8000};
                dispT       <= True; end
            2: begin 
                 instr = `SCMPLE16;
                rs1 = {16'd2,16'd1, 16'd24, 16'd0};
                rs2 = {16'd2,16'd9, 16'd0, 16'd14};
                dispT       <= False; end
            3: begin 
                 instr = `UCMPLT16;
                rs1 = {16'd2,16'd1, 16'd24, 16'd0};
                rs2 = {16'd10,16'd9, 16'd0, 16'd14};
                dispT       <= False; end
            4: begin
                 instr = `UCMPLE16;
                rs1 = {16'h8000,16'h8000, 16'h7FFF, 16'h8000};
                rs2 = {16'h8000,16'h7FFF, 16'h8000, 16'h8000};
                dispT       <= True; end
            endcase
            dut.inp(rs1,rs2,5'b0,instr);
            tbState <= RUN;
        endrule

        rule print(tbState == RUN);

            Bit#(64) result <- (dut.outp);
            if(dispT == True) begin
                
                Int#(16) i1 = unpack(result[63:48]);
                Int#(16) i2 = unpack(result[47:32]);
                Int#(16) i3 = unpack(result[31:16]);
                Int#(16) i4 = unpack(result[15:0]);
                $display("Ans: %d, %d, %d, %d", i1,i2,i3,i4);
            end else $display("Ans: %d, %d, %d, %d", result[63:48],result[47:32], result[31:16], result[15:0]);

            if(ctr == 4) begin
                tbState <= END;
                $finish(0);
            end
            else begin
                ctr <= ctr + 1;
                tbState <= READY;
            end
            
            

        endrule

    endmodule

endpackage