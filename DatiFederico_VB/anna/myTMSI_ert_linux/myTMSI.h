//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// File: myTMSI.h
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
#ifndef RTW_HEADER_myTMSI_h_
#define RTW_HEADER_myTMSI_h_
#include <math.h>
#include <float.h>
#include <string.h>
#ifndef myTMSI_COMMON_INCLUDES_
# define myTMSI_COMMON_INCLUDES_
#include "rtwtypes.h"
#include "rtw_extmode.h"
#include "sysran_types.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"
#include "dt_info.h"
#include "ext_work.h"
#include "tmsi.hpp"
#include "tmsiDevice.h"
#include "fusbi.h"
#endif                                 // myTMSI_COMMON_INCLUDES_

#include "myTMSI_types.h"

// Shared type includes
#include "multiword_types.h"

// Macros for accessing real-time model data structure
#ifndef rtmGetFinalTime
# define rtmGetFinalTime(rtm)          ((rtm)->Timing.tFinal)
#endif

#ifndef rtmGetRTWExtModeInfo
# define rtmGetRTWExtModeInfo(rtm)     ((rtm)->extModeInfo)
#endif

#ifndef rtmGetErrorStatus
# define rtmGetErrorStatus(rtm)        ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
# define rtmSetErrorStatus(rtm, val)   ((rtm)->errorStatus = (val))
#endif

#ifndef rtmGetStopRequested
# define rtmGetStopRequested(rtm)      ((rtm)->Timing.stopRequestedFlag)
#endif

#ifndef rtmSetStopRequested
# define rtmSetStopRequested(rtm, val) ((rtm)->Timing.stopRequestedFlag = (val))
#endif

#ifndef rtmGetStopRequestedPtr
# define rtmGetStopRequestedPtr(rtm)   (&((rtm)->Timing.stopRequestedFlag))
#endif

#ifndef rtmGetT
# define rtmGetT(rtm)                  ((rtm)->Timing.taskTime0)
#endif

#ifndef rtmGetTFinal
# define rtmGetTFinal(rtm)             ((rtm)->Timing.tFinal)
#endif

// Block signals (auto storage)
typedef struct {
  real_T TMSI_o1[320];                 // '<Root>/TMSI'
  real_T DiscreteFilter4;              // '<Root>/Discrete Filter4'
  real_T DiscreteFilter5;              // '<Root>/Discrete Filter5'
  real_T DiscreteFilter6;              // '<Root>/Discrete Filter6'
  real_T DiscreteFilter2;              // '<Root>/Discrete Filter2'
  real_T DiscreteFilter3;              // '<Root>/Discrete Filter3'
  real_T DiscreteFilter9;              // '<Root>/Discrete Filter9'
  real_T DiscreteFilter7;              // '<Root>/Discrete Filter7'
  real_T DiscreteFilter8;              // '<Root>/Discrete Filter8'
  int32_T TMSI_o2;                     // '<Root>/TMSI'
} BlockIO_myTMSI;

// Block states (auto storage) for system '<Root>'
typedef struct {
  real_T DiscreteFilter4_states[3];    // '<Root>/Discrete Filter4'
  real_T DiscreteFilter5_states[3];    // '<Root>/Discrete Filter5'
  real_T DiscreteFilter6_states[3];    // '<Root>/Discrete Filter6'
  real_T DiscreteFilter7_states[3];    // '<S3>/Discrete Filter7'
  real_T DiscreteFilter2_states[3];    // '<Root>/Discrete Filter2'
  real_T DiscreteFilter7_states_m[3];  // '<S1>/Discrete Filter7'
  real_T DiscreteFilter3_states[3];    // '<Root>/Discrete Filter3'
  real_T DiscreteFilter7_states_k[3];  // '<S2>/Discrete Filter7'
  real_T DiscreteFilter9_states[3];    // '<Root>/Discrete Filter9'
  real_T DiscreteFilter7_states_h[3];  // '<S4>/Discrete Filter7'
  real_T DiscreteFilter7_states_i[3];  // '<Root>/Discrete Filter7'
  real_T DiscreteFilter7_states_kj[3]; // '<S5>/Discrete Filter7'
  real_T DiscreteFilter8_states[3];    // '<Root>/Discrete Filter8'
  void *TMSI_PWORK;                    // '<Root>/TMSI'
  struct {
    void *LoggedData[4];
  } EMG1_PWORK;                        // '<Root>/EMG1'

  struct {
    void *LoggedData[4];
  } EMG3_PWORK;                        // '<Root>/EMG3'

  struct {
    void *LoggedData;
  } EMGcount_PWORK;                    // '<Root>/EMGcount'

  struct {
    void *LoggedData;
  } ToWorkspaceEMG_PWORK;              // '<Root>/To Workspace (EMG)'

  struct {
    void *LoggedData;
  } ToWorkspaceEMGcount_PWORK;         // '<Root>/To Workspace (EMGcount)'
} D_Work_myTMSI;

