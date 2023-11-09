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
    ui->SpinBox_CurrentAmplitude->setValue(0.8*current);
    ui->SpinBox_IPI->setValue(interpulse_interval);
    ui->SpinBox_ISD->setValue(interstimulus_distance);
    ui->Button_Stop->setEnabled(false);

    connect(ui->Button_Home, &QPushButton::clicked, this, &Protocol2::backHome);
    connect(ui->Button_Start, &QPushButton::clicked, this, &Protocol2::startClicked);
    connect(ui->Button_Stop, &QPushButton::clicked, this, &Protocol2::stopClicked);

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
    current=ui->SpinBox_CurrentAmplitude->value(); //copy the values set in the spin boxes in the global variables
    interpulse_interval=ui->SpinBox_IPI->value();
    interstimulus_distance=ui->SpinBox_ISD->value();

    // enable and disable objects
    ui->SpinBox_CurrentAmplitude->setEnabled(false); //disable the spin boxes to set the current and increment
    ui->SpinBox_IPI->setEnabled(false);
    ui->SpinBox_ISD->setEnabled(false);
    ui->Button_Stop->setEnabled(true);
    ui->Button_Start->setEnabled(false);

    // show parameters being imposed in the stimulation on the lcds
    ui->lcd_currentImposed->display(current);
    ui->lcdNumber_IPIImposed->display(interpulse_interval);
    ui->lcdNumber_ISDImposed->display(interstimulus_distance);
}

void Protocol2::stopClicked(){
    // enable and disable objects
    ui->SpinBox_CurrentAmplitude->setEnabled(true);
    ui->SpinBox_IPI->setEnabled(true);
    ui->SpinBox_ISD->setEnabled(true);
    ui->Button_Start->setEnabled(true);
    ui->Button_Stop->setEnabled(false);

    // clear lcd displays
    ui->lcd_currentImposed->display(0);
    ui->lcdNumber_IPIImposed->display(0);
    ui->lcdNumber_ISDImposed->display(0);

}
