package decoder;
export decoder::*;
import Vector::*;
`include "decoder.defines"

/*
    Decoder. Contains Control Signal Defintions and LUT for CtrlSignals generation
    imm needs to be Bit#(6) in the final version, but this has not yet been implemented.
*/


//Remove due to massive compile time - typedef enum {ADD16, RADD16, URADD16, KADD16, UKADD16, SUB16, RSUB16, URSUB16, KSUB16, UKSUB16, CRAS16, RCRAS16, URCRAS16, KCRAS16, UKCRAS16, CRSA16, RCRSA16, URCRSA16, KCRSA16, UKCRSA16, STAS16, RSTAS16, URSTAS16, KSTAS16, UKSTAS16, STSA16, RSTSA16, URSTSA16, KSTSA16, UKSTSA16, ADD8, RADD8, URADD8, KADD8, UKADD8, SUB8, RSUB8, URSUB8, KSUB8, UKSUB8, SRA16, SRAI16, SRA16du, SRAI16du, SRL16, SRLI16, SRL16du, SRLI16du, SLL16, SLLI16, KSLL16, KSLLI16, KSLRA16, KSLRA16du, SRA8, SRAI8, SRA8du, SRAI8du, SRL8, SRLI8, SRL8du, SRLI8du, SLL8, SLLI8, KSLL8, KSLLI8, KSLRA8, KSLRA8du, CMPEQ16, SCMPLT16, SCMPLE16, UCMPLT16, UCMPLE16, CMPEQ8, SCMPLT8, SCMPLE8, UCMPLT8, UCMPLE8, SMUL16, SMULX16, UMUL16, UMULX16, KHM16, KHMX16, SMUL8, SMULX8, UMUL8, UMULX8, KHM8, KHMX8, SMIN16, UMIN16, SMAX16, UMAX16, KABS16, CLRS16, CLZ16, SWAP16, SMIN8, UMIN8, SMAX8, UMAX8, KABS8, CLRS8, CLZ8, SWAP8, SUNPKD810, SUNPKD820, SUNPKD830, SUNPKD831, SUNPKD832, ZUNPKD810, ZUNPKD820, ZUNPKD830, ZUNPKD831, ZUNPKD832, PKBB16, PKBT16, PKTB16, PKTT16, CLRS32, CLZ32, ADD32, RADD32, URADD32, KADD32, UKADD32, SUB32, RSUB32, URSUB32, KSUB32, UKSUB32, CRAS32, RCRAS32, URCRAS32, KCRAS32, UKCRAS32, CRSA32, RCRSA32, URCRSA32, KCRSA32, UKCRSA32, STAS32, RSTAS32, URSTAS32, KSTAS32, UKSTAS32, STSA32, RSTSA32, URSTSA32, KSTSA32, UKSTSA32, SRA32, SRAI32, SRA32du, SRAI32du, SRL32, SRLI32, SRL32du, SRLI32du, SLL32, SLLI32, KSLL32, KSLLI32, KSLRA32, KSLRA32du, SMBB32, SMBT32, SMTT32, KHMBB16, KHMBT16, KHMTT16, KDMBB16, KDMBT16, KDMTT16, SMIN32, UMIN32, SMAX32, UMAX32, KABS32, PKBB32, PKBT32, PKTB32, PKTT32} PInstr deriving (Bits, Eq);
    typedef enum {/*SE9, ZE9, SE17, ZE17, SE33, ZE33,*/ EightSE16, EightZE16, NOP}     ExtCtrlSgn deriving (Bits, Eq); 
    typedef enum {CRS8, CRS16, CRS32, NOP}                                        CrsCtrlSgn deriving (Bits, Eq);
    typedef enum {INV8, INV16, INV32, LNV16, LNV32, UNV16, UNV32, NOP}            InvCtrlSgn deriving (Bits, Eq);
    typedef enum {LSFT8, LSFT16, LSFT32, RSFT8, RSFT16, RSFT32, 
                  ARSFT8, ARSFT16, ARSFT32, KLSFT8, KLSFT16, KLSFT32, NOP}                     SftCtrlSgn deriving (Bits, Eq);
    typedef enum {FX16, ATX8, TX32, RND32, RND16, RND8, LTE8, LTE16, CMP32,
                  CMP16, CMP8, CLRS32, CLRS16, CLRS8, CLZ32, CLZ16, CLZ8,
                  ABS8, ABS16, ABS32, NOP}                                       Alu2CtrlSgn deriving (Bits, Eq);
    typedef enum {QSAT31, QSAT15, QSAT7, SAT32, SAT16, SAT8, 
                  SH8, SH16, SH32, H8, H16, H32,  NOP}                            SatCtrlSgn deriving (Bits, Eq);
    typedef enum {BOT32, TOP33, TOFF33, BOT31, TOFF31, SR15, SR7, M1, BOT16, TOP16, NOP}     AluMuxCtrlSgn deriving (Bits, Eq);
    typedef enum {FX16S, ATX8S, TX32S, FX16, ATX8, TX32, NOP}                         MultCtrlSgn deriving (Bits, Eq);
    typedef enum {SAT, NOSAT}                                                    MSatCtrlSgn deriving (Bits, Eq);
    typedef enum {R3, R4, R5, IMM3U, IMM4U, IMM5U, R4S, R5S, R6S, NOP}                        SftGenCtrlSgn deriving (Bits, Eq);
    typedef enum {EQ16, EQ8, MIN16, MAX16, MIN8, MAX8, SE32, QSAT31, MIN32, MAX32, P810, P820, P830, P831, P832, NOP} WbCtrlSgn deriving (Bits, Eq);

typedef struct {
    ExtCtrlSgn     exCtrl;
    CrsCtrlSgn    crsCtrl;
    InvCtrlSgn    invCtrl;
    MultCtrlSgn    multOp; 
    MSatCtrlSgn      mSat;
    AluMuxCtrlSgn alu2Sel;
    Bool         rs2Check;
    SftGenCtrlSgn  sftGen;
    SftCtrlSgn    sftCtrl;
    SftCtrlSgn altSftCtrl;
    Alu2CtrlSgn    alu2Op;
    SatCtrlSgn    satCtrl;
    WbCtrlSgn       wbSel;
} CtrlSgnPacket deriving (Bits, Eq);


function CtrlSgnPacket decodeFunct37 (Bit#(10) instr, Bit#(5) imm);
    CtrlSgnPacket temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

    case(instr) matches
    
`ADD16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : NOP, wbSel : NOP };

