#ifndef PROTOCOL4_H
#define PROTOCOL4_H

#include <QDialog>

namespace Ui {
class Protocol4;
}

class Protocol4 : public QDialog
{
    Q_OBJECT

public:
    explicit Protocol4(QWidget *parent = nullptr);
    ~Protocol4();

private:
    Ui::Protocol4 *ui;

private slots:
    void backHome();
    void stopClicked();
    void startClicked();
};

#endif // PROTOCOL4_H
