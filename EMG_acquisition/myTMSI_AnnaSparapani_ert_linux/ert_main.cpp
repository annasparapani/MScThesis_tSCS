//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// File: ert_main.cpp
//
// Code generated for Simulink model 'myTMSI_AnnaSparapani'.
//
// Model version                  : 1.577
// Simulink Coder version         : 8.13 (R2017b) 24-Jul-2017
// C/C++ source code generated on : Mon Nov 13 10:34:32 2023
//
// Target selection: ert_linux.tlc
// Embedded hardware selection: 32-bit Generic
// Code generation objectives: Unspecified
// Validation result: Not run
//

// Multirate - Multitasking case main file
#define _BSD_SOURCE                                              // For usleep() 
#define _POSIX_C_SOURCE                200112L                   // For clock_gettime() & clock_nanosleep() 
#include <stdio.h>                     // This ert_main.c example uses printf/fflush 
#include <pthread.h>                   // Thread library header file
#include <sched.h>                     // OS scheduler header file
#include <semaphore.h>                 // Semaphores library header file
#include <time.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/mman.h>                  // For mlockall()
#include <signal.h>
#include "myTMSI_AnnaSparapani.h"      // Model's header file
#include "rtwtypes.h"                  // MathWorks types
#include "ext_work.h"                  // External mode header file
#ifndef TRUE
#define TRUE                           true
#define FALSE                          false
#endif

//==================*
//  Required defines *
// ==================
#ifndef MODEL
# error Must specify a model name. Define MODEL=name.
#else

// create generic macros that work with any model
# define EXPAND_CONCAT(name1,name2)    name1 ## name2
# define CONCAT(name1,name2)           EXPAND_CONCAT(name1,name2)
# define MODEL_INITIALIZE              CONCAT(MODEL,_initialize)
# define MODEL_STEP                    CONCAT(MODEL,_step)
# define MODEL_TERMINATE               CONCAT(MODEL,_terminate)
# define RT_MDL                        CONCAT(MODEL,_M)
#endif

// Error checking
#define STRINGIZE(num)                 #num
#define POS(line)                      __FILE__ ":" STRINGIZE(line)
#define CHECK0(expr)                   do { int __err = (expr); if (__err) { fprintf(stderr, "Error: %s returned '%s' at " POS(__LINE__) "\n", #expr, strerror(__err)); exit(1); } } while (0);
#define CHECKE(expr)                   do { if ((expr) == -1) { perror(#expr " at " POS(__LINE__)); exit(1); } } while (0);

//*
//  Maximal priority used by base rate thread.

#define MAX_PRIO                       (sched_get_priority_min(SCHED_FIFO) + 1)

struct timingStats_t{
  uint32_T overruns;
  float meanSampleTime;
  uint32_T numElapsedSamples;
  float lastElapsedTime;
  float spareTime;
  float fundamentelSampleTime;
};

struct timingStats_t timing;

// Signal handler for ABORT during simulation
void abortHandler(int sig)
{
  fprintf(stderr, "Simulation aborted by pressing CTRL+C\n");
  rtmSetStopRequested(myTMSI_AnnaSparapani_M, 1);
}

//*
//  Thread handle of the base rate thread.
//  Fundamental sample time = 0.01s

pthread_t base_rate_thread;

//*
//  Thread handles of and semaphores for sub rate threads. The array
//  is indexed by TID, i.e. the first one or two elements are unused.

struct sub_rate {
  pthread_t thread;
  sem_t sem;
} sub_rate[1];

//*
//  Flag if the simulation has been terminated.

int simulationFinished = 0;

// Indication that the base rate thread has started
sem_t ext_mode_ready;

//*
//  This is the thread function of the base rate loop.
//  Fundamental sample time = 0.01s

#ifdef __cplusplus

void * base_rate(void * )
#else
  void * base_rate(void * )