`RADD16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : SH16, wbSel : NOP };

`URADD16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : H16, wbSel : NOP };

`KADD16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : QSAT15, wbSel : NOP };

`UKADD16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : SAT16, wbSel : NOP };

`SUB16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : NOP, wbSel : NOP };

`RSUB16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : SH16, wbSel : NOP };

`URSUB16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : H16, wbSel : NOP };

`KSUB16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : QSAT15, wbSel : NOP };

`UKSUB16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : SAT16, wbSel : NOP };

`CRAS16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS16, invCtrl : LNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : NOP, wbSel : NOP };

`RCRAS16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS16, invCtrl : LNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : SH16, wbSel : NOP };

`URCRAS16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS16, invCtrl : LNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : H16, wbSel : NOP };

`KCRAS16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS16, invCtrl : LNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : QSAT15, wbSel : NOP };

`UKCRAS16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS16, invCtrl : LNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : SAT16, wbSel : NOP };

`CRSA16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS16, invCtrl : UNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : NOP, wbSel : NOP };

`RCRSA16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS16, invCtrl : UNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : SH16, wbSel : NOP };

`URCRSA16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS16, invCtrl : UNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : H16, wbSel : NOP };

`KCRSA16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS16, invCtrl : UNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : QSAT15, wbSel : NOP };

