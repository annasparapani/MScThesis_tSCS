//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// File: myTMSI_private.h
//
// Code generated for Simulink model 'myTMSI'.
//
// Model version                  : 1.571
// Simulink Coder version         : 8.13 (R2017b) 24-Jul-2017
// C/C++ source code generated on : Mon Oct 30 10:53:21 2023
//
// Target selection: ert_linux.tlc
// Embedded hardware selection: 32-bit Generic
// Code generation objectives: Unspecified
// Validation result: Not run
//
#ifndef RTW_HEADER_myTMSI_private_h_
#define RTW_HEADER_myTMSI_private_h_
#include "rtwtypes.h"
#include "multiword_types.h"

// Private macros used by the generated code to access rtModel
#ifndef rtmSetTFinal
# define rtmSetTFinal(rtm, val)        ((rtm)->Timing.tFinal = (val))
#endif

#ifndef rtmGetTPtr
# define rtmGetTPtr(rtm)               (&(rtm)->Timing.taskTime0)
#endif
#endif                                 // RTW_HEADER_myTMSI_private_h_

//
// File trailer for generated code.
//
// [EOF]
//
