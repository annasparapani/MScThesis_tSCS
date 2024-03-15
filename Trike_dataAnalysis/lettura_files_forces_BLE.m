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

num_recordings = 7; % Change this to the number of acquisitions you have
titles_recs={'passive', '20Hz + vol', '20Hz','50Hz + vol', '50Hz','80Hz + vol', '80Hz'};
titles_recs={'passive','passive+vol', 'passive+vol final', '50Hz+vol', '50Hz','80Hz+vol', '80Hz', '20Hz + vol', '20Hz'};


%% Load data for left pedal
% loading order = passive, 20 vol, 20, 50 vol, 50, 80 vol, 80
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
% clear data force angle 
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
%% Rimozione picchi dati da disconnessione pedali
figure();
% right angle
for rec = 1:num_recordings
    for i = 2:length(importData{rec}.rightAngle)
        if importData{rec}.rightAngle(i) > 360
           importData{rec}.rightAngle(i) = importData{rec}.rightAngle(i-1);  % Replace with the previous value
        end
        if importData{rec}.rightAngle(i) < 0 
           importData{rec}.rightAngle(i) = importData{rec}.rightAngle(i-1);  % Replace with the previous value
        end
    end
    plot(importData{rec}.rightAngle); hold on;
end
% left angle
figure(); 
for rec = 1:num_recordings
    for i = 2:length(importData{rec}.leftAngle)
        if importData{rec}.leftAngle(i) > 360
            importData{rec}.leftAngle(i) = importData{rec}.leftAngle(i-1);  % Replace with the previous value
        end
        if importData{rec}.leftAngle(i) < 0 
           importData{rec}.leftAngle(i) = importData{rec}.rightAngle(i-1);  % Replace with the previous value
        end
    end
    plot(importData{rec}.leftAngle); hold on;
end

% left force
figure();
for rec = 1:num_recordings
    for i = 2:length(importData{rec}.leftForce)
        if importData{rec}.leftForce(i) > 120
           importData{rec}.leftForce(i) = importData{rec}.leftForce(i-1);  % Replace with the previous value
        end
        if importData{rec}.leftForce(i) < -120
           importData{rec}.leftForce(i) = importData{rec}.leftForce(i-1);  % Replace with the previous value
        end
    end
    plot(importData{rec}.leftForce); hold on;
end

% right force
figure();
for rec = 1:num_recordings
    for i = 2:length(importData{rec}.rightForce)
        if importData{rec}.rightForce(i) > 80
           importData{rec}.rightForce(i) = importData{rec}.rightForce(i-1);  % Replace with the previous value
        end
        if importData{rec}.rightForce(i) < -80 
           importData{rec}.rightForce(i) = importData{rec}.rightForce(i-1);  % Replace with the previous value
        end
    end
    plot(importData{rec}.rightForce); hold on;
end

%% Forces Interpolation Left Pedal
screen_size = get(0, 'ScreenSize'); screen_width = screen_size(3); screen_height = screen_size(4);
desired_width = screen_width / 3;
desired_height = screen_height / 1.5;
figure('Name','Average force on left pedal during a cycling revolution','Position', [screen_width/4, screen_height/4, desired_width, desired_height]);
for rec=1:num_recordings

    [pks_right,locs_left] = findpeaks(importData{rec}.leftAngle, 'MinPeakHeight', 200);
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
    importData{rec}.stddevCycleForceLeft = std(importData{rec}.interpolatedForceLeft,[],2);
    importData{rec}.differentialForceLeft = importData{rec}.meanCycleForceLeft - importData{1}.meanCycleForceLeft;
    importData{rec}.stddevDifferentialForceLeft = std(importData{rec}.differentialForceLeft);