`UKCRSA16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS16, invCtrl : UNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : SAT16, wbSel : NOP };

`STAS16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : LNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : NOP, wbSel : NOP };

`RSTAS16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : LNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : SH16, wbSel : NOP };

`URSTAS16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : LNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : H16, wbSel : NOP };

`KSTAS16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : LNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : QSAT15, wbSel : NOP };

`UKSTAS16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : LNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : SAT16, wbSel : NOP };

`STSA16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : UNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : NOP, wbSel : NOP };

`RSTSA16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : UNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : SH16, wbSel : NOP };

`URSTSA16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : UNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : H16, wbSel : NOP };

`KSTSA16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : UNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : QSAT15, wbSel : NOP };

`UKSTSA16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : UNV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : SAT16, wbSel : NOP };

`ADD8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : ATX8, satCtrl : NOP, wbSel : NOP };

`RADD8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : ATX8, satCtrl : SH8, wbSel : NOP };

`URADD8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : ATX8, satCtrl : H8, wbSel : NOP };

`KADD8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : ATX8, satCtrl : QSAT7, wbSel : NOP };

`UKADD8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : ATX8, satCtrl : SAT8, wbSel : NOP };

`SUB8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV8, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : ATX8, satCtrl : NOP, wbSel : NOP };

`RSUB8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV8, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : ATX8, satCtrl : SH8, wbSel : NOP };

`URSUB8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV8, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : ATX8, satCtrl : H8, wbSel : NOP };

`KSUB8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV8, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : ATX8, satCtrl : QSAT7, wbSel : NOP };

`UKSUB8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV8, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : ATX8, satCtrl : SAT8, wbSel : NOP };

`SRA16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : R4, sftCtrl : ARSFT16, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SRAI16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : IMM4U, sftCtrl : ARSFT16, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SRA16du: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : R4, sftCtrl : ARSFT16, altSftCtrl : NOP, alu2Op : RND16, satCtrl : NOP, wbSel : NOP };

`SRAI16du: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : IMM4U, sftCtrl : ARSFT16, altSftCtrl : NOP, alu2Op : RND16, satCtrl : NOP, wbSel : NOP };

`SRL16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : R4, sftCtrl : RSFT16, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SRLI16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : IMM4U, sftCtrl : RSFT16, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SRL16du: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : R4, sftCtrl : RSFT16, altSftCtrl : NOP, alu2Op : RND16, satCtrl : NOP, wbSel : NOP };

`SRLI16du: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : IMM4U, sftCtrl : RSFT16, altSftCtrl : NOP, alu2Op : RND16, satCtrl : NOP, wbSel : NOP };

`SLL16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : R4, sftCtrl : LSFT16, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SLLI16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : IMM4U, sftCtrl : LSFT16, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`KSLL16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : R4, sftCtrl : KLSFT16, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`KSLLI16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : IMM4U, sftCtrl : KLSFT16, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`KSLRA16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : True, alu2Sel : NOP, sftGen : R5S, sftCtrl : KLSFT16, altSftCtrl : ARSFT16, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`KSLRA16du: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : True, alu2Sel : NOP, sftGen : R5S, sftCtrl : KLSFT16, altSftCtrl : ARSFT16, alu2Op : RND16, satCtrl : NOP, wbSel : NOP };

`SRA8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : R3, sftCtrl : ARSFT8, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SRAI8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : IMM3U, sftCtrl : ARSFT8, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SRA8du: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : R3, sftCtrl : ARSFT8, altSftCtrl : NOP, alu2Op : RND8, satCtrl : NOP, wbSel : NOP };

`SRAI8du: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : IMM3U, sftCtrl : ARSFT8, altSftCtrl : NOP, alu2Op : RND8, satCtrl : NOP, wbSel : NOP };

