package partialProductGenerator;
export  partialProductGenerator::*;
    import Vector :: *;
    /*function Vector#(32, Bit#(32)) gen (Bit#(32) a, Bit#(32) b, Bit#(3) ctrl);
        Bit#(1) z8  = ~ctrl[0];
        Bit#(1) z16 = ~(ctrl[0]|ctrl[1]);
        Bit#(1) inv8  = ctrl[0] & t;
        Bit#(1) inv16 = (ctrl[0]|ctrl[1])&t;
        Bit#(1) t   = ctrl[2];
        //DEPRECATED
        let b1a   = block1(a[7:0]  , b[7:0]  , t, 1  , inv8  );
        let b1b   = block1(a[15:8] , b[15:8] , t, 1  , inv16 );
        let b1c   = block1(a[23:16], b[23:16], t, 1  , inv8  );
        let b1d   = block1(a[31:24], b[31:24], t, 1  , 1     );
        let b2a   = block2(a[15:8] , b[7:0]  , t, z8 , inv16 );
        let b2b   = block2(a[31:24], b[23:16], t, z8 , 1     );
        let b3a   = block3(a[7:0]  , b[15:8] , t, z8 , inv16 );
        let b3b   = block3(a[23:16], b[31:24], t, z8 , 1     );
        let b216  = block2(a[31:16], b[15:0] , t, z16, 1     );
        let b316  = block3(a[15:0] , b[31:16], t, z16, 1     );
        let b1UR  = append(b1a, b3a);
        let b1UL  = append(b2a, b1b);
        let b1U   = vecMerge(b1UR, b1UL);
        let b1LR  = append(b1c, b3b);
        let b1LL  = append(b2b, b1d);
        let b1L   = vecMerge(b1LR, b1LL);
        //FEED TO REDUCER IMMEDIATELY
        let bR    = append(b1U, b316);
        let bL    = append(b216,b1L );
        let p_out = vecMerge(bR, bL);
        

        return p_out;

    endfunction*/

    function Vector#(n, Bit#(n)) block1(Bit#(n) x, Bit#(n) y, Bit#(1) t, Bit#(1) z_p)
        provisos(Add#(1, unused, n));
        Vector#(n, Bit#(n)) b1_out = newVector();
        Integer k = valueOf(n);
        for(Integer i = 0; i < k; i = i + 1)
            for(Integer j = 0; j < k; j = j + 1)
                if(((i == k - 1)||(j == k - 1)) && (!((i == k -1 )&&(j == k -1)))) b1_out[i][j] = ((x[j]&y[i])^(t))&z_p;
                else b1_out[i][j] = (x[j]&y[i]) & z_p;
        return b1_out;
    endfunction
    function Vector#(n, Bit#(n)) block2(Bit#(n) x, Bit#(n) y, Bit#(1) t, Bit#(1) z_p)
        provisos(Add#(1, unused, n));
        Vector#(n, Bit#(n)) b2_out = newVector();
        Integer k = valueOf(n);
        for(Integer i = 0; i < k; i = i + 1)
            for(Integer j = 0; j < k; j = j + 1)
                if(((j == k - 1)) ) b2_out[i][j] = ((x[j]&y[i])^(t))&z_p;
                else b2_out[i][j] = (x[j]&y[i]) & z_p;
        return b2_out;
    endfunction
    function Vector#(n, Bit#(n)) block3(Bit#(n) x, Bit#(n) y, Bit#(1) t, Bit#(1) z_p)
        provisos(Add#(1, unused, n));
        Vector#(n, Bit#(n)) b3_out = newVector();
        Integer k = valueOf(n);
        for(Integer i = 0; i < k; i = i + 1)
            for(Integer j = 0; j < k; j = j + 1)
                if(((i == k - 1)) ) b3_out[i][j] = ((x[j]&y[i])^(t))&z_p;
                else b3_out[i][j] = (x[j]&y[i]) & z_p;
        return b3_out;
    endfunction
    function Vector#(n, Bit#(TAdd#(m,m))) vecMerge (Vector#(n, Bit#(m)) v1, Vector#(n, Bit#(m)) v2);
        Vector#(n, Bit#(TAdd#(m,m))) vout;
        for(Integer i = 0; i < valueOf(n); i = i + 1)
            vout[i] = {v2[i], v1[i]};
        return vout;
    endfunction
endpackage