end 
%% Plot Interpolation Left Pedal - general
for rec = 2:2:num_recordings
    if rec == 2 color = colors{1};
    else if rec == 4 color = colors{2}; 
        else if rec == 6 color = colors{3}; 
        end 
        end 
    end
    subplot(3,2,rec-1);
    % plot passive std dev
    curve1=importData{1}.meanCycleForceLeft + importData{1}.stddevCycleForceLeft ;
    curve2=importData{1}.meanCycleForceLeft - importData{1}.stddevCycleForceLeft ;
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, Yellow(1,:), 'LineStyle', 'none', 'FaceAlpha', faceAlpha);hold on
    
    % plot tSCS + vol std dev
    curve1=importData{rec}.meanCycleForceLeft+ importData{rec}.stddevCycleForceLeft ;
    curve2=importData{rec}.meanCycleForceLeft - importData{rec}.stddevCycleForceLeft ;
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, color(2,:),'LineStyle', 'none', 'FaceAlpha', faceAlpha);
    
    % plotd tSCS std dev
    curve1=importData{rec+1}.meanCycleForceLeft+ importData{rec}.stddevCycleForceLeft ;
    curve2=importData{rec+1}.meanCycleForceLeft - importData{rec}.stddevCycleForceLeft ;
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, color(2,:),'LineStyle', 'none', 'FaceAlpha', faceAlpha);
    
    % plot lines 
    plot(1:360,importData{1}.meanCycleForceLeft,'LineWidth',1.5, 'color', Yellow(4, :));
    plot(1:360,importData{rec}.meanCycleForceLeft,'LineWidth', 2, 'color', color(5, :));   
    plot(1:360,importData{rec+1}.meanCycleForceLeft,'LineWidth', 2, 'color', color(5, :),'LineStyle','--');   
    plot(1:360, importData{1}.differentialForceLeft, 'LineWidth',0.5, 'color','k');

    grid on, xlim([0,360]), %title("Passive vs "+titles_recs{rec+1}+" force")
    xlabel('Left Crank Angle [°]','FontSize',16), ylabel('Force[N]','FontSize',16);set(gca, 'FontSize', 16); 
    %legend('','','', 'Passive', 'tSCS+vol', 'tSCS', 'FontSize', 14)
    ylim([-80,85]);

    % plot active force
    subplot(3,2,rec-1);
    curve1=importData{rec}.differentialForceLeft + std(importData{rec}.differentialForceLeft);
    curve2=importData{rec}.differentialForceLeft - std(importData{rec}.differentialForceLeft);
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, color(2,:),'LineStyle', 'none', 'FaceAlpha', faceAlpha); hold on,
    
    curve1=importData{rec+1}.differentialForceLeft + std(importData{rec}.differentialForceLeft);
    curve2=importData{rec+1}.differentialForceLeft - std(importData{rec}.differentialForceLeft);
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, color(2,:),'LineStyle', 'none', 'FaceAlpha', faceAlpha); hold on,

   plot(1:360, importData{1}.differentialForceLeft, 'LineWidth',1, 'color','k'); hold on,
    plot(1:360, importData{rec}.differentialForceLeft, 'LineWidth',2, 'color', color(5, :));
    plot(1:360, importData{rec+1}.differentialForceLeft, 'LineWidth',2, 'color', color(5, :),'LineStyle','--')

    grid on, xlim([0,360]), %title("Active force")
    xlabel('Left Crank Angle [°]', 'FontSize',16), %ylabel('Force[N]','FontSize',16);
    set(gca, 'FontSize', 16); 
    % legend('','','', 'tSCS + vol', 'tSCS', 'FontSize', 14)
    ylim([-20,20]);

end 
sgtitle('Force on left pedal during an averaged cycle', 'FontSize', 20);