`SRL8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : R3, sftCtrl : RSFT8, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SRLI8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : IMM3U, sftCtrl : RSFT8, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SRL8du: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : R3, sftCtrl : RSFT8, altSftCtrl : NOP, alu2Op : RND8, satCtrl : NOP, wbSel : NOP };

`SRLI8du: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : IMM3U, sftCtrl : RSFT8, altSftCtrl : NOP, alu2Op : RND8, satCtrl : NOP, wbSel : NOP };

`SLL8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : R3, sftCtrl : LSFT8, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SLLI8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : IMM3U, sftCtrl : LSFT8, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`KSLL8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : R3, sftCtrl : KLSFT8, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`KSLLI8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : IMM3U, sftCtrl : KLSFT8, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`KSLRA8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : True, alu2Sel : NOP, sftGen : R4S, sftCtrl : KLSFT8, altSftCtrl : ARSFT8,  alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`KSLRA8du: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : True, alu2Sel : NOP, sftGen : R4S, sftCtrl : KLSFT8, altSftCtrl : ARSFT8,  alu2Op : RND8, satCtrl : NOP, wbSel : NOP };

`CMPEQ16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : CMP16, satCtrl : NOP, wbSel : EQ16 };

`SCMPLT16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : NOP, wbSel : EQ16 };

`SCMPLE16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : LTE16, satCtrl : NOP, wbSel : EQ16 };

`UCMPLT16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : NOP, wbSel : EQ16 };

`UCMPLE16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : LTE16, satCtrl : NOP, wbSel : EQ16 };

`CMPEQ8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : CMP8, satCtrl : NOP, wbSel : EQ8 };

`SCMPLT8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV8, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : ATX8, satCtrl : NOP, wbSel : EQ8 };

`SCMPLE8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV8, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : LTE8, satCtrl : NOP, wbSel : EQ8 };

`UCMPLT8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV8, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : ATX8, satCtrl : NOP, wbSel : EQ8 };

`UCMPLE8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV8, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : LTE8, satCtrl : NOP, wbSel : EQ8 };

`SMUL16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : FX16S, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SMULX16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS16, invCtrl : NOP, multOp : FX16S, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`UMUL16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : FX16, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`UMULX16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS16, invCtrl : NOP, multOp : FX16, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`KHM16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : FX16S, mSat :  SAT, rs2Check : False, alu2Sel : SR15, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`KHMX16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS16, invCtrl : NOP, multOp : FX16S, mSat :  SAT, rs2Check : False, alu2Sel : SR15, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SMUL8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : ATX8S, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SMULX8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS8, invCtrl : NOP, multOp : ATX8S, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`UMUL8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : ATX8, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`UMULX8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS8, invCtrl : NOP, multOp : ATX8, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`KHM8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : ATX8S, mSat :  SAT, rs2Check : False, alu2Sel : SR7, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`KHMX8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS8, invCtrl : NOP, multOp : ATX8S, mSat :  SAT, rs2Check : False, alu2Sel : SR7, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SMIN16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : NOP, wbSel : MIN16 };

`UMIN16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : NOP, wbSel : MIN16 };

`SMAX16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : NOP, wbSel : MAX16 };

`UMAX16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : FX16, satCtrl : NOP, wbSel : MAX16 };




`SMIN8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV8, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : ATX8, satCtrl : NOP, wbSel : MIN8 };

`UMIN8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV8, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : ATX8, satCtrl : NOP, wbSel : MIN8 };

`SMAX8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV8, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : ATX8, satCtrl : NOP, wbSel : MAX8 };

`UMAX8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV8, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : ATX8, satCtrl : NOP, wbSel : MAX8 };



`PKBB16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : BOT16, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`PKBT16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS16, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : BOT16, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`PKTB16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS16, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : TOP16, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`PKTT16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : TOP16, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };


`ADD32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : NOP, wbSel : NOP };