// Parameters (auto storage)
struct Parameters_myTMSI_ {
  real_T Constant10_Value;             // Expression: 1
                                       //  Referenced by: '<Root>/Constant10'

  real_T Constant18_Value;             // Expression: 5
                                       //  Referenced by: '<Root>/Constant18'

  real_T DiscreteFilter4_NumCoef[4];   // Expression: [0.9405   -2.8214    2.8214   -0.9405]
                                       //  Referenced by: '<Root>/Discrete Filter4'

  real_T DiscreteFilter4_DenCoef[4];   // Expression: [1.0000   -2.8773    2.7620   -0.8845]
                                       //  Referenced by: '<Root>/Discrete Filter4'

  real_T DiscreteFilter4_InitialStates;// Expression: 0
                                       //  Referenced by: '<Root>/Discrete Filter4'

  real_T Constant9_Value;              // Expression: 1
                                       //  Referenced by: '<Root>/Constant9'

  real_T Constant8_Value;              // Expression: 6
                                       //  Referenced by: '<Root>/Constant8'

  real_T DiscreteFilter5_NumCoef[4];   // Expression: [0.9405   -2.8214    2.8214   -0.9405]
                                       //  Referenced by: '<Root>/Discrete Filter5'

  real_T DiscreteFilter5_DenCoef[4];   // Expression: [1.0000   -2.8773    2.7620   -0.8845]
                                       //  Referenced by: '<Root>/Discrete Filter5'

  real_T DiscreteFilter5_InitialStates;// Expression: 0
                                       //  Referenced by: '<Root>/Discrete Filter5'

  real_T Constant13_Value;             // Expression: 1
                                       //  Referenced by: '<Root>/Constant13'

  real_T Constant16_Value;             // Expression: 7
                                       //  Referenced by: '<Root>/Constant16'

  real_T DiscreteFilter6_NumCoef[4];   // Expression: [0.9405   -2.8214    2.8214   -0.9405]
                                       //  Referenced by: '<Root>/Discrete Filter6'

  real_T DiscreteFilter6_DenCoef[4];   // Expression: [1.0000   -2.8773    2.7620   -0.8845]
                                       //  Referenced by: '<Root>/Discrete Filter6'

  real_T DiscreteFilter6_InitialStates;// Expression: 0
                                       //  Referenced by: '<Root>/Discrete Filter6'

  real_T Constant12_Value;             // Expression: 1
                                       //  Referenced by: '<S3>/Constant12'

  real_T Constant11_Value;             // Expression: 8
                                       //  Referenced by: '<Root>/Constant11'

  real_T DiscreteFilter7_NumCoef[4];   // Expression: [0.9405   -2.8214    2.8214   -0.9405]
                                       //  Referenced by: '<S3>/Discrete Filter7'

  real_T DiscreteFilter7_DenCoef[4];   // Expression: [1.0000   -2.8773    2.7620   -0.8845]
                                       //  Referenced by: '<S3>/Discrete Filter7'

  real_T DiscreteFilter7_InitialStates;// Expression: 0
                                       //  Referenced by: '<S3>/Discrete Filter7'

  real_T DiscreteFilter2_NumCoef[4];   // Expression: [0.9405   -2.8214    2.8214   -0.9405]
                                       //  Referenced by: '<Root>/Discrete Filter2'

  real_T DiscreteFilter2_DenCoef[4];   // Expression: [1.0000   -2.8773    2.7620   -0.8845]
                                       //  Referenced by: '<Root>/Discrete Filter2'

  real_T DiscreteFilter2_InitialStates;// Expression: 0
                                       //  Referenced by: '<Root>/Discrete Filter2'

