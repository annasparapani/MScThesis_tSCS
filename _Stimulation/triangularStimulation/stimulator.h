#ifndef STIMULATOR_H
#define STIMULATOR_H

using namespace std;

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

    void init_stimulation_ll(Smpt_device *const device);
    void init_stimulation_ml(Smpt_device *const device);
    void fill_ml_init(Smpt_device *const device, Smpt_ml_init *const ml_init);
    void fill_ml_get_current_data(Smpt_device *const device, Smpt_ml_get_current_data *const ml_get_current_data);
    void fill_ml_update(Smpt_device *const device, Smpt_ml_update *const ml_update);
    void stop_stimulation(Smpt_device *const device);
};

#endif // STIMULATOR_H
