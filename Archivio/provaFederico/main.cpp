#include <QCoreApplication>

#include <time.h>
#include <sys/time.h>
#include <cstdlib>
#include <iostream>
#include <pthread.h>
#include <signal.h>
#include <qconfig.h>
#include <ctime>
#include <limits.h>

#include "smpt_ll_client.h"
#include "smpt_client.h"
#include "smpt_ml_client.h"
#include "smpt_messages.h"
#include "smpt_packet_number_generator.h"
#include "smpt_ll_packet_validity.h"

#include "stimulator.h"
using namespace std;

#define DEFAULT_LOOP_TIME_NS 1000000L
#define UNUSED(x) (void) (x)

stimulator stimulator1;
uint8_t number_of_points = 2;
int oneSec = 1000;
bool running = true;

int stimF = 50;
int stimT = 20; //[ms]
double PW = 1000; //[1000us = 1ms]
int thisCurrent = 0;

// single stimuli
int interStimDistance = 2000; //[ms] (2 s)
int totNumberStimuli = 10;
int minCurrent = 70; //[mA]
int maxCurrent = 100; //[mA] - safety measure: ramp interrupted whenever subject wants

// 2 close stimuli
int interStimDistance_closeStimuli = 5000; //[ms] (5 s)
int DistCloseStimuli = 50; //[ms]
int maxTolerance = 80; // ---- TO SET ----
int currentDoubleStimuli = 0.8 * maxTolerance;

// continuous stim
int minCurrent_continuous = 10 ; //[mA]
int maxCurrent_continuous = 50; //[mA] - safety measure: ramp interrupted whenever subject wants
int selectedCurrent_continuous = 20 ; //[mA] - current selected to be delivered for 10 minutes

timespec addition(timespec a, timespec b) {
    timespec r;

    if(a.tv_nsec + b.tv_nsec <= 999999999) {
        r.tv_nsec = a.tv_nsec + b.tv_nsec;
        r.tv_sec = a.tv_sec + b.tv_sec;
    }
    else {
        int c = (a.tv_nsec + b.tv_nsec)/1000000000;
        r.tv_nsec = a.tv_nsec + b.tv_nsec - 1000000000*c;
        r.tv_sec = a.tv_sec + b.tv_sec + c;
    }

    return r;
}

long time_now(void)
{
    struct timeval start_;

    long u1_ = 0;

    /* Get start time for timing measurements */
    gettimeofday(&start_, NULL);

    u1_ = start_.tv_sec * 1000 + start_.tv_usec / 1000;

    return (long) u1_;
}

void initStimulation() {

    // Modify with the name of your port
    const char *port_name1 = "/dev/ttyUSB0"; // "/dev/RehamoveStim-right"

    // Open serial port
    stimulator1.device = {};

    bool check_open1 = smpt_open_serial_port(&stimulator1.device, port_name1);
    cout << "Check open = " << check_open1 << endl;

    stimulator1.init_stimulation(&stimulator1.device);

    // Struct for ll_channel_config command
    for(int i = 0; i < 4; i++) {
        stimulator1.channels[i] = {};
    }

    stimulator stimulatorClass;
    stimulatorClass.channelsInitialization(stimulator1, number_of_points);
}

void myInterruptHandler (int signum) {
    printf ("ctrl-c has been pressed. Programs will be terminated in sequence.\n");
    running = false;
}

