/*
    This file contains fast Adders of varying bit widths. To understand the logic used for the creation of the adders, refer:

    1.  S.-K. Chang and C.-L. Wey, “A fast 64-bit hybrid adder design in 90nm cmos process,” 
        in 2012 IEEE 55th International Midwest Symposium on Circuits and Systems (MWSCAS), 2012, pp. 414–417.

    FUNCTIONS: 

    cla16: Simple 16b CLA
    fastSum16       : Hybrid 16b CLA
    fastSum32       : Hybrid 32b CLA
    fastSum64       : Hybrid 64b CLA
    addEverything64 : SWP 64b Adder
    addwMetaData    : SWP 64b Adder, also return MSBS and Carries

    STRUCTS:

    AdderOutput - This struct is used repeatedly
        Bit#(64) outp - Adder output
        Bit#(16) msbs - Byte-wise MSBS of RS2 and RS1 fields 
        Bit#(8)  crrs - Byte-wise carries from the adder
*/

package hybridCLA;
export hybridCLA::*;
import Vector::*;
    typedef struct {
        Bit#(64)  outp;
        Bit#(16)  msbs;
        Bit#(8)   crrs;
    } AdderOutput deriving (Bits, Eq);  

    //Format [5:0] P*, G*, C2, C1, C0
    function Bit#(1) mux2to1(Bit#(1) sel, Bit#(1) a, Bit#(1) b);
        if(sel == 1) return b;
        else         return a;
    endfunction
    //Format [1:0] P*, G*
    function Bit#(2) starCalc(Bit#(4) pin, Bit#(4) gin);
        return {(pin[3]&pin[2]&pin[1]&pin[0]),(gin[3]|(gin[2]&pin[3])|(gin[1]&pin[3]&pin[2])|(gin[0]&pin[3]&pin[2]&pin[1]))};
    endfunction
    function Bit#(4) hau4_zeroCin  (Bit#(4) pin, Bit#(4) gin, Bit#(1) inpCin);
        Vector#(2, Bit#(4)) hashVec = newVector;
        Bit#(4) outp = 0;
        hashVec[1][0] = pin[0];
        hashVec[1][1] = pin[1]&pin[0];
        hashVec[1][2] = pin[2]&pin[1]&pin[0];
        hashVec[1][3] = pin[3]&pin[2]&pin[1]&pin[0];
        hashVec[0][0] = gin[0];
        hashVec[0][1] = (gin[1]|(gin[0]&pin[1]));
        hashVec[0][2] = (gin[2]|(gin[1]&pin[2])|(gin[0]&pin[2]&pin[1]));
        hashVec[0][3] = (gin[3]|(gin[2]&pin[3])|(gin[1]&pin[3]&pin[2])|(gin[0]&pin[3]&pin[2]&pin[1]));
        outp[0] = (~hashVec[1][0])&hashVec[0][0];
        outp[1] = (~hashVec[1][1])&hashVec[0][1];
        outp[2] = (~hashVec[1][2])&hashVec[0][2];
        outp[3] = (~hashVec[1][3])&hashVec[0][3];
        return outp;

    endfunction
    function Bit#(4) hau4_z    (Bit#(4) pin, Bit#(4) gin, Bit#(1) inpCin, Bit#(2) z);
        Vector#(2, Bit#(4)) hashVec = newVector;
        Bit#(4) outp = 0;
        hashVec[1][0] = pin[0];
        hashVec[1][1] = pin[1]&(pin[0]|~z[0]);
        hashVec[1][2] = pin[2]&((pin[1]&pin[0])|~(z[0]&z[1]));
        hashVec[1][3] = pin[3]&((pin[2]&((pin[1]&pin[0])|~z[1]))|~z[0]);
        hashVec[0][0] = gin[0];
        hashVec[0][1] = (gin[1]|((gin[0]&pin[1])&z[0]));
        hashVec[0][2] = (gin[2]|(((gin[1]&pin[2])|(gin[0]&pin[2]&pin[1]))&z[0]&z[1]));
        hashVec[0][3] = (gin[3]|((gin[2]&pin[3])&z[0])|(((gin[1]&pin[3]&pin[2])|(gin[0]&pin[3]&pin[2]&pin[1]))&z[0]&z[1]));
        outp[0] = mux2to1(hashVec[1][0],hashVec[0][0],inpCin);
        outp[1] = mux2to1(hashVec[1][1],hashVec[0][1],inpCin);
        outp[2] = mux2to1(hashVec[1][2],hashVec[0][2],inpCin);
        outp[3] = mux2to1(hashVec[1][3],hashVec[0][3],inpCin);
        return outp;

    endfunction
    function Bit#(3) muxCalc_z(Bit#(3) pin, Bit#(3) gin, Bit#(1) inpCin, Bit#(1) z);
        Bit#(3) outp = 0;
        outp[0] = mux2to1(pin[0],gin[0],inpCin);
        outp[1] = mux2to1(pin[1],gin[1],inpCin&z);
        outp[2] = mux2to1(pin[2],gin[2],inpCin);
        return outp;
    endfunction

    function Vector#(2, Bit#(4)) hashCalc_z(Bit#(4) pin, Bit#(4) gin, Bit#(1) z);
        Vector#(2, Bit#(4)) outp = newVector;
        outp[1][0] = pin[0];
        outp[1][1] = pin[1]&pin[0];
        outp[1][2] = pin[2]&((pin[1]&pin[0])|~z);
        outp[1][3] = pin[3]&pin[2]&((pin[1]&pin[0])|~z);
        outp[0][0] = gin[0];
        outp[0][1] = (gin[1]|(gin[0]&pin[1]));
        outp[0][2] = (gin[2]|(((gin[1]&pin[2])|(gin[0]&pin[2]&pin[1]))&z));
        outp[0][3] = (gin[3]|(gin[2]&pin[3])|(((gin[1]&pin[3]&pin[2])|(gin[0]&pin[3]&pin[2]&pin[1]))&z));
        return outp;
    endfunction

    function Bit#(3) bcla4(Bit#(4) pin, Bit#(4) gin, Bit#(1) cin);
        Bit#(3) outp = 0;
        outp[0] = (gin[0]|(pin[0]&cin)); 
        outp[1] = (gin[1]|(gin[0]&pin[1])|(pin[1]&pin[0]&cin));
        outp[2] = (gin[2]|(gin[1]&pin[2])|(gin[0]&pin[2]&pin[1])|(pin[2]&pin[1]&pin[0]&cin));
        return outp;
    endfunction

    function Bit#(4)  cla4(Bit#(4) pin, Bit#(4) gin, Bit#(1) cin);
        Bit#(4) outp = 0;
        outp[0] = (gin[0]|(pin[0]&cin)); 
        outp[1] = (gin[1]|(gin[0]&pin[1])|(pin[1]&pin[0]&cin));
        outp[2] = (gin[2]|(gin[1]&pin[2])|(gin[0]&pin[2]&pin[1])|(pin[2]&pin[1]&pin[0]&cin));
        outp[3] = (gin[3]|(gin[2]&pin[3])|(gin[1]&pin[3]&pin[2])|(gin[0]&pin[3]&pin[2]&pin[1])|(pin[3]&pin[2]&pin[1]&pin[0]&cin));
        return outp;
    endfunction
    function Bit#(4) hau4    (Bit#(4) pin, Bit#(4) gin, Bit#(1) inpCin);
        Vector#(2, Bit#(4)) hashVec = newVector;
        Bit#(4) outp = 0;
        hashVec[1][0] = pin[0];
        hashVec[1][1] = pin[1]&pin[0];
        hashVec[1][2] = pin[2]&pin[1]&pin[0];
        hashVec[1][3] = pin[3]&pin[2]&pin[1]&pin[0];
        hashVec[0][0] = gin[0];
        hashVec[0][1] = (gin[1]|(gin[0]&pin[1]));
        hashVec[0][2] = (gin[2]|(gin[1]&pin[2])|(gin[0]&pin[2]&pin[1]));
        hashVec[0][3] = (gin[3]|(gin[2]&pin[3])|(gin[1]&pin[3]&pin[2])|(gin[0]&pin[3]&pin[2]&pin[1]));
        outp[0] = mux2to1(hashVec[1][0],hashVec[0][0],inpCin);
        outp[1] = mux2to1(hashVec[1][1],hashVec[0][1],inpCin);
        outp[2] = mux2to1(hashVec[1][2],hashVec[0][2],inpCin);
        outp[3] = mux2to1(hashVec[1][3],hashVec[0][3],inpCin);
        return outp;

    endfunction
    function Bit#(3) muxCalc(Bit#(3) pin, Bit#(3) gin, Bit#(1) inpCin);
        Bit#(3) outp = 0;
        outp[0] = mux2to1(pin[0],gin[0],inpCin);
        outp[1] = mux2to1(pin[1],gin[1],inpCin);
        outp[2] = mux2to1(pin[2],gin[2],inpCin);
        return outp;
    endfunction

    function Vector#(2, Bit#(4)) hashCalc(Bit#(4) pin, Bit#(4) gin);
        Vector#(2, Bit#(4)) outp = newVector;
        outp[1][0] = pin[0];
        outp[1][1] = pin[1]&pin[0];
        outp[1][2] = pin[2]&pin[1]&pin[0];
        outp[1][3] = pin[3]&pin[2]&pin[1]&pin[0];
        outp[0][0] = gin[0];
        outp[0][1] = (gin[1]|(gin[0]&pin[1]));
        outp[0][2] = (gin[2]|(gin[1]&pin[2])|(gin[0]&pin[2]&pin[1]));
        outp[0][3] = (gin[3]|(gin[2]&pin[3])|(gin[1]&pin[3]&pin[2])|(gin[0]&pin[3]&pin[2]&pin[1]));
        return outp;
    endfunction

    function Bit#(17) cla16 (Bit#(16) inpA, Bit#(16) inpB, Bit#(1)inpCin);

        Bit#(16) p    = 0; Bit#(16) g     = 0;
        Bit#(16) s     = 0;
        Bit#(4)  cVec = 0;
        Vector#(4, Bit#(2)) starVec = newVector;
        //PG Calculations
        p = inpA^inpB;
        g = inpA&inpB;
        starVec[0] = starCalc(p[3:0], g[3:0]);
        starVec[1] = starCalc(p[7:4], g[7:4]);
        starVec[2] = starCalc(p[11:8], g[11:8]);
        starVec[3] = starCalc(p[15:12], g[15:12]);
        cVec       = cla4({starVec[3][1],starVec[2][1],starVec[1][1],starVec[0][1]},{starVec[3][0],starVec[2][0],starVec[1][0],starVec[0][0]},inpCin);
        Bit#(3) o1 = bcla4(p[3:0]  , g[3:0]  , inpCin);
        Bit#(3) o2 = bcla4(p[7:4]  , g[7:4]  , cVec[0]);
        Bit#(3) o3 = bcla4(p[11:8] , g[11:8] , cVec[1]);
        Bit#(3) o4 = bcla4(p[15:12], g[15:12], cVec[2]);
        s[0]  =  p[0]^inpCin;
        s[1]  =  p[1]^o1[0];
        s[2]  =  p[2]^o1[1];
        s[3]  =  p[3]^o1[2];
        s[4]  =  p[4]^cVec[0];
        s[5]  =  p[5]^o2[0];
        s[6]  =  p[6]^o2[1];
        s[7]  =  p[7]^o2[2];
        s[8]  =  p[8]^cVec[1];
        s[9]  =  p[9]^o3[0];        
        s[10] = p[10]^o3[1];
        s[11] = p[11]^o3[2];
        s[12] = p[12]^cVec[2];
        s[13] = p[13]^o4[0];
        s[14] = p[14]^o4[1];
        s[15] = p[15]^o4[2];
        return {cVec[3], s};

    endfunction

    function Bit#(17) fastSum16 (Bit#(16) inpA, Bit#(16) inpB, Bit#(1)inpCin);
        //0 - 2, 4 - 6, 8 - 10, 12 - 14
        Bit#(12) pHash = 0; Bit#(12) gHash = 0;
        Bit#(4 ) pStar = 0; Bit#(4 ) gStar = 0;
        Bit#(16) p    = 0; Bit#(16) g     = 0;
        Bit#(16) s     = 0;
        Bit#(4)  cVec = 0;
        p = inpA^inpB;
        g = inpA&inpB;
        Vector#(2, Bit#(4)) hashVec1 = hashCalc(p[3:0]  , g[3:0]  );
        Vector#(2, Bit#(4)) hashVec2 = hashCalc(p[7:4]  , g[7:4]  );
        Vector#(2, Bit#(4)) hashVec3 = hashCalc(p[11:8] , g[11:8] );
        Vector#(2, Bit#(4)) hashVec4 = hashCalc(p[15:12], g[15:12]);
        pHash = {hashVec4[1][2:0],hashVec3[1][2:0],hashVec2[1][2:0],hashVec1[1][2:0]};
        gHash = {hashVec4[0][2:0],hashVec3[0][2:0],hashVec2[0][2:0],hashVec1[0][2:0]};
        pStar = {hashVec4[1][3],hashVec3[1][3],hashVec2[1][3],hashVec1[1][3]};
        gStar = {hashVec4[0][3],hashVec3[0][3],hashVec2[0][3],hashVec1[0][3]};
        cVec  = hau4(pStar, gStar, inpCin);
        Bit#(3) c1 = muxCalc(pHash[2:0] ,gHash[2:0] ,inpCin);
        Bit#(3) c2 = muxCalc(pHash[5:3] ,gHash[5:3] ,cVec[0]);
        Bit#(3) c3 = muxCalc(pHash[8:6] ,gHash[8:6] ,cVec[1]);
        Bit#(3) c4 = muxCalc(pHash[11:9],gHash[11:9],cVec[2]);
        s[0]  =  p[0]^inpCin;
        s[1]  =  p[1]^c1[0];
        s[2]  =  p[2]^c1[1];
        s[3]  =  p[3]^c1[2];
        s[4]  =  p[4]^cVec[0];
        s[5]  =  p[5]^c2[0];
        s[6]  =  p[6]^c2[1];
        s[7]  =  p[7]^c2[2];
        s[8]  =  p[8]^cVec[1];
        s[9]  =  p[9]^c3[0];        
        s[10] = p[10]^c3[1];
        s[11] = p[11]^c3[2];
        s[12] = p[12]^cVec[2];
        s[13] = p[13]^c4[0];
        s[14] = p[14]^c4[1];
        s[15] = p[15]^c4[2];
        return {cVec[3], s};
    endfunction

    function Bit#(33) fastSum32 (Bit#(32) inpA, Bit#(32) inpB, Bit#(1) inpCin);

        Bit#(24) pHash = 0; Bit#(24) gHash = 0;
        Bit#(8 ) pStar = 0; Bit#(8 ) gStar = 0;
        Bit#(32) p    = 0; Bit#(32) g     = 0;
        Bit#(16) p1    = 0; Bit#(16) g1     = 0;
        Bit#(16) p2    = 0; Bit#(16) g2     = 0;
        Bit#(32) s     = 0;
        Bit#(8)  cVec = 0;
        p = inpA^inpB;
        g = inpA&inpB;
        p1 = p[15:0]; g1 = g[15:0];
        p2 = p[31:16]; g2 = g[31:16];
        Vector#(2, Bit#(4)) hashVec1 = hashCalc(p1[3:0]  , g1[3:0]  );
        Vector#(2, Bit#(4)) hashVec2 = hashCalc(p1[7:4]  , g1[7:4]  );
        Vector#(2, Bit#(4)) hashVec3 = hashCalc(p1[11:8] , g1[11:8] );
        Vector#(2, Bit#(4)) hashVec4 = hashCalc(p1[15:12], g1[15:12]);
        Vector#(2, Bit#(4)) hashVec5 = hashCalc(p2[3:0]  , g2[3:0]  );
        Vector#(2, Bit#(4)) hashVec6 = hashCalc(p2[7:4]  , g2[7:4]  );
        Vector#(2, Bit#(4)) hashVec7 = hashCalc(p2[11:8] , g2[11:8] );
        Vector#(2, Bit#(4)) hashVec8 = hashCalc(p2[15:12], g2[15:12]);
        pHash[11:0]  = {hashVec4[1][2:0],hashVec3[1][2:0],hashVec2[1][2:0],hashVec1[1][2:0]};
        gHash[11:0]  = {hashVec4[0][2:0],hashVec3[0][2:0],hashVec2[0][2:0],hashVec1[0][2:0]};
        pHash[23:12] = {hashVec8[1][2:0],hashVec7[1][2:0],hashVec6[1][2:0],hashVec5[1][2:0]};
        gHash[23:12] = {hashVec8[0][2:0],hashVec7[0][2:0],hashVec6[0][2:0],hashVec5[0][2:0]};
        pStar[3:0] = {hashVec4[1][3],hashVec3[1][3],hashVec2[1][3],hashVec1[1][3]};
        gStar[3:0] = {hashVec4[0][3],hashVec3[0][3],hashVec2[0][3],hashVec1[0][3]};
        pStar[7:4] = {hashVec8[1][3],hashVec7[1][3],hashVec6[1][3],hashVec5[1][3]};
        gStar[7:4] = {hashVec8[0][3],hashVec7[0][3],hashVec6[0][3],hashVec5[0][3]};
        cVec[3:0]  = hau4(pStar[3:0], gStar[3:0], inpCin);
        Bit#(3) c1 = muxCalc(pHash[2:0] ,gHash[2:0] ,inpCin);
        Bit#(3) c2 = muxCalc(pHash[5:3] ,gHash[5:3] ,cVec[0]);
        Bit#(3) c3 = muxCalc(pHash[8:6] ,gHash[8:6] ,cVec[1]);
        Bit#(3) c4 = muxCalc(pHash[11:9],gHash[11:9],cVec[2]);
        cVec[7:4]  = hau4(pStar[7:4], gStar[7:4], cVec[3]);
        Bit#(3) c5 = muxCalc(pHash[14:12] ,gHash[14:12] ,cVec[3]);
        Bit#(3) c6 = muxCalc(pHash[17:15] ,gHash[17:15] ,cVec[4]);
        Bit#(3) c7 = muxCalc(pHash[20:18] ,gHash[20:18] ,cVec[5]);
        Bit#(3) c8 = muxCalc(pHash[23:21] ,gHash[23:21] ,cVec[6]);
        s[0]  =  p[0]^inpCin;
        s[1]  =  p[1]^c1[0];
        s[2]  =  p[2]^c1[1];
        s[3]  =  p[3]^c1[2];
        s[4]  =  p[4]^cVec[0];
        s[5]  =  p[5]^c2[0];
        s[6]  =  p[6]^c2[1];
        s[7]  =  p[7]^c2[2];
        s[8]  =  p[8]^cVec[1];
        s[9]  =  p[9]^c3[0];        
        s[10] = p[10]^c3[1];
        s[11] = p[11]^c3[2];
        s[12] = p[12]^cVec[2];
        s[13] = p[13]^c4[0];
        s[14] = p[14]^c4[1];
        s[15] = p[15]^c4[2];
        s[16] = p[16]^cVec[3];
        s[17] = p[17]^c5[0];
        s[18] = p[18]^c5[1];
        s[19] = p[19]^c5[2];
        s[20] = p[20]^cVec[4];
        s[21] = p[21]^c6[0];
        s[22] = p[22]^c6[1];
        s[23] = p[23]^c6[2];
        s[24] = p[24]^cVec[5];
        s[25] = p[25]^c7[0];        
        s[26] = p[26]^c7[1];
        s[27] = p[27]^c7[2];
        s[28] = p[28]^cVec[6];
        s[29] = p[29]^c8[0];
        s[30] = p[30]^c8[1];
        s[31] = p[31]^c8[2];
        return {cVec[7], s};
    endfunction

    function Bit#(65) fastSum64 (Bit#(64) inpA, Bit#(64) inpB, Bit#(1) inpCin);
        Bit#(48) pHash  = 0; Bit#(48) gHash   = 0;
        Bit#(12) pSHash = 0; Bit#(12) gSHash  = 0;
        Bit#(16) pStar  = 0; Bit#(16) gStar   = 0;
        Bit#(4)  pSS    = 0; Bit#(4)  gSS     = 0;
        Bit#(64) p      = 0; Bit#(64) g       = 0;
        Bit#(16) p1     = 0; Bit#(16) g1      = 0;
        Bit#(16) p2     = 0; Bit#(16) g2      = 0;
        Bit#(16) p3     = 0; Bit#(16) g3      = 0;
        Bit#(16) p4     = 0; Bit#(16) g4      = 0;
        Bit#(64) s      = 0;
        Bit#(4 ) cVecL1   = 0;
        Bit#(12) cVecL2   = 0;
        p  = inpA^inpB;
        g  = inpA&inpB;
        p1 = p[15: 0]; g1 = g[15: 0];
        p2 = p[31:16]; g2 = g[31:16];
        p3 = p[47:32]; g3 = g[47:32];
        p4 = p[63:48]; g4 = g[63:48];
        Vector#(2, Bit#(4)) hashVec1  = hashCalc(p1[3:0]  , g1[3:0]  );
        Vector#(2, Bit#(4)) hashVec2  = hashCalc(p1[7:4]  , g1[7:4]  );
        Vector#(2, Bit#(4)) hashVec3  = hashCalc(p1[11:8] , g1[11:8] );
        Vector#(2, Bit#(4)) hashVec4  = hashCalc(p1[15:12], g1[15:12]);
        Vector#(2, Bit#(4)) hashVec5  = hashCalc(p2[3:0]  , g2[3:0]  );
        Vector#(2, Bit#(4)) hashVec6  = hashCalc(p2[7:4]  , g2[7:4]  );
        Vector#(2, Bit#(4)) hashVec7  = hashCalc(p2[11:8] , g2[11:8] );
        Vector#(2, Bit#(4)) hashVec8  = hashCalc(p2[15:12], g2[15:12]);
        Vector#(2, Bit#(4)) hashVec9  = hashCalc(p3[3:0]  , g3[3:0]  );
        Vector#(2, Bit#(4)) hashVec10 = hashCalc(p3[7:4]  , g3[7:4]  );
        Vector#(2, Bit#(4)) hashVec11 = hashCalc(p3[11:8] , g3[11:8] );
        Vector#(2, Bit#(4)) hashVec12 = hashCalc(p3[15:12], g3[15:12]);
        Vector#(2, Bit#(4)) hashVec13 = hashCalc(p4[3:0]  , g4[3:0]  );
        Vector#(2, Bit#(4)) hashVec14 = hashCalc(p4[7:4]  , g4[7:4]  );
        Vector#(2, Bit#(4)) hashVec15 = hashCalc(p4[11:8] , g4[11:8] );
        Vector#(2, Bit#(4)) hashVec16 = hashCalc(p4[15:12], g4[15:12]);

        pHash[11:0]  = {hashVec4[1][2:0],hashVec3[1][2:0],hashVec2[1][2:0],hashVec1[1][2:0]};
        gHash[11:0]  = {hashVec4[0][2:0],hashVec3[0][2:0],hashVec2[0][2:0],hashVec1[0][2:0]};
        pHash[23:12] = {hashVec8[1][2:0],hashVec7[1][2:0],hashVec6[1][2:0],hashVec5[1][2:0]};
        gHash[23:12] = {hashVec8[0][2:0],hashVec7[0][2:0],hashVec6[0][2:0],hashVec5[0][2:0]};
        pHash[35:24]  = {hashVec12[1][2:0],hashVec11[1][2:0],hashVec10[1][2:0],hashVec9[1][2:0]};
        gHash[35:24]  = {hashVec12[0][2:0],hashVec11[0][2:0],hashVec10[0][2:0],hashVec9[0][2:0]};
        pHash[47:36] = {hashVec16[1][2:0],hashVec15[1][2:0],hashVec14[1][2:0],hashVec13[1][2:0]};
        gHash[47:36] = {hashVec16[0][2:0],hashVec15[0][2:0],hashVec14[0][2:0],hashVec13[0][2:0]};


        pStar[3:0]   = {hashVec4[1][3],hashVec3[1][3],hashVec2[1][3],hashVec1[1][3]};
        gStar[3:0]   = {hashVec4[0][3],hashVec3[0][3],hashVec2[0][3],hashVec1[0][3]};
        pStar[7:4]   = {hashVec8[1][3],hashVec7[1][3],hashVec6[1][3],hashVec5[1][3]};
        gStar[7:4]   = {hashVec8[0][3],hashVec7[0][3],hashVec6[0][3],hashVec5[0][3]};
        pStar[11:8]  = {hashVec12[1][3],hashVec11[1][3],hashVec10[1][3],hashVec9[1][3]};
        gStar[11:8]  = {hashVec12[0][3],hashVec11[0][3],hashVec10[0][3],hashVec9[0][3]};
        pStar[15:12] = {hashVec16[1][3],hashVec15[1][3],hashVec14[1][3],hashVec13[1][3]};
        gStar[15:12] = {hashVec16[0][3],hashVec15[0][3],hashVec14[0][3],hashVec13[0][3]};

        Vector#(2, Bit#(4)) starHashVec1  = hashCalc(pStar[3:0]  , gStar[3:0]  );
        Vector#(2, Bit#(4)) starHashVec2  = hashCalc(pStar[7:4]  , gStar[7:4]  );
        Vector#(2, Bit#(4)) starHashVec3  = hashCalc(pStar[11:8] , gStar[11:8] );
        Vector#(2, Bit#(4)) starHashVec4  = hashCalc(pStar[15:12], gStar[15:12]);

        pSS  = {starHashVec4[1][3], starHashVec3[1][3], starHashVec2[1][3], starHashVec1[1][3]};
        gSS  = {starHashVec4[0][3], starHashVec3[0][3], starHashVec2[0][3], starHashVec1[0][3]};

        pSHash  = {starHashVec4[1][2:0],starHashVec3[1][2:0],starHashVec2[1][2:0],starHashVec1[1][2:0]};
        gSHash  = {starHashVec4[0][2:0],starHashVec3[0][2:0],starHashVec2[0][2:0],starHashVec1[0][2:0]};
        //FOR MULTIPLIER ONLY
        cVecL1 = hau4(pSS, gSS, inpCin);

        cVecL2[2:0]  = muxCalc(pSHash[2:0]  , gSHash[2:0]  , inpCin   );
        cVecL2[5:3]  = muxCalc(pSHash[5:3]  , gSHash[5:3]  , cVecL1[0]);
        cVecL2[8:6]  = muxCalc(pSHash[8:6]  , gSHash[8:6]  , cVecL1[1]);
        cVecL2[11:9] = muxCalc(pSHash[11:9] , gSHash[11:9] , cVecL1[2]);

        Bit#(3) c1   = muxCalc(pHash[2:0]   , gHash[2:0]   , inpCin   );
        Bit#(3) c2   = muxCalc(pHash[5:3]   , gHash[5:3]   , cVecL2[0]);
        Bit#(3) c3   = muxCalc(pHash[8:6]   , gHash[8:6]   , cVecL2[1]);
        Bit#(3) c4   = muxCalc(pHash[11:9]  , gHash[11:9]  , cVecL2[2]);
        Bit#(3) c5   = muxCalc(pHash[14:12] , gHash[14:12] , cVecL1[0]);
        Bit#(3) c6   = muxCalc(pHash[17:15] , gHash[17:15] , cVecL2[3]);
        Bit#(3) c7   = muxCalc(pHash[20:18] , gHash[20:18] , cVecL2[4]);
        Bit#(3) c8   = muxCalc(pHash[23:21] , gHash[23:21] , cVecL2[5]);
        Bit#(3) c9   = muxCalc(pHash[26:24] , gHash[26:24] , cVecL1[1]);
        Bit#(3) c10  = muxCalc(pHash[29:27] , gHash[29:27] , cVecL2[6]);
        Bit#(3) c11  = muxCalc(pHash[32:30] , gHash[32:30] , cVecL2[7]);
        Bit#(3) c12  = muxCalc(pHash[35:33] , gHash[35:33] , cVecL2[8]);
        Bit#(3) c13  = muxCalc(pHash[38:36] , gHash[38:36] , cVecL1[2] );
        Bit#(3) c14  = muxCalc(pHash[41:39] , gHash[41:39] , cVecL2[9] );
        Bit#(3) c15  = muxCalc(pHash[44:42] , gHash[44:42] , cVecL2[10]);
        Bit#(3) c16  = muxCalc(pHash[47:45] , gHash[47:45] , cVecL2[11]);

        s[0]  =  p[0]^inpCin;
        s[1]  =  p[1]^c1[0];
        s[2]  =  p[2]^c1[1];
        s[3]  =  p[3]^c1[2];
        s[4]  =  p[4]^cVecL2[0];
        s[5]  =  p[5]^c2[0];
        s[6]  =  p[6]^c2[1];
        s[7]  =  p[7]^c2[2];
        s[8]  =  p[8]^cVecL2[1];
        s[9]  =  p[9]^c3[0];        
        s[10] = p[10]^c3[1];
        s[11] = p[11]^c3[2];
        s[12] = p[12]^cVecL2[2];
        s[13] = p[13]^c4[0];
        s[14] = p[14]^c4[1];
        s[15] = p[15]^c4[2];
        s[16] = p[16]^cVecL1[0];
        s[17] = p[17]^c5[0];
        s[18] = p[18]^c5[1];
        s[19] = p[19]^c5[2];
        s[20] = p[20]^cVecL2[3];
        s[21] = p[21]^c6[0];
        s[22] = p[22]^c6[1];
        s[23] = p[23]^c6[2];
        s[24] = p[24]^cVecL2[4];
        s[25] = p[25]^c7[0];        
        s[26] = p[26]^c7[1];
        s[27] = p[27]^c7[2];
        s[28] = p[28]^cVecL2[5];
        s[29] = p[29]^c8[0];
        s[30] = p[30]^c8[1];
        s[31] = p[31]^c8[2];
        s[32] = p[32]^cVecL1[1];
        s[33] = p[33]^c9[0];
        s[34] = p[34]^c9[1];
        s[35] = p[35]^c9[2];
        s[36] = p[36]^cVecL2[6];
        s[37] = p[37]^c10[0];
        s[38] = p[38]^c10[1];
        s[39] = p[39]^c10[2];
        s[40] = p[40]^cVecL2[7];
        s[41] = p[41]^c11[0];        
        s[42] = p[42]^c11[1];
        s[43] = p[43]^c11[2];
        s[44] = p[44]^cVecL2[8];
        s[45] = p[45]^c12[0];
        s[46] = p[46]^c12[1];
        s[47] = p[47]^c12[2];
        s[48] = p[48]^cVecL1[2];
        s[49] = p[49]^c13[0];
        s[50] = p[50]^c13[1];
        s[51] = p[51]^c13[2];
        s[52] = p[52]^cVecL2[9];
        s[53] = p[53]^c14[0];
        s[54] = p[54]^c14[1];
        s[55] = p[55]^c14[2];
        s[56] = p[56]^cVecL2[10];
        s[57] = p[57]^c15[0];        
        s[58] = p[58]^c15[1];
        s[59] = p[59]^c15[2];
        s[60] = p[60]^cVecL2[11];
        s[61] = p[61]^c16[0];
        s[62] = p[62]^c16[1];
        s[63] = p[63]^c16[2];
        return {cVecL1[3], s};
    endfunction
    /* CTRL SIGNAL FORMAT:
        CTRL[2]    : UNMAPPED
        CTRL[1:0]  : 00 - 8 x  8
                     01 - 4 x 16
                     10 - 2 x 32
                     11 - 1 x 64
    */
    function Bit#(65) addEverything64 (Bit#(64) inpA, Bit#(64) inpB, Bit#(1) inpCin, Bit#(2) ctrl);
        Bit#(1) cin = inpCin & ctrl[1] & ctrl[0];
        Bit#(1) z16 = ctrl[1];
        Bit#(1) z8  = (ctrl[1] | ctrl[0]);
        Bit#(1) z32 = ctrl[1]&ctrl[0];
        Bit#(48) pHash  = 0; Bit#(48) gHash   = 0;
        Bit#(12) pSHash = 0; Bit#(12) gSHash  = 0;
        Bit#(16) pStar  = 0; Bit#(16) gStar   = 0;
        Bit#(4)  pSS    = 0; Bit#(4)  gSS     = 0;
        Bit#(64) p      = 0; Bit#(64) g       = 0;
        Bit#(16) p1     = 0; Bit#(16) g1      = 0;
        Bit#(16) p2     = 0; Bit#(16) g2      = 0;
        Bit#(16) p3     = 0; Bit#(16) g3      = 0;
        Bit#(16) p4     = 0; Bit#(16) g4      = 0;
        Bit#(64) s      = 0;
        Bit#(12) cVecL2out = 0;

        p  = inpA^inpB;
        g  = inpA&inpB;
        p1 = p[15: 0]; g1 = g[15: 0];
        p2 = p[31:16]; g2 = g[31:16];
        p3 = p[47:32]; g3 = g[47:32];
        p4 = p[63:48]; g4 = g[63:48];
        Vector#(2, Bit#(4)) hashVec1  = hashCalc_z(p1[3:0]  , g1[3:0]  , 1);
        Vector#(2, Bit#(4)) hashVec2  = hashCalc_z(p1[7:4]  , g1[7:4]  , 1);
        Vector#(2, Bit#(4)) hashVec3  = hashCalc_z(p1[11:8] , g1[11:8] , 1);
        Vector#(2, Bit#(4)) hashVec4  = hashCalc_z(p1[15:12], g1[15:12], 1);
        Vector#(2, Bit#(4)) hashVec5  = hashCalc_z(p2[3:0]  , g2[3:0]  , 1);
        Vector#(2, Bit#(4)) hashVec6  = hashCalc_z(p2[7:4]  , g2[7:4]  , 1);
        Vector#(2, Bit#(4)) hashVec7  = hashCalc_z(p2[11:8] , g2[11:8] , 1);
        Vector#(2, Bit#(4)) hashVec8  = hashCalc_z(p2[15:12], g2[15:12], 1);
        Vector#(2, Bit#(4)) hashVec9  = hashCalc_z(p3[3:0]  , g3[3:0]  , 1);
        Vector#(2, Bit#(4)) hashVec10 = hashCalc_z(p3[7:4]  , g3[7:4]  , 1);
        Vector#(2, Bit#(4)) hashVec11 = hashCalc_z(p3[11:8] , g3[11:8] , 1);
        Vector#(2, Bit#(4)) hashVec12 = hashCalc_z(p3[15:12], g3[15:12], 1);
        Vector#(2, Bit#(4)) hashVec13 = hashCalc_z(p4[3:0]  , g4[3:0]  , 1);
        Vector#(2, Bit#(4)) hashVec14 = hashCalc_z(p4[7:4]  , g4[7:4]  , 1);
        Vector#(2, Bit#(4)) hashVec15 = hashCalc_z(p4[11:8] , g4[11:8] , 1);
        Vector#(2, Bit#(4)) hashVec16 = hashCalc_z(p4[15:12], g4[15:12], 1);

        pHash[11:0]  = {hashVec4[1][2:0],hashVec3[1][2:0],hashVec2[1][2:0],hashVec1[1][2:0]};
        gHash[11:0]  = {hashVec4[0][2:0],hashVec3[0][2:0],hashVec2[0][2:0],hashVec1[0][2:0]};
        pHash[23:12] = {hashVec8[1][2:0],hashVec7[1][2:0],hashVec6[1][2:0],hashVec5[1][2:0]};
        gHash[23:12] = {hashVec8[0][2:0],hashVec7[0][2:0],hashVec6[0][2:0],hashVec5[0][2:0]};
        pHash[35:24]  = {hashVec12[1][2:0],hashVec11[1][2:0],hashVec10[1][2:0],hashVec9[1][2:0]};
        gHash[35:24]  = {hashVec12[0][2:0],hashVec11[0][2:0],hashVec10[0][2:0],hashVec9[0][2:0]};
        pHash[47:36] = {hashVec16[1][2:0],hashVec15[1][2:0],hashVec14[1][2:0],hashVec13[1][2:0]};
        gHash[47:36] = {hashVec16[0][2:0],hashVec15[0][2:0],hashVec14[0][2:0],hashVec13[0][2:0]};


        pStar[3:0]   = {hashVec4[1][3],hashVec3[1][3],hashVec2[1][3],hashVec1[1][3]};
        gStar[3:0]   = {hashVec4[0][3],hashVec3[0][3],hashVec2[0][3],hashVec1[0][3]};
        pStar[7:4]   = {hashVec8[1][3],hashVec7[1][3],hashVec6[1][3],hashVec5[1][3]};
        gStar[7:4]   = {hashVec8[0][3],hashVec7[0][3],hashVec6[0][3],hashVec5[0][3]};
        pStar[11:8]  = {hashVec12[1][3],hashVec11[1][3],hashVec10[1][3],hashVec9[1][3]};
        gStar[11:8]  = {hashVec12[0][3],hashVec11[0][3],hashVec10[0][3],hashVec9[0][3]};
        pStar[15:12] = {hashVec16[1][3],hashVec15[1][3],hashVec14[1][3],hashVec13[1][3]};
        gStar[15:12] = {hashVec16[0][3],hashVec15[0][3],hashVec14[0][3],hashVec13[0][3]};

        Vector#(2, Bit#(4)) starHashVec1  = hashCalc_z(pStar[3:0]  , gStar[3:0]  , z8);
        Vector#(2, Bit#(4)) starHashVec2  = hashCalc_z(pStar[7:4]  , gStar[7:4]  , z8);
        Vector#(2, Bit#(4)) starHashVec3  = hashCalc_z(pStar[11:8] , gStar[11:8] , z8);
        Vector#(2, Bit#(4)) starHashVec4  = hashCalc_z(pStar[15:12], gStar[15:12], z8);

        pSS  = {starHashVec4[1][3], starHashVec3[1][3], starHashVec2[1][3], starHashVec1[1][3]};
        gSS  = {starHashVec4[0][3], starHashVec3[0][3], starHashVec2[0][3], starHashVec1[0][3]};

        pSHash  = {starHashVec4[1][2:0],starHashVec3[1][2:0],starHashVec2[1][2:0],starHashVec1[1][2:0]};
        gSHash  = {starHashVec4[0][2:0],starHashVec3[0][2:0],starHashVec2[0][2:0],starHashVec1[0][2:0]};

        Bit#(4) cVecL1out = hau4_z(pSS, gSS, inpCin, {z32,z16});
        Bit#(4) cVecL1    = cVecL1out&{1,z16,z32,z16};
    

        cVecL2out[2:0]  = muxCalc_z(pSHash[2:0]  , gSHash[2:0]  , cin      , z8);
        cVecL2out[5:3]  = muxCalc_z(pSHash[5:3]  , gSHash[5:3]  , cVecL1[0], z8);
        cVecL2out[8:6]  = muxCalc_z(pSHash[8:6]  , gSHash[8:6]  , cVecL1[1], z8);
        cVecL2out[11:9] = muxCalc_z(pSHash[11:9] , gSHash[11:9] , cVecL1[2], z8);
        Bit#(12) cVecL2 = cVecL2out;
        for(Integer i = 0; i < 4; i = i + 1)
            cVecL2[3*i + 1] = cVecL2[3*i+1]&z8;

        Bit#(3) c1   = muxCalc_z(pHash[2:0]   , gHash[2:0]   , cin      , 1);
        Bit#(3) c2   = muxCalc_z(pHash[5:3]   , gHash[5:3]   , cVecL2[0], 1);
        Bit#(3) c3   = muxCalc_z(pHash[8:6]   , gHash[8:6]   , cVecL2[1], 1);
        Bit#(3) c4   = muxCalc_z(pHash[11:9]  , gHash[11:9]  , cVecL2[2], 1);
        Bit#(3) c5   = muxCalc_z(pHash[14:12] , gHash[14:12] , cVecL1[0], 1);
        Bit#(3) c6   = muxCalc_z(pHash[17:15] , gHash[17:15] , cVecL2[3], 1);
        Bit#(3) c7   = muxCalc_z(pHash[20:18] , gHash[20:18] , cVecL2[4], 1);
        Bit#(3) c8   = muxCalc_z(pHash[23:21] , gHash[23:21] , cVecL2[5], 1);
        Bit#(3) c9   = muxCalc_z(pHash[26:24] , gHash[26:24] , cVecL1[1], 1);
        Bit#(3) c10  = muxCalc_z(pHash[29:27] , gHash[29:27] , cVecL2[6], 1);
        Bit#(3) c11  = muxCalc_z(pHash[32:30] , gHash[32:30] , cVecL2[7], 1);
        Bit#(3) c12  = muxCalc_z(pHash[35:33] , gHash[35:33] , cVecL2[8], 1);
        Bit#(3) c13  = muxCalc_z(pHash[38:36] , gHash[38:36] , cVecL1[2] , 1);
        Bit#(3) c14  = muxCalc_z(pHash[41:39] , gHash[41:39] , cVecL2[9] , 1);
        Bit#(3) c15  = muxCalc_z(pHash[44:42] , gHash[44:42] , cVecL2[10], 1);
        Bit#(3) c16  = muxCalc_z(pHash[47:45] , gHash[47:45] , cVecL2[11], 1);

        s[0]  =  p[0]^cin;
        s[1]  =  p[1]^c1[0];
        s[2]  =  p[2]^c1[1];
        s[3]  =  p[3]^c1[2];
        s[4]  =  p[4]^cVecL2[0];
        s[5]  =  p[5]^c2[0];
        s[6]  =  p[6]^c2[1];
        s[7]  =  p[7]^c2[2];
        s[8]  =  p[8]^cVecL2[1];
        s[9]  =  p[9]^c3[0];        
        s[10] = p[10]^c3[1];
        s[11] = p[11]^c3[2];
        s[12] = p[12]^cVecL2[2];
        s[13] = p[13]^c4[0];
        s[14] = p[14]^c4[1];
        s[15] = p[15]^c4[2];
        s[16] = p[16]^cVecL1[0];
        s[17] = p[17]^c5[0];
        s[18] = p[18]^c5[1];
        s[19] = p[19]^c5[2];
        s[20] = p[20]^cVecL2[3];
        s[21] = p[21]^c6[0];
        s[22] = p[22]^c6[1];
        s[23] = p[23]^c6[2];
        s[24] = p[24]^cVecL2[4];
        s[25] = p[25]^c7[0];        
        s[26] = p[26]^c7[1];
        s[27] = p[27]^c7[2];
        s[28] = p[28]^cVecL2[5];
        s[29] = p[29]^c8[0];
        s[30] = p[30]^c8[1];
        s[31] = p[31]^c8[2];
        s[32] = p[32]^cVecL1[1];
        s[33] = p[33]^c9[0];
        s[34] = p[34]^c9[1];
        s[35] = p[35]^c9[2];
        s[36] = p[36]^cVecL2[6];
        s[37] = p[37]^c10[0];
        s[38] = p[38]^c10[1];
        s[39] = p[39]^c10[2];
        s[40] = p[40]^cVecL2[7];
        s[41] = p[41]^c11[0];        
        s[42] = p[42]^c11[1];
        s[43] = p[43]^c11[2];
        s[44] = p[44]^cVecL2[8];
        s[45] = p[45]^c12[0];
        s[46] = p[46]^c12[1];
        s[47] = p[47]^c12[2];
        s[48] = p[48]^cVecL1[2];
        s[49] = p[49]^c13[0];
        s[50] = p[50]^c13[1];
        s[51] = p[51]^c13[2];
        s[52] = p[52]^cVecL2[9];
        s[53] = p[53]^c14[0];
        s[54] = p[54]^c14[1];
        s[55] = p[55]^c14[2];
        s[56] = p[56]^cVecL2[10];
        s[57] = p[57]^c15[0];        
        s[58] = p[58]^c15[1];
        s[59] = p[59]^c15[2];
        s[60] = p[60]^cVecL2[11];
        s[61] = p[61]^c16[0];
        s[62] = p[62]^c16[1];
        s[63] = p[63]^c16[2];
        return {cVecL1[3],s};

    endfunction
    /* 
        addEverything64 needs to be capable of handing 8x9, 4x17, 2x33, 1x65.
        We can handle this by instantiating a 72b adder and feeding inputs and Carry disables or by accepting 8 x 9'b inputs in general.
        
    */
    function AdderOutput addwMetaData (Bit#(64) inpA, Bit#(64) inpB, Bit#(1) inpCin, Bit#(2) ctrl);
        Bit#(1) cin = inpCin & ctrl[1] & ctrl[0];
        Bit#(1) z16 = ctrl[1];
        Bit#(1) z8  = (ctrl[1] | ctrl[0]);
        Bit#(1) z32 = ctrl[1]&ctrl[0];
        Bit#(48) pHash  = 0; Bit#(48) gHash   = 0;
        Bit#(12) pSHash = 0; Bit#(12) gSHash  = 0;
        Bit#(16) pStar  = 0; Bit#(16) gStar   = 0;
        Bit#(4)  pSS    = 0; Bit#(4)  gSS     = 0;
        Bit#(64) p      = 0; Bit#(64) g       = 0;
        Bit#(16) p1     = 0; Bit#(16) g1      = 0;
        Bit#(16) p2     = 0; Bit#(16) g2      = 0;
        Bit#(16) p3     = 0; Bit#(16) g3      = 0;
        Bit#(16) p4     = 0; Bit#(16) g4      = 0;
        Bit#(64) s      = 0;
        Bit#(12) cVecL2out = 0;

        p  = inpA^inpB;
        g  = inpA&inpB;
        p1 = p[15: 0]; g1 = g[15: 0];
        p2 = p[31:16]; g2 = g[31:16];
        p3 = p[47:32]; g3 = g[47:32];
        p4 = p[63:48]; g4 = g[63:48];
        Vector#(2, Bit#(4)) hashVec1  = hashCalc_z(p1[3:0]  , g1[3:0]  , 1);
        Vector#(2, Bit#(4)) hashVec2  = hashCalc_z(p1[7:4]  , g1[7:4]  , 1);
        Vector#(2, Bit#(4)) hashVec3  = hashCalc_z(p1[11:8] , g1[11:8] , 1);
        Vector#(2, Bit#(4)) hashVec4  = hashCalc_z(p1[15:12], g1[15:12], 1);
        Vector#(2, Bit#(4)) hashVec5  = hashCalc_z(p2[3:0]  , g2[3:0]  , 1);
        Vector#(2, Bit#(4)) hashVec6  = hashCalc_z(p2[7:4]  , g2[7:4]  , 1);
        Vector#(2, Bit#(4)) hashVec7  = hashCalc_z(p2[11:8] , g2[11:8] , 1);
        Vector#(2, Bit#(4)) hashVec8  = hashCalc_z(p2[15:12], g2[15:12], 1);
        Vector#(2, Bit#(4)) hashVec9  = hashCalc_z(p3[3:0]  , g3[3:0]  , 1);
        Vector#(2, Bit#(4)) hashVec10 = hashCalc_z(p3[7:4]  , g3[7:4]  , 1);
        Vector#(2, Bit#(4)) hashVec11 = hashCalc_z(p3[11:8] , g3[11:8] , 1);
        Vector#(2, Bit#(4)) hashVec12 = hashCalc_z(p3[15:12], g3[15:12], 1);
        Vector#(2, Bit#(4)) hashVec13 = hashCalc_z(p4[3:0]  , g4[3:0]  , 1);
        Vector#(2, Bit#(4)) hashVec14 = hashCalc_z(p4[7:4]  , g4[7:4]  , 1);
        Vector#(2, Bit#(4)) hashVec15 = hashCalc_z(p4[11:8] , g4[11:8] , 1);
        Vector#(2, Bit#(4)) hashVec16 = hashCalc_z(p4[15:12], g4[15:12], 1);

        pHash[11:0]  = {hashVec4[1][2:0],hashVec3[1][2:0],hashVec2[1][2:0],hashVec1[1][2:0]};
        gHash[11:0]  = {hashVec4[0][2:0],hashVec3[0][2:0],hashVec2[0][2:0],hashVec1[0][2:0]};
        pHash[23:12] = {hashVec8[1][2:0],hashVec7[1][2:0],hashVec6[1][2:0],hashVec5[1][2:0]};
        gHash[23:12] = {hashVec8[0][2:0],hashVec7[0][2:0],hashVec6[0][2:0],hashVec5[0][2:0]};
        pHash[35:24]  = {hashVec12[1][2:0],hashVec11[1][2:0],hashVec10[1][2:0],hashVec9[1][2:0]};
        gHash[35:24]  = {hashVec12[0][2:0],hashVec11[0][2:0],hashVec10[0][2:0],hashVec9[0][2:0]};
        pHash[47:36] = {hashVec16[1][2:0],hashVec15[1][2:0],hashVec14[1][2:0],hashVec13[1][2:0]};
        gHash[47:36] = {hashVec16[0][2:0],hashVec15[0][2:0],hashVec14[0][2:0],hashVec13[0][2:0]};


        pStar[3:0]   = {hashVec4[1][3],hashVec3[1][3],hashVec2[1][3],hashVec1[1][3]};
        gStar[3:0]   = {hashVec4[0][3],hashVec3[0][3],hashVec2[0][3],hashVec1[0][3]};
        pStar[7:4]   = {hashVec8[1][3],hashVec7[1][3],hashVec6[1][3],hashVec5[1][3]};
        gStar[7:4]   = {hashVec8[0][3],hashVec7[0][3],hashVec6[0][3],hashVec5[0][3]};
        pStar[11:8]  = {hashVec12[1][3],hashVec11[1][3],hashVec10[1][3],hashVec9[1][3]};
        gStar[11:8]  = {hashVec12[0][3],hashVec11[0][3],hashVec10[0][3],hashVec9[0][3]};
        pStar[15:12] = {hashVec16[1][3],hashVec15[1][3],hashVec14[1][3],hashVec13[1][3]};
        gStar[15:12] = {hashVec16[0][3],hashVec15[0][3],hashVec14[0][3],hashVec13[0][3]};

        Vector#(2, Bit#(4)) starHashVec1  = hashCalc_z(pStar[3:0]  , gStar[3:0]  , z8);
        Vector#(2, Bit#(4)) starHashVec2  = hashCalc_z(pStar[7:4]  , gStar[7:4]  , z8);
        Vector#(2, Bit#(4)) starHashVec3  = hashCalc_z(pStar[11:8] , gStar[11:8] , z8);
        Vector#(2, Bit#(4)) starHashVec4  = hashCalc_z(pStar[15:12], gStar[15:12], z8);

        pSS  = {starHashVec4[1][3], starHashVec3[1][3], starHashVec2[1][3], starHashVec1[1][3]};
        gSS  = {starHashVec4[0][3], starHashVec3[0][3], starHashVec2[0][3], starHashVec1[0][3]};

        pSHash  = {starHashVec4[1][2:0],starHashVec3[1][2:0],starHashVec2[1][2:0],starHashVec1[1][2:0]};
        gSHash  = {starHashVec4[0][2:0],starHashVec3[0][2:0],starHashVec2[0][2:0],starHashVec1[0][2:0]};

        Bit#(4) cVecL1out = hau4_z(pSS, gSS, inpCin, {z32,z16});
        Bit#(4) cVecL1    = cVecL1out&{1,z16,z32,z16};
    

        cVecL2out[2:0]  = muxCalc_z(pSHash[2:0]  , gSHash[2:0]  , cin      , z8);
        cVecL2out[5:3]  = muxCalc_z(pSHash[5:3]  , gSHash[5:3]  , cVecL1[0], z8);
        cVecL2out[8:6]  = muxCalc_z(pSHash[8:6]  , gSHash[8:6]  , cVecL1[1], z8);
        cVecL2out[11:9] = muxCalc_z(pSHash[11:9] , gSHash[11:9] , cVecL1[2], z8);
        Bit#(12) cVecL2 = cVecL2out;
        for(Integer i = 0; i < 4; i = i + 1)
            cVecL2[3*i + 1] = cVecL2[3*i+1]&z8;

        Bit#(3) c1   = muxCalc_z(pHash[2:0]   , gHash[2:0]   , cin      , 1);
        Bit#(3) c2   = muxCalc_z(pHash[5:3]   , gHash[5:3]   , cVecL2[0], 1);
        Bit#(3) c3   = muxCalc_z(pHash[8:6]   , gHash[8:6]   , cVecL2[1], 1);
        Bit#(3) c4   = muxCalc_z(pHash[11:9]  , gHash[11:9]  , cVecL2[2], 1);
        Bit#(3) c5   = muxCalc_z(pHash[14:12] , gHash[14:12] , cVecL1[0], 1);
        Bit#(3) c6   = muxCalc_z(pHash[17:15] , gHash[17:15] , cVecL2[3], 1);
        Bit#(3) c7   = muxCalc_z(pHash[20:18] , gHash[20:18] , cVecL2[4], 1);
        Bit#(3) c8   = muxCalc_z(pHash[23:21] , gHash[23:21] , cVecL2[5], 1);
        Bit#(3) c9   = muxCalc_z(pHash[26:24] , gHash[26:24] , cVecL1[1], 1);
        Bit#(3) c10  = muxCalc_z(pHash[29:27] , gHash[29:27] , cVecL2[6], 1);
        Bit#(3) c11  = muxCalc_z(pHash[32:30] , gHash[32:30] , cVecL2[7], 1);
        Bit#(3) c12  = muxCalc_z(pHash[35:33] , gHash[35:33] , cVecL2[8], 1);
        Bit#(3) c13  = muxCalc_z(pHash[38:36] , gHash[38:36] , cVecL1[2] , 1);
        Bit#(3) c14  = muxCalc_z(pHash[41:39] , gHash[41:39] , cVecL2[9] , 1);
        Bit#(3) c15  = muxCalc_z(pHash[44:42] , gHash[44:42] , cVecL2[10], 1);
        Bit#(3) c16  = muxCalc_z(pHash[47:45] , gHash[47:45] , cVecL2[11], 1);

        s[0]  =  p[0]^cin;
        s[1]  =  p[1]^c1[0];
        s[2]  =  p[2]^c1[1];
        s[3]  =  p[3]^c1[2];
        s[4]  =  p[4]^cVecL2[0];
        s[5]  =  p[5]^c2[0];
        s[6]  =  p[6]^c2[1];
        s[7]  =  p[7]^c2[2];
        s[8]  =  p[8]^cVecL2[1];
        s[9]  =  p[9]^c3[0];        
        s[10] = p[10]^c3[1];
        s[11] = p[11]^c3[2];
        s[12] = p[12]^cVecL2[2];
        s[13] = p[13]^c4[0];
        s[14] = p[14]^c4[1];
        s[15] = p[15]^c4[2];
        s[16] = p[16]^cVecL1[0];
        s[17] = p[17]^c5[0];
        s[18] = p[18]^c5[1];
        s[19] = p[19]^c5[2];
        s[20] = p[20]^cVecL2[3];
        s[21] = p[21]^c6[0];
        s[22] = p[22]^c6[1];
        s[23] = p[23]^c6[2];
        s[24] = p[24]^cVecL2[4];
        s[25] = p[25]^c7[0];        
        s[26] = p[26]^c7[1];
        s[27] = p[27]^c7[2];
        s[28] = p[28]^cVecL2[5];
        s[29] = p[29]^c8[0];
        s[30] = p[30]^c8[1];
        s[31] = p[31]^c8[2];
        s[32] = p[32]^cVecL1[1];
        s[33] = p[33]^c9[0];
        s[34] = p[34]^c9[1];
        s[35] = p[35]^c9[2];
        s[36] = p[36]^cVecL2[6];
        s[37] = p[37]^c10[0];
        s[38] = p[38]^c10[1];
        s[39] = p[39]^c10[2];
        s[40] = p[40]^cVecL2[7];
        s[41] = p[41]^c11[0];        
        s[42] = p[42]^c11[1];
        s[43] = p[43]^c11[2];
        s[44] = p[44]^cVecL2[8];
        s[45] = p[45]^c12[0];
        s[46] = p[46]^c12[1];
        s[47] = p[47]^c12[2];
        s[48] = p[48]^cVecL1[2];
        s[49] = p[49]^c13[0];
        s[50] = p[50]^c13[1];
        s[51] = p[51]^c13[2];
        s[52] = p[52]^cVecL2[9];
        s[53] = p[53]^c14[0];
        s[54] = p[54]^c14[1];
        s[55] = p[55]^c14[2];
        s[56] = p[56]^cVecL2[10];
        s[57] = p[57]^c15[0];        
        s[58] = p[58]^c15[1];
        s[59] = p[59]^c15[2];
        s[60] = p[60]^cVecL2[11];
        s[61] = p[61]^c16[0];
        s[62] = p[62]^c16[1];
        s[63] = p[63]^c16[2];
        
        AdderOutput temp;
        temp.outp = s;
        //FORMAT: Byte MSBS of RS2 [15:8]; Byte MSBS of RS1 [7:0]
        temp.msbs = {inpB[63],inpB[55],inpB[47],inpB[39],inpB[31],inpB[23],inpB[15],inpB[7],
                     inpA[63],inpA[55],inpA[47],inpA[39],inpA[31],inpA[23],inpA[15],inpA[7] };
        temp.crrs = {cVecL1out[3], cVecL2out[10], cVecL1out[2], cVecL2out[7], cVecL1out[1], cVecL2out[4], cVecL1out[0], cVecL2out[1]};
        
        
        return temp;
    endfunction
endpackage