%% Plot Interpolation Left Pedal - Cecere
for rec = 2:2:num_recordings
    if rec == 2 color = zeros(5,3);
    else if rec == 4 color = colors{1}; 
        else if rec == 6 color = colors{2}; 
            else if rec == 8 color = colors{3};
            end 
        end 
        end 
    end

    subplot(4,2,rec-1); 

    if rec < 4 faceAlpha = 0.05; 
    else faceAlpha = 0.3;
    end
    % plot passive std dev
    curve1=importData{1}.meanCycleForceLeft + importData{1}.stddevCycleForceLeft ;
    curve2=importData{1}.meanCycleForceLeft - importData{1}.stddevCycleForceLeft ;
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, Yellow(1,:), 'LineStyle', 'none', 'FaceAlpha', faceAlpha);hold on
    
    % plot tSCS + vol std dev
    curve1=importData{rec}.meanCycleForceLeft+ importData{rec}.stddevCycleForceLeft ;
    curve2=importData{rec}.meanCycleForceLeft - importData{rec}.stddevCycleForceLeft ;
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, color(2,:),'LineStyle', 'none', 'FaceAlpha', faceAlpha);
    
    % plotd tSCS std dev
    curve1=importData{rec+1}.meanCycleForceLeft+ importData{rec}.stddevCycleForceLeft ;
    curve2=importData{rec+1}.meanCycleForceLeft - importData{rec}.stddevCycleForceLeft ;
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, color(2,:),'LineStyle', 'none', 'FaceAlpha', faceAlpha);
    
    % plot lines 
    plot(1:360,importData{1}.meanCycleForceLeft,'LineWidth',1.5, 'color', Yellow(4, :));
    if rec < 4 
        plot(1:360,importData{rec}.meanCycleForceLeft,'LineWidth', 1.5, 'color', color(5, :), 'LineStyle','--');   
        plot(1:360,importData{rec+1}.meanCycleForceLeft,'LineWidth', 1.5, 'color', color(5, :),'LineStyle','-.');
    else 
        plot(1:360,importData{rec}.meanCycleForceLeft,'LineWidth', 2, 'color', color(5, :));   
        plot(1:360,importData{rec+1}.meanCycleForceLeft,'LineWidth', 2, 'color', color(5, :),'LineStyle','--');   
    end 
    plot(1:360, importData{1}.differentialForceLeft, 'LineWidth',0.5, 'color','k');

    grid on, xlim([0,360]), %title("Passive vs "+titles_recs{rec+1}+" force")
    xlabel('Left Crank Angle [°]','FontSize',16), ylabel('Force[N]','FontSize',16);set(gca, 'FontSize', 16); 
    %legend('','','', 'Passive', 'tSCS+vol', 'tSCS', 'FontSize', 14)
    ylim([-80,85]);

    % plot active force
    subplot(4,2,rec); 
    curve1=importData{rec}.differentialForceLeft + std(importData{rec}.differentialForceLeft);
    curve2=importData{rec}.differentialForceLeft - std(importData{rec}.differentialForceLeft);
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, color(2,:),'LineStyle', 'none', 'FaceAlpha', faceAlpha); hold on,
    
    curve1=importData{rec+1}.differentialForceLeft + std(importData{rec}.differentialForceLeft);
    curve2=importData{rec+1}.differentialForceLeft - std(importData{rec}.differentialForceLeft);
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, color(2,:),'LineStyle', 'none', 'FaceAlpha', faceAlpha); hold on,

   plot(1:360, importData{1}.differentialForceLeft, 'LineWidth',1, 'color','k'); hold on,
    if rec < 4 
        plot(1:360, importData{rec}.differentialForceLeft, 'LineWidth',2, 'color', color(5, :),'LineStyle','-.');
        plot(1:360, importData{rec+1}.differentialForceLeft, 'LineWidth',2, 'color', color(5, :),'LineStyle','-.')

    else 
        plot(1:360, importData{rec}.differentialForceLeft, 'LineWidth',2, 'color', color(5, :));
        plot(1:360, importData{rec+1}.differentialForceLeft, 'LineWidth',2, 'color', color(5, :),'LineStyle','--')
    end 

    grid on, xlim([0,360]), %title("Active force")
    xlabel('Left Crank Angle [°]', 'FontSize',16), %ylabel('Force[N]','FontSize',16);
    set(gca, 'FontSize', 16); 
    % legend('','','', 'tSCS + vol', 'tSCS', 'FontSize', 14)
    ylim([-20,20]);

end 
sgtitle('Force on left pedal during an averaged cycle', 'FontSize', 20);

%% Forces Interpolation Right Pedal
screen_size = get(0, 'ScreenSize'); screen_width = screen_size(3); screen_height = screen_size(4);
desired_width = screen_width / 3;
desired_height = screen_height / 1.5;
figure('Name','Average force on right pedal during a cycling revolution','Position', [screen_width/4, screen_height/4, desired_width, desired_height]);
for rec=1:num_recordings
    [pks_right,locs_right] = findpeaks(importData{rec}.rightAngle, 'MinPeakHeight', 200);
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
    importData{rec}.differentialForceRight = importData{rec}.meanCycleForceRight - importData{1}.meanCycleForceRight;
    importData{rec}.stddevDifferentialForceRight = std(importData{rec}.differentialForceRight);