  real_T Constant12_Value_e;           // Expression: 1
                                       //  Referenced by: '<S1>/Constant12'

  real_T Constant12_Value_o;           // Expression: 9
                                       //  Referenced by: '<Root>/Constant12'

  real_T DiscreteFilter7_NumCoef_g[4]; // Expression: [0.9405   -2.8214    2.8214   -0.9405]
                                       //  Referenced by: '<S1>/Discrete Filter7'

  real_T DiscreteFilter7_DenCoef_j[4]; // Expression: [1.0000   -2.8773    2.7620   -0.8845]
                                       //  Referenced by: '<S1>/Discrete Filter7'

  real_T DiscreteFilter7_InitialStates_j;// Expression: 0
                                         //  Referenced by: '<S1>/Discrete Filter7'

  real_T DiscreteFilter3_NumCoef[4];   // Expression: [0.9405   -2.8214    2.8214   -0.9405]
                                       //  Referenced by: '<Root>/Discrete Filter3'

  real_T DiscreteFilter3_DenCoef[4];   // Expression: [1.0000   -2.8773    2.7620   -0.8845]
                                       //  Referenced by: '<Root>/Discrete Filter3'

  real_T DiscreteFilter3_InitialStates;// Expression: 0
                                       //  Referenced by: '<Root>/Discrete Filter3'

  real_T Constant12_Value_i;           // Expression: 1
                                       //  Referenced by: '<S2>/Constant12'

  real_T Constant14_Value;             // Expression: 10
                                       //  Referenced by: '<Root>/Constant14'

  real_T DiscreteFilter7_NumCoef_k[4]; // Expression: [0.9405   -2.8214    2.8214   -0.9405]
                                       //  Referenced by: '<S2>/Discrete Filter7'

  real_T DiscreteFilter7_DenCoef_h[4]; // Expression: [1.0000   -2.8773    2.7620   -0.8845]
                                       //  Referenced by: '<S2>/Discrete Filter7'

  real_T DiscreteFilter7_InitialStates_p;// Expression: 0
                                         //  Referenced by: '<S2>/Discrete Filter7'

  real_T DiscreteFilter9_NumCoef[4];   // Expression: [0.9405   -2.8214    2.8214   -0.9405]
                                       //  Referenced by: '<Root>/Discrete Filter9'

  real_T DiscreteFilter9_DenCoef[4];   // Expression: [1.0000   -2.8773    2.7620   -0.8845]
                                       //  Referenced by: '<Root>/Discrete Filter9'

  real_T DiscreteFilter9_InitialStates;// Expression: 0
                                       //  Referenced by: '<Root>/Discrete Filter9'

  real_T Constant12_Value_g;           // Expression: 1
                                       //  Referenced by: '<S4>/Constant12'

  real_T Constant15_Value;             // Expression: 11
                                       //  Referenced by: '<Root>/Constant15'

  real_T DiscreteFilter7_NumCoef_h[4]; // Expression: [0.9405   -2.8214    2.8214   -0.9405]
                                       //  Referenced by: '<S4>/Discrete Filter7'

  real_T DiscreteFilter7_DenCoef_g[4]; // Expression: [1.0000   -2.8773    2.7620   -0.8845]
                                       //  Referenced by: '<S4>/Discrete Filter7'

  real_T DiscreteFilter7_InitialStates_n;// Expression: 0
                                         //  Referenced by: '<S4>/Discrete Filter7'

  real_T DiscreteFilter7_NumCoef_n[4]; // Expression: [0.9405   -2.8214    2.8214   -0.9405]
                                       //  Referenced by: '<Root>/Discrete Filter7'

  real_T DiscreteFilter7_DenCoef_n[4]; // Expression: [1.0000   -2.8773    2.7620   -0.8845]
                                       //  Referenced by: '<Root>/Discrete Filter7'

  real_T DiscreteFilter7_InitialStates_o;// Expression: 0
                                         //  Referenced by: '<Root>/Discrete Filter7'

  real_T Constant12_Value_d;           // Expression: 1
                                       //  Referenced by: '<S5>/Constant12'

  real_T Constant19_Value;             // Expression: 12
                                       //  Referenced by: '<Root>/Constant19'

  real_T DiscreteFilter7_NumCoef_gx[4];// Expression: [0.9405   -2.8214    2.8214   -0.9405]
                                       //  Referenced by: '<S5>/Discrete Filter7'

