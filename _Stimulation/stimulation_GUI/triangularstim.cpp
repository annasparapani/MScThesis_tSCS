#include "triangularstim.h"
#include "ui_triangularstim.h"
#include "globals.h"
#include "headers.h"


triangularStim::triangularStim(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::triangularStim)
{
    ui->setupUi(this);
    myThread = new stim_Thread(this);
    ui->Button_Stop_2->setEnabled(false);
    ui->plainTextEdit_Frequency->setPlainText("0.5");
    ui->plainTextEdit_WaveLength->setPlainText("200");
    ui->plainTextEdit_maxCurrent->setPlainText("100");


    connect(ui->Button_Home, &QPushButton::clicked, this, &triangularStim::backHome);
    connect(ui->Button_Start_2, &QPushButton::clicked, this, &triangularStim::startClicked);
    connect(ui->Button_Stop_2, &QPushButton::clicked, this, &triangularStim::stopClicked);
    connect(ui->Button_Stop_2, &QPushButton::clicked, myThread, &stim_Thread::stopThread);
    connect(ui->Button_Stop_2, &QPushButton::clicked, this, &triangularStim::stopClicked);

}

triangularStim::~triangularStim()
{
    delete ui;
}

void triangularStim::backHome(){
    this->hide();
    static MainWindow *mainW = new MainWindow(this);
    mainW->show();
}


void triangularStim::startClicked(){
    // copy values from interface to thread variables
    //current = ui->SpinBox_MaxCurrentAmplitude->value();
    //myThread->waveLength = ui->SpinBox_WaveLength->value();
    //double frequency = ui->SpinBox_Frequency->value();

    bool ConversionOk;
    QString string = ui->plainTextEdit_Frequency->toPlainText();
    double frequency = string.toDouble(&ConversionOk);
    myThread->stimT = (1/frequency)*1000;

    string=ui->plainTextEdit_WaveLength->toPlainText();
    myThread->waveLength=string.toInt(&ConversionOk);

    string=ui->plainTextEdit_maxCurrent->toPlainText();
    current=string.toInt();

    // enable and disable objects
    ui->plainTextEdit_Frequency->setEnabled(false);
    ui->plainTextEdit_WaveLength->setEnabled(false);
    ui->plainTextEdit_maxCurrent->setEnabled(false);
    ui-> Button_Start_2->setEnabled(false);
    ui->Button_Stop_2->setEnabled(true);
    ui->Button_Home->setEnabled(false);

    // show on lcd
     ui->lcd_currentImposed->display(current);

     //OPEN STIMULATION THREAD
     protocol=5; // set global variable protocol to enter the correct thread case to 1
     myThread->stimulating=true;
     myThread->start(); // open the thread (using federica's code)
}

void triangularStim::stopClicked(){
    //enable and disable objects
    ui->plainTextEdit_Frequency->setEnabled(true);
    ui->plainTextEdit_WaveLength->setEnabled(true);
    ui->plainTextEdit_maxCurrent->setEnabled(true);
    ui-> Button_Start_2->setEnabled(true);
    ui->Button_Stop_2->setEnabled(false);
    ui->Button_Home->setEnabled(true);

    // clear lcd display
    ui->lcd_currentImposed->display(0);
}
