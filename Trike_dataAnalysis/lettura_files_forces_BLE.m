%% Code for pedals power visualisation
clc
clear all
close all
% Colors
Pink = [245, 235, 235; 244, 217, 229; 230, 176 201; 222, 140, 174; ...
    215, 98, 147; 206, 150, 160; 191, 97, 126; 207, 65, 119; 178, 46, 92; ...
    129 27 60]/255; % 2 and 7
Blue = [230, 241, 246; 203, 224, 236; 168, 201, 222; 125, 175, 208; ...
    86, 146, 188; 59, 110, 150; 35, 74, 108]/255; % 2 and 5
Green = [228, 241, 228; 209, 228, 211; 168, 204, 171; 128, 183, 132; ...
    98, 168, 101; 70, 134, 71; 40, 87, 49]/255; % 2 and 4
Yellow = [0.9290 0.6940 0.1250; 0.9290 0.6940 0.1250; 0.9290 0.6940 0.1250;
    0.9290 0.6940 0.1250; 0.9290 0.6940 0.1250;0.9290 0.6940 0.1250];
Orange = [0.8500 0.3250 0.0980; 0.8500 0.3250 0.0980;0.8500 0.3250 0.0980;
    0.8500 0.3250 0.0980; 0.8500 0.3250 0.0980;0.8500 0.3250 0.0980];
Red = [255, 255, 178; 254, 217, 118; 254, 178, 76; 221, 134, 70; ...
    252, 78, 42; 227, 26, 28; 177, 0, 38]/255;
Black = [0, 0, 0; 127, 127, 127; 254, 178, 76; 221, 134, 70; ...
    252, 78, 42; 227, 26, 28; 177, 0, 38]/255;
colors{1} = Pink; colors{2} = Blue; colors{3} = Green; colors{4} = Yellow; 
colors{5} = Orange; colors{6} = Black; colors{7} = Red; 

titles_recs={'passive', '50Hz+vol', '50Hz','80Hz+vol', '80Hz', '20Hz + vol', '20Hz'};

%% Load data for left pedal
% loading order = passive, 50 vol, 50, 80 vol, 80, 20 vol, 20
num_recordings = 4; % Change this to the number of acquisitions you have
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
    title('Left Angles'),
    hold on
    
    subplot(2,1,2), 
    plot(xAxis, force); xlabel('time(s)'), ylabel('Force [N]')
    title('Left Forces'),legend('Passive', '50Hz', '50Hz + vol');
    hold on
    movAvgForce = movmean(force,30*(numSamples/100));
    plot(xAxis,movAvgForce, 'LineWidth',2);
end 
legend('Passive', 'Passive MA','50Hz + vol', '50Hz + vol MA', '50Hz', ...
    '50Hz MA','80Hz + vol','80Hz + vol MA', '80Hz','80Hz MA',...
     '20Hz + vol','20Hz + vol MA','20Hz', '20Hz MA');
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
    title('Right Angles'),
    hold on
    
    subplot(2,1,2), 
    plot(xAxis, force); title('Right Forces'), xlabel('time(s)'), ylabel('Force [N]')
    hold on
    movAvgForce = movmean(force,30*(numSamples/100));
    if rec==1   plot(xAxis,movAvgForce, 'r', 'LineWidth',3); 
    else  plot(xAxis,movAvgForce, 'LineWidth',2);
    end
end 
legend('Passive', 'Passive MA','50Hz + vol', '50Hz + vol MA', '50Hz', ...
    '50Hz MA','80Hz + vol','80Hz + vol MA', '80Hz','80Hz MA',...
     '20Hz + vol','20Hz + vol MA','20Hz', '20Hz MA');
       
%% Interpolation
for rec=1:num_recordings
    [pks_left,locs_left] = findpeaks(importData{rec}.leftAngle, 'MinPeakHeight', 350);
    num_samples_per_cycle = 360;
    % Preallocate an array to store interpolated force data for each cycle
    interpolated_force_cycles = zeros(num_samples_per_cycle, numel(locs_left)-1);
    % Iterate through each cycling revolution
    for i = 1:numel(locs_left)-1
        % Extract the angle and force data for the current cycling revolution
        angle_data = importData{rec}.leftAngle(locs_left(i):locs_left(i+1)-1);
        force_data = importData{rec}.leftForce(locs_left(i):locs_left(i+1)-1);
        [angle_data_unique, idx_unique] = unique(angle_data);
        force_data_unique = force_data(idx_unique);
        interpolated_force = interp1(angle_data_unique, force_data_unique, ...
            linspace(min(angle_data_unique), max(angle_data_unique), num_samples_per_cycle), 'linear');
        interpolated_force_cycles(:,i) = interpolated_force;
    end
    importData{rec}.interpolatedForceLeft = interpolated_force_cycles;
    importData{rec}.meanCycleForceLeft = mean(importData{rec}.interpolatedForceLeft,2);
    importData{rec}.stddevCycleForceRight = std(importData{rec}.interpolatedForceLeft,[],2);
    importData{rec}.differentalForceLeft = importData{rec}.meanCycleForceLeft - importData{1}.meanCycleForceLeft;

