#include "protocol4.h"
#include "ui_protocol4.h"
#include "globals.h"
#include "headers.h"

Protocol4::Protocol4(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::Protocol4)
{
    ui->setupUi(this);
    myThread = new stim_Thread(this);
    ui->SpinBox_CurrentAmplitude->setValue(current_maxRamp); // set to maximum of ramp value found in protocol 4
    ui->SpinBox_Frequency->setValue(1000/myThread->stimT);
    ui->Button_Stop_2->setEnabled(false);

    connect(ui->Button_Home, &QPushButton::clicked, this, &Protocol4::backHome);
    connect(ui->Button_Start_2, &QPushButton::clicked, this, &Protocol4::startClicked);
    connect(ui->Button_Stop_2, &QPushButton::clicked, this, &Protocol4::stopClicked);
    connect(ui->Button_Stop_2, &QPushButton::clicked, myThread, &stim_Thread::stopThread);
}

Protocol4::~Protocol4()
{
    delete ui;
}

void Protocol4::backHome(){
    this->hide();
    static MainWindow *mainW = new MainWindow(this);
    mainW->show();
}

void Protocol4::startClicked(){
    // copy values from interface to thread variables
    current = ui->SpinBox_CurrentAmplitude->value();
    //myThread->stimT=(1000/(ui->SpinBox_Frequency->value())); CURRENTLY NOT WORKING!

    // enable and disable objects
     ui->SpinBox_CurrentAmplitude->setEnabled(false);
     ui-> Button_Start_2->setEnabled(false);
     ui->SpinBox_Frequency->setEnabled(false);
     ui->Button_Stop_2->setEnabled(true);
     ui->Button_Home->setEnabled(false);

    // show on lcd
     ui->lcd_currentImposed->display(current);

     //OPEN STIMULATION THREAD
     protocol=4; // set global variable protocol to enter the correct thread case to 1
     myThread->stimulating=true;
     myThread->start(); // open the thread
}

void Protocol4::stopClicked(){

    //enable and disable objects
    ui->SpinBox_CurrentAmplitude->setEnabled(true);
    ui-> Button_Start_2->setEnabled(true);
    ui->Button_Stop_2->setEnabled(false);
    ui->Button_Home->setEnabled(true);
    ui->SpinBox_Frequency->setEnabled(true);

    // clear lcd display
    ui->lcd_currentImposed->display(0);
}
