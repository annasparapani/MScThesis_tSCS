#ifndef STIM_THREAD_H
#define STIM_THREAD_H
#include <QThread>
#include "headers.h"

class stim_Thread:public QThread
{
    Q_OBJECT
signals:
    void NumberChanged(int);
    void stopThread();
    void currentValueChanged();
    void numStimuliChanged();
    void pauseStarted();

public:
    explicit stim_Thread(QObject *parent=0);

    bool stimulating=false;
    bool calibrated=false;
    bool check_send;
    bool check_data;
    bool check_close;

    int stim_Channel = 0;
    // PROTOCOL 1 parameters
    int totNStimuli=10; //number of stimuli delivered in protocol 1
    int PW=1000; //1ms PW for protocol 1
    int maxCurrent=150; //max current for safety
    int numStimuli = 0;
    unsigned long int loop_count = 0;


    //PROTOCOL 2 parameters
    int flag = 0;
    int rep=0;

    // PROTOCOL 3 parameters
    int stimT = 20; //[ms]
    int ramp_Interval = 3000; // [ms]

    // PROTOCOL 5 - triangular stimulation - parameters
    int waveLength=200; //[ms] length of triangular wave
    int stepsNo;
    bool wave_formed=false;
    int direction=1;


    void run();
    void stimulation();

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


public slots:
    void stopStimulation();

};

#endif // STIM_THREAD_H
