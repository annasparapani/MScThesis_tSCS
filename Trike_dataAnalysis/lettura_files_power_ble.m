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
% load control passive data 
[fn_passive,p_passive,fi_passive] = uigetfile('*.csv','Pick a csv file');
[~, fileName_passive, ~] = fileparts(fn_passive);

%% Save as vectors for files WITHOUT TARGET POWER
data = readtable(fn, 'NumHeaderLines',3);
pidCoeff = table2array(data(:,1))*100;
totPower = table2array(data(:,2));
movingAverPower = table2array(data(:,3));

motorPower = table2array(data(:,8));
stimCurr = table2array(data(:,9));
gear = table2array(data(:,10));
cadence = table2array(data(:,11));
motorCurrent = table2array(data(:,12));

% same for passive 
data_passive = readtable(fn_passive, 'NumHeaderLines',3);
pidCoeff_passive = table2array(data_passive(:,1))*100;
totPower_passive = table2array(data_passive(:,2));
movingAverPower_passive = table2array(data_passive(:,3));

motorPower_passive = table2array(data_passive(:,8));
stimCurr_passive = table2array(data_passive(:,9));
gear_passive = table2array(data_passive(:,10));
cadence_passive = table2array(data_passive(:,11));
motorCurrent_passive = table2array(data_passive(:,12));

%% Save as vectors for files WITH TARGET POWER
data = readtable(fn, 'NumHeaderLines',3);
pidCoeff = table2array(data(:,1))*100;
totPower = table2array(data(:,2));
movingAverPower = table2array(data(:,3));
totTargetPower = table2array(data(:,4));
motorPower = table2array(data(:,8));
stimCurr = table2array(data(:,9));
gear = table2array(data(:,10));
cadence = table2array(data(:,11));
motorCurrent = table2array(data(:,12));
% same for passive
data_passive = readtable(fn_passive, 'NumHeaderLines',3);
pidCoeff_passive = table2array(data_passive(:,1))*100;
totPower_passive = table2array(data_passive(:,2));
movingAverPower_passive = table2array(data_passive(:,3));
totTargetPower_passive = table2array(data_passive(:,4));
motorPower_passive = table2array(data_passive(:,8));
stimCurr_passive = table2array(data_passive(:,9));
gear_passive = table2array(data_passive(:,10));
cadence_passive = table2array(data_passive(:,11));
motorCurrent_passive = table2array(data_passive(:,12));

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

% same for passive
averagedMotorPower_passive = movmean(motorPower_passive,3);
sumPower_passive = averagedMotorPower_passive + movingAverPower_passive;

meanVolPower_passive = mean(movingAverPower_passive);
stdVolPower_passive = std(movingAverPower_passive);
meanMotorPower_passive = mean(averagedMotorPower_passive);
stdMotorPower_passive = std(averagedMotorPower_passive);
meanSumPower_passive = mean(sumPower_passive);
stdSumPower_passive = std(sumPower_passive);
meanCadence_passive = mean(cadence_passive);
stdCadence_passive = std(cadence_passive);
%% Create a table
Mean = [meanVolPower; meanMotorPower; meanSumPower; meanCadence];
Std = [stdVolPower; stdMotorPower; stdSumPower; stdCadence];
Values = ["PedPower"; "MotorPower"; "SumPower"; "Cadence"];
StatValue = ["Mean"; "Std"];
volPowerStat = [meanVolPower; stdVolPower];
motorPowerStat = [meanMotorPower; stdMotorPower];
sumPowerStat = [meanSumPower; stdSumPower];
cadenceStat = [meanCadence; stdCadence];

% same for passive
Mean_passive = [meanVolPower_passive; meanMotorPower_passive; meanSumPower_passive; meanCadence_passive];
Std_passive = [stdVolPower_passive; stdMotorPower_passive; stdSumPower_passive; stdCadence_passive];
Values_passive = ["PedPower_passive"; "MotorPower_passive"; "SumPower_passive"; "Cadence_passive"];
StatValue_passive = ["Mean_passive"; "Std_passive"];
volPowerStat_passive = [meanVolPower_passive; stdVolPower_passive];
motorPowerStat_passive = [meanMotorPower_passive; stdMotorPower_passive];
sumPowerStat_passive = [meanSumPower_passive; stdSumPower_passive];
cadenceStat_passive = [meanCadence_passive; stdCadence_passive];

% Creare la tabella
% tabella = table(StatValue, volPowerStat, motorPowerStat, sumPowerStat, cadenceStat);
tabella = table(Values, Mean, Std);
disp(tabella);

% same for passive
tabella_passive = table(Values_passive, Mean_passive, Std_passive);
disp(tabella_passive);

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