`RADD32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : SH32, wbSel : NOP };

`URADD32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : H32, wbSel : NOP };

`KADD32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : QSAT31, wbSel : NOP };

`UKADD32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : SAT32, wbSel : NOP };

`SUB32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : NOP, wbSel : NOP };

`RSUB32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : SH32, wbSel : NOP };

`URSUB32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : H32, wbSel : NOP };

`KSUB32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : QSAT31, wbSel : NOP };

`UKSUB32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : SAT32, wbSel : NOP };

`CRAS32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS32, invCtrl : LNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : NOP, wbSel : NOP };

`RCRAS32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS32, invCtrl : LNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : SH32, wbSel : NOP };

`URCRAS32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS32, invCtrl : LNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : H32, wbSel : NOP };

`KCRAS32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS32, invCtrl : LNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : QSAT31, wbSel : NOP };

`UKCRAS32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS32, invCtrl : LNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : SAT32, wbSel : NOP };

`CRSA32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS32, invCtrl : UNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : NOP, wbSel : NOP };

`RCRSA32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS32, invCtrl : UNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : SH32, wbSel : NOP };

`URCRSA32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS32, invCtrl : UNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : H32, wbSel : NOP };

`KCRSA32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS32, invCtrl : UNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : QSAT31, wbSel : NOP };

`UKCRSA32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS32, invCtrl : UNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : SAT32, wbSel : NOP };

`STAS32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : LNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : NOP, wbSel : NOP };

`RSTAS32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : LNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : SH32, wbSel : NOP };

`URSTAS32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : LNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : H32, wbSel : NOP };

`KSTAS32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : LNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : QSAT31, wbSel : NOP };

`UKSTAS32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : LNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : SAT32, wbSel : NOP };

`STSA32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : UNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : NOP, wbSel : NOP };

`RSTSA32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : UNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : SH32, wbSel : NOP };

`URSTSA32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : UNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : H32, wbSel : NOP };

`KSTSA32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : UNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : QSAT31, wbSel : NOP };

`UKSTSA32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : UNV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : SAT32, wbSel : NOP };

`SRA32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : R5, sftCtrl : ARSFT32, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SRAI32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : IMM5U, sftCtrl : ARSFT32, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SRA32du: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : R5, sftCtrl : ARSFT32, altSftCtrl : NOP, alu2Op : RND32, satCtrl : NOP, wbSel : NOP };

`SRAI32du: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : IMM5U, sftCtrl : ARSFT32, altSftCtrl : NOP, alu2Op : RND32, satCtrl : NOP, wbSel : NOP };

`SRL32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : R5, sftCtrl : RSFT32, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SRLI32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : IMM5U, sftCtrl : RSFT32, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SRL32du: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : R5, sftCtrl : RSFT32, altSftCtrl : NOP, alu2Op : RND32, satCtrl : NOP, wbSel : NOP };

`SRLI32du: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : IMM5U, sftCtrl : RSFT32, altSftCtrl : NOP, alu2Op : RND32, satCtrl : NOP, wbSel : NOP };

`SLL32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : R5, sftCtrl : LSFT32, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SLLI32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : IMM5U, sftCtrl : LSFT32, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`KSLL32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : R5, sftCtrl : KLSFT32, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`KSLLI32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : IMM5U, sftCtrl : KLSFT32, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`KSLRA32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : True, alu2Sel : NOP, sftGen : R6S, sftCtrl : KLSFT32, altSftCtrl : ARSFT32,  alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`KSLRA32du: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : True, alu2Sel : NOP, sftGen : R6S, sftCtrl : KLSFT32, altSftCtrl : ARSFT32,  alu2Op : RND32, satCtrl : NOP, wbSel : NOP };

`MULSR64: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : TX32S, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SMBT32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS32, invCtrl : NOP, multOp : TX32S, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SMTT32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : TX32S, mSat :  NOSAT, rs2Check : False, alu2Sel : M1, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`KHMBB16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : FX16S, mSat :  SAT, rs2Check : False, alu2Sel : BOT32, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : SE32 };

