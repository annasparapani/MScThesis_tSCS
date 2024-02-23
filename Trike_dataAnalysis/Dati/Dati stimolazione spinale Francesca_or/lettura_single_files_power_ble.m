%% Code for pedals power visualisation
clc
clear all
close all

%% Load left data
[fnLP,pLP,fiLP] = uigetfile('*.csv','Pick a csv file');

%% Save as vectors
dataLP = readtable(fnLP, 'NumHeaderLines',2);
leftPower = table2array(dataLP(:,1));
VectorSizeL = table2array(dataLP(:,2));
xL = 1:size(dataLP, 1);

%% Load right data
[fnRP,pRP,fiRP] = uigetfile('*.csv','Pick a csv file');

%% Save as vector
dataRP = readtable(fnRP, 'NumHeaderLines',2);
rightPower = table2array(dataRP(:,1));
VectorSizeR = table2array(dataRP(:,2));
xR = 1:size(dataRP, 1);

%% Plot data
figure(); 
subplot(2, 1, 1), plot(xL, leftPower, 'r', xR, rightPower, 'b'), xlabel ('samples'), ylabel('Power [W]'), ylim([-10 40]), legend('left', 'right'), grid on;
subplot(2, 1, 2), plot(xL, VectorSizeL, 'r', xR, VectorSizeR, 'b'), xlabel('samples'), ylabel('Vector Size for Power computation'), legend('left', 'right'), grid on;
