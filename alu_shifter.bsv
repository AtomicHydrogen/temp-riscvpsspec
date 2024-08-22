package alu_shifter;
export alu_shifter::*;

/*
    Contains All Shifter Modules

    FUNCTIONS: 

    r8_arithm : SWP 8b  Arithmetic Right Shift
    r16_arithm: SWP 16b Arithmetic Right Shift
    r32_arithm: SWP 32b Arithmetic Right Shift
    r8_logic  : SWP 8b  Logical    Right Shift
    r16_logic : SWP 16b Logical    Right Shift
    r32_logic : SWP 32b Logical    Right Shift
    left8     : SWP 8b  Sat/NoSat  Left  Shift
    left16    : SWP 16b Sat/NoSat  Left  Shift
    left32    : SWP 32b Sat/NoSat  Left  Shift

    STRUCTS:
    
    Shifter: Bit#(64) op - Shifter output
             Bit#(8) msb - Rounding bits

    For Arthimetic Shifts of subwords size 'n', we shift by sa - 1.
    Let ioutp = subwordx << (sa - 1) (sa != 0)
    outp = signExtend(ioutp[n-1:1]), rndBitx = ioutp[0]

    Bit#(1) sat determines whether to saturate or not for left shifts.

*/

typedef struct {

        Bit#(8) msb;
        Bit#(64) op;

    } Shifter deriving (Bits, Eq);



