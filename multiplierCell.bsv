package multiplierCell;
export  multiplierCell :: *;

//USELESS FILE

//Output Format: Out[1] = Carry, Out[0] = Sum

function Bit#(2) fadd (Bit#(1) a, Bit#(1) b, Bit#(1) cin);
    return{(a&b)|(a&cin)|(b&cin), a^(b^cin)};
endfunction
function Bit#(2) hadd (Bit#(1) a, Bit#(1) b);
    return{(a&b), a^b};
endfunction
endpackage