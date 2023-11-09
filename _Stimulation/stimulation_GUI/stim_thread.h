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
    void currentValueChanged(); //generated every time the imposed current value changes
                                // and used to update the value displayed on the lcd display

public:
    explicit stim_Thread(QObject *parent=0);

    bool stimulating=false;
    bool calibrated=false;
    bool check_send;
    bool check_data;
    bool check_close;

    // PROTOCOL 1 parameters
    int totNStimuli=10; //number of stimuli delivered in protocol 1
    int PW=1000; //1ms PW for protocol 1
    int maxCurrent=150; //max current for safety
    int numStimuli = 0;
    unsigned long int loop_count = 58000;

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