void *threadPeriodicStim_ramp(void *a)
{ // PERIODIC stimulation
    UNUSED(a);
    signal(SIGINT, myInterruptHandler);

    struct timespec t_start; // starting time of new step
    struct timespec t_next; // time to wait before repeating thread loop
    struct timespec t_period; // loop duration insiede thread

    unsigned long int loop_count = 0;

    t_period.tv_sec = 0;
    t_period.tv_nsec = DEFAULT_LOOP_TIME_NS; //1ms (define)

    clock_gettime( CLOCK_MONOTONIC, &t_next);
    clock_gettime( CLOCK_MONOTONIC, &t_start);
    int incremento = 1; //[mA]
    thisCurrent = minCurrent_continuous;

    while(running)
    {
        t_next = addition(t_next, t_period);

        if(loop_count%stimT == 0) // repeats every stimT (every 20ms = 50Hz)
        {
            stimulator1.channels[0].packet_number = smpt_packet_number_generator_next(&stimulator1.device);

            stimulator1.channels[0].points[0].current =  thisCurrent;
            stimulator1.channels[0].points[0].time = PW;
            stimulator1.channels[0].points[1].current =  -thisCurrent;
            stimulator1.channels[0].points[1].time = PW;

            bool check_sent = smpt_send_ll_channel_config(&stimulator1.device, &stimulator1.channels[0]);
        }


        if(loop_count%3000 == 0) // after 3s either increment current or stop (if max current was reached)
        {
            if (thisCurrent+incremento >= maxCurrent_continuous) running = false;
            else
            {
                thisCurrent = thisCurrent+incremento;
                printf("Current: %d\n", thisCurrent);
                loop_count=0;
            }
        }

        loop_count++;
        clock_nanosleep ( CLOCK_MONOTONIC, TIMER_ABSTIME, &t_next, nullptr );
    }
    return 0;
}

void *threadPeriodicStim_constant10s(void *a)
{ // PERIODIC stimulation
    UNUSED(a);
    signal(SIGINT, myInterruptHandler);

    struct timespec t_start; // starting time of new step
    struct timespec t_next; // time to wait before repeating thread loop
    struct timespec t_period; // loop duration insiede thread

    unsigned long int loop_count = 1;

    t_period.tv_sec = 0;
    t_period.tv_nsec = DEFAULT_LOOP_TIME_NS; //1ms (define)

    clock_gettime( CLOCK_MONOTONIC, &t_next);
    clock_gettime( CLOCK_MONOTONIC, &t_start);

    thisCurrent = selectedCurrent_continuous;

    while(running)
    {
        t_next = addition(t_next, t_period);

        if(loop_count%stimT == 0) // repeats every stimT (every 20ms = 50Hz)
        {
            stimulator1.channels[0].packet_number = smpt_packet_number_generator_next(&stimulator1.device);

            stimulator1.channels[0].points[0].current =  thisCurrent;
            stimulator1.channels[0].points[0].time = PW;
            stimulator1.channels[0].points[1].current =  -thisCurrent;
            stimulator1.channels[0].points[1].time = PW;

            bool check_sent = smpt_send_ll_channel_config(&stimulator1.device, &stimulator1.channels[0]);
        }


        if(loop_count%600000 == 0) // after 600s = 10min -> stop stimulation
        {
            running = false;
        }

        loop_count++;
        clock_nanosleep ( CLOCK_MONOTONIC, TIMER_ABSTIME, &t_next, nullptr );
    }
    return 0;
}

void *threadSingleStim(void *a) { // SINGLE stimulation
    UNUSED(a);

    stimulator1.channels[0].packet_number = smpt_packet_number_generator_next(&stimulator1.device);

    stimulator1.channels[0].points[0].current =  thisCurrent;
    stimulator1.channels[0].points[0].time = PW;
    stimulator1.channels[0].points[1].current =  -thisCurrent;
    stimulator1.channels[0].points[1].time = PW;

    bool check_sent = smpt_send_ll_channel_config(&stimulator1.device, &stimulator1.channels[0]);

    return 0;
}