end 

figure('Name', 'Force during an averaged cycle - left pedal'); 
for rec = 2:num_recordings
    subplot(2,3,rec-1); 
    plot(1:360,importData{1}.meanCycleForceLeft,'LineWidth',1.5, 'color', colors{7}(4, :)); hold on
    plot(1:360,importData{rec}.meanCycleForceLeft,'LineWidth', 2, 'color', colors{2}(5, :));
    plot(1:360, importData{1}.differentalForceLeft, 'LineWidth',0.5, 'color',colors{7}(7, :))
    plot(1:360, importData{rec}.differentalForceLeft, 'LineWidth',1.5,'color', colors{2}(4, :))
    grid on, xlim([0,360]), title("Passive vs "+titles_recs{rec}+" force")
    xlabel('Crank Angle [°]'), ylabel('Force[N]');
    legend('Passive', 'tSCS', '', 'Passive - tSCS')
end 
%% 
for rec=1:num_recordings
    [pks_right,locs_right] = findpeaks(importData{rec}.rightAngle, 'MinPeakHeight', 350);
    num_samples_per_cycle = 360;
    % Preallocate an array to store interpolated force data for each cycle
    interpolated_force_cycles = zeros(num_samples_per_cycle, numel(locs_right)-1);
    % Iterate through each cycling revolution
    for i = 1:numel(locs_right)-1
        % Extract the angle and force data for the current cycling revolution
        angle_data = importData{rec}.rightAngle(locs_right(i):locs_right(i+1)-1);
        force_data = importData{rec}.rightForce(locs_right(i):locs_right(i+1)-1);
        [angle_data_unique, idx_unique] = unique(angle_data);
        force_data_unique = force_data(idx_unique);
        interpolated_force = interp1(angle_data_unique, force_data_unique, ...
            linspace(min(angle_data_unique), max(angle_data_unique), num_samples_per_cycle), 'linear');
        interpolated_force_cycles(:,i) = interpolated_force;
    end
    importData{rec}.interpolatedForceRight = interpolated_force_cycles;
    importData{rec}.meanCycleForceRight = mean(importData{rec}.interpolatedForceRight,2);
    importData{rec}.stddevCycleForceRight = std(importData{rec}.interpolatedForceRight,[],2);
    importData{rec}.differentalForceRight = importData{rec}.meanCycleForceRight - importData{1}.meanCycleForceRight;

end

figure('Name', 'Force during an averaged cycle - right pedal'); 
for rec = 2:num_recordings
    subplot(2,3,rec-1); 
    plot(importData{1}.meanCycleForceRight, 'r','LineWidth',1.5, 'color', colors{7}(4, :)); hold on
    plot(importData{rec}.meanCycleForceRight,'LineWidth', 2, 'color', colors{2}(5, :));
    plot(1:360, importData{1}.differentalForceRight, 'LineWidth',0.5, 'color',colors{7}(7, :))
    plot(1:360, importData{rec}.differentalForceRight, 'LineWidth',1.5,'color', colors{2}(4, :))
    grid on, xlim([0,360]), title("Passive vs "+titles_recs{rec}+" force")
    xlabel('Crank Angle [°]'), ylabel('Force[N]');
    legend('Passive', 'tSCS', '', 'Passive - tSCS')
    
end 

%% Grafici : Compute Mean and Standard Deviation

