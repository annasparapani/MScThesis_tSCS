#include "mainwindow.h"
#include "./ui_mainwindow.h"

#include "globals.h"
#include "headers.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
   ui->setupUi(this);
   connect(ui->Button_quit, &QPushButton::clicked, this, &MainWindow::closeApplication);
   connect(ui->Button_10Pulses, &QPushButton::clicked, this, &MainWindow::openProtocol1);
   connect(ui->Button_2CloseStim, &QPushButton::clicked, this, &MainWindow::openProtocol2);
   connect(ui->Button_Ramp, &QPushButton::clicked, this, &MainWindow::openProtocol3);
   connect(ui->Button_ContinuousStim, &QPushButton::clicked, this, &MainWindow::openProtocol4);
 }

MainWindow::~MainWindow()
{
    delete ui;

}

void MainWindow::closeApplication(){
    myThread->calibrated=false; // additional control to lower calibration flag
    QCoreApplication::exit(0);
}

void MainWindow::openProtocol1(){
    this->hide();
    static Protocol1 *myProtocol1 = new Protocol1(this);
    myProtocol1->show();
}

void MainWindow::openProtocol2(){
    this->hide();
    static Protocol2 *myProtocol2 = new Protocol2(this);
    myProtocol2->show();
}

void MainWindow::openProtocol3(){
    this->hide();
    static Protocol3 *myProtocol3 = new Protocol3(this);
    myProtocol3->show();
}

void MainWindow::openProtocol4(){
    this->hide();
    static Protocol4 *myProtocol4 = new Protocol4(this);
    myProtocol4->show();
}