end 
%% Plot Interpolation Right Pedal - general
for rec = 2:2:num_recordings
    if rec == 2 color = colors{1}; 
        else if rec == 4 color = colors{2}; 
            else if rec == 6 color = colors{3};
            end 
        end 
    end
    % if rec == 1 subplot(4,2,rec-1); % per Cecere
    % else subplot(4,2,rec); 
    % end 
    subplot(3,2,rec-1) 

    % plot passive std dev
    curve1=importData{1}.meanCycleForceRight + importData{1}.stddevCycleForceRight ;
    curve2=importData{1}.meanCycleForceRight - importData{1}.stddevCycleForceRight ;
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, Yellow(1,:), 'LineStyle', 'none', 'FaceAlpha', 0.3);hold on
    
    % plot tSCS + vol std dev
    curve1=importData{rec}.meanCycleForceRight+ importData{rec}.stddevCycleForceRight ;
    curve2=importData{rec}.meanCycleForceRight - importData{rec}.stddevCycleForceRight ;
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, color(2,:),'LineStyle', 'none', 'FaceAlpha', 0.5);
    
    % plotd tSCS std dev
    curve1=importData{rec+1}.meanCycleForceRight+ importData{rec}.stddevCycleForceRight ;
    curve2=importData{rec+1}.meanCycleForceRight - importData{rec}.stddevCycleForceRight ;
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, color(2,:),'LineStyle', 'none', 'FaceAlpha', 0.5);
    
    % plot lines 
    plot(1:360,importData{1}.meanCycleForceRight,'LineWidth',1.5, 'color', Yellow(4, :));
    plot(1:360,importData{rec}.meanCycleForceRight,'LineWidth', 2, 'color', color(5, :));   
    plot(1:360,importData{rec+1}.meanCycleForceRight,'LineWidth', 2, 'color', color(5, :),'LineStyle','--');    
    plot(1:360, importData{1}.differentialForceRight, 'LineWidth',0.5, 'color','k');

    grid on, xlim([0,360]), %title("Passive vs "+titles_recs{rec+1}+" force")
    xlabel('Right Crank Angle [°]','FontSize',16), ylabel('Force[N]','FontSize',16);
    set(gca, 'FontSize', 16);    %legend('','','', 'Passive', 'tSCS+vol', 'tSCS', 'FontSize', 14)
    ylim([-80,85]);

    % plot active force
    subplot(3,2,rec)
    curve1=importData{rec}.differentialForceRight + std(importData{rec}.differentialForceRight);
    curve2=importData{rec}.differentialForceRight - std(importData{rec}.differentialForceRight);
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, color(2,:),'LineStyle', 'none', 'FaceAlpha', 0.5); hold on,
    
    curve1=importData{rec+1}.differentialForceRight + std(importData{rec}.differentialForceRight);
    curve2=importData{rec+1}.differentialForceRight - std(importData{rec}.differentialForceRight);
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, color(2,:),'LineStyle', 'none', 'FaceAlpha', 0.5); hold on,

    plot(1:360, importData{1}.differentialForceRight, 'LineWidth',1, 'color','k'); hold on,
    plot(1:360, importData{rec}.differentialForceRight, 'LineWidth',2, 'color', color(5, :));
    plot(1:360, importData{rec+1}.differentialForceRight, 'LineWidth',2, 'color', color(5, :),'LineStyle','--')

    grid on, xlim([0,360]), %title("Active force")
    xlabel('Right Crank Angle [°]','FontSize',16), %ylabel('Force[N]','FontSize',16);
    set(gca, 'FontSize', 16);
    % legend('','','', 'tSCS + vol', 'tSCS', 'FontSize', 14)
    ylim([-20,20]);

end 
sgtitle('Force on right pedal during an averaged cycle', 'FontSize', 20);
%% Plot Interpolation Right Pedal - Cecere
screen_size = get(0, 'ScreenSize'); screen_width = screen_size(3); screen_height = screen_size(4);
desired_width = screen_width / 3;
desired_height = screen_height / 1.5;
figure('Name','Average force on right pedal during a cycling revolution','Position', [screen_width/4, screen_height/4, desired_width, desired_height]);

