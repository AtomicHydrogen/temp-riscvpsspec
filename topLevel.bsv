package topLevel;
    import pprtExtension32  :: *;
    import hybridCLA        :: *;
    import Vector           :: *;
    import alus             :: *;
    import writebackControl :: *;
    import unpackUnit       :: *;
	import decoder		    :: *;

    //DEFINE ctrlSgnPacket as a Struct containing individual Ctrl Signals

    //The highest level hardware file.
   


    function Bit#(64) pboxDataflow(Bit#(64) inpRs1, Bit#(64) inpRs2, Bit#(5) imm, Bit#(10) instr);

        //Decode
        CtrlSgnPacket ctrlSignals = decodeFunct37(instr, imm);

        //Generate SA
        ShiftAmount sGen = shiftGen(inpRs2[5:0], imm, ctrlSignals.sftGen);
        Bit#(5) sa_signed = sGen.signedSA;
        Bit#(5) sa        = sGen.outpSA;

        //ALU Dataflow
        Alu1Packet      outp1 = alu1(inpRs1, inpRs2, ctrlSignals.exCtrl, ctrlSignals.crsCtrl, ctrlSignals.invCtrl);

        //Multiplier Dataflow
        MultOut         outpM = multiplySaturate(outp1.rs1out, outp1.rs2out, ctrlSignals.multOp, ctrlSignals.mSat);

        //Unpack Unit Dataflow
        Bit#(64)        outpU = unpck(outp1.unpkd, ctrlSignals.wbSel);

        //ALU Input Mux and mulplier saturation
        Alu2InPacket       i1 = aluMux(outpM, outp1, ctrlSignals.alu2Sel, ctrlSignals.mSat);
        SftCtrlSgn temp;

        //RS2 Check for KSLRA
        if(ctrlSignals.rs2Check == True) begin
            if(sa_signed[4] == 1) begin
                temp = ctrlSignals.altSftCtrl;
            end
            else 
                temp = ctrlSignals.sftCtrl;
        end else temp = ctrlSignals.sftCtrl;
        
        //ALU2 dataflow
        Alu2Packet      outp2 = alu2(inpRs1,i1.rs1out,i1.rs2out,sa,ctrlSignals.alu2Sel,ctrlSignals.alu2Op,temp,ctrlSignals.satCtrl, ctrlSignals.invCtrl);
        Bit#(64) outp3;
        //What to do when both Multiplier and ALU2 are used:: TBD
        //Output Source Select
        if(ctrlSignals.multOp == NOP)
            outp3 = outp2.outp;
        else 
            outp3 = i1.mOut;

        //Generate the relevant 'metadata' bits for WB Control
        Bit#(4) zfs16 = 0;
        Bit#(8) zfs8  = 0;
        if(ctrlSignals.alu2Op == LTE16)
            zfs16  = {outp2.zflags[7]&outp2.zflags[6], outp2.zflags[5]&outp2.zflags[4], outp2.zflags[3]&outp2.zflags[2], outp2.zflags[1]&outp2.zflags[0]}|{outp2.outp[63],outp2.outp[47],outp2.outp[31],outp2.outp[15]};
        else if(ctrlSignals.alu2Op == FX16)
            zfs16 = {outp2.outp[63], outp2.outp[47], outp2.outp[31], outp2.outp[15]};
        else
            zfs16  = {outp2.zflags[7]&outp2.zflags[6], outp2.zflags[5]&outp2.zflags[4], outp2.zflags[3]&outp2.zflags[2], outp2.zflags[1]&outp2.zflags[0]};

        if(ctrlSignals.alu2Op == LTE8) 
            zfs8 = outp2.zflags|{outp2.outp[63],outp2.outp[55],outp2.outp[47],outp2.outp[39],outp2.outp[31],outp2.outp[23],outp2.outp[15],outp2.outp[7]};
        else if(ctrlSignals.alu2Op == ATX8)
            zfs8 = {outp2.outp[63],outp2.outp[55],outp2.outp[47],outp2.outp[39],outp2.outp[31],outp2.outp[23],outp2.outp[15],outp2.outp[7]};
        else 
            zfs8 = outp2.zflags;
    
        Bit#(4)  crrs16 = {outp2.crrs[7],outp2.crrs[5],outp2.crrs[3],outp2.crrs[1]};
        Bit#(2)  crrs32 = {outp2.crrs[7],outp2.crrs[5]};


        //Writeback control and final output
        Bit#(64) rd = writeback(inpRs1,inpRs2,ctrlSignals.wbSel,zfs16,zfs8,crrs16,crrs16,outp2.crrs,outp2.crrs,crrs32,crrs32,outpU,{i1.mOut[62:47],i1.mOut[30:15]},outp3);
        return rd;

    endfunction

endpackage