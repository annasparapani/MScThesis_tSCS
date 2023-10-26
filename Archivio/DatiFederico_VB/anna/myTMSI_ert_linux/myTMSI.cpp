//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// File: myTMSI.cpp
//
// Code generated for Simulink model 'myTMSI'.
//
// Model version                  : 1.571
// Simulink Coder version         : 8.13 (R2017b) 24-Jul-2017
// C/C++ source code generated on : Thu Oct 26 12:18:12 2023
//
// Target selection: ert_linux.tlc
// Embedded hardware selection: 32-bit Generic
// Code generation objectives: Unspecified
// Validation result: Not run
//
#include "myTMSI.h"
#include "myTMSI_private.h"
#include "myTMSI_dt.h"

// Block signals (auto storage)
BlockIO_myTMSI myTMSI_B;

// Block states (auto storage)
D_Work_myTMSI myTMSI_DWork;

// Real-time model
RT_MODEL_myTMSI myTMSI_M_;
RT_MODEL_myTMSI *const myTMSI_M = &myTMSI_M_;

// Model step function
void myTMSI_step(void)
{
  int32_T j;
  int32_T memOffset;
  real_T rtb_VariableSelector5[20];
  real_T DiscreteFilter4_tmp;
  real_T DiscreteFilter5_tmp;
  real_T DiscreteFilter6_tmp;
  real_T DiscreteFilter7_tmp;
  real_T DiscreteFilter2_tmp;
  real_T DiscreteFilter7_tmp_l;
  real_T DiscreteFilter3_tmp;
  real_T DiscreteFilter7_tmp_i;
  real_T DiscreteFilter9_tmp;
  real_T DiscreteFilter7_tmp_k;
  real_T DiscreteFilter7_tmp_b;
  real_T DiscreteFilter7_tmp_p;
  real_T DiscreteFilter8_tmp;

  // S-Function (TMSI): '<Root>/TMSI'
  output_tmsi(&myTMSI_DWork.TMSI_PWORK, &myTMSI_B.TMSI_o1[0], &myTMSI_B.TMSI_o2);

  // S-Function (sdspperm2): '<Root>/Variable Selector5' incorporates:
  //   Constant: '<Root>/Constant18'

  memOffset = (int32_T)floor(myTMSI_P.Constant18_Value) - 1;
  if (memOffset < 0) {
    memOffset = 0;
  } else {
    if (memOffset >= 16) {
      memOffset = 15;
    }
  }

  for (j = 0; j < 20; j++) {
    rtb_VariableSelector5[j] = myTMSI_B.TMSI_o1[(j << 4) + memOffset];
  }

  // End of S-Function (sdspperm2): '<Root>/Variable Selector5'

  // DiscreteFilter: '<Root>/Discrete Filter4' incorporates:
  //   Constant: '<Root>/Constant10'
  //   MultiPortSwitch: '<Root>/Index Vector6'

  DiscreteFilter4_tmp = (((rtb_VariableSelector5[(int32_T)
    myTMSI_P.Constant10_Value] - myTMSI_P.DiscreteFilter4_DenCoef[1] *
    myTMSI_DWork.DiscreteFilter4_states[0]) - myTMSI_P.DiscreteFilter4_DenCoef[2]
    * myTMSI_DWork.DiscreteFilter4_states[1]) -
    myTMSI_P.DiscreteFilter4_DenCoef[3] * myTMSI_DWork.DiscreteFilter4_states[2])
    / myTMSI_P.DiscreteFilter4_DenCoef[0];
  myTMSI_B.DiscreteFilter4 = ((myTMSI_P.DiscreteFilter4_NumCoef[0] *
    DiscreteFilter4_tmp + myTMSI_P.DiscreteFilter4_NumCoef[1] *
    myTMSI_DWork.DiscreteFilter4_states[0]) + myTMSI_P.DiscreteFilter4_NumCoef[2]
    * myTMSI_DWork.DiscreteFilter4_states[1]) +
    myTMSI_P.DiscreteFilter4_NumCoef[3] * myTMSI_DWork.DiscreteFilter4_states[2];

  // S-Function (sdspperm2): '<Root>/Variable Selector4' incorporates:
  //   Constant: '<Root>/Constant8'

  memOffset = (int32_T)floor(myTMSI_P.Constant8_Value) - 1;
  if (memOffset < 0) {
    memOffset = 0;
  } else {
    if (memOffset >= 16) {
      memOffset = 15;
    }
  }

  for (j = 0; j < 20; j++) {
    rtb_VariableSelector5[j] = myTMSI_B.TMSI_o1[(j << 4) + memOffset];
  }

  // End of S-Function (sdspperm2): '<Root>/Variable Selector4'

  // DiscreteFilter: '<Root>/Discrete Filter5' incorporates:
  //   Constant: '<Root>/Constant9'
  //   MultiPortSwitch: '<Root>/Index Vector5'

  DiscreteFilter5_tmp = (((rtb_VariableSelector5[(int32_T)
    myTMSI_P.Constant9_Value] - myTMSI_P.DiscreteFilter5_DenCoef[1] *
    myTMSI_DWork.DiscreteFilter5_states[0]) - myTMSI_P.DiscreteFilter5_DenCoef[2]
    * myTMSI_DWork.DiscreteFilter5_states[1]) -
    myTMSI_P.DiscreteFilter5_DenCoef[3] * myTMSI_DWork.DiscreteFilter5_states[2])
    / myTMSI_P.DiscreteFilter5_DenCoef[0];
  myTMSI_B.DiscreteFilter5 = ((myTMSI_P.DiscreteFilter5_NumCoef[0] *
    DiscreteFilter5_tmp + myTMSI_P.DiscreteFilter5_NumCoef[1] *
    myTMSI_DWork.DiscreteFilter5_states[0]) + myTMSI_P.DiscreteFilter5_NumCoef[2]
    * myTMSI_DWork.DiscreteFilter5_states[1]) +
    myTMSI_P.DiscreteFilter5_NumCoef[3] * myTMSI_DWork.DiscreteFilter5_states[2];

  // S-Function (sdspperm2): '<Root>/Variable Selector7' incorporates:
  //   Constant: '<Root>/Constant16'

  memOffset = (int32_T)floor(myTMSI_P.Constant16_Value) - 1;
  if (memOffset < 0) {
    memOffset = 0;
  } else {
    if (memOffset >= 16) {
      memOffset = 15;
    }
  }

  for (j = 0; j < 20; j++) {
    rtb_VariableSelector5[j] = myTMSI_B.TMSI_o1[(j << 4) + memOffset];
  }

  // End of S-Function (sdspperm2): '<Root>/Variable Selector7'

  // DiscreteFilter: '<Root>/Discrete Filter6' incorporates:
  //   Constant: '<Root>/Constant13'
  //   MultiPortSwitch: '<Root>/Index Vector8'

  DiscreteFilter6_tmp = (((rtb_VariableSelector5[(int32_T)
    myTMSI_P.Constant13_Value] - myTMSI_P.DiscreteFilter6_DenCoef[1] *
    myTMSI_DWork.DiscreteFilter6_states[0]) - myTMSI_P.DiscreteFilter6_DenCoef[2]
    * myTMSI_DWork.DiscreteFilter6_states[1]) -
    myTMSI_P.DiscreteFilter6_DenCoef[3] * myTMSI_DWork.DiscreteFilter6_states[2])
    / myTMSI_P.DiscreteFilter6_DenCoef[0];
  myTMSI_B.DiscreteFilter6 = ((myTMSI_P.DiscreteFilter6_NumCoef[0] *
    DiscreteFilter6_tmp + myTMSI_P.DiscreteFilter6_NumCoef[1] *
    myTMSI_DWork.DiscreteFilter6_states[0]) + myTMSI_P.DiscreteFilter6_NumCoef[2]
    * myTMSI_DWork.DiscreteFilter6_states[1]) +
    myTMSI_P.DiscreteFilter6_NumCoef[3] * myTMSI_DWork.DiscreteFilter6_states[2];

  // S-Function (sdspperm2): '<S3>/Variable Selector6' incorporates:
  //   Constant: '<Root>/Constant11'

  memOffset = (int32_T)floor(myTMSI_P.Constant11_Value) - 1;
  if (memOffset < 0) {
    memOffset = 0;
  } else {
    if (memOffset >= 16) {
      memOffset = 15;
    }
  }

  for (j = 0; j < 20; j++) {
    rtb_VariableSelector5[j] = myTMSI_B.TMSI_o1[(j << 4) + memOffset];
  }

  // End of S-Function (sdspperm2): '<S3>/Variable Selector6'

  // DiscreteFilter: '<S3>/Discrete Filter7' incorporates:
  //   Constant: '<S3>/Constant12'
  //   MultiPortSwitch: '<S3>/Index Vector7'

  DiscreteFilter7_tmp = (((rtb_VariableSelector5[(int32_T)
    myTMSI_P.Constant12_Value] - myTMSI_P.DiscreteFilter7_DenCoef[1] *
    myTMSI_DWork.DiscreteFilter7_states[0]) - myTMSI_P.DiscreteFilter7_DenCoef[2]
    * myTMSI_DWork.DiscreteFilter7_states[1]) -
    myTMSI_P.DiscreteFilter7_DenCoef[3] * myTMSI_DWork.DiscreteFilter7_states[2])
    / myTMSI_P.DiscreteFilter7_DenCoef[0];

  // DiscreteFilter: '<Root>/Discrete Filter2' incorporates:
  //   DiscreteFilter: '<S3>/Discrete Filter7'

  DiscreteFilter2_tmp = ((((((myTMSI_P.DiscreteFilter7_NumCoef[0] *
    DiscreteFilter7_tmp + myTMSI_P.DiscreteFilter7_NumCoef[1] *
    myTMSI_DWork.DiscreteFilter7_states[0]) + myTMSI_P.DiscreteFilter7_NumCoef[2]
    * myTMSI_DWork.DiscreteFilter7_states[1]) +
    myTMSI_P.DiscreteFilter7_NumCoef[3] * myTMSI_DWork.DiscreteFilter7_states[2])
    - myTMSI_P.DiscreteFilter2_DenCoef[1] * myTMSI_DWork.DiscreteFilter2_states
    [0]) - myTMSI_P.DiscreteFilter2_DenCoef[2] *
    myTMSI_DWork.DiscreteFilter2_states[1]) - myTMSI_P.DiscreteFilter2_DenCoef[3]
    * myTMSI_DWork.DiscreteFilter2_states[2]) /
    myTMSI_P.DiscreteFilter2_DenCoef[0];
  myTMSI_B.DiscreteFilter2 = ((myTMSI_P.DiscreteFilter2_NumCoef[0] *
    DiscreteFilter2_tmp + myTMSI_P.DiscreteFilter2_NumCoef[1] *
    myTMSI_DWork.DiscreteFilter2_states[0]) + myTMSI_P.DiscreteFilter2_NumCoef[2]
    * myTMSI_DWork.DiscreteFilter2_states[1]) +
    myTMSI_P.DiscreteFilter2_NumCoef[3] * myTMSI_DWork.DiscreteFilter2_states[2];

  // S-Function (sdspperm2): '<S1>/Variable Selector6' incorporates:
  //   Constant: '<Root>/Constant12'

  memOffset = (int32_T)floor(myTMSI_P.Constant12_Value_o) - 1;
  if (memOffset < 0) {
    memOffset = 0;
  } else {
    if (memOffset >= 16) {
      memOffset = 15;
    }
  }

  for (j = 0; j < 20; j++) {
    rtb_VariableSelector5[j] = myTMSI_B.TMSI_o1[(j << 4) + memOffset];
  }

  // End of S-Function (sdspperm2): '<S1>/Variable Selector6'

  // DiscreteFilter: '<S1>/Discrete Filter7' incorporates:
  //   Constant: '<S1>/Constant12'
  //   MultiPortSwitch: '<S1>/Index Vector7'

  DiscreteFilter7_tmp_l = (((rtb_VariableSelector5[(int32_T)
    myTMSI_P.Constant12_Value_e] - myTMSI_P.DiscreteFilter7_DenCoef_j[1] *
    myTMSI_DWork.DiscreteFilter7_states_m[0]) -
    myTMSI_P.DiscreteFilter7_DenCoef_j[2] *
    myTMSI_DWork.DiscreteFilter7_states_m[1]) -
    myTMSI_P.DiscreteFilter7_DenCoef_j[3] *
    myTMSI_DWork.DiscreteFilter7_states_m[2]) /
    myTMSI_P.DiscreteFilter7_DenCoef_j[0];

  // DiscreteFilter: '<Root>/Discrete Filter3' incorporates:
  //   DiscreteFilter: '<S1>/Discrete Filter7'

  DiscreteFilter3_tmp = ((((((myTMSI_P.DiscreteFilter7_NumCoef_g[0] *
    DiscreteFilter7_tmp_l + myTMSI_P.DiscreteFilter7_NumCoef_g[1] *
    myTMSI_DWork.DiscreteFilter7_states_m[0]) +
    myTMSI_P.DiscreteFilter7_NumCoef_g[2] *
    myTMSI_DWork.DiscreteFilter7_states_m[1]) +
    myTMSI_P.DiscreteFilter7_NumCoef_g[3] *
    myTMSI_DWork.DiscreteFilter7_states_m[2]) -
    myTMSI_P.DiscreteFilter3_DenCoef[1] * myTMSI_DWork.DiscreteFilter3_states[0])
    - myTMSI_P.DiscreteFilter3_DenCoef[2] * myTMSI_DWork.DiscreteFilter3_states
    [1]) - myTMSI_P.DiscreteFilter3_DenCoef[3] *
    myTMSI_DWork.DiscreteFilter3_states[2]) / myTMSI_P.DiscreteFilter3_DenCoef[0];
  myTMSI_B.DiscreteFilter3 = ((myTMSI_P.DiscreteFilter3_NumCoef[0] *
    DiscreteFilter3_tmp + myTMSI_P.DiscreteFilter3_NumCoef[1] *
    myTMSI_DWork.DiscreteFilter3_states[0]) + myTMSI_P.DiscreteFilter3_NumCoef[2]
    * myTMSI_DWork.DiscreteFilter3_states[1]) +
    myTMSI_P.DiscreteFilter3_NumCoef[3] * myTMSI_DWork.DiscreteFilter3_states[2];

  // S-Function (sdspperm2): '<S2>/Variable Selector6' incorporates:
  //   Constant: '<Root>/Constant14'

  memOffset = (int32_T)floor(myTMSI_P.Constant14_Value) - 1;
  if (memOffset < 0) {
    memOffset = 0;
  } else {
    if (memOffset >= 16) {
      memOffset = 15;
    }
  }

  for (j = 0; j < 20; j++) {
    rtb_VariableSelector5[j] = myTMSI_B.TMSI_o1[(j << 4) + memOffset];
  }

  // End of S-Function (sdspperm2): '<S2>/Variable Selector6'

  // DiscreteFilter: '<S2>/Discrete Filter7' incorporates:
  //   Constant: '<S2>/Constant12'
  //   MultiPortSwitch: '<S2>/Index Vector7'

  DiscreteFilter7_tmp_i = (((rtb_VariableSelector5[(int32_T)
    myTMSI_P.Constant12_Value_i] - myTMSI_P.DiscreteFilter7_DenCoef_h[1] *
    myTMSI_DWork.DiscreteFilter7_states_k[0]) -
    myTMSI_P.DiscreteFilter7_DenCoef_h[2] *
    myTMSI_DWork.DiscreteFilter7_states_k[1]) -
    myTMSI_P.DiscreteFilter7_DenCoef_h[3] *
    myTMSI_DWork.DiscreteFilter7_states_k[2]) /
    myTMSI_P.DiscreteFilter7_DenCoef_h[0];

  // DiscreteFilter: '<Root>/Discrete Filter9' incorporates:
  //   DiscreteFilter: '<S2>/Discrete Filter7'

  DiscreteFilter9_tmp = ((((((myTMSI_P.DiscreteFilter7_NumCoef_k[0] *
    DiscreteFilter7_tmp_i + myTMSI_P.DiscreteFilter7_NumCoef_k[1] *
    myTMSI_DWork.DiscreteFilter7_states_k[0]) +
    myTMSI_P.DiscreteFilter7_NumCoef_k[2] *
    myTMSI_DWork.DiscreteFilter7_states_k[1]) +
    myTMSI_P.DiscreteFilter7_NumCoef_k[3] *
    myTMSI_DWork.DiscreteFilter7_states_k[2]) -
    myTMSI_P.DiscreteFilter9_DenCoef[1] * myTMSI_DWork.DiscreteFilter9_states[0])
    - myTMSI_P.DiscreteFilter9_DenCoef[2] * myTMSI_DWork.DiscreteFilter9_states
    [1]) - myTMSI_P.DiscreteFilter9_DenCoef[3] *
    myTMSI_DWork.DiscreteFilter9_states[2]) / myTMSI_P.DiscreteFilter9_DenCoef[0];
  myTMSI_B.DiscreteFilter9 = ((myTMSI_P.DiscreteFilter9_NumCoef[0] *
    DiscreteFilter9_tmp + myTMSI_P.DiscreteFilter9_NumCoef[1] *
    myTMSI_DWork.DiscreteFilter9_states[0]) + myTMSI_P.DiscreteFilter9_NumCoef[2]
    * myTMSI_DWork.DiscreteFilter9_states[1]) +
    myTMSI_P.DiscreteFilter9_NumCoef[3] * myTMSI_DWork.DiscreteFilter9_states[2];

  // S-Function (sdspperm2): '<S4>/Variable Selector6' incorporates:
  //   Constant: '<Root>/Constant15'

  memOffset = (int32_T)floor(myTMSI_P.Constant15_Value) - 1;
  if (memOffset < 0) {
    memOffset = 0;
  } else {
    if (memOffset >= 16) {
      memOffset = 15;
    }
  }

  for (j = 0; j < 20; j++) {
    rtb_VariableSelector5[j] = myTMSI_B.TMSI_o1[(j << 4) + memOffset];
  }

  // End of S-Function (sdspperm2): '<S4>/Variable Selector6'

  // DiscreteFilter: '<S4>/Discrete Filter7' incorporates:
  //   Constant: '<S4>/Constant12'
  //   MultiPortSwitch: '<S4>/Index Vector7'

  DiscreteFilter7_tmp_k = (((rtb_VariableSelector5[(int32_T)
    myTMSI_P.Constant12_Value_g] - myTMSI_P.DiscreteFilter7_DenCoef_g[1] *
    myTMSI_DWork.DiscreteFilter7_states_h[0]) -
    myTMSI_P.DiscreteFilter7_DenCoef_g[2] *
    myTMSI_DWork.DiscreteFilter7_states_h[1]) -
    myTMSI_P.DiscreteFilter7_DenCoef_g[3] *
    myTMSI_DWork.DiscreteFilter7_states_h[2]) /
    myTMSI_P.DiscreteFilter7_DenCoef_g[0];

  // DiscreteFilter: '<Root>/Discrete Filter7' incorporates:
  //   DiscreteFilter: '<S4>/Discrete Filter7'

  DiscreteFilter7_tmp_b = ((((((myTMSI_P.DiscreteFilter7_NumCoef_h[0] *
    DiscreteFilter7_tmp_k + myTMSI_P.DiscreteFilter7_NumCoef_h[1] *
    myTMSI_DWork.DiscreteFilter7_states_h[0]) +
    myTMSI_P.DiscreteFilter7_NumCoef_h[2] *
    myTMSI_DWork.DiscreteFilter7_states_h[1]) +
    myTMSI_P.DiscreteFilter7_NumCoef_h[3] *
    myTMSI_DWork.DiscreteFilter7_states_h[2]) -
    myTMSI_P.DiscreteFilter7_DenCoef_n[1] *
    myTMSI_DWork.DiscreteFilter7_states_i[0]) -
    myTMSI_P.DiscreteFilter7_DenCoef_n[2] *
    myTMSI_DWork.DiscreteFilter7_states_i[1]) -
    myTMSI_P.DiscreteFilter7_DenCoef_n[3] *
    myTMSI_DWork.DiscreteFilter7_states_i[2]) /
    myTMSI_P.DiscreteFilter7_DenCoef_n[0];
  myTMSI_B.DiscreteFilter7 = ((myTMSI_P.DiscreteFilter7_NumCoef_n[0] *
    DiscreteFilter7_tmp_b + myTMSI_P.DiscreteFilter7_NumCoef_n[1] *
    myTMSI_DWork.DiscreteFilter7_states_i[0]) +
    myTMSI_P.DiscreteFilter7_NumCoef_n[2] *
    myTMSI_DWork.DiscreteFilter7_states_i[1]) +
    myTMSI_P.DiscreteFilter7_NumCoef_n[3] *
    myTMSI_DWork.DiscreteFilter7_states_i[2];

  // S-Function (sdspperm2): '<S5>/Variable Selector6' incorporates:
  //   Constant: '<Root>/Constant19'

  memOffset = (int32_T)floor(myTMSI_P.Constant19_Value) - 1;
  if (memOffset < 0) {
    memOffset = 0;
  } else {
    if (memOffset >= 16) {
      memOffset = 15;
    }
  }

  for (j = 0; j < 20; j++) {
    rtb_VariableSelector5[j] = myTMSI_B.TMSI_o1[(j << 4) + memOffset];
  }

  // End of S-Function (sdspperm2): '<S5>/Variable Selector6'

  // DiscreteFilter: '<S5>/Discrete Filter7' incorporates:
  //   Constant: '<S5>/Constant12'
  //   MultiPortSwitch: '<S5>/Index Vector7'

  DiscreteFilter7_tmp_p = (((rtb_VariableSelector5[(int32_T)
    myTMSI_P.Constant12_Value_d] - myTMSI_P.DiscreteFilter7_DenCoef_l[1] *
    myTMSI_DWork.DiscreteFilter7_states_kj[0]) -
    myTMSI_P.DiscreteFilter7_DenCoef_l[2] *
    myTMSI_DWork.DiscreteFilter7_states_kj[1]) -
    myTMSI_P.DiscreteFilter7_DenCoef_l[3] *
    myTMSI_DWork.DiscreteFilter7_states_kj[2]) /
    myTMSI_P.DiscreteFilter7_DenCoef_l[0];

  // DiscreteFilter: '<Root>/Discrete Filter8' incorporates:
  //   DiscreteFilter: '<S5>/Discrete Filter7'

  DiscreteFilter8_tmp = ((((((myTMSI_P.DiscreteFilter7_NumCoef_gx[0] *
    DiscreteFilter7_tmp_p + myTMSI_P.DiscreteFilter7_NumCoef_gx[1] *
    myTMSI_DWork.DiscreteFilter7_states_kj[0]) +
    myTMSI_P.DiscreteFilter7_NumCoef_gx[2] *
    myTMSI_DWork.DiscreteFilter7_states_kj[1]) +
    myTMSI_P.DiscreteFilter7_NumCoef_gx[3] *
    myTMSI_DWork.DiscreteFilter7_states_kj[2]) -
    myTMSI_P.DiscreteFilter8_DenCoef[1] * myTMSI_DWork.DiscreteFilter8_states[0])
    - myTMSI_P.DiscreteFilter8_DenCoef[2] * myTMSI_DWork.DiscreteFilter8_states
    [1]) - myTMSI_P.DiscreteFilter8_DenCoef[3] *
    myTMSI_DWork.DiscreteFilter8_states[2]) / myTMSI_P.DiscreteFilter8_DenCoef[0];
  myTMSI_B.DiscreteFilter8 = ((myTMSI_P.DiscreteFilter8_NumCoef[0] *
    DiscreteFilter8_tmp + myTMSI_P.DiscreteFilter8_NumCoef[1] *
    myTMSI_DWork.DiscreteFilter8_states[0]) + myTMSI_P.DiscreteFilter8_NumCoef[2]
    * myTMSI_DWork.DiscreteFilter8_states[1]) +
    myTMSI_P.DiscreteFilter8_NumCoef[3] * myTMSI_DWork.DiscreteFilter8_states[2];

  // Update for DiscreteFilter: '<Root>/Discrete Filter4'
  myTMSI_DWork.DiscreteFilter4_states[2] = myTMSI_DWork.DiscreteFilter4_states[1];
  myTMSI_DWork.DiscreteFilter4_states[1] = myTMSI_DWork.DiscreteFilter4_states[0];
  myTMSI_DWork.DiscreteFilter4_states[0] = DiscreteFilter4_tmp;

  // Update for DiscreteFilter: '<Root>/Discrete Filter5'
  myTMSI_DWork.DiscreteFilter5_states[2] = myTMSI_DWork.DiscreteFilter5_states[1];
  myTMSI_DWork.DiscreteFilter5_states[1] = myTMSI_DWork.DiscreteFilter5_states[0];
  myTMSI_DWork.DiscreteFilter5_states[0] = DiscreteFilter5_tmp;

  // Update for DiscreteFilter: '<Root>/Discrete Filter6'
  myTMSI_DWork.DiscreteFilter6_states[2] = myTMSI_DWork.DiscreteFilter6_states[1];
  myTMSI_DWork.DiscreteFilter6_states[1] = myTMSI_DWork.DiscreteFilter6_states[0];
  myTMSI_DWork.DiscreteFilter6_states[0] = DiscreteFilter6_tmp;

  // Update for DiscreteFilter: '<S3>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states[2] = myTMSI_DWork.DiscreteFilter7_states[1];
  myTMSI_DWork.DiscreteFilter7_states[1] = myTMSI_DWork.DiscreteFilter7_states[0];
  myTMSI_DWork.DiscreteFilter7_states[0] = DiscreteFilter7_tmp;

  // Update for DiscreteFilter: '<Root>/Discrete Filter2'
  myTMSI_DWork.DiscreteFilter2_states[2] = myTMSI_DWork.DiscreteFilter2_states[1];
  myTMSI_DWork.DiscreteFilter2_states[1] = myTMSI_DWork.DiscreteFilter2_states[0];
  myTMSI_DWork.DiscreteFilter2_states[0] = DiscreteFilter2_tmp;

  // Update for DiscreteFilter: '<S1>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_m[2] =
    myTMSI_DWork.DiscreteFilter7_states_m[1];
  myTMSI_DWork.DiscreteFilter7_states_m[1] =
    myTMSI_DWork.DiscreteFilter7_states_m[0];
  myTMSI_DWork.DiscreteFilter7_states_m[0] = DiscreteFilter7_tmp_l;

  // Update for DiscreteFilter: '<Root>/Discrete Filter3'
  myTMSI_DWork.DiscreteFilter3_states[2] = myTMSI_DWork.DiscreteFilter3_states[1];
  myTMSI_DWork.DiscreteFilter3_states[1] = myTMSI_DWork.DiscreteFilter3_states[0];
  myTMSI_DWork.DiscreteFilter3_states[0] = DiscreteFilter3_tmp;

  // Update for DiscreteFilter: '<S2>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_k[2] =
    myTMSI_DWork.DiscreteFilter7_states_k[1];
  myTMSI_DWork.DiscreteFilter7_states_k[1] =
    myTMSI_DWork.DiscreteFilter7_states_k[0];
  myTMSI_DWork.DiscreteFilter7_states_k[0] = DiscreteFilter7_tmp_i;

  // Update for DiscreteFilter: '<Root>/Discrete Filter9'
  myTMSI_DWork.DiscreteFilter9_states[2] = myTMSI_DWork.DiscreteFilter9_states[1];
  myTMSI_DWork.DiscreteFilter9_states[1] = myTMSI_DWork.DiscreteFilter9_states[0];
  myTMSI_DWork.DiscreteFilter9_states[0] = DiscreteFilter9_tmp;

  // Update for DiscreteFilter: '<S4>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_h[2] =
    myTMSI_DWork.DiscreteFilter7_states_h[1];
  myTMSI_DWork.DiscreteFilter7_states_h[1] =
    myTMSI_DWork.DiscreteFilter7_states_h[0];
  myTMSI_DWork.DiscreteFilter7_states_h[0] = DiscreteFilter7_tmp_k;

  // Update for DiscreteFilter: '<Root>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_i[2] =
    myTMSI_DWork.DiscreteFilter7_states_i[1];
  myTMSI_DWork.DiscreteFilter7_states_i[1] =
    myTMSI_DWork.DiscreteFilter7_states_i[0];
  myTMSI_DWork.DiscreteFilter7_states_i[0] = DiscreteFilter7_tmp_b;

  // Update for DiscreteFilter: '<S5>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_kj[2] =
    myTMSI_DWork.DiscreteFilter7_states_kj[1];
  myTMSI_DWork.DiscreteFilter7_states_kj[1] =
    myTMSI_DWork.DiscreteFilter7_states_kj[0];
  myTMSI_DWork.DiscreteFilter7_states_kj[0] = DiscreteFilter7_tmp_p;

  // Update for DiscreteFilter: '<Root>/Discrete Filter8'
  myTMSI_DWork.DiscreteFilter8_states[2] = myTMSI_DWork.DiscreteFilter8_states[1];
  myTMSI_DWork.DiscreteFilter8_states[1] = myTMSI_DWork.DiscreteFilter8_states[0];
  myTMSI_DWork.DiscreteFilter8_states[0] = DiscreteFilter8_tmp;

  // External mode
  rtExtModeUploadCheckTrigger(1);

  {                                    // Sample time: [0.01s, 0.0s]
    rtExtModeUpload(0, myTMSI_M->Timing.taskTime0);
  }

  // signal main to stop simulation
  {                                    // Sample time: [0.01s, 0.0s]
    if ((rtmGetTFinal(myTMSI_M)!=-1) &&
        !((rtmGetTFinal(myTMSI_M)-myTMSI_M->Timing.taskTime0) >
          myTMSI_M->Timing.taskTime0 * (DBL_EPSILON))) {
      rtmSetErrorStatus(myTMSI_M, "Simulation finished");
    }

    if (rtmGetStopRequested(myTMSI_M)) {
      rtmSetErrorStatus(myTMSI_M, "Simulation finished");
    }
  }

  // Update absolute time for base rate
  // The "clockTick0" counts the number of times the code of this task has
  //  been executed. The absolute time is the multiplication of "clockTick0"
  //  and "Timing.stepSize0". Size of "clockTick0" ensures timer will not
  //  overflow during the application lifespan selected.

  myTMSI_M->Timing.taskTime0 =
    (++myTMSI_M->Timing.clockTick0) * myTMSI_M->Timing.stepSize0;
}

