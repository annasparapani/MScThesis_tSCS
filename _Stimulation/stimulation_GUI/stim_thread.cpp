#include <QThread>
#include <QtCore>
#include "headers.h"
#include "globals.h"

stim_Thread::stim_Thread(QObject *parent):
    QThread(parent)
{
    connect(this, &stim_Thread::stopThread, this, &stim_Thread::stopStimulation);
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
        cout<<"check one"<<endl;
        // Struct for ll_channel_config command
        for(int i = 0; i < 4; i++) {
            stimulator1.channels[i] = {};
        }
        cout<<"check two"<<endl;
        stimulator stimulatorClass;
        if (protocol<5){
            stimulatorClass.channelsInitialization(stimulator1, number_of_points); // initialize to 2 points in the case of std stimulation
        } else stimulatorClass.channelsInitialization(stimulator1, 16); // initialize to 16 points in the case of triangular wave
        cout<<"check three"<<endl;
        calibrated=true;
        stimulating = true; // set the stimulating flag to true so that it runs the stimulation part of the thread
        cout<<"Raising stimulation flag"<< endl;

    }
    // DEFINE TIME STRUCTS
    struct timespec t_start; // starting time of new step
    struct timespec t_next; // time to wait before repeating thread loop
    struct timespec t_period; // loop duration inside thread

        switch(protocol){

            case 1: // CODE TO RUN THE PROTOCOL 1

                cout<<"I'm running protocol 1"<<endl;
                cout<<"Current: " << current << endl;
                cout << "PW: " << PW<<" mus"<<endl;

                t_period.tv_sec = 0;
                t_period.tv_nsec = DEFAULT_LOOP_TIME_NS; //1ms

                clock_gettime( CLOCK_MONOTONIC, &t_next);
                clock_gettime( CLOCK_MONOTONIC, &t_start);

                loop_count = 58000;

                while(stimulating) {
                    t_next = addition(t_next, t_period);

                    if(loop_count%interstimulus_distance == 0 && loop_count>60000) // repeats every interStimDistance -> every 2s a single pulse is sent (pause of 60s when current increases)
                    {
                        if(numStimuli<totNStimuli) {
                            cout << " STIMULUS sent " << endl;
                            stimulator1.channels[stim_Channel].packet_number = smpt_packet_number_generator_next(&stimulator1.device);

                            stimulator1.channels[stim_Channel].points[0].current =  current;
                            stimulator1.channels[stim_Channel].points[0].time = PW;
                            stimulator1.channels[stim_Channel].points[1].current =  -current;
                            stimulator1.channels[stim_Channel].points[1].time = PW;

                            bool check_sent = smpt_send_ll_channel_config(&stimulator1.device, &stimulator1.channels[stim_Channel]);

                            numStimuli = numStimuli + 1;
                            emit numStimuliChanged();
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
                            emit pauseStarted();
                        }
                    }

                    loop_count++;
                    clock_nanosleep ( CLOCK_MONOTONIC, TIMER_ABSTIME, &t_next, nullptr );
                }

                break;

            case 2: // CODE TO RUN THE PROTOCOL 2
                cout<<"I'm running protocol 2"<<endl;
                cout << "Current: "<< current << endl;

                loop_count = 0;

                    t_period.tv_sec = 0;
                    t_period.tv_nsec = DEFAULT_LOOP_TIME_NS; //1ms

                    clock_gettime( CLOCK_MONOTONIC, &t_next);
                    clock_gettime( CLOCK_MONOTONIC, &t_start);

                    numStimuli = 0;

                    while(stimulating){
                        t_next = addition(t_next, t_period);

                        if(loop_count%interpulse_interval == 0) // repeats every DistCloseStimuli (50ms)
                        {
                            if(rep<2)
                            {
                                stimulator1.channels[stim_Channel].packet_number = smpt_packet_number_generator_next(&stimulator1.device);

                                // BIFASICO
                                stimulator1.channels[stim_Channel].points[0].current =  current;
                                stimulator1.channels[stim_Channel].points[0].time = PW;
                                stimulator1.channels[stim_Channel].points[1].current =  -current;
                                stimulator1.channels[stim_Channel].points[1].time = PW;

                                bool check_sent = smpt_send_ll_channel_config(&stimulator1.device, &stimulator1.channels[stim_Channel]);
                                printf("Stimolo inviato\n");

                                rep++;
                                flag = 1;
                            }

                            if (rep==2 && flag == 1) // 2 close stimuli were sent
                            {
                                numStimuli = numStimuli + 1;
                                printf("N°cycle: %d\n", numStimuli);
                                emit numStimuliChanged();
                                emit pauseStarted();
                            }

                            flag = 0;
                        }

                        if(loop_count%interstimulus_distance==0) {
                            rep=0; // after 5s allows to send again pulses
                        }

                        if(numStimuli >= totNStimuli)
                            stimulating = false;

                        loop_count++;
                        clock_nanosleep ( CLOCK_MONOTONIC, TIMER_ABSTIME, &t_next, nullptr );
                    }
                    break;

            case 3: // CODE TO RUN PROTOCOL 3
                cout<<"I'm running protocol 3"<<endl;
                cout << "Current: "<< current << endl;
                cout << "Frequency: "<< (1000/stimT)<< " and stimT : " << stimT << endl;
                cout << "Ramp interval: " << (ramp_Interval/1000)<<" s"<<endl;
                cout << "PW: " << PW<<" mus"<<endl;

                current= current-current_increment;
                loop_count = 0;

                t_period.tv_sec = 0;
                t_period.tv_nsec = DEFAULT_LOOP_TIME_NS; //1ms (define)

                clock_gettime( CLOCK_MONOTONIC, &t_next);
                clock_gettime( CLOCK_MONOTONIC, &t_start);

                while(stimulating)
                {
                    t_next = addition(t_next, t_period);

                    if(loop_count%stimT == 0) // repeats every stimT (every 20ms = 50Hz)
                    {
                        stimulator1.channels[stim_Channel].packet_number = smpt_packet_number_generator_next(&stimulator1.device);

                        stimulator1.channels[stim_Channel].points[0].current =  current;
                        stimulator1.channels[stim_Channel].points[0].time = PW;
                        stimulator1.channels[stim_Channel].points[1].current =  -current;
                        stimulator1.channels[stim_Channel].points[1].time = PW;

                        bool check_sent = smpt_send_ll_channel_config(&stimulator1.device, &stimulator1.channels[stim_Channel]);
                    }


                    if(loop_count%ramp_Interval == 0) // after 3s either increment current or stop (if max current was reached)
                    {
                        if (current+current_increment >= current_maxContinuous) stimulating = false;
                        else
                        {
                            current += current_increment;
                            emit currentValueChanged();
                            printf("Current: %d and signal emitted \n", current);
                            loop_count=0;
                        }
                    }

                    loop_count++;
                    clock_nanosleep ( CLOCK_MONOTONIC, TIMER_ABSTIME, &t_next, nullptr );
                }


                break;
            case 4: // CODE TO RUN PROTOCOL 4
                cout << "I'm running protocol 4"<<endl;
                cout << "Current: "<< current <<"mA"<< endl;
                cout << "Period: "<< stimT <<"ms"<< endl;
                cout << "PW: "<< PW<<"mus"<<endl;

                loop_count = 1;

                t_period.tv_sec = 0;
                t_period.tv_nsec = DEFAULT_LOOP_TIME_NS; //1ms (define)

                clock_gettime( CLOCK_MONOTONIC, &t_next);
                clock_gettime( CLOCK_MONOTONIC, &t_start);

                while(stimulating)
                {
                    t_next = addition(t_next, t_period);

                    if(loop_count%stimT == 0) // repeats every stimT (every 20ms = 50Hz)
                    {
                        stimulator1.channels[stim_Channel].packet_number = smpt_packet_number_generator_next(&stimulator1.device);

                        stimulator1.channels[stim_Channel].points[0].current =  current;
                        stimulator1.channels[stim_Channel].points[0].time = PW;
                        stimulator1.channels[stim_Channel].points[1].current =  -current;
                        stimulator1.channels[stim_Channel].points[1].time = PW;

                        bool check_sent = smpt_send_ll_channel_config(&stimulator1.device, &stimulator1.channels[stim_Channel]);
                    }

                    if(loop_count%600000 == 0) // after 600s = 10min -> stop stimulation
                    {
                        stimulating = false;
                    }

                    loop_count++;
                    clock_nanosleep ( CLOCK_MONOTONIC, TIMER_ABSTIME, &t_next, nullptr );
                }
                break;

        case 5: // CODE TO RUN PROTOCOL 5 - triangular wave  currenlty not working
            cout<<"I'm running protocol 5"<<endl;
            cout << "Current: "<< current <<"mA"<< endl;
            cout << "StimT "<< stimT <<"ms"<< endl;
            this->PW = this->waveLength*1000/13;
            cout << "Pulse Width: "<< this->PW <<"micro s"<< endl;
            float increment = (current/14);
            loop_count = 1;

            t_period.tv_sec = 0;
            t_period.tv_nsec = DEFAULT_LOOP_TIME_NS; //1ms (define)

            clock_gettime( CLOCK_MONOTONIC, &t_next);
            clock_gettime( CLOCK_MONOTONIC, &t_start);

            while(stimulating)
            {
                t_next = addition(t_next, t_period);

                if(loop_count%stimT == 0) // repeats every stimT (every 20ms = 50Hz)
                {
                    cout << "Current: "<< current <<"mA"<< endl;
                    cout << "StimT "<< stimT << "ms"<<endl;
                    cout << "Pulse Width: "<< this->PW <<"micro s"<< endl;

                    stimulator1.channels[stim_Channel].packet_number = smpt_packet_number_generator_next(&stimulator1.device);

                    // Sending 16 points to build the triangular wave
                    stimulator1.channels[stim_Channel].points[0].current = increment*1;
                    stimulator1.channels[stim_Channel].points[0].time = PW;
                    cout << "Current: "<< increment*1 << endl;
                    stimulator1.channels[stim_Channel].points[1].current=increment*2;
                    stimulator1.channels[stim_Channel].points[1].time = PW;
                    cout << "Current: "<< increment*2 << endl;
                    stimulator1.channels[stim_Channel].points[2].current=increment*3;
                    stimulator1.channels[stim_Channel].points[2].time = PW;
                    cout << "Current: "<< increment*3 << endl;
                    stimulator1.channels[stim_Channel].points[3].current=increment*4;
                    stimulator1.channels[stim_Channel].points[3].time = PW;
                    cout << "Current: "<< increment*4 << endl;
                    stimulator1.channels[stim_Channel].points[4].current=increment*5;
                    stimulator1.channels[stim_Channel].points[4].time = PW;
                    cout << "Current: "<< increment*5 << endl;
                    stimulator1.channels[stim_Channel].points[5].current=increment*6;
                    stimulator1.channels[stim_Channel].points[5].time = PW;
                    cout << "Current: "<< increment*6 << endl;
                    stimulator1.channels[stim_Channel].points[6].current=increment*7;
                    stimulator1.channels[stim_Channel].points[6].time = PW;
                    cout << "Current: "<< increment*7 << endl;
                    stimulator1.channels[stim_Channel].points[7].current=increment*8;
                    stimulator1.channels[stim_Channel].points[7].time = PW;
                    cout << "Current: "<< increment*8 << endl;
                    stimulator1.channels[stim_Channel].points[8].current=increment*9;
                    stimulator1.channels[stim_Channel].points[8].time = PW;
                    cout << "Current: "<< increment*9 << endl;
                    stimulator1.channels[stim_Channel].points[9].current=increment*10;
                    stimulator1.channels[stim_Channel].points[9].time = PW;
                    cout << "Current: "<< increment*10 << endl;
                    stimulator1.channels[stim_Channel].points[10].current=increment*11;
                    stimulator1.channels[stim_Channel].points[10].time = PW;
                    cout << "Current: "<< increment*11 << endl;
                    stimulator1.channels[stim_Channel].points[11].current=increment*12;
                    stimulator1.channels[stim_Channel].points[11].time = PW;
                    cout << "Current: "<< increment*12 << endl;
                    stimulator1.channels[stim_Channel].points[12].current=increment*13;
                    stimulator1.channels[stim_Channel].points[12].time = PW;
                    cout << "Current: "<< increment*13 << endl;
                    stimulator1.channels[stim_Channel].points[13].current=increment*14;
                    stimulator1.channels[stim_Channel].points[13].time = PW;
                    cout << "Current: "<< increment*14 << endl;
                    stimulator1.channels[stim_Channel].points[14].current=0;
                    stimulator1.channels[stim_Channel].points[14].time = PW;
                    cout << "Current: "<< 0 << endl;
                    stimulator1.channels[stim_Channel].points[15].current=-current;
                    stimulator1.channels[stim_Channel].points[15].time = this->waveLength*1000; // this is going to be in overflow for sure, max PW = 64000mus = 64ms
                                                                                    // if complete balance is needed, more points for the negative pulse are needed
                    cout << "Current: "<< -current<< endl;
                    cout << "---------------------------------------"<< endl;

                    bool check_sent = smpt_send_ll_channel_config(&stimulator1.device, &stimulator1.channels[stim_Channel]);
                }
                loop_count++;
                clock_nanosleep ( CLOCK_MONOTONIC, TIMER_ABSTIME, &t_next, nullptr );
               /* if(!wave_formed){

                    stimulator1.channels[stim_Channel].packet_number = smpt_packet_number_generator_next(&stimulator1.device);

                    stimulator1.channels[stim_Channel].points[0].current = current;
                    stimulator1.channels[stim_Channel].points[0].time = PW;

                    cout << "Current: "<< current << endl;
                    bool check_sent = smpt_send_ll_channel_config(&stimulator1.device, &stimulator1.channels[stim_Channel]);

                    current+=direction*current_increment;

                    if(current>=current_maxContinuous||current<=0){
                        direction *=-1;
                    }

                    if(current<=0)  wave_formed=1;
                }
                loop_count++;
                clock_nanosleep ( CLOCK_MONOTONIC, TIMER_ABSTIME, &t_next, nullptr );
            }*/
            }
            break;

       }
}

void stim_Thread::stopStimulation(){

    stimulating=false;
    // CLEAN UP VARIABLES
    current_increment = 2;
    numStimuli=0;
}