tg_mean_left=mean(tg_left');
tg_std_left=std(tg_left');
curve1_left=tg_mean_left+tg_std_left;
curve2_left=tg_mean_left-tg_std_left;
x2_left = [flipud(crank_angle_left); crank_angle_left];

tg_mean_right=mean(tg_right');
tg_std_right=std(tg_right');
curve1_right=tg_mean_right+tg_std_right;
curve2_right=tg_mean_right-tg_std_right;
x2_right = [flipud(crank_angle_right); crank_angle_right];

figure()
inBetween = [flipud(curve1_left'); curve2_left'];fill(x2_left, inBetween, Blue(2, :),...
    'LineStyle','none', 'FaceAlpha',.5);...
    hold on; plot(crank_angle_left,tg_mean_left,'LineWidth', 2,'color', Blue(5, :)),...
    xlim([0  max(crank_angle_left)]),xlabel('Crank Angle [°]-0° right pedal in upper position'), ylabel('Force[N]');
hold on
inBetween = [flipud(curve1_right'); curve2_right'];fill(x2_right, inBetween, Green(2, :),...
    'LineStyle','none', 'FaceAlpha',.5);...
    hold on; plot(crank_angle_right,tg_mean_right,'LineWidth', 2,'color', Green(5, :)),...
    xlim([0  max(crank_angle_right)]),xlabel('Crank Angle [°]-0° right pedal in upper position'), ylabel('Force[N]');
title( 'Tangential Force - Blue=Left,Green=Right')

%% FINE NICOLE

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
    powerData{rec}.powerRight = tgright_c.*40.*(3.14./30).*0.155;
    powerData{rec}.powerPerCycleLeft = sum(powerData{rec}.powerLeft)./length(powerData{rec}.powerLeft);
    powerData{rec}.powerPerCycleRight = sum(powerData{rec}.powerRight)./length(powerData{rec}.powerRight);
end 
%% Plot Power Data 
figure('Name', 'Power on left pedal')
for rec = 2:num_recordings 
    subplot(2,3,rec-1)
    title ('Averaged power on left pedal'), grid on
    plot(1:length(powerData{1}.powerPerCycleLeft),movmean(powerData{1}.powerPerCycleLeft, 30),'LineWidth',1.5, 'Color', colors{7}(4,:));
    hold on, grid on
    plot(movmean(powerData{rec}.powerPerCycleLeft, 30),'LineWidth',2, 'color', colors{2}(5,:));
    xlabel('Cycling revolutions'), ylabel('Power')
    title("Passive vs "+titles_recs{rec}+" power"), legend('Passive', 'tSCS')
end 
%%
figure('Name', 'Power on right pedal')
for rec = 2:num_recordings 
    subplot(2,3,rec-1)
    title ('Averaged power on left pedal'), grid on
    plot(1:length(powerData{1}.powerPerCycleRight),movmean(powerData{1}.powerPerCycleRight, 30),'LineWidth',1.5, 'Color', colors{7}(4,:));
    hold on, grid on
    plot(movmean(powerData{rec}.powerPerCycleRight, 30),'LineWidth',2, 'color', colors{2}(5,:)');
    xlabel('Cycling revolutions'), ylabel('Power')
    title("Passive vs "+titles_recs{rec}+" power"), legend('Passive', 'tSCS')
end 
%% Boxplots of forces
figure()
for rec = 1:num_recordings
    trial_array = importData{rec}.meanCycleForceLeft;
    boxplot(trial_array,'Positions', rec, 'Widths', 0.20, 'Colors', colors{2}(5,:));
    hold on 
    title('Forces on single cycle - left pedal')
end 
set(gca, 'XTick', 1:num_recordings, 'XTickLabel', titles_recs); xtickangle(45);
%%
figure()
for rec = 1:num_recordings
    trial_array = importData{rec}.meanCycleForceRight;
    boxplot(trial_array,'Positions', rec, 'Widths', 0.20, 'Colors', colors{2}(5,:));
    hold on 
    title('Forces on single cycle - right pedal')
end 
set(gca, 'XTick', 1:num_recordings, 'XTickLabel', titles_recs); xtickangle(45);
%% Boxplots of powers
figure()
for rec = 1:num_recordings
    trial_array = powerData{rec}.powerPerCycleLeft;
    boxplot(trial_array,'Positions', rec, 'Widths', 0.20, 'Colors', colors{rec}(5,:));
    hold on 
    title('Powers mediated - left pedal')
end 
set(gca, 'XTick', 1:num_recordings, 'XTickLabel', titles_recs); xtickangle(45);
%%
figure()
for rec = 1:num_recordings
    trial_array = powerData{rec}.powerPerCycleRight;
    boxplot(trial_array,'Positions', rec, 'Widths', 0.20, 'Colors', colors{2}(5,:));
    hold on 
    title('Powers mediated - right pedal')
end 
set(gca, 'XTick', 1:num_recordings, 'XTickLabel', titles_recs); xtickangle(45);