`KHMBT16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS16, invCtrl : NOP, multOp : FX16S, mSat :  SAT, rs2Check : False, alu2Sel : BOT32, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : SE32 };

`KHMTT16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : FX16S, mSat :  SAT, rs2Check : False, alu2Sel : TOP33, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : SE32 };

`KDMBB16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : FX16S, mSat :  SAT, rs2Check : False, alu2Sel : BOT31, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`KDMBT16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS16, invCtrl : NOP, multOp : FX16S, mSat :  SAT, rs2Check : False, alu2Sel : BOT31, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`KDMTT16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : FX16S, mSat :  SAT, rs2Check : False, alu2Sel : TOFF31, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`SMIN32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : NOP, wbSel : MIN32 };

`UMIN32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : NOP, wbSel : MIN32 };

`SMAX32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : NOP, wbSel : MAX32 };

`UMAX32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : TX32, satCtrl : NOP, wbSel : MAX32 };


/*`PKBB32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : BOT32, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };
*/
`PKBT32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS32, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : BOT32, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

`PKTB32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS32, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : TOP33, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };

/*`PKTT32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : TOP33, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };
*/
`ONEOP: begin
    case(imm) matches
    `SUNPKD810: 

    temp = CtrlSgnPacket { exCtrl : EightSE16, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : P810 };

`SUNPKD820: 

    temp = CtrlSgnPacket { exCtrl : EightSE16, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : P820 };

`SUNPKD830: 

    temp = CtrlSgnPacket { exCtrl : EightSE16, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : P830 };

`SUNPKD831: 

    temp = CtrlSgnPacket { exCtrl : EightSE16, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : P831 };

`SUNPKD832: 

    temp = CtrlSgnPacket { exCtrl : EightSE16, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : P832 };

`ZUNPKD810: 

    temp = CtrlSgnPacket { exCtrl : EightZE16, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : P810 };

`ZUNPKD820: 

    temp = CtrlSgnPacket { exCtrl : EightZE16, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : P820 };

`ZUNPKD830: 

    temp = CtrlSgnPacket { exCtrl : EightZE16, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : P830 };

`ZUNPKD831: 

    temp = CtrlSgnPacket { exCtrl : EightZE16, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : P831 };

`ZUNPKD832: 

    temp = CtrlSgnPacket { exCtrl : EightZE16, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : P832 };
`KABS16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV16, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : ABS16, satCtrl : NOP, wbSel : NOP };
`KABS8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV8, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : ABS8, satCtrl : NOP, wbSel : NOP };

    `KABS32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : INV32, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : ABS32, satCtrl : NOP, wbSel : NOP };

`SWAP8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : CRS8, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : NOP, satCtrl : NOP, wbSel : NOP };
  

    default: begin
    end
    

    endcase
end

`ONEOP2: begin
    case(imm) matches
    `CLRS16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : CLRS16, satCtrl : NOP, wbSel : NOP };

    `CLZ16: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : CLZ16, satCtrl : NOP, wbSel : NOP };
    `CLRS8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : CLRS8, satCtrl : NOP, wbSel : NOP };

    `CLZ8: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : CLZ8, satCtrl : NOP, wbSel : NOP };
    `CLRS32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : CLRS32, satCtrl : NOP, wbSel : NOP };

    `CLZ32: 

    temp = CtrlSgnPacket { exCtrl : NOP, crsCtrl : NOP, invCtrl : NOP, multOp : NOP, mSat :  NOSAT, rs2Check : False, alu2Sel : NOP, sftGen : NOP, sftCtrl : NOP, altSftCtrl : NOP, alu2Op : CLZ32, satCtrl : NOP, wbSel : NOP };

    endcase
end
    default: begin
    end
    endcase
    return temp;

    
endfunction 
endpackage