/*
AUTHOR: Anna Sparapani (anna.sparapani@mail.polimi.it)
DATE: 11-23

******* CODE DESCRIPTION *****************
The following code is being developed in the scope of my MSc's Thesis
in Biomedical Engineering at the NearLab, Politecnico di Milano.
The thesis aims at defining a protocol for transcutaneous spinal cord
stimulation for motor rehabilitatio in post-stroke patients, hence the
need of the present code to perform the stimulation.
The code stands on the code previously developed by Federico Monterosso,
in the scope of his MSc's Thesis. The current version offers the code and
interface for performing 4 protocols of transcutaneous spinal cord
sitmulation with RehaMove stimulators.
The stimulation uses a single channel [0] and surface electrodes.

STIMULATOR USED: RehaMove PRO, Hasomed (Germany)
ELECTRODES USED: PALS 5x5cm square, Axelgaard Manufacturing (USA)

The code only deliver the stimulation, data analysis is perfomed on EMG
data on MATLAB.
*/

#include "globals.h"
#include "headers.h"

#include <QApplication>


/**************************************
******** GLOBAL VARIABLES ************
***************************************/

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    MainWindow w;    
    w.show();
    return a.exec();

}

