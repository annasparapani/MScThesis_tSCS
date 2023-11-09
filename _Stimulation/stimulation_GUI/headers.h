#ifndef HEADERS_H
#define HEADERS_H

// GRAPHIC
#include "mainwindow.h"
#include "protocol1.h"
#include "protocol2.h"
#include "protocol3.h"
#include "protocol4.h"

//STIMULATION THREAD
#include "stim_thread.h"

//STIMULATOR
#include "smpt_ll_client.h"
#include "smpt_client.h"
#include "smpt_ml_client.h"
#include "smpt_messages.h"
#include "smpt_packet_number_generator.h"
#include "smpt_ll_packet_validity.h"
#include "stimulator.h"

// STD LIBRARIES
#include <iostream>
#include <ostream>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <vector>
#include <numeric>
#include <string>

//TIME AND COMMUNICATION
#include <thread>
#include <pthread.h>
#include <chrono>
#include <time.h>
#include <sys/time.h>
#include <termios.h>
#include <fcntl.h>
#include <getopt.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>
#include <fstream>
#include <libconfig.h++>
#include <cstdlib>
#include <signal.h>
#include <qconfig.h>
#include <ctime>
#include <limits.h>


#endif // HEADERS_H
