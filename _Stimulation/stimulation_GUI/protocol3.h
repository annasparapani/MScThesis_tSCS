#ifndef PROTOCOL3_H
#define PROTOCOL3_H

#include <QDialog>

namespace Ui {
class Protocol3;
}

class Protocol3 : public QDialog
{
    Q_OBJECT

public:
    explicit Protocol3(QWidget *parent = nullptr);
    ~Protocol3();

private:
    Ui::Protocol3 *ui;

private slots:
    void backHome();
    void startClicked();
    void stopClicked();
};

#endif // PROTOCOL3_H
