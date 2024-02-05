%% Code for pedals power visualisation
clc
clear all
close all

%% Load left data
[fnLP,pLP,fiLP] = uigetfile('*.csv','Pick a csv file');
[fnLP_passive,pLP_passive,fiLP_passive] = uigetfile('*.csv','Pick a csv file for the passive control');

%% Save as vectors
dataLP = readtable(fnLP, 'NumHeaderLines',2);
leftPower = table2array(dataLP(:,1));
VectorSizeL = table2array(dataLP(:,2));
xL = 1:size(dataLP, 1);

%same for passive
dataLP_passive = readtable(fnLP_passive, 'NumHeaderLines',2);
leftPower_passive = table2array(dataLP_passive(:,1));
VectorSizeL_passive = table2array(dataLP_passive(:,2));
xL_passive = 1:size(dataLP_passive, 1);

%% Load right data
[fnRP,pRP,fiRP] = uigetfile('*.csv','Pick a csv file');
[fnRP_passive,pRP_passive,fiRP_passive] = uigetfile('*.csv','Pick a csv file for the passive control');

%% Save as vector
dataRP = readtable(fnRP, 'NumHeaderLines',2);
rightPower = table2array(dataRP(:,1));
VectorSizeR = table2array(dataRP(:,2));
xR = 1:size(dataRP, 1);

% same for passive
dataRP_passive = readtable(fnRP_passive, 'NumHeaderLines',2);
rightPower_passive = table2array(dataRP_passive(:,1));
VectorSizeR_passive = table2array(dataRP_passive(:,2));
xR_passive = 1:size(dataRP_passive, 1);

%% Plot data
figure(); 
subplot(2, 1, 1), plot(xL, leftPower, 'r', xR, rightPower, 'b'), xlabel ('samples'), ylabel('Power [W]'), grid on;
hold on 
plot(xL_passive, leftPower_passive, 'r','LineStyle','-.'), plot(xR_passive, rightPower_passive, 'b','LineStyle','-.'), legend('left', 'right','left passive', 'right passive')

subplot(2, 1, 2), plot(xL, VectorSizeL, 'r', xR, VectorSizeR, 'b'), xlabel('samples'), ylabel('Vector Size for Power computation'), grid on;
hold on
plot(xL_passive, VectorSizeL_passive, 'b','LineStyle','-.'), plot(xR_passive, VectorSizeR_passive, 'r', 'LineStyle','-.'), legend('left', 'right', 'left passive', 'right passive');
