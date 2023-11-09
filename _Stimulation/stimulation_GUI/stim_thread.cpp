#include <QThread>
#include <QtCore>
#include "headers.h"
#include "globals.h"

stim_Thread::stim_Thread(QObject *parent):
    QThread(parent)
{
    connect(this, &stim_Thread::stopThread, this, &stim_Thread::stopStimulation);
    //connect(this, &stim_Thread::currentValueChanged,*myProtocol1, &Protocol1::updateLCD); TO FIX
    //-> how to communicate with interfaces? problem because they are static?
}

void stim_Thread::run(){

    if(!calibrated){ // INITIALIZE THE STIMULATION
        cout<<"Initializing the serial connection"<<endl;
        // Modify with the name of your port
        const char *port_name = "/dev/ttyUSB0"; // "/dev/RehamoveStim-right"

        // Open serial port
        stimulator1.device = {};

        bool check_open = smpt_open_serial_port(&stimulator1.device, port_name);
        cout << "Check open = " << check_open << endl;

        stimulator1.init_stimulation(&stimulator1.device);

        // Struct for ll_channel_config command
        for(int i = 0; i < 4; i++) {
            stimulator1.channels[i] = {};
        }

        stimulator stimulatorClass;
        stimulatorClass.channelsInitialization(stimulator1, number_of_points);

        calibrated=true;
        stimulating = true; // set the stimulating flag to true so that it runs the stimulation part of the thread
        cout<<"Raising stimulation flag"<< endl;
    }

        switch(protocol){

            case 1: // CODE TO RUN THE PROTOCOL 1

                cout<<"I'm running protocol 1"<<endl;
                struct timespec t_start; // starting time of new step
                struct timespec t_next; // time to wait before repeating thread loop
                struct timespec t_period; // loop duration insiede thread

                t_period.tv_sec = 0;
                t_period.tv_nsec = DEFAULT_LOOP_TIME_NS; //1ms

                clock_gettime( CLOCK_MONOTONIC, &t_next);
                clock_gettime( CLOCK_MONOTONIC, &t_start);

                while(stimulating) {
                    t_next = addition(t_next, t_period);

                    if(loop_count%interstimulus_distance == 0 && loop_count>60000) // repeats every interStimDistance -> every 2s a single pulse is sent (pause of 60s when current increases)
                    {
                        if(numStimuli<totNStimuli) {
                            cout << " STIMULUS sent " << endl;
                            stimulator1.channels[0].packet_number = smpt_packet_number_generator_next(&stimulator1.device);

                            stimulator1.channels[0].points[0].current =  current;
                            stimulator1.channels[0].points[0].time = PW;
                            stimulator1.channels[0].points[1].current =  -current;
                            stimulator1.channels[0].points[1].time = PW;

                            bool check_sent = smpt_send_ll_channel_config(&stimulator1.device, &stimulator1.channels[0]);

                            numStimuli = numStimuli + 1;
                            printf("N°cycle: %d\n",numStimuli);
                        }
                    }

                    if(numStimuli >= totNStimuli) { // after 10 stimuli: either increase current or stop
                        if (current+current_increment >= maxCurrent) stimulating = false;
                        else
                        {
                            current = current+current_increment;
                            emit currentValueChanged();
                            printf("Current: %d\n", current);
                            loop_count=0;
                            numStimuli=0;
                        }
                    }

                    loop_count++;
                    clock_nanosleep ( CLOCK_MONOTONIC, TIMER_ABSTIME, &t_next, nullptr );
                }

                break;

            case 2: // CODE TO RUN THE PROTOCOL 2
                cout<<"I'm running protocol 2"<<endl;
                break;
            case 3: // CODE TO RUN PROTOCOL 3
                cout<<"I'm running protocol 3"<<endl;
                break;
            case 4: // CODE TO RUN PROTOCOL 4
                cout<<"I'm running protocol 4"<<endl;
                break;
       }
}

void stim_Thread::stopStimulation(){
    stimulating=false;

    // CLEAN UP VARIABLES
    current = 3; // reset current
    current_increment = 2;
    numStimuli=0;
}