for rec = 2:2:num_recordings
    if rec == 2 color = zeros(5,3);
    else if rec == 4 color = colors{1}; 
        else if rec == 6 color = colors{2}; 
            else if rec == 8 color = colors{3};
            end 
        end 
        end 
    end

    subplot(4,2,rec-1); 

    if rec < 4 faceAlpha = 0.05; 
    else faceAlpha = 0.3;
    end
    % plot passive std dev
    curve1=importData{1}.meanCycleForceRight + importData{1}.stddevCycleForceRight ;
    curve2=importData{1}.meanCycleForceRight - importData{1}.stddevCycleForceRight ;
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, Yellow(1,:), 'LineStyle', 'none', 'FaceAlpha', faceAlpha);hold on
    
    % plot tSCS + vol std dev
    curve1=importData{rec}.meanCycleForceRight+ importData{rec}.stddevCycleForceRight ;
    curve2=importData{rec}.meanCycleForceRight - importData{rec}.stddevCycleForceRight ;
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, color(2,:),'LineStyle', 'none', 'FaceAlpha', faceAlpha);
    
    % plotd tSCS std dev
    curve1=importData{rec+1}.meanCycleForceRight+ importData{rec}.stddevCycleForceRight ;
    curve2=importData{rec+1}.meanCycleForceRight - importData{rec}.stddevCycleForceRight ;
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, color(2,:),'LineStyle', 'none', 'FaceAlpha', faceAlpha);
    
    % plot lines 
    plot(1:360,importData{1}.meanCycleForceRight,'LineWidth',1.5, 'color', Yellow(4, :));
    if rec < 4 
        plot(1:360,importData{rec}.meanCycleForceRight,'LineWidth', 1.5, 'color', color(5, :), 'LineStyle','--');   
        plot(1:360,importData{rec+1}.meanCycleForceRight,'LineWidth', 1.5, 'color', color(5, :),'LineStyle','-.');
    else 
        plot(1:360,importData{rec}.meanCycleForceRight,'LineWidth', 2, 'color', color(5, :));   
        plot(1:360,importData{rec+1}.meanCycleForceRight,'LineWidth', 2, 'color', color(5, :),'LineStyle','--');   
    end 
    plot(1:360, importData{1}.differentialForceLeft, 'LineWidth',0.5, 'color','k');

    grid on, xlim([0,360]), %title("Passive vs "+titles_recs{rec+1}+" force")
    xlabel('Right Crank Angle [°]','FontSize',16), ylabel('Force[N]','FontSize',16);set(gca, 'FontSize', 16); 
    %legend('','','', 'Passive', 'tSCS+vol', 'tSCS', 'FontSize', 14)
    ylim([-80,85]);

    % plot active force
    subplot(4,2,rec);
    curve1=importData{rec}.differentialForceRight + std(importData{rec}.differentialForceRight);
    curve2=importData{rec}.differentialForceRight - std(importData{rec}.differentialForceRight);
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, color(2,:),'LineStyle', 'none', 'FaceAlpha', faceAlpha); hold on,
    
    curve1=importData{rec+1}.differentialForceRight + std(importData{rec}.differentialForceRight);
    curve2=importData{rec+1}.differentialForceRight - std(importData{rec}.differentialForceRight);
    inBetween = [curve1; flipud(curve2)]; xAxis = [(1:360)'; flipud((1:360)')];
    fill(xAxis, inBetween, color(2,:),'LineStyle', 'none', 'FaceAlpha', faceAlpha); hold on,

   plot(1:360, importData{1}.differentialForceRight, 'LineWidth',1, 'color','k'); hold on,
    if rec < 4 
        plot(1:360, importData{rec}.differentialForceRight, 'LineWidth',2, 'color', color(5, :),'LineStyle','-.');
        plot(1:360, importData{rec+1}.differentialForceRight, 'LineWidth',2, 'color', color(5, :),'LineStyle','-.')

    else 
        plot(1:360, importData{rec}.differentialForceRight, 'LineWidth',2, 'color', color(5, :));
        plot(1:360, importData{rec+1}.differentialForceRight, 'LineWidth',2, 'color', color(5, :),'LineStyle','--')
    end 

    grid on, xlim([0,360]), %title("Active force")
    xlabel('Right Crank Angle [°]', 'FontSize',16), %ylabel('Force[N]','FontSize',16);
    set(gca, 'FontSize', 16); 
    % legend('','','', 'tSCS + vol', 'tSCS', 'FontSize', 14)
    ylim([-40,40]);