void *threadTenSingleStim(void *a) {
    UNUSED(a);
    signal(SIGINT, myInterruptHandler);

    struct timespec t_start; // starting time of new step
    struct timespec t_next; // time to wait before repeating thread loop
    struct timespec t_period; // loop duration insiede thread

    unsigned long int loop_count = 58000;
    t_period.tv_sec = 0;
    t_period.tv_nsec = DEFAULT_LOOP_TIME_NS; //1ms

    clock_gettime( CLOCK_MONOTONIC, &t_next);
    clock_gettime( CLOCK_MONOTONIC, &t_start);

    int incremento=5; //[mA]
    int numStimuli = 0;

    thisCurrent = minCurrent;

    while(running) {
        t_next = addition(t_next, t_period);

        if(loop_count%interStimDistance == 0 && loop_count>60000) // repeats every interStimDistance -> every 2s a single pulse is sent (pause of 60s when current increases)
        {
            if(numStimuli<totNumberStimuli) {
                cout << " STIMULUS sent " << endl;
                stimulator1.channels[0].packet_number = smpt_packet_number_generator_next(&stimulator1.device);

                stimulator1.channels[0].points[0].current =  thisCurrent;
                stimulator1.channels[0].points[0].time = PW;
                stimulator1.channels[0].points[1].current =  -thisCurrent;
                stimulator1.channels[0].points[1].time = PW;

                bool check_sent = smpt_send_ll_channel_config(&stimulator1.device, &stimulator1.channels[0]);

                numStimuli = numStimuli + 1;
                printf("N°cycle: %d\n",numStimuli);
            }
        }

        if(numStimuli >= totNumberStimuli) { // after 10 stimuli: either increase current or stop
            if (thisCurrent+incremento >= maxCurrent) running = false;
            else
            {
                thisCurrent = thisCurrent+incremento;
                printf("Current: %d\n", thisCurrent);
                loop_count=0;
                numStimuli=0;
            }
        }

        loop_count++;
        clock_nanosleep ( CLOCK_MONOTONIC, TIMER_ABSTIME, &t_next, nullptr );
    }
    return 0;
}

void *threadCloseStimuli(void *a)
{ // 10 pulses stimulation (2 stimuli 50ms interstimuli)
    UNUSED(a);
    signal(SIGINT, myInterruptHandler);

    struct timespec t_start; // starting time of new step
    struct timespec t_next; // time to wait before repeating thread loop
    struct timespec t_period; // loop duration insiede thread

    unsigned long int loop_count = 0;

    t_period.tv_sec = 0;
    t_period.tv_nsec = DEFAULT_LOOP_TIME_NS; //1ms

    clock_gettime( CLOCK_MONOTONIC, &t_next);
    clock_gettime( CLOCK_MONOTONIC, &t_start);

    thisCurrent = currentDoubleStimuli;

    int flag = 0;
    int numStimuli = 0;
    int rep=0;

    while(running)
    {
        t_next = addition(t_next, t_period);

        if(loop_count%DistCloseStimuli == 0) // repeats every DistCloseStimuli (50ms)
        {
            if(rep<2)
            {
                stimulator1.channels[0].packet_number = smpt_packet_number_generator_next(&stimulator1.device);

                // BIFASICO
                stimulator1.channels[0].points[0].current =  thisCurrent;
                stimulator1.channels[0].points[0].time = PW;
                stimulator1.channels[0].points[1].current =  -thisCurrent;
                stimulator1.channels[0].points[1].time = PW;

                bool check_sent = smpt_send_ll_channel_config(&stimulator1.device, &stimulator1.channels[0]);
                printf("Stimolo inviato\n");

                rep++;
                flag = 1;
            }

            if (rep==2 && flag == 1) // 2 close stimuli were sent
            {
                numStimuli = numStimuli + 1;
                printf("N°cycle: %d\n",numStimuli);
            }

            flag = 0;
        }

        if(loop_count%interStimDistance_closeStimuli==0) rep=0; // after 5s allows to send again pulses

        if(numStimuli >= totNumberStimuli)
            running = false;

        loop_count++;
        clock_nanosleep ( CLOCK_MONOTONIC, TIMER_ABSTIME, &t_next, nullptr );
    }
    return 0;
}


int main()
{
    pthread_t thread;
    initStimulation();

    running = true;

    pthread_create(&thread, NULL, threadTenSingleStim, nullptr);

//    pthread_create(&thread, NULL, threadCloseStimuli, nullptr);

//    pthread_create(&thread, NULL, threadPeriodicStim_ramp, nullptr);

//    pthread_create(&thread, NULL, threadPeriodicStim_constant10s, nullptr);

    pthread_join(thread, NULL);
}
