#include "stimulator.h"

stimulator::stimulator()
{

}

void stimulator::channelsInitialization(stimulator &stim, uint8_t nPoints)
{
    stim.channels[0].enable_stimulation = true;
    stim.channels[0].channel = Smpt_Channel_Red;
    stim.channels[0].number_of_points = nPoints;

    stim.channels[1].enable_stimulation = true;
    stim.channels[1].channel = Smpt_Channel_Blue;
    stim.channels[1].number_of_points = nPoints;

    stim.channels[2].enable_stimulation = true;
    stim.channels[2].channel = Smpt_Channel_Black;
    stim.channels[2].number_of_points = nPoints;

    stim.channels[3].enable_stimulation = true;
    stim.channels[3].channel = Smpt_Channel_White;
    stim.channels[3].number_of_points = nPoints;
}

void stimulator::init_stimulation(Smpt_device *const device)
{
    Smpt_ll_init ll_init = {};  /* Struct for ll_init command */
    Smpt_ll_init_ack ll_init_ack = {};  /* Struct for ll_init_ack response */
    Smpt_ack ack = {};  /* Struct for general response */

    smpt_clear_ll_init(&ll_init);
    ll_init.packet_number = smpt_packet_number_generator_next(device);

    smpt_send_ll_init(device, &ll_init);   /* Send the ll_init command to the stimulation unit */

    while (!smpt_new_packet_received(device)) { /* busy waits for Ll_init_ack response */}

    smpt_clear_ack(&ack);
    smpt_last_ack(device, &ack);

    if (ack.command_number == Smpt_Cmd_Ll_Init_Ack)
    {
        smpt_get_ll_init_ack(device, &ll_init_ack);  /* Writes the received data into ll_init_ack */

    }

    else
    {

    }
}
