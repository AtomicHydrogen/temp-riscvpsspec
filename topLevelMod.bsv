package topLevelMod;
export topLevelMod::*;

    typedef enum {IDLE, PROCESS, READY} MState deriving (Bits, Eq);

    import topLevel::*;
    import Vector :: *;
    import decoder::*;
    
    interface PBoxIfc;
        method Action inp (Bit#(64) rs1, Bit#(64) rs2, Bit#(5) imm, Bit#(10) instr);
        method ActionValue#(Bit#(64)) outp;
    endinterface
    module mkPBox(PBoxIfc);
   
        Reg#(MState) state <- mkReg(IDLE);

        Reg#(Bit#(64)) rs1Inp <- mkRegU;
        Reg#(Bit#(64)) rs2Inp <- mkRegU;
        Reg#(Bit#( 5)) rs3Inp <- mkRegU;
        Reg#(Bit#(10)) instrInp <- mkRegU;
       

        Reg#(Bit#(64)) rd <- mkRegU;

        rule go (state == PROCESS);
            let opa  = rs1Inp;
            let opb  = rs2Inp;
            let opc  = rs3Inp;
            let ctrl = instrInp;
            rd <= pboxDataflow(opa, opb, opc, ctrl);
            state <= READY;
        endrule

        method Action inp (Bit#(64) rs1, Bit#(64) rs2, Bit#(5) imm, Bit#(10) instr) if(state == IDLE);
            rs1Inp <= rs1;
            rs2Inp <= rs2;
            rs3Inp <= imm;
            instrInp <= instr;
            state <= PROCESS;
        endmethod
        method ActionValue#(Bit#(64)) outp if(state == READY);
            state <= IDLE;
            return rd;
        endmethod


    endmodule

endpackage