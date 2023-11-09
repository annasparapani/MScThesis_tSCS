#include "protocol3.h"
#include "ui_protocol3.h"
#include "globals.h"
#include "headers.h"

Protocol3::Protocol3(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::Protocol3)
{
    ui->setupUi(this);
    ui->SpinBox_CurrentAmplitude->setValue(current_minRamp); // set spin boxes to default values
    ui->SpinBox_CurrentIncrement->setValue(increment_minRamp);
    ui->Button_Stop_2->setEnabled(false);

    connect(ui->Button_Home, &QPushButton::clicked, this, &Protocol3::backHome);
    connect(ui->Button_Start_2, &QPushButton::clicked, this, &Protocol3::startClicked);
    connect(ui->Button_Stop_2, &QPushButton::clicked, this, &Protocol3::stopClicked);


}

Protocol3::~Protocol3()
{
    delete ui;
}

void Protocol3::backHome(){
    this->hide();
    static MainWindow *mainW = new MainWindow(this);
    mainW->show();
}

void Protocol3::startClicked(){
    current=ui->SpinBox_CurrentAmplitude->value(); //copy the values set in the spin boxes in the global variables
    current_increment=ui->SpinBox_CurrentIncrement->value();

    // enable and disable objects
    ui->SpinBox_CurrentAmplitude->setEnabled(false); //disable the spin boxes to set the current and increment
    ui->SpinBox_CurrentIncrement->setEnabled(false);
    ui->Button_Stop_2->setEnabled(true);
    ui->Button_Start_2->setEnabled(false);

   // show parameters being imposed in the stimulation on the lcds
   ui->lcd_currentImposed->display(current);
}

void Protocol3::stopClicked(){
    // save the maximum ramp value for continuous stimulation
    current_maxRamp=current;

    // enable and disable objects
     ui->SpinBox_CurrentAmplitude->setEnabled(true);
     ui->SpinBox_CurrentIncrement->setEnabled(true);
     ui->Button_Start_2->setEnabled(true);
     ui->Button_Stop_2->setEnabled(false);


     // clear lcd displays
     ui->lcd_currentImposed->display(0);

}
