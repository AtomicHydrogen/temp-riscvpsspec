package pbox;

    import topLevelMod::*;



    (*synthesize*)
    module mkTb (PBoxIfc);
        let clk <- exposeCurrentClock;
        let rst <- exposeCurrentReset;
        let ifc();
        mkPBox _temp(ifc);
        return ifc;
    endmodule

endpackage