  real_T DiscreteFilter7_DenCoef_l[4]; // Expression: [1.0000   -2.8773    2.7620   -0.8845]
                                       //  Referenced by: '<S5>/Discrete Filter7'

  real_T DiscreteFilter7_InitialStates_l;// Expression: 0
                                         //  Referenced by: '<S5>/Discrete Filter7'

  real_T DiscreteFilter8_NumCoef[4];   // Expression: [0.9405   -2.8214    2.8214   -0.9405]
                                       //  Referenced by: '<Root>/Discrete Filter8'

  real_T DiscreteFilter8_DenCoef[4];   // Expression: [1.0000   -2.8773    2.7620   -0.8845]
                                       //  Referenced by: '<Root>/Discrete Filter8'

  real_T DiscreteFilter8_InitialStates;// Expression: 0
                                       //  Referenced by: '<Root>/Discrete Filter8'

  int32_T TMSI_p2;                     // Expression: int32(aux)
                                       //  Referenced by: '<Root>/TMSI'

  int32_T TMSI_p3;                     // Expression: int32(digital)
                                       //  Referenced by: '<Root>/TMSI'

  int32_T TMSI_p5[16];                 // Expression: int32(ch)
                                       //  Referenced by: '<Root>/TMSI'

  uint16_T TMSI_p1;                    // Expression: uint16(frequency)
                                       //  Referenced by: '<Root>/TMSI'

};

// Real-time Model Data Structure
struct tag_RTM_myTMSI {
  const char_T *errorStatus;
  RTWExtModeInfo *extModeInfo;

  //
  //  Sizes:
  //  The following substructure contains sizes information
  //  for many of the model attributes such as inputs, outputs,
  //  dwork, sample times, etc.

  struct {
    uint32_T checksums[4];
  } Sizes;

  //
  //  SpecialInfo:
  //  The following substructure contains special information
  //  related to other components that are dependent on RTW.

  struct {
    const void *mappingInfo;
  } SpecialInfo;

  //
  //  Timing:
  //  The following substructure contains information regarding
  //  the timing information for the model.

  struct {
    time_T taskTime0;
    uint32_T clockTick0;
    time_T stepSize0;
    time_T tFinal;
    boolean_T stopRequestedFlag;
  } Timing;
};

// Block parameters (auto storage)
#ifdef __cplusplus

extern "C" {

#endif

  extern Parameters_myTMSI myTMSI_P;

#ifdef __cplusplus

}
#endif

// Block signals (auto storage)
extern BlockIO_myTMSI myTMSI_B;

// Block states (auto storage)
extern D_Work_myTMSI myTMSI_DWork;

#ifdef __cplusplus

extern "C" {

#endif

  // Model entry point functions
  extern void myTMSI_initialize(void);
  extern void myTMSI_step(void);
  extern void myTMSI_terminate(void);

#ifdef __cplusplus

}
#endif

// Real-time Model object
#ifdef __cplusplus

extern "C" {

#endif

  extern RT_MODEL_myTMSI *const myTMSI_M;

#ifdef __cplusplus

}
#endif

//-
//  The generated code includes comments that allow you to trace directly
//  back to the appropriate location in the model.  The basic format
//  is <system>/block_name, where system is the system number (uniquely
//  assigned by Simulink) and block_name is the name of the block.
//
//  Use the MATLAB hilite_system command to trace the generated code back
//  to the model.  For example,
//
//  hilite_system('<S3>')    - opens system 3
//  hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
//
//  Here is the system hierarchy for this model
//
//  '<Root>' : 'myTMSI'
//  '<S1>'   : 'myTMSI/Subsystem1'
//  '<S2>'   : 'myTMSI/Subsystem2'
//  '<S3>'   : 'myTMSI/Subsystem3'
//  '<S4>'   : 'myTMSI/Subsystem4'
//  '<S5>'   : 'myTMSI/Subsystem5'
//  '<S6>'   : 'myTMSI/Subsystem6'
//  '<S7>'   : 'myTMSI/Subsystem7'
//  '<S8>'   : 'myTMSI/Subsystem8'
//  '<S9>'   : 'myTMSI/Subsystem9'

#endif                                 // RTW_HEADER_myTMSI_h_

//
// File trailer for generated code.
//
// [EOF]
//
