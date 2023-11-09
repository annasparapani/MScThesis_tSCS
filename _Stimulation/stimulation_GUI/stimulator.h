#ifndef STIMULATOR_H
#define STIMULATOR_H

using namespace std;

#include "headers.h"

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
