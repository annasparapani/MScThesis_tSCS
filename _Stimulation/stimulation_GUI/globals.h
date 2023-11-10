#ifndef GLOBALS_H
#define GLOBALS_H

#include "headers.h"

#define DEFAULT_LOOP_TIME_NS 1000000L
#define UNUSED(x) (void) (x)

extern int protocol;

extern int current;
extern int current_increment;
extern int interstimulus_distance; // distance between stimuli
extern int interpulse_interval; // interval between two stimuli in protocol 2
extern int current_minRamp;
extern int increment_minRamp;
extern int current_maxRamp;
extern int current_maxContinuous;
extern int totNStimuli;
// VARIABLES for the STIMULATOR & WAVE
extern stimulator stimulator1;
extern int number_of_points; // number of points to impose current (square wave = 2)

//THREAD
extern stim_Thread *myThread;


#endif // GLOBALS_H