end 
sgtitle('Force on right pedal during an averaged cycle', 'FontSize', 20);
%% RMS Left 
screen_size = get(0, 'ScreenSize'); screen_width = screen_size(3); screen_height = screen_size(4);
desired_width = screen_width / 6;
desired_height = screen_height / 1.3;
figure('Name','RMS of Active Force', 'Position', [screen_width/4, screen_height/4, desired_width, desired_height]);

subplot (2,1,1), plot(-5:354,importData{1}.differentialForceLeft, 'LineWidth',2, 'color',Yellow(2,:)); hold on
for rec = 2:num_recordings
    importData{rec}.activeForceRMSLeft = mean(importData{rec}.differentialForceLeft,2);
    
    if rec == 1 color = Yellow; 
        else if rec == 2 color = colors{1}; 
            else if rec == 4 color = colors{2};
                else if rec==6 color = colors{3}; 
                end 
            end
        end 
    end
    if rem(rec,2)==0
        errorbar(rec-1, mean(importData{rec}.activeForceRMSLeft),std(importData{rec}.activeForceRMSLeft), ...
            'o', 'MarkerSize',15, 'MarkerFaceColor', color(2,:), 'LineWidth', 1.5, 'color', color(5,:)); hold on;
        else if rec == 1 
            errorbar(rec-1, mean(importData{rec}.activeForceRMSLeft),std(importData{rec}.activeForceRMSLeft), ...
            'o', 'MarkerSize', 15, 'LineWidth', 1.5, 'color', color(5,:)); hold on; 
            else if rec > 1
                errorbar(rec-1, mean(importData{rec}.activeForceRMSLeft),std(importData{rec}.activeForceRMSLeft), ...
                'o', 'MarkerSize', 15, 'LineWidth', 1.5, 'color', color(5,:), 'LineStyle', '--'); hold on;
            end 
        end 
    end 
end 
ylabel('Active Force Mean [N]', 'FontSize',16);
grid on;
%set(gca, 'XTick', 1:num_recordings, 'XTickLabel', titles_recs(2:end), 'FontSize', 14); xtickangle(45);
xlim([0.5 6.5]), set(gca,'Xticklabel',[]), set(gca, 'FontSize', 18); 
ylim([-10,10])
%sgtitle('RMS of active force on left pedal during cycling', 'FontSize', 22);

% RMS Right 

subplot (2,1,2),plot(-5:354,importData{1}.differentialForceRight, 'LineWidth',2, 'color',Yellow(2,:)); hold on
for rec = 2:num_recordings
    importData{rec}.activeForceRMSRight = mean(importData{rec}.differentialForceRight,2);
    
    if rec == 1 color = Yellow; 
        else if rec == 2 color = colors{1}; 
            else if rec == 4 color = colors{2};
                else if rec==6 color = colors{3}; 
                end 
            end
        end 
    end
    if rem(rec,2)==0
        subplot (2,1,2),errorbar(rec-1, mean(importData{rec}.activeForceRMSRight),std(importData{rec}.activeForceRMSRight), ...
            'o', 'MarkerSize',15, 'MarkerFaceColor', color(2,:), 'LineWidth', 1.5, 'color', color(5,:)); hold on;
        else if rec == 1 
            subplot (2,1,1), errorbar(rec-1, mean(importData{rec}.activeForceRMSRight),std(importData{rec}.activeForceRMSRight), ...
            'o', 'MarkerSize', 15, 'LineWidth', 1.5, 'color', color(5,:)); hold on; 
            else if rec > 1
                subplot (2,1,2), errorbar(rec-1, mean(importData{rec}.activeForceRMSRight),std(importData{rec}.activeForceRMSRight), ...
                'o', 'MarkerSize', 15, 'LineWidth', 1.5, 'color', color(5,:), 'LineStyle', '--'); hold on;
            end 
        end 
    end 
