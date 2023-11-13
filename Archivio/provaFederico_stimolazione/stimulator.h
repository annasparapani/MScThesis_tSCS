#ifndef STIMULATOR_H
#define STIMULATOR_H

using namespace std;

//#include "header.h"

#include "smpt_client.h"
#include "smpt_definitions.h"
#include "smpt_definitions_data_types.h"
#include "smpt_ll_client.h"
#include "smpt_ll_definitions.h"
#include "smpt_ll_definitions_data_types.h"
#include "smpt_ll_packet_validity.h"
#include "smpt_messages.h"
#include "smpt_ml_client.h"
#include "smpt_ml_definitions.h"
#include "smpt_ml_definitions_data_types.h"
#include "smpt_ml_packet_validity.h"
#include "smpt_packet_number_generator.h"

class stimulator
{
public:
    stimulator();

    Smpt_device device;
    Smpt_ll_channel_config channels[4];

    void one_pulse();
    void channelsInitialization(stimulator &stim, uint8_t nPoints);

    void init_stimulation(Smpt_device *const device);

    void stop_stimulation(Smpt_device *const device);
};

#endif // STIMULATOR_H
