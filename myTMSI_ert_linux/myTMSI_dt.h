//
//  myTMSI_dt.h
//
//  Academic License - for use in teaching, academic research, and meeting
//  course requirements at degree granting institutions only.  Not for
//  government, commercial, or other organizational use.
//
//  Code generation for model "myTMSI".
//
//  Model version              : 1.571
//  Simulink Coder version : 8.13 (R2017b) 24-Jul-2017
//  C++ source code generated on : Mon Oct 30 10:53:21 2023
//
//  Target selection: ert_linux.tlc
//  Embedded hardware selection: 32-bit Generic
//  Code generation objectives: Unspecified
//  Validation result: Not run


#include "ext_types.h"

// data type size table
static uint_T rtDataTypeSizes[] = {
  sizeof(real_T),
  sizeof(real32_T),
  sizeof(int8_T),
  sizeof(uint8_T),
  sizeof(int16_T),
  sizeof(uint16_T),
  sizeof(int32_T),
  sizeof(uint32_T),
  sizeof(boolean_T),
  sizeof(fcn_call_T),
  sizeof(int_T),
  sizeof(pointer_T),
  sizeof(action_T),
  2*sizeof(uint32_T)
};

// data type name table
static const char_T * rtDataTypeNames[] = {
  "real_T",
  "real32_T",
  "int8_T",
  "uint8_T",
  "int16_T",
  "uint16_T",
  "int32_T",
  "uint32_T",
  "boolean_T",
  "fcn_call_T",
  "int_T",
  "pointer_T",
  "action_T",
  "timer_uint32_pair_T"
};

// data type transitions for block I/O structure
static DataTypeTransition rtBTransitions[] = {
  { (char_T *)(&myTMSI_B.TMSI_o1[0]), 0, 0, 328 },

  { (char_T *)(&myTMSI_B.TMSI_o2), 6, 0, 1 }
  ,

  { (char_T *)(&myTMSI_DWork.DiscreteFilter4_states[0]), 0, 0, 39 },

  { (char_T *)(&myTMSI_DWork.TMSI_PWORK), 11, 0, 12 }
};

// data type transition table for block I/O structure
static DataTypeTransitionTable rtBTransTable = {
  4U,
  rtBTransitions
};

// data type transitions for Parameters structure
static DataTypeTransition rtPTransitions[] = {
  { (char_T *)(&myTMSI_P.Constant10_Value), 0, 0, 133 },

  { (char_T *)(&myTMSI_P.TMSI_p2), 6, 0, 18 },

  { (char_T *)(&myTMSI_P.TMSI_p1), 5, 0, 1 }
};

// data type transition table for Parameters structure
static DataTypeTransitionTable rtPTransTable = {
  3U,
  rtPTransitions
};

// [EOF] myTMSI_dt.h
