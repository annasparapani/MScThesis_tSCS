%% Code for pedals power visualisation
clc
clear all
close all

%% Load data for left pedal
num_recordings = 7; % Change this to the number of acquisitions you have
importData = cell(num_recordings, 1); % Store acquisitions in a cell array
for rec = 1:num_recordings
    % Load data for each acquisition
    [filename, path, ~] = uigetfile('*.csv', ['Pick a csv file to import for LEFT pedal ', num2str(rec)]);
    full_filename = fullfile(path, filename);
    
    % Read data from the CSV file
    data = readtable(full_filename, 'NumHeaderLines', 2);
    force = table2array(data(:, 1)); % Store left force data
    angle = table2array(data(:, 2)); % Store left angle data
    
    importData{rec}.leftForce = force; 
    importData{rec}.leftAngle = angle;
    importData{rec}.xL = 1:size(data, 1);
end

%% Load data for right pedal
for rec = 1:num_recordings
    % Load data for each acquisition
    [filename, path, ~] = uigetfile('*.csv', ['Pick a csv file to import for LEFT pedal ', num2str(rec)]);
    full_filename = fullfile(path, filename);
    
    % Read data from the CSV file
    data = readtable(full_filename, 'NumHeaderLines', 2);
    force = table2array(data(:, 1)); % Store left force data
    angle = table2array(data(:, 2)); % Store left angle data
    
    importData{rec}.rightForce = force; 
    importData{rec}.rightAngle = angle;
    importData{rec}.xR = 1:size(data, 1);
end

%% Plot data
%Left
triggerLocsLeft = cell(num_recordings,1);
for rec = 1:num_recordings
    % add later trigger on if data_struct{rec}.
    [cycle_pks,cycle_locs]=findpeaks(importData{rec}.leftAngle, "MinPeakDistance", 50, "MinPeakHeight",20); 
    triggerLocsLeft{rec} = cycle_locs; 
end 

figure('Name','Left Plot');
for rec = 1:num_recordings
    numSamples = length(importData{rec}.xL) - triggerLocsLeft{rec}(2)+1;
    xAxis=[]; xAxis = linspace(0,180, numSamples);
    angle = importData{rec}.leftAngle(triggerLocsLeft{rec}(2):end); 
    force = importData{rec}.leftForce(triggerLocsLeft{rec}(2):end);
    subplot(2,1,1), 
    plot(xAxis, angle), xlabel('time(s)'), ylabel('Angle [°]')
    title('Left Angles'), legend('Passive', '50Hz', '50Hz + vol')
    hold on
    
    subplot(2,1,2), 
    plot(xAxis, force); xlabel('time(s)'), ylabel('Force [N]')
    title('Left Forces'),legend('Passive', '50Hz', '50Hz + vol');
    hold on
    movAvgForce = movmean(force,30*(numSamples/100));
    plot(xAxis,movAvgForce, 'LineWidth',2);
    legend('Passive', '50Hz', '50Hz + vol', '80Hz', '80Hz + vol', '20Hz',... 
    '20Hz + vol', 'Passive MA', '50Hz MA', '50Hz + vol MA','80Hz MA', ...
    '80Hz + vol MA', '20Hz MA', '20Hz + vol MA' );
end 
%%
%Right
triggerLocsRight = cell(num_recordings,1);
for rec = 1:num_recordings
    % add later trigger on if data_struct{rec}.
    [cycle_pks,cycle_locs]=findpeaks(importData{rec}.rightAngle, "MinPeakDistance", 50, "MinPeakHeight",20); 
    triggerLocsRight{rec} = cycle_locs; 
end

figure('Name','Right Plot');
for rec = 1:num_recordings
    numSamples = length(importData{rec}.xR) - triggerLocsRight{rec}(2)+1;
    xAxis=[]; xAxis = linspace(0,180, numSamples);
    angle = importData{rec}.rightAngle(triggerLocsRight{rec}(2):end); 
    force = importData{rec}.rightForce(triggerLocsRight{rec}(2):end);
    subplot(2,1,1), 
    plot(xAxis, angle), xlabel('time(s)'), ylabel('Angle [°]')
    title('Right Angles'), legend('Passive', '50Hz', '50Hz + vol')
    hold on
    
    subplot(2,1,2), 
    plot(xAxis, force); title('Right Forces'), xlabel('time(s)'), ylabel('Force [N]')
    hold on
    movAvgForce = movmean(force,30*(numSamples/100));
    plot(xAxis,movAvgForce, 'LineWidth',2); 
    legend('Passive', '50Hz', '50Hz + vol', '80Hz', '80Hz + vol', '20Hz',... 
    '20Hz + vol', 'Passive MA', '50Hz MA', '50Hz + vol MA','80Hz MA', ...
    '80Hz + vol MA', '20Hz MA', '20Hz + vol MA' );
       
