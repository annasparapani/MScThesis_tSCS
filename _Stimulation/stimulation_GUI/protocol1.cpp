#include "protocol1.h"
#include "ui_protocol1.h"
#include "headers.h"
#include "globals.h"

Protocol1::Protocol1(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::Protocol1)
{
    ui->setupUi(this);
    // SET DEFAULT VALUES
    ui->SpinBox_CurrentAmplitude->setValue(10); // set the default current value to 10
    ui->SpinBox_Increment->setValue(2);
    ui->Button_Stop->setEnabled(false);

    // CONNECT BUTTONS
    connect(ui->Button_Home, &QPushButton::clicked, this, &Protocol1::backHome);
    connect(ui->Button_Start, &QPushButton::clicked, this, &Protocol1::startClicked);
    connect(ui->Button_Stop, &QPushButton::clicked, this, &Protocol1::stopClicked);

}

Protocol1::~Protocol1()
{
    delete ui;
}


void Protocol1::backHome(){
    this->hide();
    static MainWindow *mainW = new MainWindow(this);
    mainW->show();
}

void Protocol1::startClicked(){
    current=ui->SpinBox_CurrentAmplitude->value(); //copy the values set in the spin boxes in the global variables
    current_increment=ui->SpinBox_Increment->value();

    // enable and disable objects
    ui->SpinBox_CurrentAmplitude->setEnabled(false); //disable the spin boxes to set the current and increment
    ui->SpinBox_Increment->setEnabled(false);
    ui->Button_Stop->setEnabled(true);
    ui->Button_Start->setEnabled(false);

    // show parameters being imposed in the stimulation on the lcds
    ui->LCD_Current->display(current);
}

void Protocol1::stopClicked(){
    // enable and disable objects
    ui->SpinBox_CurrentAmplitude->setEnabled(true);
    ui->SpinBox_Increment->setEnabled(true);
    ui->Button_Start->setEnabled(true);
    ui->Button_Stop->setEnabled(false);

    ui->LCD_Current->display(0);
}