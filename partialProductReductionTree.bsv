package partialProductReductionTree;
    import Vector :: *;
	import partialProductGenerator :: *;
    import multiplierCell :: *;
    function Bit#(32) dadda16_1 (Bit#(16) v1, Bit#(16) v2);
        Bit#(20) s1 = 0, c1 = 0;
        Bit#(36) s2 = 0, c2 = 0;
        Bit#(54) s3 = 0, c3 = 0;
        Bit#(46) s4 = 0, c4 = 0;
        Bit#(26) s5 = 0, c5 = 0;
        Bit#(28) s6 = 0, c6 = 0;

        Vector#(16, Bit#(16)) inPP = block1(v1, v2,0,1,1);

        //STAGE 1: HALF ADDERS
        Bit#(2) ha11 = hadd(inPP[0][12], inPP[1][11]);
        s1[0] = ha11[0]; c1[0] = ha11[1];
        Bit#(2) ha12 = hadd(inPP[3][10], inPP[4][9]);
        s1[1] = ha12[0]; c1[1] = ha12[1];
        Bit#(2) ha13 = hadd(inPP[6][8], inPP[7][7]);
        s1[2] = ha13[0]; c1[2] = ha13[1];
        Bit#(2) ha14 = hadd(inPP[9][6], inPP[10][5]);
        s1[3] = ha14[0]; c1[3] = ha14[1];
        Bit#(2) ha15 = hadd(inPP[10][6], inPP[11][5]);
        s1[4] = ha15[0]; c1[4] = ha15[1];
   
        //STAGE 1: FULL ADDERS
        Bit#(2) fa11 = fadd(inPP[0][13], inPP[1][12], inPP[2][11]);
        s1[5] = fa11[0]; c1[5] = fa11[1];

        Bit#(2) fa12 = fadd(inPP[0][14], inPP[1][13], inPP[2][12]);
        s1[6] = fa12[0]; c1[6] = fa12[1];
        Bit#(2) fa13 = fadd(inPP[3][11], inPP[4][10], inPP[5][9]);
        s1[7] = fa13[0]; c1[7] = fa13[1];
        
        Bit#(2) fa14 = fadd(inPP[0][15], inPP[1][14], inPP[2][13]);
        s1[8] = fa14[0]; c1[8] = fa14[1];
        Bit#(2) fa15 = fadd(inPP[3][12], inPP[4][11], inPP[5][10]);
        s1[9] = fa15[0]; c1[9] = fa15[1];
        Bit#(2) fa16 = fadd(inPP[6][9], inPP[7][8], inPP[8][7]);
        s1[10] = fa16[0]; c1[10] = fa16[1];

        Bit#(2) fa17 = fadd(inPP[1][15], inPP[2][14], inPP[3][13]);
        s1[11] = fa17[0]; c1[11] = fa17[1];
        Bit#(2) fa18 = fadd(inPP[4][12], inPP[5][11], inPP[6][10]);
        s1[12] = fa18[0]; c1[12] = fa18[1];
        Bit#(2) fa19 = fadd(inPP[7][9], inPP[8][8], inPP[9][7]);
        s1[13] = fa19[0]; c1[13] = fa19[1];

        Bit#(2) fa110 = fadd(inPP[2][15], inPP[3][14], inPP[4][13]);
        s1[14] = fa110[0]; c1[14] = fa110[1];
        Bit#(2) fa111 = fadd(inPP[5][12], inPP[6][11], inPP[7][10]);
        s1[15] = fa111[0]; c1[15] = fa111[1];
        Bit#(2) fa112 = fadd(inPP[8][9], inPP[9][8], inPP[10][7]);
        s1[16] = fa112[0]; c1[16] = fa112[1];

        Bit#(2) fa113 = fadd(inPP[3][15], inPP[4][14], inPP[5][13]);
        s1[17] = fa113[0]; c1[17] = fa113[1];
        Bit#(2) fa114 = fadd(inPP[6][12], inPP[7][11], inPP[8][10]);
        s1[18] = fa114[0]; c1[18] = fa114[1];

        Bit#(2) fa115 = fadd(inPP[4][15], inPP[5][14], inPP[6][13]);
        s1[19] = fa115[0]; c1[19] = fa115[1];


        //STAGE 2: HALF ADDERS
        Bit#(2) ha21 = hadd(inPP[0][9], inPP[1][8]);
        s2[0] = ha21[0]; c2[0] = ha21[1];
        Bit#(2) ha22 = hadd(inPP[3][7], inPP[4][6]);
        s2[1] = ha22[0]; c2[1] = ha22[1];
        Bit#(2) ha23 = hadd(inPP[6][5], inPP[7][4]);
        s2[2] = ha23[0]; c2[2] = ha23[1];

        //STAGE 2: FULL ADDERS
        Bit#(2) fa21 = fadd(inPP[0][10], inPP[1][9], inPP[2][8]);
        s2[3] = fa21[0]; c2[3] = fa21[1];

        Bit#(2) fa22 = fadd(inPP[0][11], inPP[1][10], inPP[2][9]);
        s2[4] = fa22[0]; c2[4] = fa22[1];
        Bit#(2) fa23 = fadd(inPP[3][8], inPP[4][7], inPP[5][6]);
        s2[5] = fa23[0]; c2[5] = fa23[1];

        Bit#(2) fa24 = fadd(inPP[2][10], inPP[3][9], inPP[4][8]);
        s2[6] = fa24[0]; c2[6] = fa24[1];
        Bit#(2) fa25 = fadd(inPP[5][7], inPP[6][6], inPP[7][5]);
        s2[7] = fa25[0]; c2[7] = fa25[1];
        Bit#(2) fa26 = fadd(inPP[8][4], inPP[9][3], inPP[10][2]);
        s2[8] = fa26[0]; c2[8] = fa26[1];

        Bit#(2) fa27 = fadd(inPP[5][8], inPP[6][7], inPP[7][6]);
        s2[9] = fa27[0]; c2[9] = fa27[1];
        Bit#(2) fa28 = fadd(inPP[8][5], inPP[9][4], inPP[10][3]);
        s2[10] = fa28[0]; c2[10] = fa28[1];
        Bit#(2) fa29 = fadd(inPP[11][2], inPP[12][1], inPP[13][0]);
        s2[11] = fa29[0]; c2[11] = fa29[1];

        Bit#(2) fa210 = fadd(inPP[8][6], s1[2], s1[7]);
        s2[12] = fa210[0]; c2[12] = fa210[1];
        Bit#(2) fa211 = fadd(inPP[9][5], inPP[10][4], inPP[11][3]);
        s2[13] = fa211[0]; c2[13] = fa211[1];
        Bit#(2) fa212 = fadd(inPP[12][2], inPP[13][1], inPP[14][0]);
        s2[14] = fa212[0]; c2[14] = fa212[1];

        Bit#(2) fa213 = fadd(s1[8], s1[9], s1[10]);
        s2[15] = fa213[0]; c2[15] = fa213[1];
        Bit#(2) fa214 = fadd(s1[3], inPP[11][4], inPP[12][3]);
        s2[16] = fa214[0]; c2[16] = fa214[1];
        Bit#(2) fa215 = fadd(inPP[13][2], inPP[14][1], inPP[15][0]);
        s2[17] = fa215[0]; c2[17] = fa215[1];

        Bit#(2) fa216 = fadd(c1[3], s1[11], s1[12]);
        s2[18] = fa216[0]; c2[18] = fa216[1];
        Bit#(2) fa217 = fadd(s1[13], s1[4], inPP[12][4]);
        s2[19] = fa217[0]; c2[19] = fa217[1];
        Bit#(2) fa218 = fadd(inPP[13][3], inPP[14][2], inPP[15][1]);
        s2[20] = fa218[0]; c2[20] = fa218[1];

        Bit#(2) fa219 = fadd(c1[4], s1[14], s1[15]);
        s2[21] = fa219[0]; c2[21] = fa219[1];
        Bit#(2) fa220 = fadd(s1[16], inPP[11][6], inPP[12][5]);
        s2[22] = fa220[0]; c2[22] = fa220[1];
        Bit#(2) fa221 = fadd(inPP[13][4], inPP[14][3], inPP[15][2]);
        s2[23] = fa221[0]; c2[23] = fa221[1];

        Bit#(2) fa222 = fadd(inPP[9][9], s1[17], s1[18]);
        s2[24] = fa222[0]; c2[24] = fa222[1];
        Bit#(2) fa223 = fadd(inPP[10][8], inPP[11][7], inPP[12][6]);
        s2[25] = fa223[0]; c2[25] = fa223[1];
        Bit#(2) fa224 = fadd(inPP[13][5], inPP[14][4], inPP[15][3]);
        s2[26] = fa224[0]; c2[26] = fa224[1];
   
        Bit#(2) fa225 = fadd(inPP[7][12], inPP[8][11], inPP[9][10]);
        s2[27] = fa225[0]; c2[27] = fa225[1];
        Bit#(2) fa226 = fadd(inPP[10][9], inPP[11][8], inPP[12][7]);
        s2[28] = fa226[0]; c2[28] = fa226[1];
        Bit#(2) fa227 = fadd(inPP[13][6], inPP[14][5], inPP[15][4]);
        s2[29] = fa227[0]; c2[29] = fa227[1];

        Bit#(2) fa228 = fadd(inPP[7][13], inPP[8][12], inPP[9][11]);
        s2[30] = fa228[0]; c2[30] = fa228[1];
        Bit#(2) fa229 = fadd(inPP[10][10], inPP[11][9], inPP[12][8]);
        s2[31] = fa229[0]; c2[31] = fa229[1];
        Bit#(2) fa230 = fadd(inPP[13][7], inPP[14][6], inPP[15][5]);
        s2[32] = fa230[0]; c2[32] = fa230[1];

        Bit#(2) fa231 = fadd(inPP[10][11], inPP[11][10], inPP[12][9]);
        s2[33] = fa231[0]; c2[33] = fa231[1];
        Bit#(2) fa232 = fadd(inPP[13][8], inPP[14][7], inPP[15][6]);
        s2[34] = fa232[0]; c2[34] = fa232[1];

        Bit#(2) fa233 = fadd(inPP[13][9], inPP[14][8], inPP[15][7]);
        s2[35] = fa233[0]; c2[35] = fa233[1];

        //STAGE 3: HALF ADDERS
        Bit#(2) ha31 = hadd(inPP[0][6], inPP[1][5]);
        s3[0] = ha31[0]; c3[0] = ha31[1];
        Bit#(2) ha32 = hadd(inPP[3][4], inPP[4][3]);
        s3[1] = ha32[0]; c3[1] = ha32[1];
        Bit#(2) ha33 = hadd(inPP[6][2], inPP[7][1]);
        s3[2] = ha33[0]; c3[2] = ha33[1];

        //STAGE 3: FULL ADDERS
        Bit#(2) fa31 = fadd(inPP[0][7], inPP[1][6], inPP[2][5]);
        s3[3] = fa31[0]; c3[3] = fa31[1];

        Bit#(2) fa32 = fadd(inPP[0][8], inPP[1][7], inPP[2][6]);
        s3[4] = fa32[0]; c3[4] = fa32[1];
        Bit#(2) fa33 = fadd(inPP[3][5], inPP[4][4], inPP[5][3]);
        s3[5] = fa33[0]; c3[5] = fa33[1];

        Bit#(2) fa34 = fadd(s2[0], inPP[2][7], inPP[3][6]);
		s3[6] = fa34[0]; c3[6] = fa34[1];
		Bit#(2) fa35 = fadd(inPP[4][5], inPP[5][4], inPP[6][3]);
		s3[7] = fa35[0]; c3[7] = fa35[1];
		Bit#(2) fa36 = fadd(inPP[7][2], inPP[8][1], inPP[9][0]);
		s3[8] = fa36[0]; c3[8] = fa36[1];

		Bit#(2) fa37 = fadd(c2[0], s2[3], s2[1]);
		s3[9] = fa37[0]; c3[9] = fa37[1];
		Bit#(2) fa38 = fadd(inPP[5][5], inPP[6][4], inPP[7][3]);
		s3[10] = fa38[0]; c3[10] = fa38[1];
		Bit#(2) fa39 = fadd(inPP[8][2], inPP[9][1], inPP[10][0]);
		s3[11] = fa39[0]; c3[11] = fa39[1];

		Bit#(2) fa310 = fadd(c2[3], c2[1], s2[4]);
		s3[12] = fa310[0]; c3[12] = fa310[1];
		Bit#(2) fa311 = fadd(s2[5], s2[2], inPP[8][3]);
		s3[13] = fa311[0]; c3[13] = fa311[1];
		Bit#(2) fa312 = fadd(inPP[9][2], inPP[10][1], inPP[11][0]);
		s3[14] = fa312[0]; c3[14] = fa312[1];

		Bit#(2) fa313 = fadd(c2[4], c2[5], c2[2]);
		s3[15] = fa313[0]; c3[15] = fa313[1];
		Bit#(2) fa314 = fadd(s1[0], s2[6], s2[7]);
		s3[16] = fa314[0]; c3[16] = fa314[1];
		Bit#(2) fa315 = fadd(s2[8], inPP[11][1], inPP[12][0]);
		s3[17] = fa315[0]; c3[17] = fa315[1];

		Bit#(2) fa316 = fadd(c2[6], c2[7], c2[8]);
		s3[18] = fa316[0]; c3[18] = fa316[1];
		Bit#(2) fa317 = fadd(c1[0], s1[5], s1[1]);
		s3[19] = fa317[0]; c3[19] = fa317[1];
		Bit#(2) fa318 = fadd(s2[9], s2[10], s2[11]);
		s3[20] = fa318[0]; c3[20] = fa318[1];

		Bit#(2) fa319 = fadd(c2[9], c2[10], c2[11]);
		s3[21] = fa319[0]; c3[21] = fa319[1];
		Bit#(2) fa320 = fadd(c1[5], c1[1], s1[6]);
		s3[22] = fa320[0]; c3[22] = fa320[1];
		Bit#(2) fa321 = fadd(s2[12], s2[13], s2[14]);
		s3[23] = fa321[0]; c3[23] = fa321[1];

		Bit#(2) fa322 = fadd(c2[12], c2[13], c2[14]);
		s3[24] = fa322[0]; c3[24] = fa322[1];
		Bit#(2) fa323 = fadd(c1[6], c1[7], c1[2]);
		s3[25] = fa323[0]; c3[25] = fa323[1];
		Bit#(2) fa324 = fadd(s2[15], s2[16], s2[17]);
		s3[26] = fa324[0]; c3[26] = fa324[1];

		Bit#(2) fa325 = fadd(c2[15], c2[16], c2[17]);
		s3[27] = fa325[0]; c3[27] = fa325[1];
		Bit#(2) fa326 = fadd(c1[8], c1[9], c1[10]);
		s3[28] = fa326[0]; c3[28] = fa326[1];
		Bit#(2) fa327 = fadd(s2[18], s2[19], s2[20]);
		s3[29] = fa327[0]; c3[29] = fa327[1];

		Bit#(2) fa328 = fadd(c2[18], c2[19], c2[20]);
		s3[30] = fa328[0]; c3[30] = fa328[1];
		Bit#(2) fa329 = fadd(c1[11], c1[12], c1[13]);
		s3[31] = fa329[0]; c3[31] = fa329[1];
		Bit#(2) fa330 = fadd(s2[21], s2[22], s2[23]);
		s3[32] = fa330[0]; c3[32] = fa330[1];

		Bit#(2) fa331 = fadd(c2[21], c2[22], c2[23]);
		s3[33] = fa331[0]; c3[33] = fa331[1];
		Bit#(2) fa332 = fadd(c1[14], c1[15], c1[16]);
		s3[34] = fa332[0]; c3[34] = fa332[1];
		Bit#(2) fa333 = fadd(s2[24], s2[25], s2[26]);
		s3[35] = fa333[0]; c3[35] = fa333[1];

		Bit#(2) fa334 = fadd(c2[24], c2[25], c2[26]);
		s3[36] = fa334[0]; c3[36] = fa334[1];
		Bit#(2) fa335 = fadd(c1[17], c1[18], s1[19]);
		s3[37] = fa335[0]; c3[37] = fa335[1];
		Bit#(2) fa336 = fadd(s2[27], s2[28], s2[29]);
		s3[38] = fa336[0]; c3[38] = fa336[1];

		Bit#(2) fa337 = fadd(c2[27], c2[28], c2[29]);
		s3[39] = fa337[0]; c3[39] = fa337[1];
		Bit#(2) fa338 = fadd(c1[19], inPP[5][15], inPP[6][14]);
		s3[40] = fa338[0]; c3[40] = fa338[1];
		Bit#(2) fa339 = fadd(s2[30], s2[31], s2[32]);
		s3[41] = fa339[0]; c3[41] = fa339[1];

		Bit#(2) fa340 = fadd(c2[30], c2[31], c2[32]);
		s3[42] = fa340[0]; c3[42] = fa340[1];
		Bit#(2) fa341 = fadd(inPP[6][15], inPP[7][14], inPP[8][13]);
		s3[43] = fa341[0]; c3[43] = fa341[1];
		Bit#(2) fa342 = fadd(inPP[9][12], s2[33], s2[34]);
		s3[44] = fa342[0]; c3[44] = fa342[1];

		Bit#(2) fa343 = fadd(c2[33], c2[34], inPP[7][15]);
		s3[45] = fa343[0]; c3[45] = fa343[1];
		Bit#(2) fa344 = fadd(inPP[8][14], inPP[9][13], inPP[10][12]);
		s3[46] = fa344[0]; c3[46] = fa344[1];
		Bit#(2) fa345 = fadd(inPP[11][11], inPP[12][10], s2[35]);
		s3[47] = fa345[0]; c3[47] = fa345[1];

		Bit#(2) fa346 = fadd(c2[35], inPP[8][15], inPP[9][14]);
		s3[48] = fa346[0]; c3[48] = fa346[1];
		Bit#(2) fa347 = fadd(inPP[10][13], inPP[11][12], inPP[12][11]);
		s3[49] = fa347[0]; c3[49] = fa347[1];
		Bit#(2) fa348 = fadd(inPP[13][10], inPP[14][9], inPP[15][8]);
		s3[50] = fa348[0]; c3[50] = fa348[1];        

        Bit#(2) fa349 = fadd(inPP[9][15], inPP[10][14], inPP[11][13]);
        s3[51] = fa349[0]; c3[51] = fa349[1];
        Bit#(2) fa350 = fadd(inPP[12][12], inPP[13][11], inPP[14][10]);
        s3[52] = fa350[0]; c3[52] = fa350[1];

        Bit#(2) fa351 = fadd(inPP[10][15], inPP[11][14], inPP[12][13]);
        s3[53] = fa351[0]; c3[53] = fa351[1];

        //STAGE 4: HALF ADDERS
        Bit#(2) ha41 = hadd(inPP[0][4], inPP[1][3]);
        s4[0] = ha41[0]; c4[0] = ha41[1];
        Bit#(2) ha42 = hadd(inPP[3][2], inPP[4][1]);
        s4[1] = ha42[0]; c4[1] = ha42[1];

        //STAGE 4: FULL ADDERS
        Bit#(2) fa41 = fadd(inPP[0][5], inPP[1][4], inPP[2][3]);
		s4[2] = fa41[0]; c4[2] = fa41[1];

        Bit#(2) fa42 = fadd(s3[0], inPP[2][4], inPP[3][3]);
		s4[3] = fa42[0]; c4[3] = fa42[1];
		Bit#(2) fa43 = fadd(inPP[4][2], inPP[5][1], inPP[6][0]);
		s4[4] = fa43[0]; c4[4] = fa43[1];

		Bit#(2) fa44 = fadd(c3[0], s3[3], s3[1]);
		s4[5] = fa44[0]; c4[5] = fa44[1];
		Bit#(2) fa45 = fadd(inPP[5][2], inPP[6][1], inPP[7][0]);
		s4[6] = fa45[0]; c4[6] = fa45[1];

		Bit#(2) fa46 = fadd(c3[3], c3[1], s3[4]);
		s4[7] = fa46[0]; c4[7] = fa46[1];
		Bit#(2) fa47 = fadd(s3[5], s3[2], inPP[8][0]);
		s4[8] = fa47[0]; c4[8] = fa47[1];

		Bit#(2) fa48 = fadd(c3[4], c3[5], c3[2]);
		s4[9] = fa48[0]; c4[9] = fa48[1];
		Bit#(2) fa49 = fadd(s3[6], s3[7], s3[8]);
		s4[10] = fa49[0]; c4[10] = fa49[1];

		Bit#(2) fa410 = fadd(c3[6], c3[7], c3[8]);
		s4[11] = fa410[0]; c4[11] = fa410[1];
		Bit#(2) fa411 = fadd(s3[9], s3[10], s3[11]);
		s4[12] = fa411[0]; c4[12] = fa411[1];

		Bit#(2) fa412 = fadd(c3[9], c3[10], c3[11]);
		s4[13] = fa412[0]; c4[13] = fa412[1];
		Bit#(2) fa413 = fadd(s3[12], s3[13], s3[14]);
		s4[14] = fa413[0]; c4[14] = fa413[1];

		Bit#(2) fa414 = fadd(c3[12], c3[13], c3[14]);
		s4[15] = fa414[0]; c4[15] = fa414[1];
		Bit#(2) fa415 = fadd(s3[15], s3[16], s3[17]);
		s4[16] = fa415[0]; c4[16] = fa415[1];

		Bit#(2) fa416 = fadd(c3[15], c3[16], c3[17]);
		s4[17] = fa416[0]; c4[17] = fa416[1];
		Bit#(2) fa417 = fadd(s3[18], s3[19], s3[20]);
		s4[18] = fa417[0]; c4[18] = fa417[1];

		Bit#(2) fa418 = fadd(c3[18], c3[19], c3[20]);
		s4[19] = fa418[0]; c4[19] = fa418[1];
		Bit#(2) fa419 = fadd(s3[21], s3[22], s3[23]);
		s4[20] = fa419[0]; c4[20] = fa419[1];

		Bit#(2) fa420 = fadd(c3[21], c3[22], c3[23]);
		s4[21] = fa420[0]; c4[21] = fa420[1];
		Bit#(2) fa421 = fadd(s3[24], s3[25], s3[26]);
		s4[22] = fa421[0]; c4[22] = fa421[1];

		Bit#(2) fa422 = fadd(c3[24], c3[25], c3[26]);
		s4[23] = fa422[0]; c4[23] = fa422[1];
		Bit#(2) fa423 = fadd(s3[27], s3[28], s3[29]);
		s4[24] = fa423[0]; c4[24] = fa423[1];

		Bit#(2) fa424 = fadd(c3[27], c3[28], c3[29]);
		s4[25] = fa424[0]; c4[25] = fa424[1];
		Bit#(2) fa425 = fadd(s3[30], s3[31], s3[32]);
		s4[26] = fa425[0]; c4[26] = fa425[1];

		Bit#(2) fa426 = fadd(c3[30], c3[31], c3[32]);
		s4[27] = fa426[0]; c4[27] = fa426[1];
		Bit#(2) fa427 = fadd(s3[33], s3[34], s3[35]);
		s4[28] = fa427[0]; c4[28] = fa427[1];

		Bit#(2) fa428 = fadd(c3[33], c3[34], c3[35]);
		s4[29] = fa428[0]; c4[29] = fa428[1];
		Bit#(2) fa429 = fadd(s3[36], s3[37], s3[38]);
		s4[30] = fa429[0]; c4[30] = fa429[1];

		Bit#(2) fa430 = fadd(c3[36], c3[37], c3[38]);
		s4[31] = fa430[0]; c4[31] = fa430[1];
		Bit#(2) fa431 = fadd(s3[39], s3[40], s3[41]);
		s4[32] = fa431[0]; c4[32] = fa431[1];

		Bit#(2) fa432 = fadd(c3[39], c3[40], c3[41]);
		s4[33] = fa432[0]; c4[33] = fa432[1];
		Bit#(2) fa433 = fadd(s3[42], s3[43], s3[44]);
		s4[34] = fa433[0]; c4[34] = fa433[1];

		Bit#(2) fa434 = fadd(c3[42], c3[43], c3[44]);
		s4[35] = fa434[0]; c4[35] = fa434[1];
		Bit#(2) fa435 = fadd(s3[45], s3[46], s3[47]);
		s4[36] = fa435[0]; c4[36] = fa435[1];

		Bit#(2) fa436 = fadd(c3[45], c3[46], c3[47]);
		s4[37] = fa436[0]; c4[37] = fa436[1];
		Bit#(2) fa437 = fadd(s3[48], s3[49], s3[50]);
		s4[38] = fa437[0]; c4[38] = fa437[1];

		Bit#(2) fa438 = fadd(c3[48], c3[49], c3[50]);
		s4[39] = fa438[0]; c4[39] = fa438[1];
		Bit#(2) fa439 = fadd(s3[51], s3[52], inPP[15][9]);
		s4[40] = fa439[0]; c4[40] = fa439[1];

		Bit#(2) fa440 = fadd(c3[51], c3[52], s3[53]);
		s4[41] = fa440[0]; c4[41] = fa440[1];
		Bit#(2) fa441 = fadd(inPP[13][12], inPP[14][11], inPP[15][10]);
		s4[42] = fa441[0]; c4[42] = fa441[1];

		Bit#(2) fa442 = fadd(c3[53], inPP[11][15], inPP[12][14]);
		s4[43] = fa442[0]; c4[43] = fa442[1];
		Bit#(2) fa443 = fadd(inPP[13][13], inPP[14][12], inPP[15][11]);
		s4[44] = fa443[0]; c4[44] = fa443[1];

        Bit#(2) fa444 = fadd(inPP[12][15], inPP[13][14], inPP[14][13]);
		s4[45] = fa444[0]; c4[45] = fa444[1];

        //STAGE 5: HALF ADDERS
        Bit#(2) ha51 = hadd(inPP[0][3], inPP[1][2]);
        s5[0] = ha51[0]; c5[0] = ha51[1];

        //STAGE 5: FULL ADDERS

        Bit#(2) fa51 = fadd(inPP[2][2], inPP[3][1], inPP[4][0]);
		s5[1] = fa51[0]; c5[1] = fa51[1];

		Bit#(2) fa52 = fadd(s4[2], s4[1], inPP[5][0]);
		s5[2] = fa52[0]; c5[2] = fa52[1];

		Bit#(2) fa53 = fadd(c4[2], s4[3], s4[4]);
		s5[3] = fa53[0]; c5[3] = fa53[1];

		Bit#(2) fa54 = fadd(c4[4], s4[5], s4[6]);
		s5[4] = fa54[0]; c5[4] = fa54[1];

		Bit#(2) fa55 = fadd(c4[6], s4[7], s4[8]);
		s5[5] = fa55[0]; c5[5] = fa55[1];

		Bit#(2) fa56 = fadd(c4[8], s4[9], s4[10]);
		s5[6] = fa56[0]; c5[6] = fa56[1];

		Bit#(2) fa57 = fadd(c4[10], s4[11], s4[12]);
		s5[7] = fa57[0]; c5[7] = fa57[1];

		Bit#(2) fa58 = fadd(c4[12], s4[13], s4[14]);
		s5[8] = fa58[0]; c5[8] = fa58[1];

		Bit#(2) fa59 = fadd(c4[14], s4[15], s4[16]);
		s5[9] = fa59[0]; c5[9] = fa59[1];

		Bit#(2) fa510 = fadd(c4[16], s4[17], s4[18]);
		s5[10] = fa510[0]; c5[10] = fa510[1];

		Bit#(2) fa511 = fadd(c4[18], s4[19], s4[20]);
		s5[11] = fa511[0]; c5[11] = fa511[1];

		Bit#(2) fa512 = fadd(c4[20], s4[21], s4[22]);
		s5[12] = fa512[0]; c5[12] = fa512[1];

		Bit#(2) fa513 = fadd(c4[22], s4[23], s4[24]);
		s5[13] = fa513[0]; c5[13] = fa513[1];

		Bit#(2) fa514 = fadd(c4[24], s4[25], s4[26]);
		s5[14] = fa514[0]; c5[14] = fa514[1];

		Bit#(2) fa515 = fadd(c4[26], s4[27], s4[28]);
		s5[15] = fa515[0]; c5[15] = fa515[1];

		Bit#(2) fa516 = fadd(c4[28], s4[29], s4[30]);
		s5[16] = fa516[0]; c5[16] = fa516[1];

		Bit#(2) fa517 = fadd(c4[30], s4[31], s4[32]);
		s5[17] = fa517[0]; c5[17] = fa517[1];

		Bit#(2) fa518 = fadd(c4[32], s4[33], s4[34]);
		s5[18] = fa518[0]; c5[18] = fa518[1];

		Bit#(2) fa519 = fadd(c4[34], s4[35], s4[36]);
		s5[19] = fa519[0]; c5[19] = fa519[1];

		Bit#(2) fa520 = fadd(c4[36], s4[37], s4[38]);
		s5[20] = fa520[0]; c5[20] = fa520[1];

		Bit#(2) fa521 = fadd(c4[38], s4[39], s4[40]);
		s5[21] = fa521[0]; c5[21] = fa521[1];

		Bit#(2) fa522 = fadd(c4[40], s4[41], s4[42]);
		s5[22] = fa522[0]; c5[22] = fa522[1];

		Bit#(2) fa523 = fadd(c4[42], s4[43], s4[44]);
		s5[23] = fa523[0]; c5[23] = fa523[1];

		Bit#(2) fa524 = fadd(c4[44], s4[45], inPP[15][12]);
		s5[24] = fa524[0]; c5[24] = fa524[1];

		Bit#(2) fa525 = fadd(inPP[13][15], inPP[14][14], inPP[15][13]);
		s5[25] = fa525[0]; c5[25] = fa525[1];

        //STAGE 6: HALF ADDERS
        Bit#(2) ha61 = hadd(inPP[0][2], inPP[1][1]);
        s6[0] = ha61[0]; c6[0] = ha61[1];

        //STAGE 6: FULL ADDERS
		Bit#(2) fa61 = fadd(s5[0], inPP[2][1], inPP[3][0]);
		s6[1] = fa61[0]; c6[1] = fa61[1];

		Bit#(2) fa62 = fadd(c5[0], s4[0], s5[1]);
		s6[2] = fa62[0]; c6[2] = fa62[1];

		Bit#(2) fa63 = fadd(c5[1], c4[0], s5[2]);
		s6[3] = fa63[0]; c6[3] = fa63[1];

		Bit#(2) fa64 = fadd(c5[2], c4[1], s5[3]);
		s6[4] = fa64[0]; c6[4] = fa64[1];

		Bit#(2) fa65 = fadd(c5[3], c4[3], s5[4]);
		s6[5] = fa65[0]; c6[5] = fa65[1];

		Bit#(2) fa66 = fadd(c5[4], c4[5], s5[5]);
		s6[6] = fa66[0]; c6[6] = fa66[1];

		Bit#(2) fa67 = fadd(c5[5], c4[7], s5[6]);
		s6[7] = fa67[0]; c6[7] = fa67[1];

		Bit#(2) fa68 = fadd(c5[6], c4[9], s5[7]);
		s6[8] = fa68[0]; c6[8] = fa68[1];

		Bit#(2) fa69 = fadd(c5[7], c4[11], s5[8]);
		s6[9] = fa69[0]; c6[9] = fa69[1];

		Bit#(2) fa610 = fadd(c5[8], c4[13], s5[9]);
		s6[10] = fa610[0]; c6[10] = fa610[1];

		Bit#(2) fa611 = fadd(c5[9], c4[15], s5[10]);
		s6[11] = fa611[0]; c6[11] = fa611[1];

		Bit#(2) fa612 = fadd(c5[10], c4[17], s5[11]);
		s6[12] = fa612[0]; c6[12] = fa612[1];

		Bit#(2) fa613 = fadd(c5[11], c4[19], s5[12]);
		s6[13] = fa613[0]; c6[13] = fa613[1];

		Bit#(2) fa614 = fadd(c5[12], c4[21], s5[13]);
		s6[14] = fa614[0]; c6[14] = fa614[1];

		Bit#(2) fa615 = fadd(c5[13], c4[23], s5[14]);
		s6[15] = fa615[0]; c6[15] = fa615[1];

		Bit#(2) fa616 = fadd(c5[14], c4[25], s5[15]);
		s6[16] = fa616[0]; c6[16] = fa616[1];

		Bit#(2) fa617 = fadd(c5[15], c4[27], s5[16]);
		s6[17] = fa617[0]; c6[17] = fa617[1];

		Bit#(2) fa618 = fadd(c5[16], c4[29], s5[17]);
		s6[18] = fa618[0]; c6[18] = fa618[1];

		Bit#(2) fa619 = fadd(c5[17], c4[31], s5[18]);
		s6[19] = fa619[0]; c6[19] = fa619[1];

		Bit#(2) fa620 = fadd(c5[18], c4[33], s5[19]);
		s6[20] = fa620[0]; c6[20] = fa620[1];

		Bit#(2) fa621 = fadd(c5[19], c4[35], s5[20]);
		s6[21] = fa621[0]; c6[21] = fa621[1];

		Bit#(2) fa622 = fadd(c5[20], c4[37], s5[21]);
		s6[22] = fa622[0]; c6[22] = fa622[1];

		Bit#(2) fa623 = fadd(c5[21], c4[39], s5[22]);
		s6[23] = fa623[0]; c6[23] = fa623[1];

		Bit#(2) fa624 = fadd(c5[22], c4[41], s5[23]);
		s6[24] = fa624[0]; c6[24] = fa624[1];

		Bit#(2) fa625 = fadd(c5[23], c4[43], s5[24]);
		s6[25] = fa625[0]; c6[25] = fa625[1];

		Bit#(2) fa626 = fadd(c5[24], c4[45], s5[25]);
		s6[26] = fa626[0]; c6[26] = fa626[1];

		Bit#(2) fa627 = fadd(c5[25], inPP[14][15], inPP[15][14]);
		s6[27] = fa627[0]; c6[27] = fa627[1];

        //FINAL ADDER (31 WIDE)
        Bit#(1) zero = 0;
        return signExtend({zero,c6,s6[0],inPP[0][1],inPP[0][0]}+{zero,inPP[15][15], s6[27:1], inPP[2][0], inPP[1][0], zero});



    endfunction
    
endpackage