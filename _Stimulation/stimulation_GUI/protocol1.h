#ifndef PROTOCOL1_H
#define PROTOCOL1_H

#include <QDialog>

namespace Ui {
class Protocol1;
}

class Protocol1 : public QDialog
{
    Q_OBJECT

public:
    explicit Protocol1(QWidget *parent = nullptr);
    ~Protocol1();
    void updateLCD();

private:
    Ui::Protocol1 *ui;

private slots:
    void backHome();
    void startClicked();
    void stopClicked();

};

#endif // PROTOCOL1_H
