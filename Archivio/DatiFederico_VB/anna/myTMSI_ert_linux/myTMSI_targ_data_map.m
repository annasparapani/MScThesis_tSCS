  function targMap = targDataMap(),

  ;%***********************
  ;% Create Parameter Map *
  ;%***********************
      
    nTotData      = 0; %add to this count as we go
    nTotSects     = 3;
    sectIdxOffset = 0;
    
    ;%
    ;% Define dummy sections & preallocate arrays
    ;%
    dumSection.nData = -1;  
    dumSection.data  = [];
    
    dumData.logicalSrcIdx = -1;
    dumData.dtTransOffset = -1;
    
    ;%
    ;% Init/prealloc paramMap
    ;%
    paramMap.nSections           = nTotSects;
    paramMap.sectIdxOffset       = sectIdxOffset;
      paramMap.sections(nTotSects) = dumSection; %prealloc
    paramMap.nTotData            = -1;
    
    ;%
    ;% Auto data (myTMSI_P)
    ;%
      section.nData     = 55;
      section.data(55)  = dumData; %prealloc
      
	  ;% myTMSI_P.Constant10_Value
	  section.data(1).logicalSrcIdx = 0;
	  section.data(1).dtTransOffset = 0;
	
	  ;% myTMSI_P.Constant18_Value
	  section.data(2).logicalSrcIdx = 1;
	  section.data(2).dtTransOffset = 1;
	
	  ;% myTMSI_P.DiscreteFilter4_NumCoef
	  section.data(3).logicalSrcIdx = 2;
	  section.data(3).dtTransOffset = 2;
	
	  ;% myTMSI_P.DiscreteFilter4_DenCoef
	  section.data(4).logicalSrcIdx = 3;
	  section.data(4).dtTransOffset = 6;
	
	  ;% myTMSI_P.DiscreteFilter4_InitialStates
	  section.data(5).logicalSrcIdx = 4;
	  section.data(5).dtTransOffset = 10;
	
	  ;% myTMSI_P.Constant9_Value
	  section.data(6).logicalSrcIdx = 5;
	  section.data(6).dtTransOffset = 11;
	
	  ;% myTMSI_P.Constant8_Value
	  section.data(7).logicalSrcIdx = 6;
	  section.data(7).dtTransOffset = 12;
	
	  ;% myTMSI_P.DiscreteFilter5_NumCoef
	  section.data(8).logicalSrcIdx = 7;
	  section.data(8).dtTransOffset = 13;
	
	  ;% myTMSI_P.DiscreteFilter5_DenCoef
	  section.data(9).logicalSrcIdx = 8;
	  section.data(9).dtTransOffset = 17;
	
	  ;% myTMSI_P.DiscreteFilter5_InitialStates
	  section.data(10).logicalSrcIdx = 9;
	  section.data(10).dtTransOffset = 21;
	
	  ;% myTMSI_P.Constant13_Value
	  section.data(11).logicalSrcIdx = 10;
	  section.data(11).dtTransOffset = 22;
	
	  ;% myTMSI_P.Constant16_Value
	  section.data(12).logicalSrcIdx = 11;
	  section.data(12).dtTransOffset = 23;
	
	  ;% myTMSI_P.DiscreteFilter6_NumCoef
	  section.data(13).logicalSrcIdx = 12;
	  section.data(13).dtTransOffset = 24;
	
	  ;% myTMSI_P.DiscreteFilter6_DenCoef
	  section.data(14).logicalSrcIdx = 13;
	  section.data(14).dtTransOffset = 28;
	
	  ;% myTMSI_P.DiscreteFilter6_InitialStates
	  section.data(15).logicalSrcIdx = 14;
	  section.data(15).dtTransOffset = 32;
	
	  ;% myTMSI_P.Constant12_Value
	  section.data(16).logicalSrcIdx = 15;
	  section.data(16).dtTransOffset = 33;
	
	  ;% myTMSI_P.Constant11_Value
	  section.data(17).logicalSrcIdx = 16;
	  section.data(17).dtTransOffset = 34;
	
	  ;% myTMSI_P.DiscreteFilter7_NumCoef
	  section.data(18).logicalSrcIdx = 17;
	  section.data(18).dtTransOffset = 35;
	
	  ;% myTMSI_P.DiscreteFilter7_DenCoef
	  section.data(19).logicalSrcIdx = 18;
	  section.data(19).dtTransOffset = 39;
	
	  ;% myTMSI_P.DiscreteFilter7_InitialStates
	  section.data(20).logicalSrcIdx = 19;
	  section.data(20).dtTransOffset = 43;
	
	  ;% myTMSI_P.DiscreteFilter2_NumCoef
	  section.data(21).logicalSrcIdx = 20;
	  section.data(21).dtTransOffset = 44;
	
	  ;% myTMSI_P.DiscreteFilter2_DenCoef
	  section.data(22).logicalSrcIdx = 21;
	  section.data(22).dtTransOffset = 48;
	
	  ;% myTMSI_P.DiscreteFilter2_InitialStates
	  section.data(23).logicalSrcIdx = 22;
	  section.data(23).dtTransOffset = 52;
	
	  ;% myTMSI_P.Constant12_Value_e
	  section.data(24).logicalSrcIdx = 23;
	  section.data(24).dtTransOffset = 53;
	
	  ;% myTMSI_P.Constant12_Value_o
	  section.data(25).logicalSrcIdx = 24;
	  section.data(25).dtTransOffset = 54;
	
	  ;% myTMSI_P.DiscreteFilter7_NumCoef_g
	  section.data(26).logicalSrcIdx = 25;
	  section.data(26).dtTransOffset = 55;
	
	  ;% myTMSI_P.DiscreteFilter7_DenCoef_j
	  section.data(27).logicalSrcIdx = 26;
	  section.data(27).dtTransOffset = 59;
	
	  ;% myTMSI_P.DiscreteFilter7_InitialStates_j
	  section.data(28).logicalSrcIdx = 27;
	  section.data(28).dtTransOffset = 63;
	
	  ;% myTMSI_P.DiscreteFilter3_NumCoef
	  section.data(29).logicalSrcIdx = 28;
	  section.data(29).dtTransOffset = 64;
	
	  ;% myTMSI_P.DiscreteFilter3_DenCoef
	  section.data(30).logicalSrcIdx = 29;
	  section.data(30).dtTransOffset = 68;
	
	  ;% myTMSI_P.DiscreteFilter3_InitialStates
	  section.data(31).logicalSrcIdx = 30;
	  section.data(31).dtTransOffset = 72;
	
	  ;% myTMSI_P.Constant12_Value_i
	  section.data(32).logicalSrcIdx = 31;
	  section.data(32).dtTransOffset = 73;
	
	  ;% myTMSI_P.Constant14_Value
	  section.data(33).logicalSrcIdx = 32;
	  section.data(33).dtTransOffset = 74;
	
	  ;% myTMSI_P.DiscreteFilter7_NumCoef_k
	  section.data(34).logicalSrcIdx = 33;
	  section.data(34).dtTransOffset = 75;
	
	  ;% myTMSI_P.DiscreteFilter7_DenCoef_h
	  section.data(35).logicalSrcIdx = 34;
	  section.data(35).dtTransOffset = 79;
	
	  ;% myTMSI_P.DiscreteFilter7_InitialStates_p
	  section.data(36).logicalSrcIdx = 35;
	  section.data(36).dtTransOffset = 83;
	
	  ;% myTMSI_P.DiscreteFilter9_NumCoef
	  section.data(37).logicalSrcIdx = 36;
	  section.data(37).dtTransOffset = 84;
	
	  ;% myTMSI_P.DiscreteFilter9_DenCoef
	  section.data(38).logicalSrcIdx = 37;
	  section.data(38).dtTransOffset = 88;
	
	  ;% myTMSI_P.DiscreteFilter9_InitialStates
	  section.data(39).logicalSrcIdx = 38;
	  section.data(39).dtTransOffset = 92;
	
	  ;% myTMSI_P.Constant12_Value_g
	  section.data(40).logicalSrcIdx = 39;
	  section.data(40).dtTransOffset = 93;
	
	  ;% myTMSI_P.Constant15_Value
	  section.data(41).logicalSrcIdx = 40;
	  section.data(41).dtTransOffset = 94;
	
	  ;% myTMSI_P.DiscreteFilter7_NumCoef_h
	  section.data(42).logicalSrcIdx = 41;
	  section.data(42).dtTransOffset = 95;
	
	  ;% myTMSI_P.DiscreteFilter7_DenCoef_g
	  section.data(43).logicalSrcIdx = 42;
	  section.data(43).dtTransOffset = 99;
	
	  ;% myTMSI_P.DiscreteFilter7_InitialStates_n
	  section.data(44).logicalSrcIdx = 43;
	  section.data(44).dtTransOffset = 103;
	
	  ;% myTMSI_P.DiscreteFilter7_NumCoef_n
	  section.data(45).logicalSrcIdx = 44;
	  section.data(45).dtTransOffset = 104;
	
	  ;% myTMSI_P.DiscreteFilter7_DenCoef_n
	  section.data(46).logicalSrcIdx = 45;
	  section.data(46).dtTransOffset = 108;
	
	  ;% myTMSI_P.DiscreteFilter7_InitialStates_o
	  section.data(47).logicalSrcIdx = 46;
	  section.data(47).dtTransOffset = 112;
	
	  ;% myTMSI_P.Constant12_Value_d
	  section.data(48).logicalSrcIdx = 47;
	  section.data(48).dtTransOffset = 113;
	
	  ;% myTMSI_P.Constant19_Value
	  section.data(49).logicalSrcIdx = 48;
	  section.data(49).dtTransOffset = 114;
	
	  ;% myTMSI_P.DiscreteFilter7_NumCoef_gx
	  section.data(50).logicalSrcIdx = 49;
	  section.data(50).dtTransOffset = 115;
	
	  ;% myTMSI_P.DiscreteFilter7_DenCoef_l
	  section.data(51).logicalSrcIdx = 50;
	  section.data(51).dtTransOffset = 119;
	
	  ;% myTMSI_P.DiscreteFilter7_InitialStates_l
	  section.data(52).logicalSrcIdx = 51;
	  section.data(52).dtTransOffset = 123;
	
	  ;% myTMSI_P.DiscreteFilter8_NumCoef
	  section.data(53).logicalSrcIdx = 52;
	  section.data(53).dtTransOffset = 124;
	
	  ;% myTMSI_P.DiscreteFilter8_DenCoef
	  section.data(54).logicalSrcIdx = 53;
	  section.data(54).dtTransOffset = 128;
	
	  ;% myTMSI_P.DiscreteFilter8_InitialStates
	  section.data(55).logicalSrcIdx = 54;
	  section.data(55).dtTransOffset = 132;
	
      nTotData = nTotData + section.nData;
      paramMap.sections(1) = section;
      clear section
      
      section.nData     = 3;
      section.data(3)  = dumData; %prealloc
      
	  ;% myTMSI_P.TMSI_p2
	  section.data(1).logicalSrcIdx = 55;
	  section.data(1).dtTransOffset = 0;
	
	  ;% myTMSI_P.TMSI_p3
	  section.data(2).logicalSrcIdx = 56;
	  section.data(2).dtTransOffset = 1;
	
	  ;% myTMSI_P.TMSI_p5
	  section.data(3).logicalSrcIdx = 57;
	  section.data(3).dtTransOffset = 2;
	
      nTotData = nTotData + section.nData;
      paramMap.sections(2) = section;
      clear section
      
      section.nData     = 1;
      section.data(1)  = dumData; %prealloc
      
	  ;% myTMSI_P.TMSI_p1
	  section.data(1).logicalSrcIdx = 58;
	  section.data(1).dtTransOffset = 0;
	
      nTotData = nTotData + section.nData;
      paramMap.sections(3) = section;
      clear section
      
    
      ;%
      ;% Non-auto Data (parameter)
      ;%
    

    ;%
    ;% Add final counts to struct.
    ;%
    paramMap.nTotData = nTotData;
    


  ;%**************************
  ;% Create Block Output Map *
  ;%**************************
      
    nTotData      = 0; %add to this count as we go
    nTotSects     = 2;
    sectIdxOffset = 0;
    
    ;%
    ;% Define dummy sections & preallocate arrays
    ;%
    dumSection.nData = -1;  
    dumSection.data  = [];
    
    dumData.logicalSrcIdx = -1;
    dumData.dtTransOffset = -1;
    
    ;%
    ;% Init/prealloc sigMap
    ;%
    sigMap.nSections           = nTotSects;
    sigMap.sectIdxOffset       = sectIdxOffset;
      sigMap.sections(nTotSects) = dumSection; %prealloc
    sigMap.nTotData            = -1;
    
    ;%
    ;% Auto data (myTMSI_B)
    ;%
      section.nData     = 9;
      section.data(9)  = dumData; %prealloc
      
	  ;% myTMSI_B.TMSI_o1
	  section.data(1).logicalSrcIdx = 0;
	  section.data(1).dtTransOffset = 0;
	
	  ;% myTMSI_B.DiscreteFilter4
	  section.data(2).logicalSrcIdx = 1;
	  section.data(2).dtTransOffset = 320;
	
	  ;% myTMSI_B.DiscreteFilter5
	  section.data(3).logicalSrcIdx = 2;
	  section.data(3).dtTransOffset = 321;
	
	  ;% myTMSI_B.DiscreteFilter6
	  section.data(4).logicalSrcIdx = 3;
	  section.data(4).dtTransOffset = 322;
	
	  ;% myTMSI_B.DiscreteFilter2
	  section.data(5).logicalSrcIdx = 4;
	  section.data(5).dtTransOffset = 323;
	
	  ;% myTMSI_B.DiscreteFilter3
	  section.data(6).logicalSrcIdx = 5;
	  section.data(6).dtTransOffset = 324;
	
	  ;% myTMSI_B.DiscreteFilter9
	  section.data(7).logicalSrcIdx = 6;
	  section.data(7).dtTransOffset = 325;
	
	  ;% myTMSI_B.DiscreteFilter7
	  section.data(8).logicalSrcIdx = 7;
	  section.data(8).dtTransOffset = 326;
	
	  ;% myTMSI_B.DiscreteFilter8
	  section.data(9).logicalSrcIdx = 8;
	  section.data(9).dtTransOffset = 327;
	
      nTotData = nTotData + section.nData;
      sigMap.sections(1) = section;
      clear section
      
      section.nData     = 1;
      section.data(1)  = dumData; %prealloc
      
	  ;% myTMSI_B.TMSI_o2
	  section.data(1).logicalSrcIdx = 9;
	  section.data(1).dtTransOffset = 0;
	
      nTotData = nTotData + section.nData;
      sigMap.sections(2) = section;
      clear section
      
    
      ;%
      ;% Non-auto Data (signal)
      ;%
    

    ;%
    ;% Add final counts to struct.
    ;%
    sigMap.nTotData = nTotData;
    


  ;%*******************
  ;% Create DWork Map *
  ;%*******************
      
    nTotData      = 0; %add to this count as we go
    nTotSects     = 2;
    sectIdxOffset = 2;
    
    ;%
    ;% Define dummy sections & preallocate arrays
    ;%
    dumSection.nData = -1;  
    dumSection.data  = [];
    
    dumData.logicalSrcIdx = -1;
    dumData.dtTransOffset = -1;
    
    ;%
    ;% Init/prealloc dworkMap
    ;%
    dworkMap.nSections           = nTotSects;
    dworkMap.sectIdxOffset       = sectIdxOffset;
      dworkMap.sections(nTotSects) = dumSection; %prealloc
    dworkMap.nTotData            = -1;
    
    ;%
    ;% Auto data (myTMSI_DWork)
    ;%
      section.nData     = 13;
      section.data(13)  = dumData; %prealloc
      
	  ;% myTMSI_DWork.DiscreteFilter4_states
	  section.data(1).logicalSrcIdx = 0;
	  section.data(1).dtTransOffset = 0;
	
	  ;% myTMSI_DWork.DiscreteFilter5_states
	  section.data(2).logicalSrcIdx = 1;
	  section.data(2).dtTransOffset = 3;
	
	  ;% myTMSI_DWork.DiscreteFilter6_states
	  section.data(3).logicalSrcIdx = 2;
	  section.data(3).dtTransOffset = 6;
	
	  ;% myTMSI_DWork.DiscreteFilter7_states
	  section.data(4).logicalSrcIdx = 3;
	  section.data(4).dtTransOffset = 9;
	
	  ;% myTMSI_DWork.DiscreteFilter2_states
	  section.data(5).logicalSrcIdx = 4;
	  section.data(5).dtTransOffset = 12;
	
	  ;% myTMSI_DWork.DiscreteFilter7_states_m
	  section.data(6).logicalSrcIdx = 5;
	  section.data(6).dtTransOffset = 15;
	
	  ;% myTMSI_DWork.DiscreteFilter3_states
	  section.data(7).logicalSrcIdx = 6;
	  section.data(7).dtTransOffset = 18;
	
	  ;% myTMSI_DWork.DiscreteFilter7_states_k
	  section.data(8).logicalSrcIdx = 7;
	  section.data(8).dtTransOffset = 21;
	
	  ;% myTMSI_DWork.DiscreteFilter9_states
	  section.data(9).logicalSrcIdx = 8;
	  section.data(9).dtTransOffset = 24;
	
	  ;% myTMSI_DWork.DiscreteFilter7_states_h
	  section.data(10).logicalSrcIdx = 9;
	  section.data(10).dtTransOffset = 27;
	
	  ;% myTMSI_DWork.DiscreteFilter7_states_i
	  section.data(11).logicalSrcIdx = 10;
	  section.data(11).dtTransOffset = 30;
	
	  ;% myTMSI_DWork.DiscreteFilter7_states_kj
	  section.data(12).logicalSrcIdx = 11;
	  section.data(12).dtTransOffset = 33;
	
	  ;% myTMSI_DWork.DiscreteFilter8_states
	  section.data(13).logicalSrcIdx = 12;
	  section.data(13).dtTransOffset = 36;
	
      nTotData = nTotData + section.nData;
      dworkMap.sections(1) = section;
      clear section
      
      section.nData     = 6;
      section.data(6)  = dumData; %prealloc
      
	  ;% myTMSI_DWork.TMSI_PWORK
	  section.data(1).logicalSrcIdx = 26;
	  section.data(1).dtTransOffset = 0;
	
	  ;% myTMSI_DWork.EMG1_PWORK.LoggedData
	  section.data(2).logicalSrcIdx = 27;
	  section.data(2).dtTransOffset = 1;
	
	  ;% myTMSI_DWork.EMG3_PWORK.LoggedData
	  section.data(3).logicalSrcIdx = 28;
	  section.data(3).dtTransOffset = 5;
	
	  ;% myTMSI_DWork.EMGcount_PWORK.LoggedData
	  section.data(4).logicalSrcIdx = 29;
	  section.data(4).dtTransOffset = 9;
	
	  ;% myTMSI_DWork.ToWorkspaceEMG_PWORK.LoggedData
	  section.data(5).logicalSrcIdx = 30;
	  section.data(5).dtTransOffset = 10;
	
	  ;% myTMSI_DWork.ToWorkspaceEMGcount_PWORK.LoggedData
	  section.data(6).logicalSrcIdx = 31;
	  section.data(6).dtTransOffset = 11;
	
      nTotData = nTotData + section.nData;
      dworkMap.sections(2) = section;
      clear section
      
    
      ;%
      ;% Non-auto Data (dwork)
      ;%
    

    ;%
    ;% Add final counts to struct.
    ;%
    dworkMap.nTotData = nTotData;
    


  ;%
  ;% Add individual maps to base struct.
  ;%

  targMap.paramMap  = paramMap;    
  targMap.signalMap = sigMap;
  targMap.dworkMap  = dworkMap;
  
  ;%
  ;% Add checksums to base struct.
  ;%


  targMap.checksum0 = 2009393086;
  targMap.checksum1 = 2995121225;
  targMap.checksum2 = 1703715540;
  targMap.checksum3 = 4197625414;