// Model initialize function
void myTMSI_initialize(void)
{
  // Registration code

  // initialize real-time model
  (void) memset((void *)myTMSI_M, 0,
                sizeof(RT_MODEL_myTMSI));
  rtmSetTFinal(myTMSI_M, -1);
  myTMSI_M->Timing.stepSize0 = 0.01;

  // External mode info
  myTMSI_M->Sizes.checksums[0] = (2009393086U);
  myTMSI_M->Sizes.checksums[1] = (2995121225U);
  myTMSI_M->Sizes.checksums[2] = (1703715540U);
  myTMSI_M->Sizes.checksums[3] = (4197625414U);

  {
    static const sysRanDType rtAlwaysEnabled = SUBSYS_RAN_BC_ENABLE;
    static RTWExtModeInfo rt_ExtModeInfo;
    static const sysRanDType *systemRan[1];
    myTMSI_M->extModeInfo = (&rt_ExtModeInfo);
    rteiSetSubSystemActiveVectorAddresses(&rt_ExtModeInfo, systemRan);
    systemRan[0] = &rtAlwaysEnabled;
    rteiSetModelMappingInfoPtr(myTMSI_M->extModeInfo,
      &myTMSI_M->SpecialInfo.mappingInfo);
    rteiSetChecksumsPtr(myTMSI_M->extModeInfo, myTMSI_M->Sizes.checksums);
    rteiSetTPtr(myTMSI_M->extModeInfo, rtmGetTPtr(myTMSI_M));
  }

  // block I/O
  (void) memset(((void *) &myTMSI_B), 0,
                sizeof(BlockIO_myTMSI));

  // states (dwork)
  (void) memset((void *)&myTMSI_DWork, 0,
                sizeof(D_Work_myTMSI));

  // data type transition information
  {
    static DataTypeTransInfo dtInfo;
    (void) memset((char_T *) &dtInfo, 0,
                  sizeof(dtInfo));
    myTMSI_M->SpecialInfo.mappingInfo = (&dtInfo);
    dtInfo.numDataTypes = 14;
    dtInfo.dataTypeSizes = &rtDataTypeSizes[0];
    dtInfo.dataTypeNames = &rtDataTypeNames[0];

    // Block I/O transition table
    dtInfo.BTransTable = &rtBTransTable;

    // Parameters transition table
    dtInfo.PTransTable = &rtPTransTable;
  }

  // Start for S-Function (TMSI): '<Root>/TMSI'
  init_tmsi(&myTMSI_DWork.TMSI_PWORK, myTMSI_P.TMSI_p1, myTMSI_P.TMSI_p2,
            myTMSI_P.TMSI_p3, 20, (int32_T*)myTMSI_P.TMSI_p5, 16);

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter4'
  myTMSI_DWork.DiscreteFilter4_states[0] =
    myTMSI_P.DiscreteFilter4_InitialStates;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter5'
  myTMSI_DWork.DiscreteFilter5_states[0] =
    myTMSI_P.DiscreteFilter5_InitialStates;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter6'
  myTMSI_DWork.DiscreteFilter6_states[0] =
    myTMSI_P.DiscreteFilter6_InitialStates;

  // InitializeConditions for DiscreteFilter: '<S3>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states[0] =
    myTMSI_P.DiscreteFilter7_InitialStates;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter2'
  myTMSI_DWork.DiscreteFilter2_states[0] =
    myTMSI_P.DiscreteFilter2_InitialStates;

  // InitializeConditions for DiscreteFilter: '<S1>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_m[0] =
    myTMSI_P.DiscreteFilter7_InitialStates_j;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter3'
  myTMSI_DWork.DiscreteFilter3_states[0] =
    myTMSI_P.DiscreteFilter3_InitialStates;

  // InitializeConditions for DiscreteFilter: '<S2>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_k[0] =
    myTMSI_P.DiscreteFilter7_InitialStates_p;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter9'
  myTMSI_DWork.DiscreteFilter9_states[0] =
    myTMSI_P.DiscreteFilter9_InitialStates;

  // InitializeConditions for DiscreteFilter: '<S4>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_h[0] =
    myTMSI_P.DiscreteFilter7_InitialStates_n;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_i[0] =
    myTMSI_P.DiscreteFilter7_InitialStates_o;

  // InitializeConditions for DiscreteFilter: '<S5>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_kj[0] =
    myTMSI_P.DiscreteFilter7_InitialStates_l;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter8'
  myTMSI_DWork.DiscreteFilter8_states[0] =
    myTMSI_P.DiscreteFilter8_InitialStates;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter4'
  myTMSI_DWork.DiscreteFilter4_states[1] =
    myTMSI_P.DiscreteFilter4_InitialStates;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter5'
  myTMSI_DWork.DiscreteFilter5_states[1] =
    myTMSI_P.DiscreteFilter5_InitialStates;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter6'
  myTMSI_DWork.DiscreteFilter6_states[1] =
    myTMSI_P.DiscreteFilter6_InitialStates;

  // InitializeConditions for DiscreteFilter: '<S3>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states[1] =
    myTMSI_P.DiscreteFilter7_InitialStates;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter2'
  myTMSI_DWork.DiscreteFilter2_states[1] =
    myTMSI_P.DiscreteFilter2_InitialStates;

  // InitializeConditions for DiscreteFilter: '<S1>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_m[1] =
    myTMSI_P.DiscreteFilter7_InitialStates_j;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter3'
  myTMSI_DWork.DiscreteFilter3_states[1] =
    myTMSI_P.DiscreteFilter3_InitialStates;

  // InitializeConditions for DiscreteFilter: '<S2>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_k[1] =
    myTMSI_P.DiscreteFilter7_InitialStates_p;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter9'
  myTMSI_DWork.DiscreteFilter9_states[1] =
    myTMSI_P.DiscreteFilter9_InitialStates;

  // InitializeConditions for DiscreteFilter: '<S4>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_h[1] =
    myTMSI_P.DiscreteFilter7_InitialStates_n;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_i[1] =
    myTMSI_P.DiscreteFilter7_InitialStates_o;

  // InitializeConditions for DiscreteFilter: '<S5>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_kj[1] =
    myTMSI_P.DiscreteFilter7_InitialStates_l;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter8'
  myTMSI_DWork.DiscreteFilter8_states[1] =
    myTMSI_P.DiscreteFilter8_InitialStates;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter4'
  myTMSI_DWork.DiscreteFilter4_states[2] =
    myTMSI_P.DiscreteFilter4_InitialStates;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter5'
  myTMSI_DWork.DiscreteFilter5_states[2] =
    myTMSI_P.DiscreteFilter5_InitialStates;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter6'
  myTMSI_DWork.DiscreteFilter6_states[2] =
    myTMSI_P.DiscreteFilter6_InitialStates;

  // InitializeConditions for DiscreteFilter: '<S3>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states[2] =
    myTMSI_P.DiscreteFilter7_InitialStates;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter2'
  myTMSI_DWork.DiscreteFilter2_states[2] =
    myTMSI_P.DiscreteFilter2_InitialStates;

  // InitializeConditions for DiscreteFilter: '<S1>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_m[2] =
    myTMSI_P.DiscreteFilter7_InitialStates_j;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter3'
  myTMSI_DWork.DiscreteFilter3_states[2] =
    myTMSI_P.DiscreteFilter3_InitialStates;

  // InitializeConditions for DiscreteFilter: '<S2>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_k[2] =
    myTMSI_P.DiscreteFilter7_InitialStates_p;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter9'
  myTMSI_DWork.DiscreteFilter9_states[2] =
    myTMSI_P.DiscreteFilter9_InitialStates;

  // InitializeConditions for DiscreteFilter: '<S4>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_h[2] =
    myTMSI_P.DiscreteFilter7_InitialStates_n;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_i[2] =
    myTMSI_P.DiscreteFilter7_InitialStates_o;

  // InitializeConditions for DiscreteFilter: '<S5>/Discrete Filter7'
  myTMSI_DWork.DiscreteFilter7_states_kj[2] =
    myTMSI_P.DiscreteFilter7_InitialStates_l;

  // InitializeConditions for DiscreteFilter: '<Root>/Discrete Filter8'
  myTMSI_DWork.DiscreteFilter8_states[2] =
    myTMSI_P.DiscreteFilter8_InitialStates;
}

// Model terminate function
void myTMSI_terminate(void)
{
  // Terminate for S-Function (TMSI): '<Root>/TMSI'
  terminate_tmsi(&myTMSI_DWork.TMSI_PWORK);
}

//
// File trailer for generated code.
//
// [EOF]
//
