#include "smpt_ml_client.h"
#include "stdio.h"
#include <iostream>
#include <stdlib.h>
using namespace std;

static void mid_level_stimulation(const char *port_name);
static void fill_ml_init(Smpt_device * const device, Smpt_ml_init *const ml_init);
static void fill_ml_update(Smpt_device * const device, Smpt_ml_update *const ml_update);
static void fill_ml_get_current_data(Smpt_device * const device, Smpt_ml_get_current_data *const ml_get_current_data);

int nPoints = 2; // number of points defined
int rampPoints=3; // points that compose the ramp to reach the top of the triangular wave (.)
int currentMax=4; // current reached at the top of the triangular wave (mA)
int period = 2000; // period of stimulation repetition (ms)

int main()
{
    /* EDIT: Change to the virtual com port of your device */
    const char *port_name = "/dev/ttyUSB0";;

    mid_level_stimulation(port_name);
    return 0;
}

void mid_level_stimulation(const char *port_name)
{
    cout<<"Entering mid level stimulation"<<endl;
    Smpt_device device = {0};
    smpt_open_serial_port(&device, port_name);

    Smpt_ml_init ml_init = {0};           /* Struct for ml_init command */
    fill_ml_init(&device, &ml_init);
    smpt_send_ml_init(&device, &ml_init); /* Send the ml_init command to the stimulation unit */

    cout<<"Device initialized"<<endl;
    cout<<"Starting Stimulation"<<endl;
    cout<<"Current: "<< currentMax<<"mA"<<endl;
    cout << "N° points: " << nPoints << " at +- "<<currentMax<<"mA"<< endl;
    cout << "Single pulse length: 1 ms"<<endl;
    cout << "Period of the entire wave: "<< period << "ms"<<endl;

    Smpt_ml_update ml_update = {0};       /* Struct for ml_update command */
    fill_ml_update(&device, &ml_update);
    smpt_send_ml_update(&device, &ml_update);

    Smpt_ml_get_current_data ml_get_current_data = {0};
    fill_ml_get_current_data(&device, &ml_get_current_data);
    smpt_send_ml_get_current_data(&device, &ml_get_current_data);

    smpt_send_ml_stop(&device, smpt_packet_number_generator_next(&device));

    smpt_close_serial_port(&device);
}

void fill_ml_init(Smpt_device *const device, Smpt_ml_init *const ml_init)
{
    /* Clear ml_init struct and set the data */
    smpt_clear_ml_init(ml_init);
    ml_init->packet_number = smpt_packet_number_generator_next(device);
}

void fill_ml_update(Smpt_device *const device, Smpt_ml_update *const ml_update)
{
    /* Clear ml_update and set the data */
    smpt_clear_ml_update(ml_update);
    ml_update->enable_channel[Smpt_Channel_Red] = true;  /* Enable channel red */
    ml_update->packet_number = smpt_packet_number_generator_next(device);

    ml_update->channel_config[Smpt_Channel_Red].number_of_points = nPoints;  /* < [1 - 16] Number of points */
    ml_update->channel_config[Smpt_Channel_Red].ramp = rampPoints;           /*< [0-15] pulses \n
                                                                                Number of linear increasing lower current pulse pattern
                                                                                until the full current is reached\n for each point */
    ml_update->channel_config[Smpt_Channel_Red].period = period;            /*< [0,5–16383] ms \n ([<0.1-2000] Hz)
                                                                                Time between two pulse patterns
                                                                                Frequency: 1/(period*1000) Hz */
    /* Set the stimulation pulse for the first point*/
    ml_update->channel_config[Smpt_Channel_Red].points[0].current = currentMax; // current = 5mA, [-150 .. -149.5 .. 150] mA current
    ml_update->channel_config[Smpt_Channel_Red].points[0].time = 1000; //[0 .. 1 .. 4095] µs duration. (Every value < 10 = 10 µs)

    /* Second point, pause 100 µs */
   // ml_update->channel_config[Smpt_Channel_Red].points[1].time = 100;

    /* Second point */
    ml_update->channel_config[Smpt_Channel_Red].points[1].current = -currentMax;
    ml_update->channel_config[Smpt_Channel_Red].points[1].time = 1000;
}

void fill_ml_get_current_data(Smpt_device *const device, Smpt_ml_get_current_data *const ml_get_current_data)
{
    ml_get_current_data->packet_number = smpt_packet_number_generator_next(device);
    ml_get_current_data->data_selection[Smpt_Ml_Data_Stimulation] = true; /* get stimulation data */
}
