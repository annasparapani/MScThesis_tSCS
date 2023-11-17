// GLOBALS.CPP
// the file defines all global variables

#include "globals.h"
#include "headers.h"


int protocol=0;

int current=5;
int current_increment=2;
int interstimulus_distance=2000; // distance between stimuli (ms), default for protocol 1
int interpulse_interval=50; //distance between two close pulses in protocol 2 (ms)
int current_minRamp = 10;
int increment_minRamp= 2;
int current_maxRamp = current_minRamp;
int current_maxContinuous = 150;


stimulator stimulator1;
int number_of_points=2;

stim_Thread *myThread;
