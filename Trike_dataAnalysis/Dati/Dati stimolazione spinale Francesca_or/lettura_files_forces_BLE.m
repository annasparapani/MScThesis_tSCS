%% Code for pedals power visualisation
clc
clear all
close all

%% Load data left pedal
[fnL,pL,fiL] = uigetfile('*.csv','Pick a csv file');

%% Save as vectors left pedal
dataL = readtable(fnL, 'NumHeaderLines',2);
leftForce = table2array(dataL(:,1));
leftAngle = table2array(dataL(:,2));

%% Load data right pedal
[fnR,pR,fiR] = uigetfile('*.csv','Pick a csv file');

%% Save as vectors right pedal
dataR = readtable(fnR, 'NumHeaderLines',2);
rightForce = table2array(dataR(:,1));
rightAngle = table2array(dataR(:,2));
xL = 1:size(dataL, 1);
xR = 1:size(dataR, 1);

%% Plot data
figure(); 
subplot(2,1,1),plot(xL, leftAngle, 'r', xR, rightAngle, 'b'), xlabel ('samples'), ylabel('Angle [°]'), ylim([-10 400]), legend('left', 'right'), grid on;
subplot(2,1,2),plot(xL, leftForce, 'r', xR, rightForce, 'b'), xlabel ('samples'), ylabel('Force [N]'), ylim([-150 150]), legend('left', 'right'), grid on;

%% Select a period of pedaling
locspi = 1;
locspfL = length(xL);
angle_nL = leftAngle(locspi:locspfL);
tg_left_n = leftForce(locspi:locspfL);

locspfR = length(xR);
angle_nR = rightAngle(locspi:locspfR);
tg_right_n = rightForce(locspi:locspfR);
%% Divide cycles
windows = 360;
angle_cL = (linspace(0,359,windows));
angle_cR = (linspace(0,359,windows));

[pksL, locsL] = findpeaks(angle_nL, 'MinPeakHeight', 310);
[pksR, locsR] = findpeaks(angle_nR, 'MinPeakHeight', 310);

rowLocsL = locsL;
rowLocsR = locsR;

tgleft_c = zeros(windows,size(locsL,1)-1);
for i=1:size(locsL,1)-1
   tgleft_c(:,i) = interp1(xL(locsL(i):locsL(i+1)-1),tg_left_n(locsL(i):locsL(i+1)-1),...
        linspace(xL(locsL(i)),xL(locsL(i+1)-1),windows),'spline');
end

tgright_c = zeros(windows,size(locsR,1)-1);
for i=1:size(locsR,1)-1
   tgright_c(:,i) = interp1(xR(locsR(i):locsR(i+1)-1),tg_right_n(locsR(i):locsR(i+1)-1),...
        linspace(xR(locsR(i)),xR(locsR(i+1)-1),windows),'spline');
end
%% Power
powerLeft= tgleft_c.*40.*(3.14./30).*0.155;
powerRight=tgright_c.*40.*(3.14./30).*0.155;
powerPerCycleL= sum(powerLeft)./length(powerLeft);
powerPerCycleR=sum(powerRight)./length(powerRight);
figure; plot(powerPerCycleL);
hold on; plot(movmean(powerPerCycleL,10)); title('Left Power');
grid on;

figure; plot(powerPerCycleR);
hold on; plot(movmean(powerPerCycleR,10)); title('Right Power');
grid on;

%% Plot time
% timeL_diff = zeros(size(TimeL,1)-1,1);
% for i=1:size(TimeL)-1
%    timeL_diff(i,1) = TimeL(i+1) - TimeL(i);
% end
% 
% figure();
% plot(timeL_diff);ylim([0 0,010]);