#endif
{
  struct timespec now, next, last_now;
  struct timespec period = { 0U, 10000000U };// 0.01 seconds

  boolean_T eventFlags[1];             // Model has 1 rates
  int_T taskCounter[1] = { 0 };

  int_T OverrunFlags[1];
  int step_sem_value;
  int_T i;

  // assign timing stats
  timing.fundamentelSampleTime = 0.01F;
  timing.meanSampleTime = 0.01F;

  // External mode
  rtSetTFinalForExtMode(&rtmGetTFinal(myTMSI_AnnaSparapani_M));
  rtExtModeCheckInit(1);

  {
    boolean_T rtmStopReq = false;
    rtExtModeWaitForStartPkt(myTMSI_AnnaSparapani_M->extModeInfo, 1, &rtmStopReq);
    if (rtmStopReq) {
      rtmSetStopRequested(myTMSI_AnnaSparapani_M, true);
    }
  }

  rtERTExtModeStartMsg();
  CHECKE(sem_post(&ext_mode_ready));
  clock_gettime(CLOCK_MONOTONIC, &next);
  last_now = next;

  // Main loop, running until all the threads are terminated
  while (rtmGetErrorStatus(myTMSI_AnnaSparapani_M) == NULL &&
         !rtmGetStopRequested(myTMSI_AnnaSparapani_M)) {
    // Check subrate overrun, set rates that need to run this time step

    // Trigger sub-rate threads

    // Execute base rate step
    myTMSI_AnnaSparapani_step();
    rtExtModeCheckEndTrigger();
    do {
      next.tv_sec += period.tv_sec;
      next.tv_nsec += period.tv_nsec;
      if (next.tv_nsec >= 1000000000) {
        next.tv_sec++;
        next.tv_nsec -= 1000000000;
      }

      clock_gettime(CLOCK_MONOTONIC, &now);

      // update timing statistics
      timing.numElapsedSamples++;
      timing.lastElapsedTime = (now.tv_sec - last_now.tv_sec) +
        (now.tv_nsec - last_now.tv_nsec) / 1000000000.0F;
      timing.meanSampleTime = 0.99F * timing.meanSampleTime + 0.01F *
        timing.lastElapsedTime;
      timing.spareTime = (next.tv_sec - now.tv_sec) +
        (next.tv_nsec - now.tv_nsec) / 1000000000.0F;
      last_now = now;

      //fprintf(stderr, "elapsedTime = %f s, meanSampleTime = %f\n", timing.lastElapsedTime, timing.meanSampleTime);
      if (now.tv_sec > next.tv_sec ||
          (now.tv_sec == next.tv_sec && now.tv_nsec > next.tv_nsec)) {
        uint32_T usec = (now.tv_sec - next.tv_sec) * 1000000 + (now.tv_nsec -
          next.tv_nsec)/1000;
        fprintf(stderr, "Base rate (0.01s) overrun by %d us\n", usec);
        timing.overruns++;
        next = now;
        continue;
      }
    } while (0);

    clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &next, NULL);
  }

  simulationFinished = 1;

  // Final step
  for (i = 1; i < 1; i++) {
    sem_post(&sub_rate[i].sem);
    sem_post(&sub_rate[i].sem);
  }

  return 0;
}

//*
//  This is the main function of the model.
//  Multirate - Multitasking case main file

int_T main(int_T argc, const char_T *argv[])
{
  const char_T *errStatus;
  int_T i;
  pthread_attr_t attr;
  struct sched_param sched_param;

  // External mode
  // rtERTExtModeParseArgs(argc, argv);
  rtExtModeParseArgs(argc, argv, NULL);
  CHECKE(sem_init(&ext_mode_ready, 0, 0));
  CHECKE(mlockall(MCL_FUTURE));

  // Initialize model
  myTMSI_AnnaSparapani_initialize();
  simulationFinished = 0;

  // Prepare task attributes
  CHECK0(pthread_attr_init(&attr));
  CHECK0(pthread_attr_setinheritsched(&attr, PTHREAD_EXPLICIT_SCHED));
  CHECK0(pthread_attr_setschedpolicy(&attr, SCHED_FIFO));

  // Starting the base rate thread
  sched_param.sched_priority = MAX_PRIO;
  CHECK0(pthread_attr_setschedparam(&attr, &sched_param));
  CHECK0(pthread_create(&base_rate_thread, &attr, base_rate, NULL));
  CHECK0(pthread_attr_destroy(&attr));

  // External mode
  CHECKE(sem_wait(&ext_mode_ready));
  signal(SIGINT, abortHandler);        // important for letting the destructor be called.
  while (rtmGetErrorStatus(myTMSI_AnnaSparapani_M) == NULL &&
         !rtmGetStopRequested(myTMSI_AnnaSparapani_M)) {
    rtExtModeOneStep(rtmGetRTWExtModeInfo(RT_MDL), NUMST, (boolean_T *)
                     &rtmGetStopRequested(RT_MDL));
    usleep(10000U);
  }

  // Wait for threads to finish
  pthread_join(base_rate_thread, NULL);
  rtExtModeShutdown(1);

  // Terminate model
  myTMSI_AnnaSparapani_terminate();
  errStatus = rtmGetErrorStatus(myTMSI_AnnaSparapani_M);
  if (errStatus != NULL && strcmp(errStatus, "Simulation finished")) {
    if (!strcmp(errStatus, "Overrun")) {
      printf("ISR overrun - sampling rate too fast\n");
    }

    return(1);
  }

  return 0;
}

// Local Variables:
// compile-command: "make -f myTMSI_AnnaSparapani.mk"
// End:

//
// File trailer for generated code.
//
// [EOF]
//
