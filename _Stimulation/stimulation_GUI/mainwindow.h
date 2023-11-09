#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private:
    Ui::MainWindow *ui;
    void closeApplication(); // declaration of function to close application
    void openProtocol1(); // declaration of function to open protocol 1 window from mainwindow
    void openProtocol2(); // declaration of function to open protocol 2 window from mainwindow
    void openProtocol3(); // declaration of function to open protocol 3 window from mainwindow
    void openProtocol4(); // declaration of function to open protocol 4 window from mainwindow
};
#endif // MAINWINDOW_H
