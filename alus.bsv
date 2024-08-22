/*
    Contains functions that describe the behaviour of all major Functional Units. Refer the Block diagram to understand
    where everything fits.

    FUNCTIONS:

    doubleSE               : Sign Extend every Byte of RS1 to a half-word
    doubleZE               : Zero Extend every Byte of RS1 to a half-word
    shiftGen               : Generate sa[4:0] based on SftGenCtrlSgn
    cross64                : SWP Cross Module
    invert                 : SWP Inversion Module
    alu1                   : Entire ALU1 block functionality
    aluMux                 : ALU2 input Mux, multiplier saturation
    alu2                   : Entire ALU2 block functionality
    multiplySaturate       : M1 and M0 multiplication, with mask Bit generation
    mainAluAdd             : Handles all Adder related alu2 ops
    mainAluRandoOperations : Handles all non-Adder related alu2 ops
    mainAluSat             : Handles alu2 post-processing [Signed Halving (SH), Signed Saturation (QSAT), Unsigned Saturation (SAT)]
    
    STRUCTS:

    MultOut: Bit#(64)       m1 - M1 output
             Bit#(64)       m0 - M0 output
             Bit#(8)   andMask - Mask Bits to set MSB = 0 for saturation
             Bit#(128)  orMask - Mask Bits to set [n-2:0] = 1...1 for saturation
            
    Alu1Packet: Bit#(128)  unpkd - input for unpackUnit
                Bit#(64)  rs1out - rs1 output from alu1
                Bit#(64)  rs2out - rs2 output from alu1
    
    Alu2Packet: Bit#(64)   outp - alu2 output
                Bit#(16)   msbs - Byte MSBS of inpA and inpB for Saturation
                Bit#(8)    crrs - Byte-wise Carries (if any) for Min/Max
                Bit#(8)  zflags - Byte-wise zero flags (if any) for LTE, EQ

    Alu2InPacket: Bit#(64) mOut   - Multiplier final output
                  Bit#(64) rs1out - Muxed RS1 field
                  Bit#(64) rs2out - Muxed RS2 field

*/
package alus;
export  alus::*;
import hybridCLA::*;
import alu_shifter::*;
import pprtExtension32::*;
import decoder::*;

    typedef struct {
        Bit#(64) m1;
        Bit#(64) m0;
        Bit#(8)  andMask;
        Bit#(128) orMask;
    } MultOut deriving (Bits, Eq);

    typedef struct {
        Bit#(128) unpkd;
        Bit#(64)  rs1out;
        Bit#(64)  rs2out;

    } Alu1Packet deriving (Bits, Eq);

    typedef struct {
        Bit#(64) outp;
        Bit#(16) msbs;
        Bit#(8 ) crrs;
        Bit#(8) zflags;

    } Alu2Packet deriving (Bits, Eq);

    typedef struct {
        Bit#(64) mOut;
        Bit#(64) rs1out;
        Bit#(64) rs2out;

    } Alu2InPacket deriving (Bits, Eq);
    typedef struct {
        Bit#(5) signedSA;
        Bit#(5) outpSA;
    } ShiftAmount deriving (Bits, Eq);


   
    function Bit#(128) doubleSE (Bit#(64) inpA);
        Bit#(16)t8 = signExtend(inpA[63:56]), t7 =  signExtend(inpA[55:48]),
                t6 = signExtend(inpA[47:40]), t5 =  signExtend(inpA[39:32]),
                t4 = signExtend(inpA[31:24]), t3 = signExtend(inpA[23:16]),
                t2 = signExtend(inpA[15:8]) , t1 = signExtend(inpA[7:0]);
        return {t8,t7,t6,t5,t4,t3,t2,t1};
    endfunction
    function Bit#(128) doubleZE (Bit#(64) inpA);
        Bit#(16)t8 = zeroExtend(inpA[63:56]), t7 = zeroExtend(inpA[55:48]),
                t6 = zeroExtend(inpA[47:40]), t5 = zeroExtend(inpA[39:32]),
                t4 = zeroExtend(inpA[31:24]), t3 = zeroExtend(inpA[23:16]),
                t2 = zeroExtend(inpA[15:8]) , t1 = zeroExtend(inpA[7:0]);
        return {t8,t7,t6,t5,t4,t3,t2,t1};
    endfunction
    
    function ShiftAmount shiftGen (Bit#(6) rs2, Bit#(5) imm, SftGenCtrlSgn genSel);
        ShiftAmount temp = unpack({10'b0});
        case (genSel) matches
            R3: begin
                temp.signedSA = signExtend(rs2[2:0]);
                temp.outpSA   = zeroExtend(rs2[2:0]);
            end
            R4: begin
                temp.signedSA = signExtend(rs2[3:0]);
                temp.outpSA   = zeroExtend(rs2[3:0]);
            end
            R5: begin
                temp.signedSA = signExtend(rs2[4:0]);
                temp.outpSA   = zeroExtend(rs2[4:0]);
            end
            IMM3U: begin
                temp.signedSA = signExtend(imm[2:0]);
                temp.outpSA   = zeroExtend(imm[2:0]);
            end
            IMM4U: begin
                temp.signedSA = signExtend(imm[3:0]);
                temp.outpSA   = zeroExtend(imm[3:0]);
            end
            IMM5U: begin
                temp.signedSA = signExtend(imm[4:0]);
                temp.outpSA   = zeroExtend(imm[4:0]);
            end
            R4S: begin
                if(rs2[3] == 1) begin
                    temp.outpSA = zeroExtend((~rs2[2:0]) + 1);
                    temp.signedSA = signExtend(1'b1);
                end
                else
                    temp.outpSA = zeroExtend(rs2[2:0]);
            end
            R5S: begin
                if(rs2[4] == 1) begin
                    temp.outpSA = zeroExtend((~rs2[3:0]) + 1);
                    temp.signedSA = signExtend(1'b1);
                end
                else
                    temp.outpSA = zeroExtend(rs2[3:0]);
            end
            R6S: begin
                if(rs2[5] == 1) begin
                    temp.outpSA = zeroExtend((~rs2[4:0]) + 1);
                    temp.signedSA = signExtend(1'b1);
                end
                else
                    temp.outpSA = zeroExtend(rs2[4:0]);
            end
            NOP: begin
                temp.signedSA = 5'b0;
                temp.outpSA   = 5'b0;
            end
        endcase
        return temp;
    endfunction



    function Bit#(64) cross64 (Bit#(64) inp, CrsCtrlSgn crs);
        case (crs) matches
            CRS8:
                return {  
                inp[55:48], inp[63:56], 
                inp[39:32], inp[47:40],
                inp[23:16], inp[31:24],
                inp[7:0]  , inp[15: 8]
                };
            CRS16:
                return {
                    inp[47:32], inp[63:48],
                    inp[15: 0], inp[31:16]
                };
            CRS32:
                return {
                    inp[31: 0], inp[63:32]
                };
            NOP:
                return inp;
            endcase
    endfunction

    function Bit#(64) invert (Bit#(64) inp, InvCtrlSgn inv);
        Bit#(64) tempin;
        Bit#(64) addend;
        Bit#(2)    ctrl;
        case (inv) matches 
            INV8: begin
                addend = {8'b1, 8'b1, 8'b1, 8'b1, 8'b1, 8'b1, 8'b1, 8'b1};
                ctrl   = 2'b00;
                tempin = ~(inp);
                return addEverything64(tempin, addend, 1'b0, ctrl)[63:0];
            end
            INV16: begin
                addend = {16'b1, 16'b1, 16'b1, 16'b1};
                ctrl   = 2'b01;
                tempin = ~(inp);
                return addEverything64(tempin, addend, 1'b0, ctrl)[63:0];
            end
            INV32: begin
                addend = {32'b1, 32'b1};
                ctrl   = 2'b10;
                tempin = ~(inp);
                return addEverything64(tempin, addend, 1'b0, ctrl)[63:0];
            end
            LNV16: begin
                addend = {16'b0,16'b1,16'b0,16'b1};
                ctrl   = 2'b01;
                tempin = {inp[63:48],~(inp[47:32]),inp[31:16],~(inp[15:0])};
                return addEverything64(tempin, addend, 1'b0, ctrl)[63:0];
            end
            LNV32: begin
                addend = {32'b0, 32'b1};
                ctrl   = 2'b10;
                tempin = {inp[63:32],~(inp[31:0])};
                return addEverything64(tempin, addend, 1'b0, ctrl)[63:0];
            end
            UNV16: begin
                addend = {16'b1, 16'b0, 16'b1, 16'b0};
                ctrl   = 2'b01;
                tempin = {~(inp[63:48]),inp[47:32],~(inp[31:16]),inp[15:0]};
                return addEverything64(tempin, addend, 1'b0, ctrl)[63:0];
            end
            UNV32: begin
                addend = {32'b1, 32'b0};
                ctrl   = 2'b10;
                tempin = {~(inp[63:32]),inp[31:0]};
                return addEverything64(tempin, addend, 1'b0, ctrl)[63:0];
            end
            NOP: begin
                addend = 64'b0;
                ctrl   = 2'b11;
                tempin = inp;
                return tempin;
            end
            endcase
       
        

    endfunction



    function Alu1Packet alu1 (Bit#(64) rs1, Bit#(64) rs2, ExtCtrlSgn ext, CrsCtrlSgn crs, InvCtrlSgn inv);
        Alu1Packet outp;

        //Unpacking Sign/Zero Extension
        if(ext == EightSE16) outp.unpkd = doubleSE(rs1);
        else                 outp.unpkd = doubleZE(rs1);
        
        Bit#(64) tempRs2 = cross64(rs2, crs);
        outp.rs1out = rs1; outp.rs2out = invert(tempRs2, inv);

        return outp;
    
    endfunction

    function Alu2InPacket aluMux (MultOut rawMul, Alu1Packet alu1Out, AluMuxCtrlSgn ctrl, MSatCtrlSgn mSat);
        Alu2InPacket temp = unpack(192'b0);
        case (ctrl) matches
            BOT32: begin
                temp.mOut = {rawMul.m1[31:0],rawMul.m0[31:0]};
                if(mSat == SAT) begin
                    Bit#(64) mask = {rawMul.orMask[95:64],rawMul.orMask[31:0]};
                    temp.mOut = temp.mOut|mask;
                    temp.mOut[31] = temp.mOut[31] & rawMul.andMask[1];
                    temp.mOut[63] = temp.mOut[63] & rawMul.andMask[4];
                end
                temp.rs1out  = {alu1Out.rs1out[31:0],alu1Out.rs2out[31:0]};
                
            end
            TOP33: begin
                temp.mOut = {rawMul.m1[63:32],rawMul.m0[63:32]};
                if(mSat == SAT) begin
                    Bit#(64) mask = {rawMul.orMask[127:96],rawMul.orMask[63:32]};
                    temp.mOut = temp.mOut|mask;
                    temp.mOut[31] = temp.mOut[31] & rawMul.andMask[3];
                    temp.mOut[63] = temp.mOut[63] & rawMul.andMask[7];
                end
                temp.rs1out  = {alu1Out.rs1out[63:32],alu1Out.rs2out[63:32]};
            end
            TOFF33: begin
                temp.mOut = {rawMul.m1[62:31],rawMul.m0[62:31]};
                temp.rs1out  = alu1Out.rs1out;
            end
            BOT31: begin
                temp.mOut = {rawMul.m1[30:0],1'b0,rawMul.m0[30:0],1'b0};
                if(mSat == SAT) begin
                    Bit#(64) mask = {rawMul.orMask[95:64],rawMul.orMask[31:0]};
                    temp.mOut = temp.mOut|mask;
                    temp.mOut[31] = temp.mOut[31] & rawMul.andMask[1];
                    temp.mOut[63] = temp.mOut[63] & rawMul.andMask[4];
                end
                temp.rs1out  = alu1Out.rs1out;
            end
            TOFF31: begin
                temp.mOut = {rawMul.m1[62:32],1'b0,rawMul.m0[62:32],1'b0};
                if(mSat == SAT) begin
                    Bit#(64) mask = {rawMul.orMask[127:96],rawMul.orMask[63:32]};
                    temp.mOut = temp.mOut|mask;
                    temp.mOut[31] = temp.mOut[31] & rawMul.andMask[3];
                    temp.mOut[63] = temp.mOut[63] & rawMul.andMask[7];
                end
                temp.rs1out  = alu1Out.rs1out;
            end
            SR15: begin
                temp.mOut = {rawMul.m1[62:47],rawMul.m1[30:15],rawMul.m0[62:47],rawMul.m0[30:15]};
                if(mSat == SAT) begin
                    Bit#(64) mask = {rawMul.orMask[127:112],rawMul.orMask[95:80],rawMul.orMask[63:48],rawMul.orMask[31:16]};
                    temp.mOut = temp.mOut|mask;
                    temp.mOut[15] = temp.mOut[15] & rawMul.andMask[1];
                    temp.mOut[31] = temp.mOut[31] & rawMul.andMask[3];
                    temp.mOut[47] = temp.mOut[47] & rawMul.andMask[5];
                    temp.mOut[63] = temp.mOut[63] & rawMul.andMask[7];
                end
                temp.rs1out  = alu1Out.rs1out;
            end
            SR7: begin
                temp.mOut = {rawMul.m1[62:55],rawMul.m1[46:39],rawMul.m1[30:23],rawMul.m1[14:7],rawMul.m0[62:55],rawMul.m0[46:39],rawMul.m0[30:23],rawMul.m0[14:7]};
                if(mSat == SAT) begin
                    Bit#(64) mask = {rawMul.orMask[127:120],rawMul.orMask[111:104],rawMul.orMask[95:88],rawMul.orMask[79:72],rawMul.orMask[63:56],rawMul.orMask[47:40],rawMul.orMask[31:24],rawMul.orMask[15:8]};
                    temp.mOut = temp.mOut|mask;
                    temp.mOut[7]  = temp.mOut[7]  & rawMul.andMask[0];
                    temp.mOut[15] = temp.mOut[15] & rawMul.andMask[1];
                    temp.mOut[23] = temp.mOut[23] & rawMul.andMask[2];
                    temp.mOut[31] = temp.mOut[31] & rawMul.andMask[3];
                    temp.mOut[39] = temp.mOut[39] & rawMul.andMask[4];
                    temp.mOut[47] = temp.mOut[47] & rawMul.andMask[5];
                    temp.mOut[55] = temp.mOut[55] & rawMul.andMask[6];
                    temp.mOut[63] = temp.mOut[63] & rawMul.andMask[7];
                end
                temp.rs1out  = alu1Out.rs1out;
            end
            M1: begin
                temp.mOut = rawMul.m1;
                temp.rs1out  = alu1Out.rs1out;
            end
            BOT16: begin
                temp.mOut = rawMul.m0;
                temp.rs1out  = {alu1Out.rs1out[47:32],alu1Out.rs2out[47:32],alu1Out.rs1out[15:0],alu1Out.rs2out[15:0]};
            end
            TOP16: begin
                temp.mOut = rawMul.m0;
                temp.rs1out  = {alu1Out.rs1out[63:48],alu1Out.rs2out[63:48],alu1Out.rs1out[31:16],alu1Out.rs2out[31:16]};
            end
            
            NOP: begin
                temp.mOut = rawMul.m0;
                temp.rs1out  = alu1Out.rs1out;
            end
        endcase

        temp.rs2out  = alu1Out.rs2out;
        return temp;
    endfunction

    function Alu2Packet alu2 (Bit#(64) rs1, Bit#(64) inpA, Bit#(64) inpB, Bit#(5) shiftAmount, AluMuxCtrlSgn aluSel, Alu2CtrlSgn alu2Op, SftCtrlSgn sftCtrl, SatCtrlSgn satCtrl, InvCtrlSgn invCtrl);

        Shifter     iRes1  =         mainAluShift(inpA, shiftAmount, sftCtrl);
        Bool useAdder;
        case(alu2Op) matches
            FX16   : useAdder = True;
            ATX8   : useAdder = True;
            TX32   : useAdder = True;
            RND32  : useAdder = True; 
            RND16  : useAdder = True; 
            RND8   : useAdder = True; 
            LTE8   : useAdder = True; 
            LTE16  : useAdder = True;
            CMP32  : useAdder = False;
            CMP16  : useAdder = False; 
            CMP8   : useAdder = False; 
            CLRS32 : useAdder = False; 
            CLRS16 : useAdder = False; 
            CLRS8  : useAdder = False; 
            CLZ32  : useAdder = False; 
            CLZ16  : useAdder = False; 
            CLZ8   : useAdder = False;
            ABS8   : useAdder = False; 
            ABS16  : useAdder = False; 
            ABS32  : useAdder = False; 
            NOP    : useAdder = False;
            default: useAdder = True;
        endcase
        Bit#(8) zfs = 0;
        AdderOutput iRes2;
        if(useAdder == True) begin
            iRes2 =  mainAluAdd(iRes1.op,inpB, iRes1.msb, alu2Op);
            for(Integer i = 0; i < 8; i = i + 1) begin
                Bit#(8) slicedBits = iRes2.outp[7 + 8*i : 8*i];
                if(slicedBits == 8'h00) 
                    zfs[i] = 1'b1;
                else 
                    zfs[i] = 1'b0;
            end
        end
        else begin
            iRes2 = mainAluRandoOperations(rs1,iRes1.op,inpB, alu2Op);
            zfs = iRes2.crrs;
        end
        
        Alu2Packet temp;
        temp.outp = mainAluSat(iRes2, satCtrl,invCtrl);
        temp.msbs = iRes2.msbs;
        temp.crrs = iRes2.crrs;
        temp.zflags = zfs;
        
        return temp;
        

    endfunction

    function AdderOutput mainAluRandoOperations (Bit#(64) rs1, Bit#(64) inpA, Bit#(64) inpB, Alu2CtrlSgn miscCtrl);
        AdderOutput temp = unpack(88'b0);
        case (miscCtrl) matches
            CMP8: begin
                Bit#(64) xorRed  = inpA^inpB;
                Bit#(8)  zeroDet = {(&xorRed[63:56]),(&xorRed[55:48]),(&xorRed[47:40]),(&xorRed[39:32]),(&xorRed[31:24]),(&xorRed[23:16]),(&xorRed[15:8]),(&xorRed[7:0])};
                temp.crrs = zeroDet;
                temp.outp = xorRed;
            end
            CMP16: begin
                Bit#(64) xorRed  = inpA^inpB;
                Bit#(8) zeroDet = 0;
                for(Integer i = 0; i < 8; i = i + 1) begin
                    Bit#(8) slicedBits = xorRed[7 + 8*i : 8*i];
                    if(slicedBits == 8'h00)
                        zeroDet[i] = 1'b1;
                end
                temp.crrs = zeroDet;
                temp.outp = xorRed;
            end
            CMP32: begin
                Bit#(64) xorRed  = inpA^inpB;
                Bit#(8)  zeroDet = {(&xorRed[63:56]),(&xorRed[55:48]),(&xorRed[47:40]),(&xorRed[39:32]),(&xorRed[31:24]),(&xorRed[23:16]),(&xorRed[15:8]),(&xorRed[7:0])};
                temp.crrs = zeroDet;
                temp.outp = xorRed;
            end
            CLZ8: begin
                for(Integer i = 0; i < 8; i = i + 1) begin
                    Bit#(8) slicedBits = inpA[7 + 8*i : 8*i];
                    Bit#(4) res        = pack(countZerosMSB(slicedBits));
                    temp.outp[7 + 8*i : 8*i] = {4'b0, res};
                end
                temp.crrs = 8'b0;
            end 
            CLZ16: begin
                for(Integer i = 0; i < 4; i = i + 1) begin
                    Bit#(16) slicedBits = inpA[15 + 16*i : 16*i];
                    Bit#(5)  res        = pack(countZerosMSB(slicedBits));
                    temp.outp[15 + 16*i : 16*i] = {11'b0, res};
                end
                temp.crrs = 8'b0;
            end 
            CLZ32: begin
                for(Integer i = 0; i < 2; i = i + 1) begin
                    Bit#(32) slicedBits = inpA[31 + 32*i : 32*i];
                    Bit#(6)  res        = pack(countZerosMSB(slicedBits));
                    temp.outp[31 + 32*i : 32*i] = {26'b0, res};
                end
                temp.crrs = 8'b0;
            end
            CLRS8: begin
                for(Integer i = 0; i < 8; i = i + 1) begin
                    if(inpA[7 + 8*i] == 1) begin 
                        Bit#(8) slicedBits = ~(inpA[7 + 8*i : 8*i]);
                        Bit#(4) res        = pack(countZerosMSB(slicedBits));
                        temp.outp[7 + 8*i : 8*i] = {4'b0, res};
                    end
                    else begin
                        Bit#(8) slicedBits = inpA[7 + 8*i : 8*i];
                        Bit#(4) res        = pack(countZerosMSB(slicedBits));
                        temp.outp[7 + 8*i : 8*i] = {4'b0, res};
                    end
                end
                temp.crrs = 8'b0;
            end 
            CLRS16: begin
                for(Integer i = 0; i < 4; i = i + 1) begin
                    if(inpA[15 + 16*i] == 1) begin
                        Bit#(16) slicedBits = ~(inpA[15 + 16*i : 16*i]);
                        Bit#(5)  res        = pack(countZerosMSB(slicedBits));
                        temp.outp[15 + 16*i : 16*i] = {11'b0, res};
                    end
                    else begin
                        Bit#(16) slicedBits = inpA[15 + 16*i : 16*i];
                        Bit#(5)  res        = pack(countZerosMSB(slicedBits));
                        temp.outp[15 + 16*i : 16*i] = {11'b0, res};
                    end
                end
                temp.crrs = 8'b0;
            end 
            CLRS32: begin
                for(Integer i = 0; i < 2; i = i + 1) begin
                    if(inpA[31 + 32*i] == 1) begin
                        Bit#(32) slicedBits = ~(inpA[31 + 32*i : 32*i]);
                        Bit#(6)  res        = pack(countZerosMSB(slicedBits));
                        temp.outp[31 + 32*i : 32*i] = {26'b0, res};
                    end
                    else begin
                        Bit#(32) slicedBits = inpA[31 + 32*i : 32*i];
                        Bit#(6)  res        = pack(countZerosMSB(slicedBits));
                        temp.outp[31 + 32*i : 32*i] = {26'b0, res};
                    end
                end
                temp.crrs = 8'b0;
            end 
            ABS8: begin
                for(Integer i = 0; i < 8; i = i + 1) begin
                    if(inpA[7 + 8*i] == 1) begin
                        Bit#(8) slicedBits = inpA[7 + 8*i : 8*i];
                        temp.outp[7 + 8*i : 8*i] = slicedBits;
                    end
                    else begin
                        Bit#(8) rs1Slice = rs1[7 + 8*i : 8*i];
                        temp.outp[7 + 8*i : 8*i] = rs1Slice;
                    end
                end
                temp.crrs = 8'b0;
            end 
            ABS16: begin
                for(Integer i = 0; i < 4; i = i + 1) begin
                    if(inpA[15 + 16*i] == 1) begin
                        Bit#(16) slicedBits = inpA[15 + 16*i : 16*i];
                        temp.outp[15 + 16*i : 16*i] = slicedBits;
                    end
                    else begin
                        Bit#(16) rs1Slice = rs1[15 + 16*i : 16*i];
                        temp.outp[15 + 16*i : 16*i] = rs1Slice;
                    end
                end
                temp.crrs = 8'b0;
            end 
            ABS32: begin
                for(Integer i = 0; i < 2; i = i + 1) begin
                    if(inpA[31 + 32*i] == 1) begin
                        Bit#(32) slicedBits = inpA[31 + 32*i : 32*i];
                        temp.outp[31 + 32*i : 32*i] = slicedBits;
                    end
                    else begin
                        Bit#(32) rs1Slice = rs1[31 + 32*i : 32*i];
                        temp.outp[31 + 32*i : 32*i] = rs1Slice;
                    end
                end
                temp.crrs = 8'b0;
            end 

            default: begin
                temp.outp = inpA;
                temp.crrs = 8'b0;
            end
        endcase
        return temp;


    endfunction


    function AdderOutput mainAluAdd (Bit#(64) inpA, Bit#(64) inpB, Bit#(8) rndData, Alu2CtrlSgn ctrl);
        Bit#(2)  addOp;
        Bit#(64)   op2;
        
        Bool lte;
        case (ctrl) matches
            ATX8: begin
                op2   = inpB;
                addOp = 2'b00;
                
                lte = False;
            end
            FX16: begin
                op2   = inpB;
                addOp = 2'b01;
                
                lte = False;
            end
            TX32: begin
                op2   = inpB;
                addOp = 2'b10;
                
                lte = False;
            end
            RND8: begin
                op2   = {7'b0, rndData[7], 7'b0, rndData[6], 7'b0, rndData[5], 7'b0, rndData[4],
                         7'b0, rndData[3], 7'b0, rndData[2], 7'b0, rndData[1],7 'b0, rndData[0]};
                addOp = 2'b00;
                
                lte = False;
            end 
            RND16: begin
                op2   = {7'b0, rndData[7], 7'b0, rndData[6], 7'b0, rndData[5], 7'b0, rndData[4],
                         7'b0, rndData[3], 7'b0, rndData[2], 7'b0, rndData[1], 7'b0, rndData[0]};
                addOp = 2'b01;
                
                lte = False;
            end 
            RND32: begin
                op2   = {7'b0, rndData[7], 7'b0, rndData[6], 7'b0, rndData[5], 7'b0, rndData[4],
                         7'b0, rndData[3], 7'b0, rndData[2], 7'b0, rndData[1], 7'b0, rndData[0]};
                addOp = 2'b10;
                
                lte = False;
            end 
            CMP16: begin
                op2   = inpB;
                addOp = 2'b01;
                
                lte = False;
            end
            CMP8: begin
                op2   = inpB;
                addOp = 2'b00;
                
                lte = False;
            end
            LTE16: begin
                op2   = inpB;
                addOp = 2'b01;
                
                lte = True;
            end
            LTE8: begin
                op2   = inpB;
                addOp = 2'b00;
                
                lte = True;
            end
            default: begin
                op2   = inpB;
                addOp = 2'b11;
                
                lte = False;
            end
        endcase
        AdderOutput temp = addwMetaData(inpA, op2, 1'b0, addOp);
        if(lte == True)
            temp.crrs = {temp.outp[63],temp.outp[55],temp.outp[47],temp.outp[39],temp.outp[31],temp.outp[23],temp.outp[15],temp.outp[7]};

        return temp;
    endfunction

    function Bit#(64) mainAluSat (AdderOutput rawVal, SatCtrlSgn ctrl, InvCtrlSgn inv);
        Bit#(64) res = 0;
        Bit#(64) temp = rawVal.outp;
        case (ctrl) matches 
            SH8: begin
                for(Integer i = 0; i < 8; i = i + 1) begin
                    Bit#(7) slicedBits = (temp[7 + 8*i : 1 + 8*i]);
                    res[7 + 8*i : 8*i] = {slicedBits[6], slicedBits};
                end
            end
            SH16: begin
                for(Integer i = 0; i < 4; i = i + 1) begin
                    Bit#(15) slicedBits = temp[15 + 16*i : 1 + 16*i];
                    res[15 + 16*i : 16*i] = {slicedBits[14], slicedBits};
                end
            end
            SH32: begin
                for(Integer i = 0; i < 2; i = i + 1) begin
                    Bit#(31) slicedBits = temp[31 + 32*i : 1+32*i];
                    res[31 + 32*i : 32*i] = {slicedBits[30],slicedBits};
                end
            end
            H8: begin
                for(Integer i = 0; i < 8; i = i + 1) begin
                    Bit#(7) slicedBits = (temp[7 + 8*i : 1 + 8*i]);
                    res[7 + 8*i : 8*i] = {1'b0, slicedBits};
                end
            end
            H16: begin
                for(Integer i = 0; i < 4; i = i + 1) begin
                    Bit#(15) slicedBits = temp[15 + 16*i : 1 + 16*i];
                    res[15 + 16*i : 16*i] = {1'b0, slicedBits};
                end
            end
            H32: begin
                for (Integer i = 0; i < 2; i = i + 1) begin
                    Bit#(31) slicedBits = temp[31 + 32*i : 1 + 32*i];
                    res[31 + 32*i : 32*i] = {1'b0, slicedBits};
                 end
            end
            QSAT7: begin
                for(Integer i = 0; i < 8; i = i + 1) begin
                    if((rawVal.msbs[i] == rawVal.msbs[8 + i])&&(rawVal.msbs[i] != rawVal.outp[7 + 8*i])) begin
                        if(rawVal.msbs[i] == 0) 
                            res[7 + 8*i : 8*i] = 8'h7F;
                        else
                            res[7 + 8*i : 8*i] = 8'h80;
                    end
                    else begin
                        Bit#(8) slicedBits = temp[7 + 8*i : 8*i];
                        res[7 + 8*i : 8*i] = slicedBits;
                    end
                end
            end
            QSAT15: begin
                for(Integer i = 0; i < 4; i = i + 1) begin
                    if((rawVal.msbs[2*i+1] == rawVal.msbs[9 + 2*i])&&(rawVal.msbs[2*i+1] != rawVal.outp[15 + 16*i])) begin
                        if(rawVal.msbs[2*i+1] == 0) 
                            res[15 + 16*i : 16*i] = 16'h7FFF;
                        else
                            res[15 + 16*i : 16*i] = 16'h8000;
                    end
                    else begin
                        Bit#(16) slicedBits = temp[15 + 16*i : 16*i];
                        res[15 + 16*i : 16*i] = slicedBits;
                    end
                end
            end
            QSAT31: begin
                for(Integer i = 0; i < 2; i = i + 1) begin
                    if((rawVal.msbs[4*i+3] == rawVal.msbs[11 + 4*i])&&(rawVal.msbs[4*i+3] != rawVal.outp[31 + 32*i])) begin
                        if(rawVal.msbs[4*i+3] == 0) 
                            res[31 + 32*i : 32*i] = 32'h7FFFFFFF;
                        else
                            res[31 + 32*i : 32*i] = 32'h80000000;
                    end
                    else begin
                        Bit#(32) slicedBits = temp[31 + 32*i : 32*i];
                        res[31 + 32*i : 32*i] = slicedBits;
                    end
                end
            end
            SAT8: begin
                for(Integer i = 0; i < 8; i = i + 1)  begin
                    if(inv == INV8) begin
                        if(rawVal.crrs[i] == 0)
                            res[7 + 8*i : 8*i] = 8'h00;
                        else begin
                            Bit#(8) slicedBits = temp[7 + 8*i : 8*i];
                            res[7 + 8*i : 8*i] = slicedBits;
                        end
                    end
                    else begin
                        if(rawVal.crrs[i] == 1)
                            res[7 + 8*i : 8*i] = 8'hFF;
                        else begin
                            Bit#(8) slicedBits = temp[7 + 8*i : 8*i];
                            res[7 + 8*i : 8*i] = slicedBits;
                        end
                    end
                    
                end
            end
            SAT16: begin
                for(Integer i = 0; i < 4; i = i + 1)  begin
                    if(inv == INV16) begin
                        if(rawVal.crrs[2*i+1] == 0)
                            res[15 + 16*i : 16*i] = 16'h0000;
                        else begin
                            Bit#(16) slicedBits = temp[15 + 16*i : 16*i];
                            res[15 + 16*i : 16*i] = slicedBits;
                        end
                    end
                    else if((inv == LNV16)&&(i%2==0)) begin
                        if(rawVal.crrs[2*i+1] == 0)
                            res[15 + 16*i : 16*i] = 16'h0000;
                        else begin
                            Bit#(16) slicedBits = temp[15 + 16*i : 16*i];
                            res[15 + 16*i : 16*i] = slicedBits;
                        end
                    end
                    else if((inv == UNV16)&&(i%2==1)) begin
                        if(rawVal.crrs[2*i+1] == 0)
                            res[15 + 16*i : 16*i] = 16'h0000;
                        else begin
                            Bit#(16) slicedBits = temp[15 + 16*i : 16*i];
                            res[15 + 16*i : 16*i] = slicedBits;
                        end
                    end
                    else begin
                        if(rawVal.crrs[2*i+1] == 1)
                            res[15 + 16*i : 16*i] = 16'hFFFF;
                        else begin
                            Bit#(16) slicedBits = temp[15 + 16*i : 16*i];
                            res[15 + 16*i : 16*i] = slicedBits;
                        end
                    end

                end
            end
            SAT32: begin
                for(Integer i = 0; i < 2; i = i + 1)  begin
                    if(inv == INV32) begin
                        if(rawVal.crrs[4*i+3] == 0)
                            res[31 + 32*i : 32*i] = 32'h00000000;
                        else begin
                            Bit#(32) slicedBits = temp[31 + 32*i : 32*i];
                            res[31 + 32*i : 32*i] = slicedBits;
                        end
                    end
                    else if((inv == LNV32)&&(i%2==0)) begin
                        if(rawVal.crrs[4*i+3] == 0)
                            res[31 + 32*i : 32*i] = 32'h00000000;
                        else begin
                            Bit#(32) slicedBits = temp[31 + 32*i : 32*i];
                            res[31 + 32*i : 32*i] = slicedBits;
                        end
                    end
                    else if((inv == UNV32)&&(i%2==1)) begin
                        if(rawVal.crrs[4*i+3] == 0)
                            res[31 + 32*i : 32*i] = 32'h00000000;
                        else begin
                            Bit#(32) slicedBits = temp[31 + 32*i : 32*i];
                            res[31 + 32*i : 32*i] = slicedBits;
                        end
                    end
                    else begin
                        if(rawVal.crrs[4*i+3] == 1)
                            res[31 + 32*i : 32*i] = 32'hFFFFFFFF;
                        else begin
                            Bit#(32) slicedBits = temp[31 + 32*i : 32*i];
                            res[31 + 32*i : 32*i] = slicedBits;
                        end
                    end
                end
            end
            NOP:
                res = rawVal.outp;
            default:
                res = rawVal.outp;
        endcase

        return res;
    endfunction

    function Shifter mainAluShift (Bit#(64) inp, Bit#(5) sa, SftCtrlSgn ctrl);
        case (ctrl) matches
            LSFT8:
                return  left8(inp, sa, 0);
            LSFT16:
                return left16(inp, sa, 0);
            LSFT32: 
                return left32(inp ,sa, 0);
            KLSFT8:
                return  left8(inp, sa, 1);
            KLSFT16:
                return left16(inp, sa, 1);
            KLSFT32: 
                return left32(inp ,sa, 1);
            RSFT8:
                return  r8_logic(inp, sa);
            RSFT16:
                return r16_logic(inp, sa);
            RSFT32:
                return r32_logic(inp, sa);
            ARSFT8:
                return  r8_arithm(inp, sa);
            ARSFT16:
                return r16_arithm(inp, sa);
            ARSFT32:
                return r32_arithm(inp ,sa);
            NOP:
                return Shifter {op:inp, msb:8'd0};
        endcase
    endfunction

    function MultOut multiplySaturate (Bit#(64) inpA, Bit#(64) inpB, MultCtrlSgn ctrl, MSatCtrlSgn satCtrl);
        Bit#(8) andMask = 8'hFF;
        Bit#(128) orMask = 0;
        Bit#(3)    mCtrl;
        MultOut temp;
        case(ctrl) matches
            ATX8S:
                mCtrl = 3'b101;
            FX16S:
                mCtrl = 3'b110;
            TX32S:
                mCtrl = 3'b100;
            ATX8:
                mCtrl = 3'b001;
            FX16:
                mCtrl = 3'b010;
            TX32:
                mCtrl = 3'b000;
            default:
                mCtrl = 3'b000;
        endcase

        temp.m0 = product(inpA[31:0] , inpB[31:0]  , mCtrl);
        temp.m1 = product(inpA[63:32], inpB[63:32] , mCtrl);

        case(satCtrl) matches
            SAT: begin
                case(ctrl) matches
                    ATX8S: begin
                        for(Integer i = 0; i < 8; i = i + 1) begin
                            Bit#(8) rs1Slice = inpA[7 + 8*i : 8*i];
                            Bit#(8) rs2Slice = inpB[7 + 8*i : 8*i];
                            if(rs1Slice == 8'h80 && rs2Slice == 8'h80) begin
                                andMask[i] = 1'b0;
                                orMask [15 + 16*i : 16*i] = 16'h7FFF;
                            end
                            else begin
                                andMask[i] = 1'b1;
                                orMask [15 + 16*i : 16*i] = 16'b0;
                            end
                        end
                    end
                    FX16S: begin
                        for(Integer i = 0; i < 4; i = i + 1) begin
                            Bit#(16) rs1Slice = inpA[15 + 16*i : 16*i];
                            Bit#(16) rs2Slice = inpB[15 + 16*i : 16*i];
                            if(rs1Slice == 16'h8000 && rs2Slice == 16'h8000) begin
                                andMask[2*i+1] = 1'b0;
                                orMask [31 + 32*i : 32*i] = 32'h7FFFFFFF;
                            end
                            else begin
                                andMask[2*i+1] = 1'b1;
                                orMask [31 + 32*i : 32*i] = 32'b0;
                            end
                        end
                    end
                    TX32S: begin
                        for(Integer i = 0; i < 2; i = i + 1) begin
                            Bit#(32) rs1Slice = inpA[31 + 32*i : 32*i];
                            Bit#(32) rs2Slice = inpB[31 + 32*i : 32*i];
                            if(rs1Slice == 32'h80000000 && rs2Slice == 32'h80000000) begin
                                andMask[4*i+3] = 1'b0;
                                orMask [63 + 64*i : 64*i] = 64'h7FFFFFFFFFFFFFFF;
                            end
                            else begin
                                andMask[4*i+3] = 1'b1;
                                orMask [63 + 64*i : 64*i] = 64'b0;
                            end
                        end
                    end
                    default: begin
                        andMask = 8'hFF;
                        orMask  = 128'b0;
                    end
                endcase
            end
            NOSAT: begin
                andMask = 8'hFF;
                orMask  = 128'b0;
            end
            default begin
                andMask = 8'hFF;
                orMask  = 128'b0;
            end
       

        endcase
        temp.andMask = andMask;
        temp.orMask  =  orMask;
        return temp;


    endfunction


endpackage