end 
ylabel('Active Force Mean [N]','FontSize',16);
grid on;
set(gca, 'XTick', 1:num_recordings, 'XTickLabel', titles_recs(2:end), 'FontSize', 18); xtickangle(45);
xlim([0.5 6.5]), 
ylim([-5,12])
%sgtitle('RMS of active force on right pedal during cycling', 'FontSize', 22);

%% Select a period of pedaling, divide in cycles and compute the power
windows = 360;
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
                        linspace(xL(locsL(i)),xL(locsL(i+1)-1),windows),'linear');
    end

    locsR = triggerLocsRight{rec};
    tgright_c = zeros(windows,size(locsR,1)-1);
    for i=1:size(locsR,1)-1
       tgright_c(:,i) = interp1(xR(locsR(i):locsR(i+1)-1),tg_right_n(locsR(i):locsR(i+1)-1),...
            linspace(xR(locsR(i)),xR(locsR(i+1)-1),windows),'linear');
    end
    % importData{rec}.powerLeft = tgleft_c.*25.*(3.14./30).*0.155;
    % importData{rec}.powerRight = tgright_c.*25.*(3.14./30).*0.155;

    cadence_rpm = 25; cadence_rps = cadence_rpm / 60;
    importData{rec}.powerLeft = importData{rec}.interpolatedForceLeft.* cadence_rps .* 2 * pi * 0.165;
    importData{rec}.powerRight = importData{rec}.interpolatedForceRight.* cadence_rps .* 2 * pi * 0.165;
    % 
    importData{rec}.powerPerCycleLeft = sum(importData{rec}.powerLeft)./length(importData{rec}.powerLeft);
    importData{rec}.meanCyclePowerLeft = mean(importData{rec}.powerLeft,2);
    importData{rec}.powerPerCycleRight = sum(importData{rec}.powerRight)./length(importData{rec}.powerRight);
end 

%% Plot Power Data 
figure('Name', 'Power on left pedal')
for rec = 2:num_recordings 
    if rec == 2&&3 color = colors{1}; 
        else if rec == 4&&5 color = colors{2}; 
            else if rec == 6&&7 color = colors{3};
            end 
        end 
    end
    subplot(3,2,rec-1)
    % if rec == 1 subplot(4,2,rec-1);
    % else subplot(4,2,rec); 
    % end 
    curve1=importData{1}.powerPerCycleLeft + std(importData{1}.powerPerCycleLeft,[],2);
    curve2=importData{1}.powerPerCycleLeft - std(importData{1}.powerPerCycleLeft,[],2);
    inBetween = [curve1'; flipud(curve2')]; xAxis = [(1:length(curve1))'; flipud((1:length(curve1))')];
    fill(xAxis, movmean(inBetween,30), Yellow(1,:), 'LineStyle', 'none', 'FaceAlpha', 0.2); hold on
    
    curve1=importData{rec}.powerPerCycleLeft + std(importData{rec}.powerPerCycleLeft,[],2);
    curve2=importData{rec}.powerPerCycleLeft - std(importData{rec}.powerPerCycleLeft,[],2);
    inBetween = [curve1'; flipud(curve2')]; xAxis = [(1:length(curve1))'; flipud((1:length(curve1))')];
    fill(xAxis, movmean(inBetween,30), color(2,:), 'LineStyle', 'none', 'FaceAlpha', 0.3);
    
    plot(1:length(importData{1}.powerPerCycleLeft),movmean(importData{1}.powerPerCycleLeft, 10),'LineWidth',1.5, 'Color', colors{7}(4,:));
    plot(movmean(importData{rec}.powerPerCycleLeft, 10),'LineWidth',2, 'color', color(6,:));
    xlabel('Cycling revolutions'), ylabel('Power')
    title("Passive vs "+titles_recs{rec}+" power"), legend('','','Passive', 'tSCS'), grid on
    
