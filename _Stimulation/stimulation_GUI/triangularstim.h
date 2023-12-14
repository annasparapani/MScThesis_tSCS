#ifndef TRIANGULARSTIM_H
#define TRIANGULARSTIM_H

#include <QDialog>

namespace Ui {
class triangularStim;
}

class triangularStim : public QDialog
{
    Q_OBJECT

public:
    explicit triangularStim(QWidget *parent = nullptr);
    ~triangularStim();

private:
    Ui::triangularStim *ui;
private slots:
    void backHome();
    void stopClicked();
    void startClicked();

};

#endif // TRIANGULARSTIM_H
