%% Code for pedals power visualisation
clc
clear
close all

%% Colours
orange = [0.8500 0.3250 0.0980];
green = [0.4660 0.6740 0.1880];
light_blue = [0 0.4470 0.7410];

%% Load data
[fn,p,fi] = uigetfile('*.csv','Pick a csv file');
[~, fileName, ~] = fileparts(fn);

%% Save as vectors for files WITHOUT TARGET POWER
data = readtable(fn, 'NumHeaderLines',3);
pidCoeff = table2array(data(:,1))*100;
totPower = table2array(data(:,2));
movingAverPower = table2array(data(:,3));

motorPower = table2array(data(:,4));
stimCurr = table2array(data(:,5));
gear = table2array(data(:,6));
cadence = table2array(data(:,7));
motorCurrent = table2array(data(:,8));

%% Save as vectors for files WITH TARGET POWER
data = readtable(fn, 'NumHeaderLines',3);
pidCoeff = table2array(data(:,1))*100;
totPower = table2array(data(:,2));
movingAverPower = table2array(data(:,3));
totTargetPower = table2array(data(:,4));
motorPower = table2array(data(:,5));
stimCurr = table2array(data(:,6));
gear = table2array(data(:,7));
cadence = table2array(data(:,8));
motorCurrent = table2array(data(:,9));

%% Compute mean and std
averagedMotorPower = movmean(motorPower,3);
sumPower = averagedMotorPower + movingAverPower;

meanVolPower = mean(movingAverPower);
stdVolPower = std(movingAverPower);
meanMotorPower = mean(averagedMotorPower);
stdMotorPower = std(averagedMotorPower);
meanSumPower = mean(sumPower);
stdSumPower = std(sumPower);
meanCadence = mean(cadence);
stdCadence = std(cadence);


%% Create a table
Mean = [meanVolPower; meanMotorPower; meanSumPower; meanCadence];
Std = [stdVolPower; stdMotorPower; stdSumPower; stdCadence];
Values = ["PedPower"; "MotorPower"; "SumPower"; "Cadence"];
StatValue = ["Mean"; "Std"];
volPowerStat = [meanVolPower; stdVolPower];
motorPowerStat = [meanMotorPower; stdMotorPower];
sumPowerStat = [meanSumPower; stdSumPower];
cadenceStat = [meanCadence; stdCadence];

% Creare la tabella
% tabella = table(StatValue, volPowerStat, motorPowerStat, sumPowerStat, cadenceStat);
tabella = table(Values, Mean, Std);
disp(tabella);

%% Plot data
% Power
figure();
p1 = plot(pidCoeff, 'Color', green);
hold on;
% p2 = plot(totPower, 'g'); % 'Pedals total power'
hold on;
p3 = plot(movingAverPower, 'b');
hold on;

% plot(movmean(totPower,8), 'r');
hold on;
p3_1 = plot(averagedMotorPower, 'm');
hold on;
p4 = plot(totTargetPower, 'Color', light_blue);
hold on;
p5 = plot(sumPower, 'k');
hold on;
% plot(motorCurrent, 'y');
p7 = plot(movmean(cadence, 5), 'r');
xlabel('Cycles');
ylabel('Values');
legend('Pid Coefficient', 'Averaged Pedals Total Power - rasp', 'Averaged Motor Power', 'Total Target Power', 'Total Power (MOT+PED)', 'cadence');
% legend('Total power', 'Averaged Total Power - MatWind10');
% legend('Total power', 'Averaged Total Power - rasp', 'Averaged Total Power - MatWind');
title(fileName);
grid on;

%% Plot pid vs power
%t_t0 = linspace( 0 , size(andrea_19_12.pid,1)/1000 , size(andrea_19_12.pid,1) )';
%ccc=interp1(linspace(0, 126, length(Andrea.FESMOT_3.currents.correnteEffettivaQuadDx)),Andrea.FESMOT_3.currents.correnteEffettivaQuadDx,linspace(0, 126, 126))';
l=length(motorPower);
figure;t=tiledlayout(2,1);
s1=nexttile;
plot(pidCoeff); xlabel("Number of revolutions");ylabel("Pid Coefficient"); xlim([0 l]);
s2=nexttile;
plot(movingAverPower);xlabel("Number of revolutions");ylabel("Mean power"); xlim([0 l]);
hold on;
yline(15);
plot(motorPower);
title(t, "Prova 1");


%% Plot table
fig = uifigure();
uitable(fig,'Data',tabella,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);


