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
    ui->SpinBox_startingCurrent->setValue(2);
    ui->plainTextEdit_Frequency->setPlainText("50");
    ui->plainTextEdit_PW->setPlainText("1000");
    ui->Button_Stop_2->setEnabled(false);
    ui->SpinBox_Interval->setValue(myThread->ramp_Interval/1000);
    ui->SpinBox_CurrentIncrement->setValue(increment_minRamp);

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
    current_maxContinuous = ui->SpinBox_CurrentAmplitude->value();
    current = ui->SpinBox_startingCurrent->value();
    current_increment = ui->SpinBox_CurrentIncrement->value();
    myThread->ramp_Interval = ui->SpinBox_Interval->value()*1000;

    cout << "Current: "<< current <<"mA"<< endl;    // read frequency
    bool ConversionOk;
    QString string = ui->plainTextEdit_Frequency->toPlainText();
    double frequency = string.toDouble(&ConversionOk);
    myThread->stimT = (1/frequency)*1000;

    //read PW
    string = ui->plainTextEdit_PW->toPlainText();
    double PW = string.toDouble(&ConversionOk);
    myThread->PW=PW;

    // enable and disable objects
     ui->SpinBox_CurrentAmplitude->setEnabled(false);
     ui->SpinBox_CurrentIncrement->setEnabled(false);
     ui->SpinBox_Interval->setEnabled(false);
     ui->SpinBox_startingCurrent->setEnabled(false);
     ui-> Button_Start_2->setEnabled(false);
     ui->plainTextEdit_Frequency->setEnabled(false);
     ui->Button_Stop_2->setEnabled(true);
     ui->Button_Home->setEnabled(false);
     ui->plainTextEdit_PW->setEnabled(false);

    // show on lcd
     ui->lcd_currentImposed->display(current_maxContinuous);

     //OPEN STIMULATION THREAD
     protocol=4; // set global variable protocol to enter the correct thread case to 1
     myThread->stimulating=true;
     myThread->start(); // open the thread
}

void Protocol4::stopClicked(){
    myThread->stimulating=false; // STOP STIMULATION THREAD

    //enable and disable objects
    ui->SpinBox_CurrentIncrement->setEnabled(true);
    ui->SpinBox_Interval->setEnabled(true);
    ui->SpinBox_startingCurrent->setEnabled(true);
    ui->SpinBox_CurrentAmplitude->setEnabled(true);
    ui-> Button_Start_2->setEnabled(true);
    ui->Button_Stop_2->setEnabled(false);
    ui->Button_Home->setEnabled(true);
    ui->plainTextEdit_Frequency->setEnabled(true);
    ui->plainTextEdit_PW->setEnabled(true);
    // clear lcd display
    ui->lcd_currentImposed->display(0);
}