function Shifter r8_arithm( Bit#(64) inp, Bit#(5) ctrl);

    Shifter temp = unpack(72'b0);

    if(ctrl != 0) begin

    //Bit#(8) msb;
        Int#(8) op0,op1,op2,op3,op4,op5,op6,op7;
        Bit#(8) of0,of1,of2,of3,of4,of5,of6,of7;
    //Bit#(64) opb;

    
    //for(Integer i = 0; i < 2; i = i + 1) begin

        //Int#(8)temp1= unpack(inp[7+8*i:0+8*i])

        Int#(8)temp0= unpack(inp[7:0]);
        Int#(8)temp1= unpack(inp[15:8]);
        Int#(8)temp2= unpack(inp[23:16]);
        Int#(8)temp3= unpack(inp[31:24]);
        Int#(8)temp4= unpack(inp[39:32]);
        Int#(8)temp5= unpack(inp[47:40]);
        Int#(8)temp6= unpack(inp[55:48]);
        Int#(8)temp7= unpack(inp[63:56]);

        op0= (temp0 >> (ctrl[2:0] - 1));
        op1= (temp1 >> (ctrl[2:0] - 1));
        op2= (temp2 >> (ctrl[2:0] - 1));
        op3= (temp3 >> (ctrl[2:0] - 1));
        op4= (temp4 >> (ctrl[2:0] - 1));
        op5= (temp5 >> (ctrl[2:0] - 1));
        op6= (temp6 >> (ctrl[2:0] - 1));
        op7= (temp7 >> (ctrl[2:0] - 1));

        of0 = signExtend(pack(op0)[7:1]);
        of1 = signExtend(pack(op1)[7:1]);
        of2 = signExtend(pack(op2)[7:1]);
        of3 = signExtend(pack(op3)[7:1]);
        of4 = signExtend(pack(op4)[7:1]);
        of5 = signExtend(pack(op5)[7:1]);
        of6 = signExtend(pack(op6)[7:1]);
        of7 = signExtend(pack(op7)[7:1]);

        //opb[7+8*i:0] = pack((temp >> (ctrl[2:0] - 1)));
        temp.op = {of7,of6,of5,of4,of3,of2,of1,of0};
        temp.msb = {pack(op7)[0],pack(op6)[0],pack(op5)[0],pack(op4)[0],pack(op3)[0],pack(op2)[0],pack(op1)[0],pack(op0)[0]};

    end

    else begin 

        temp.op = inp;
        temp.msb = 8'd0;

    end



    return temp;


endfunction


function Shifter r16_arithm( Bit#(64) inp, Bit#(5) ctrl);

    /*Int#(16) op;

    Int#(16)temp = unpack(inp[15:0]);

    op = (temp >> (ctrl[3:0]-1));

    return pack(op);*/

    Shifter temp = unpack(72'b0);


    if(ctrl != 0) begin

        //Bit#(8) msb;
        Int#(16) op0,op1,op2,op3;
        Bit#(16) of0,of1,of2,of3;
        //Bit#(64) opb;

        Int#(16)temp0= unpack(inp[15:0]);
        Int#(16)temp1= unpack(inp[31:16]);
        Int#(16)temp2= unpack(inp[47:32]);
        Int#(16)temp3= unpack(inp[63:48]);

        op0= (temp0 >> (ctrl[3:0] - 1));
        op1= (temp1 >> (ctrl[3:0] - 1));
        op2= (temp2 >> (ctrl[3:0] - 1));
        op3= (temp3 >> (ctrl[3:0] - 1));

        of0 = signExtend(pack(op0)[15:1]);
        of1 = signExtend(pack(op1)[15:1]);
        of2 = signExtend(pack(op2)[15:1]);
        of3 = signExtend(pack(op3)[15:1]);

        temp.op = {of3,of2,of1,of0};
        temp.msb = {1'b0,pack(op3)[0],1'b0,pack(op2)[0],1'b0,pack(op1)[0],1'b0,pack(op0)[0]};
    end

    else begin 

        temp.op = inp;
        temp.msb = 8'd0;

    end

    

    return temp;

endfunction

function Shifter r32_arithm( Bit#(64) inp, Bit#(5) ctrl);

    /*Int#(16) op;

    Int#(16)temp = unpack(inp[15:0]);

    op = (temp >> (ctrl[3:0]-1));

    return pack(op);*/

    Shifter temp = unpack(72'b0);
    
    if(ctrl != 0) begin
        //Bit#(8) msb;
        Int#(32) op0,op1;
        Bit#(32) of0,of1;
        //Bit#(64) opb;

        Int#(32)temp0= unpack(inp[31:0]);
        Int#(32)temp1= unpack(inp[63:32]);

        op0= (temp0 >> (ctrl[4:0] - 1));
        op1= (temp1 >> (ctrl[4:0] - 1));

        of0 = signExtend(pack(op0)[31:1]);
        of1 = signExtend(pack(op1)[31:1]);

        temp.op = {of1,of0};
        temp.msb = {3'b0,pack(op1)[0],3'b0,pack(op0)[0]};
    end

    else begin 

        temp.op = inp;
        temp.msb = 8'd0;

    end

    return temp;

endfunction

function Shifter r8_logic( Bit#(64) inp, Bit#(5) ctrl);

    Shifter temp = unpack(72'b0);

    //Bit#(8) msb;
    if(ctrl != 0) begin

        Bit#(8) op0,op1,op2,op3,op4,op5,op6,op7;
        Bit#(8) of0,of1,of2,of3,of4,of5,of6,of7;
    //Bit#(64) opb;

    
    //for(Integer i = 0; i < 2; i = i + 1) begin

        //Int#(8)temp1= unpack(inp[7+8*i:0+8*i])

        Bit#(8)temp0= (inp[7:0]);
        Bit#(8)temp1= (inp[15:8]);
        Bit#(8)temp2= (inp[23:16]);
        Bit#(8)temp3= (inp[31:24]);
        Bit#(8)temp4= (inp[39:32]);
        Bit#(8)temp5= (inp[47:40]);
        Bit#(8)temp6= (inp[55:48]);
        Bit#(8)temp7= (inp[63:56]);

        op0= (temp0 >> (ctrl[2:0]-1));
        op1= (temp1 >> (ctrl[2:0]-1));
        op2= (temp2 >> (ctrl[2:0]-1));
        op3= (temp3 >> (ctrl[2:0]-1));
        op4= (temp4 >> (ctrl[2:0]-1));
        op5= (temp5 >> (ctrl[2:0]-1));
        op6= (temp6 >> (ctrl[2:0]-1));
        op7= (temp7 >> (ctrl[2:0]-1));

        of0 = zeroExtend((op0)[7:1]);
        of1 = zeroExtend((op1)[7:1]);
        of2 = zeroExtend((op2)[7:1]);
        of3 = zeroExtend((op3)[7:1]);
        of4 = zeroExtend((op4)[7:1]);
        of5 = zeroExtend((op5)[7:1]);
        of6 = zeroExtend((op6)[7:1]);
        of7 = zeroExtend((op7)[7:1]);

        //opb[7+8*i:0] = pack((temp >> (ctrl[2:0] - 1)));
        temp.op = {of7,of6,of5,of4,of3,of2,of1,of0};
        temp.msb = {op7[0],op6[0],op5[0],op4[0],op3[0],op2[0],op1[0],op0[0]};

    end

    else begin 

        temp.op = inp;

    end

    return temp;

endfunction

function Shifter r16_logic( Bit#(64) inp, Bit#(5) ctrl);

    Shifter temp = unpack(72'b0);

    //Bit#(8) msb;
    if(ctrl != 0) begin

        Bit#(16) op0,op1,op2,op3;
        Bit#(16) of0,of1,of2,of3;
    //Bit#(64) opb;

    
    //for(Integer i = 0; i < 2; i = i + 1) begin

        //Int#(8)temp1= unpack(inp[7+8*i:0+8*i])

        Bit#(16)temp0= (inp[15:0]);
        Bit#(16)temp1= (inp[31:16]);
        Bit#(16)temp2= (inp[47:32]);
        Bit#(16)temp3= (inp[63:48]);

        op0= (temp0 >> (ctrl[3:0]-1));
        op1= (temp1 >> (ctrl[3:0]-1));
        op2= (temp2 >> (ctrl[3:0]-1));
        op3= (temp3 >> (ctrl[3:0]-1));

        of0 = zeroExtend((op0)[15:1]);
        of1 = zeroExtend((op1)[15:1]);
        of2 = zeroExtend((op2)[15:1]);
        of3 = zeroExtend((op3)[15:1]);

        //opb[7+8*i:0] = pack((temp >> (ctrl[2:0] - 1)));
        temp.op = {of3,of2,of1,of0};
        temp.msb = {1'b0,op3[0],1'b0,op2[0],1'b0,op1[0],1'b0,op0[0]};

    end

    else begin 

        temp.op = inp;

    end

    return temp;

endfunction

function Shifter r32_logic( Bit#(64) inp, Bit#(5) ctrl);

    Shifter temp = unpack(72'b0);

    //Bit#(8) msb;
    if(ctrl != 0) begin

        Bit#(32) op0,op1;
        Bit#(32) of0,of1;
    //Bit#(64) opb;

    
    //for(Integer i = 0; i < 2; i = i + 1) begin

        //Int#(8)temp1= unpack(inp[7+8*i:0+8*i])

        Bit#(32)temp0= (inp[31:0]);
        Bit#(32)temp1= (inp[63:32]);

        op0= (temp0 >> (ctrl[4:0]-1));
        op1= (temp1 >> (ctrl[4:0]-1));
        of0 = zeroExtend(op0[31:1]);
        of1 = zeroExtend(op1[31:1]);

        //opb[7+8*i:0] = pack((temp >> (ctrl[2:0] - 1)));
        temp.op = {of1,of0};
        temp.msb = {3'b0,op1[0],3'b0,op0[0]};

    end

    else begin 

        temp.op = inp;

    end

    return temp;

endfunction

function Shifter left8( Bit#(64) inp, Bit#(5) ctrl, Bit#(1) sat);

    Shifter temp = unpack(72'b0);

    //Bit#(8) msb;

        Bit#(16) op0,op1,op2,op3,op4,op5,op6,op7;
        //Bit#(8) of0,of1,of2,of3,of4,of5,of6,of7;
        //Bit#(64) opb;

        
        //for(Integer i = 0; i < 2; i = i + 1) begin

            //Int#(8)temp1= unpack(inp[7+8*i:0+8*i])

            Bit#(16) temp0= signExtend(inp[7:0]);
            Bit#(16) temp1= signExtend(inp[15:8]);
            Bit#(16) temp2= signExtend(inp[23:16]);
            Bit#(16) temp3= signExtend(inp[31:24]);
            Bit#(16) temp4= signExtend(inp[39:32]);
            Bit#(16) temp5= signExtend(inp[47:40]);
            Bit#(16) temp6= signExtend(inp[55:48]);
            Bit#(16) temp7= signExtend(inp[63:56]);

            op0= (temp0 << (ctrl[2:0]));
            op1= (temp1 << (ctrl[2:0]));
            op2= (temp2 << (ctrl[2:0]));
            op3= (temp3 << (ctrl[2:0]));
            op4= (temp4 << (ctrl[2:0]));
            op5= (temp5 << (ctrl[2:0]));
            op6= (temp6 << (ctrl[2:0]));
            op7= (temp7 << (ctrl[2:0]));
            
            if(sat == 1) begin
                Bit#(128) ops = {(op7),(op6),(op5),(op4),(op3),(op2),(op1),(op0)};
                for(Integer i = 0; i < 8; i = i + 1) begin
                    Bit#(8) slicedBits = ops[14 + 16*i : 7 + 16*i];
                    Bit#(8) lowerB     = ops[7 + 16*i : 16*i];
                    if(ops[15 + 16*i] == 1) begin
                        if(&slicedBits == 1) 
                            temp.op[7 + 8*i : 8*i] = lowerB;
                        else 
                            temp.op[7 + 8*i : 8*i] = 8'h80;
                    end 
                    else begin
                        if(|slicedBits == 0)
                            temp.op[7 + 8*i : 8*i] = lowerB;
                        else 
                            temp.op[7 + 8*i : 8*i] = 8'h7F;
                    end
                end
            end else 
                temp.op = {op7[7:0],op6[7:0],op5[7:0],op4[7:0],op3[7:0],op2[7:0],op1[7:0],op0[7:0]};

            temp.msb = 8'd0;


    return temp;

endfunction

function Shifter left16( Bit#(64) inp, Bit#(5) ctrl, Bit#(1) sat);

    Shifter temp = unpack(72'b0);

    //Bit#(8) msb;

        Bit#(32) op0,op1,op2,op3;
        //Bit#(8) of0,of1,of2,of3,of4,of5,of6,of7;
        //Bit#(64) opb;

        
        //for(Integer i = 0; i < 2; i = i + 1) begin

            //Int#(8)temp1= unpack(inp[7+8*i:0+8*i])

            Bit#(32) temp0= signExtend(inp[15:0]);
            Bit#(32) temp1= signExtend(inp[31:16]);
            Bit#(32) temp2= signExtend(inp[47:32]);
            Bit#(32) temp3= signExtend(inp[63:48]);

            op0= (temp0 << (ctrl[3:0]));
            op1= (temp1 << (ctrl[3:0]));
            op2= (temp2 << (ctrl[3:0]));
            op3= (temp3 << (ctrl[3:0]));

            if(sat == 1) begin
                Bit#(128) ops = {(op3),(op2),(op1),(op0)};
                for(Integer i = 0; i < 4; i = i + 1) begin
                    Bit#(16) slicedBits = ops[30 + 32*i : 15 + 32*i];
                    Bit#(16) lowerH     = ops[15 + 32*i : 32*i];
                    if(ops[31 + 32*i] == 1) begin
                        if(&slicedBits == 1) 
                            temp.op[15 + 16*i : 16*i] = lowerH;
                        else 
                            temp.op[15 + 16*i : 16*i] = 16'h8000;
                    end 
                    else begin
                        if(|slicedBits == 0)
                            temp.op[15 + 16*i : 16*i] = lowerH;
                        else 
                            temp.op[15 + 16*i : 16*i] = 16'h7FFF;
                    end
                end
            end else 
                temp.op = {op3[15:0],op2[15:0],op1[15:0],op0[15:0]};

            //opb[7+8*i:0] = pack((temp >> (ctrl[2:0] - 1)));
            temp.msb = 8'd0;


    return temp;


endfunction

function Shifter left32( Bit#(64) inp, Bit#(5) ctrl, Bit#(1) sat);

    Shifter temp = unpack(72'b0);

    //Bit#(8) msb;

        Bit#(64) op0,op1;
        //Bit#(8) of0,of1,of2,of3,of4,of5,of6,of7;
        //Bit#(64) opb;

        
        //for(Integer i = 0; i < 2; i = i + 1) begin

            //Int#(8)temp1= unpack(inp[7+8*i:0+8*i])

            Bit#(64) temp0= signExtend(inp[31:0]);
            Bit#(64) temp1= signExtend(inp[63:32]);

            op0= (temp0 << (ctrl[4:0]));
            op1= (temp1 << (ctrl[4:0]));


            if(sat == 1) begin
                Bit#(128) ops = {(op1),(op0)};
                for(Integer i = 0; i < 2; i = i + 1) begin
                    Bit#(32) slicedBits = ops[62 + 64*i : 31 + 64*i];
                    Bit#(32) lowerW     = ops[31 + 64*i : 64*i];
                    if(ops[63 + 64*i] == 1) begin
                        if(&slicedBits == 1) 
                            temp.op[31 + 32*i : 32*i] = lowerW;
                        else 
                            temp.op[31 + 32*i : 32*i] = 32'h80000000;
                    end 
                    else begin
                        if(|slicedBits == 0)
                            temp.op[31 + 32*i : 32*i] = lowerW;
                        else 
                            temp.op[31 + 32*i : 32*i] = 32'h7FFFFFFF;
                    end
                end
            end else
                temp.op = {op1[31:0],op0[31:0]};

            //opb[7+8*i:0] = pack((temp >> (ctrl[2:0] - 1)));
            temp.msb = 8'd0;


    return temp;
endfunction














endpackage