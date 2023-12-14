#include "protocol2.h"
#include "ui_protocol2.h"
#include "globals.h"
#include "headers.h"


//int current_double=0.8*current; // the current used in the double stimuli protocol
                                // is 80% of the max tolerance found in the protocol 1


Protocol2::Protocol2(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::Protocol2)
{
    ui->setupUi(this);
    myThread = new stim_Thread(this);
    progressBarTimer = new QTimer(this);
    interstimulus_distance=5; // since in protocol 2 interstimulus distance is expressed
                              // in seconds, redefine it to 5 s
    ui->SpinBox_CurrentAmplitude->setValue(0.8*current);
    ui->SpinBox_IPI->setValue(interpulse_interval);
    ui->SpinBox_ISD->setValue(interstimulus_distance);
    ui->Button_Stop->setEnabled(false);
    ui->progressBar_Pause->setRange(0,50);
    ui->progressBar_Pause->setValue(0);

    connect(ui->Button_Home, &QPushButton::clicked, this, &Protocol2::backHome);
    connect(ui->Button_Start, &QPushButton::clicked, this, &Protocol2::startClicked);
    connect(ui->Button_Stop, &QPushButton::clicked, this, &Protocol2::stopClicked);
    connect(ui->Button_Stop, &QPushButton::clicked, myThread, &stim_Thread::stopThread);
    connect(myThread, &stim_Thread::numStimuliChanged, this, &Protocol2::update_numStimuli);
    connect(myThread, &stim_Thread::pauseStarted, this, &Protocol2::startPause);
    connect(progressBarTimer, &QTimer::timeout, this, &Protocol2::updatePauseProgressBar);

}

Protocol2::~Protocol2()
{
    delete ui;
}

void Protocol2::backHome(){
    this->hide();
    static MainWindow *mainW = new MainWindow(this);
    mainW->show();
}

void Protocol2::startClicked(){
    // copy values from interface to thread variables
    current=ui->SpinBox_CurrentAmplitude->value(); //copy the values set in the spin boxes in the global variables
    interpulse_interval=ui->SpinBox_IPI->value();
    interstimulus_distance=ui->SpinBox_ISD->value();
    interstimulus_distance=interstimulus_distance*1000; // from s to ms

    // enable and disable objects
    ui->SpinBox_CurrentAmplitude->setEnabled(false); //disable the spin boxes to set the current and increment
    ui->SpinBox_IPI->setEnabled(false);
    ui->SpinBox_ISD->setEnabled(false);
    ui->Button_Stop->setEnabled(true);
    ui->Button_Start->setEnabled(false);
    ui->Button_Home->setEnabled(false);

    // show parameters being imposed in the stimulation on the lcds
    ui->lcd_currentImposed->display(current);
    ui->lcdNumber_IPIImposed->display(interpulse_interval);
    ui->lcdNumber_ISDImposed->display(ui->SpinBox_ISD->value());

    protocol=2; // set global variable protocol to enter the correct thread case to 1
    myThread->stimulating=true;
    myThread->start(); // open the thread (using federica's code)
}

void Protocol2::stopClicked(){
    // enable and disable objects
    ui->SpinBox_CurrentAmplitude->setEnabled(true);
    ui->SpinBox_IPI->setEnabled(true);
    ui->SpinBox_ISD->setEnabled(true);
    ui->Button_Start->setEnabled(true);
    ui->Button_Stop->setEnabled(false);
    ui->Button_Home->setEnabled(true);

    // clear lcd displays
    ui->lcd_currentImposed->display(0);
    ui->lcdNumber_IPIImposed->display(0);
    ui->lcdNumber_ISDImposed->display(0);
}

void Protocol2::update_numStimuli(){
       cout<<"Updating num stimuli\n";
       ui->LCD_PulseNo->display(myThread->numStimuli);
}

void Protocol2::startPause(){
    progressBarTimer->start(100);

}
void Protocol2::updatePauseProgressBar(){

    int value = ui->progressBar_Pause->value();
    ui->progressBar_Pause->setValue(value+1);

    if(value==50||!(myThread->stimulating)){
        progressBarTimer->stop();
        ui->progressBar_Pause->setValue(0);
    }
}


