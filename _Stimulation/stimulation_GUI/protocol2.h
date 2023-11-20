#ifndef PROTOCOL2_H
#define PROTOCOL2_H

#include <QDialog>

namespace Ui {
class Protocol2;
}

class Protocol2 : public QDialog
{
    Q_OBJECT

public:
    explicit Protocol2(QWidget *parent = nullptr);
    ~Protocol2();

private:
    Ui::Protocol2 *ui;
    QTimer* progressBarTimer;

private slots:
    void backHome();
    void startClicked();
    void stopClicked();
    void update_numStimuli();
    void updatePauseProgressBar();
    void startPause();
};

#endif // PROTOCOL2_H