end 
sgtitle('Power on left pedal during an averaged cycle', 'FontSize', 20);
%%
figure('Name', 'Power on right pedal')
for rec = 2:num_recordings 
    if rec == 2&&3 color = colors{1}; 
        else if rec == 4&&5 color = colors{2}; 
            else if rec == 6&&7 color = colors{3};
            end 
        end 
    end
    subplot(3,2,rec-1)
    % if rec == 1 subplot(4,2,rec-1); % per Cecere
    % else subplot(4,2,rec); 
    % end 
    curve1=importData{1}.powerPerCycleRight + std(importData{1}.powerPerCycleRight,[],2);
    curve2=importData{1}.powerPerCycleRight - std(importData{1}.powerPerCycleRight,[],2);
    inBetween = [curve1'; flipud(curve2')]; xAxis = [(1:length(curve1))'; flipud((1:length(curve1))')];
    fill(xAxis, movmean(inBetween,30), Yellow(1,:), 'LineStyle', 'none', 'FaceAlpha', 0.2); hold on
    
    curve1=importData{rec}.powerPerCycleRight + std(importData{rec}.powerPerCycleRight,[],2);
    curve2=importData{rec}.powerPerCycleRight - std(importData{rec}.powerPerCycleRight,[],2);
    inBetween = [curve1'; flipud(curve2')]; xAxis = [(1:length(curve1))'; flipud((1:length(curve1))')];
    fill(xAxis, movmean(inBetween,15), color(2,:), 'LineStyle', 'none', 'FaceAlpha', 0.3); hold on
    
    plot(1:length(importData{1}.powerPerCycleRight),movmean(importData{1}.powerPerCycleRight, 10),'LineWidth',1.5, 'Color', colors{7}(4,:));
    plot(movmean(importData{rec}.powerPerCycleRight, 30),'LineWidth',2, 'color', color(6,:)');
    xlabel('Cycling revolutions'), ylabel('Power')
    title("Passive vs "+titles_recs{rec}+" power"), legend('','','Passive', 'tSCS'), grid on
end 
sgtitle('Power on right pedal during an averaged cycle', 'FontSize', 20);

%% Legend Print
figure('Name','Legend');
for rec = 2:2:num_recordings+1
    if rec == 2 color = colors{1}; 
        else if rec == 4 color = colors{2}; 
            else if rec == 6 color = colors{3};
            else if rec == 8 color = colors{4}; 
            end 
            end 
        end 
    end
    if rec > num_recordings
         plot(0,0,'color', Yellow(5,:), 'LineWidth',2); hold on
    else 
        plot(0,0,'color', color(5,:),'LineWidth',2); hold on
        plot(0,0,'color', color(5,:),'LineStyle','--','LineWidth',2);
    end

end 
legend('20Hz + vol', '20Hz','50Hz+vol', '50Hz','80Hz+vol', '80Hz', 'passive', 'FontSize', 22, 'Orientation', 'horizontal')

% %% Boxplots of forces
% figure()
% for rec = 1:num_recordings
%     trial_array = importData{rec}.meanCycleForceLeft;
%     boxplot(trial_array,'Positions', rec, 'Widths', 0.20, 'Colors', colors{2}(5,:));
%     hold on 
%     title('Forces on single cycle - left pedal')
% end 
% set(gca, 'XTick', 1:num_recordings, 'XTickLabel', titles_recs); xtickangle(45);
% %%
% figure()
% for rec = 1:num_recordings
%     trial_array = importData{rec}.meanCycleForceRight;
%     boxplot(trial_array,'Positions', rec, 'Widths', 0.20, 'Colors', colors{2}(5,:));
%     hold on 
%     title('Forces on single cycle - right pedal')
% end 
% set(gca, 'XTick', 1:num_recordings, 'XTickLabel', titles_recs); xtickangle(45);
% %% Boxplots of powers
% figure()
% for rec = 1:num_recordings
%     trial_array = importData{rec}.powerPerCycleLeft;
%     boxplot(trial_array,'Positions', rec, 'Widths', 0.20, 'Colors', colors{rec}(5,:));
%     hold on 
%     title('Powers mediated - left pedal')
% end 
% set(gca, 'XTick', 1:num_recordings, 'XTickLabel', titles_recs); xtickangle(45);
% %%
% figure()
% for rec = 1:num_recordings
%     trial_array = importData{rec}.powerPerCycleRight;
%     boxplot(trial_array,'Positions', rec, 'Widths', 0.20, 'Colors', colors{2}(5,:));
%     hold on 
%     title('Powers mediated - right pedal')
% end 
% set(gca, 'XTick', 1:num_recordings, 'XTickLabel', titles_recs); xtickangle(45);