package unpackUnit;
export  unpackUnit::*;
import  decoder::*;
/* 
    Unpack Unit. Ideally should be in alus.bsv
    Used for the SUNPKD and ZUNPDK instructions.
*/
    
    function Bit#(64) unpck (Bit#(128) inpSE, WbCtrlSgn uctrl);
        case (uctrl) matches
            P810: return {inpSE[95:80]  , inpSE[79:64] , inpSE[31:16], inpSE[15:0] };
            P820: return {inpSE[111:96] , inpSE[79:64] , inpSE[47:32], inpSE[15:0] };
            P830: return {inpSE[127:112], inpSE[79:64] , inpSE[63:48], inpSE[15:0] };
            P831: return {inpSE[127:112], inpSE[95:80] , inpSE[63:48], inpSE[31:16]};
            P832: return {inpSE[127:112], inpSE[111:96], inpSE[63:48], inpSE[47:32]};
            default: return 64'b0;
        endcase
    endfunction
endpackage