end 

%% Select a period of pedaling, divide in cycles and compute the power

cyclicData = cell(num_recordings,1);
powerData = cell(num_recordings,1);
windows = 360;
angle_cL = (linspace(0,359,windows)); 
angle_cR = (linspace(0,359,windows)); 

for rec = 1:num_recordings
    locspi = 1; % start 
    locspfL = length(importData{rec}.xL);  % end 
    xL = importData{rec}.xL; xR = importData{rec}.xR; 
    angle_nL = importData{rec}.leftAngle(locspi:locspfL); 
    tg_left_n = importData{rec}.leftForce(locspi:locspfL);
    locspfR = length(importData{rec}.xR); 
    angle_nR = importData{rec}.rightAngle(locspi:locspfR); 
    tg_right_n = importData{rec}.rightForce(locspi:locspfR);
    
    locsL = triggerLocsLeft{rec};
    tgleft_c = zeros(windows,size(locsL,1)-1);
    for i=1:size(locsL,1)-1
        tgleft_c(:,i) = interp1(xL(locsL(i):locsL(i+1)-1),tg_left_n(locsL(i):locsL(i+1)-1),...
                        linspace(xL(locsL(i)),xL(locsL(i+1)-1),windows),'spline');
    end

    locsR = triggerLocsRight{rec};
    tgright_c = zeros(windows,size(locsR,1)-1);
    for i=1:size(locsR,1)-1
       tgright_c(:,i) = interp1(xR(locsR(i):locsR(i+1)-1),tg_right_n(locsR(i):locsR(i+1)-1),...
            linspace(xR(locsR(i)),xR(locsR(i+1)-1),windows),'spline');
    end

    powerLeft= tgleft_c.*40.*(3.14./30).*0.155;
    powerRight=tgright_c.*40.*(3.14./30).*0.155;

    cyclicData{rec}.tgleft_c = tgleft_c; 
    cyclicData{rec}.tgright_c = tgright_c; 

    powerData{rec}.powerLeft = tgleft_c.*40.*(3.14./30).*0.155;
    powerData{rec}.powerRight = tgleft_c.*40.*(3.14./30).*0.155;
    powerData{rec}.powerPerCycleLeft = sum(powerData{rec}.powerLeft)./length(powerData{rec}.powerLeft);
    powerData{rec}.powerPerCycleRight = sum(powerData{rec}.powerRight)./length(powerData{rec}.powerRight);

end 

figure('Name', 'Power on pedals')
for rec = 1:num_recordings 
    plot(powerData{rec}.powerPerCycleLeft,LineStyle='--');
    title ('Power on pedals and 10 steps moving average')
    hold on, grid on
    if rec == 1
        plot(movmean(powerData{rec}.powerPerCycleLeft, 10),'r', 'LineWidth',3);
    else plot(movmean(powerData{rec}.powerPerCycleLeft, 10),'LineWidth',2);
    end
end 
legend('Passive', 'Passive Ma', '50Hz', '50Hz MA', '50Hz + vol', ...
    '50Hz + vol MA', '80Hz', '80Hz MA', '80Hz+ vol', '80Hz + vol MA', ...
    '20Hz', '20Hz MA', '20Hz + vol', '20Hz + vol MA','zero')
x_limits = xlim; % Get the x-axis limits
plot(x_limits, [0 0], 'b', 'LineWidth', 2); % Plot the red line at y = 0
hold off 

figure('Name', 'Power on pedals')
for rec = 1:num_recordings 
    plot(powerData{rec}.powerPerCycleRight,LineStyle='--');
    title ('Power on pedals and 10 steps moving average')
    hold on, grid on
    if rec == 1
        plot(movmean(powerData{rec}.powerPerCycleRight, 10),'r', 'LineWidth',3);
    else plot(movmean(powerData{rec}.powerPerCycleRight, 10),'LineWidth',2);
    end
end 
legend('Passive', 'Passive Ma', '50Hz', '50Hz MA', '50Hz + vol', ...
    '50Hz + vol MA', '80Hz', '80Hz MA', '80Hz+ vol', '80Hz + vol MA', ...
    '20Hz', '20Hz MA', '20Hz + vol', '20Hz + vol MA','zero')
x_limits = xlim; % Get the x-axis limits
plot(x_limits, [0 0], 'b', 'LineWidth', 2); % Plot the red line at y = 0
hold off 

%% Plot time
% timeL_diff = zeros(size(TimeL,1)-1,1);
% for i=1:size(TimeL)-1
%    timeL_diff(i,1) = TimeL(i+1) - TimeL(i);
% end
% 
% figure();
% plot(timeL_diff);ylim([0 0,010]);

