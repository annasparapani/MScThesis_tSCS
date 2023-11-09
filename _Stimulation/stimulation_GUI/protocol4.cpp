#include "protocol4.h"
#include "ui_protocol4.h"
#include "globals.h"
#include "headers.h"

Protocol4::Protocol4(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::Protocol4)
{
    ui->setupUi(this);
    ui->SpinBox_CurrentAmplitude->setValue(current_maxRamp); // set to maximum of ramp value found in protocol 4
    ui->Button_Stop_2->setEnabled(false);

    connect(ui->Button_Home, &QPushButton::clicked, this, &Protocol4::backHome);
    connect(ui->Button_Start_2, &QPushButton::clicked, this, &Protocol4::startClicked);
    connect(ui->Button_Stop_2, &QPushButton::clicked, this, &Protocol4::stopClicked);

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
    current = ui->SpinBox_CurrentAmplitude->value();

    // enable and disable objects
     ui->SpinBox_CurrentAmplitude->setEnabled(false);
     ui-> Button_Start_2->setEnabled(false);
     ui->Button_Stop_2->setEnabled(true);

    // show on lcd
     ui->lcd_currentImposed->display(current);

}

void Protocol4::stopClicked(){

    //enable and disable objects
    ui->SpinBox_CurrentAmplitude->setEnabled(true);
    ui-> Button_Start_2->setEnabled(true);
    ui->Button_Stop_2->setEnabled(false);

    // clear lcd display
    ui->lcd_currentImposed->display(0);


}
