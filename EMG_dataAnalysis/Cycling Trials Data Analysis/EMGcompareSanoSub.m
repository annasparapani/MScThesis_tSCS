%% Overlap sano e Edo / Cecere per vedere sfasamento 
clear all
close all
clc
num_recordings = 7; % Define the number of recordings
clear recording_data time Emg_Signal data_mot_emg rawData prompt dlgtitle dims bipChannels mono
plots_on = 1;
fs=2000;
% francesca : titles_recs = {'50Hz', '80Hz', '20 Hz', 'passive'}
titles_recs={'50Hz', '50Hz + vol','80Hz', '80Hz + vol', '20Hz', '20Hz + vol','passive', 'passive + vol', 'passive + vol finale'}; 
titles_muscles={'QUAD RIGHT','HAMS RIGHT', 'GAST RIGHT', 'TA RIGHT',...
    'QUAD LEFT','HAMS LEFT', 'GAST LEFT', 'TA LEFT', 'Trigger','QUAD RIGHT bip'};
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

%% Normalized average cycles for both data sets
for muscle = 1:8
    maxVal = 0;
    for rec = 1:num_recordings
        maxVal = max(maxVal, max(data_struct{rec}.averagedCycle(muscle,:)));
    end
    
    for rec = 1:num_recordings
        data_struct{rec}.avgCycleNorm(muscle, :) = data_struct{rec}.averagedCycle(muscle,:) / maxVal;
    end
    
        maxVal = max(data_struct_sano{1}.averagedCycle(muscle,:));
        data_struct_sano{1}.avgCycleNorm(muscle,:) =  data_struct_sano{1}.averagedCycle(muscle,:)/maxVal;
    
end
%% Right leg plot
screen_size = get(0, 'ScreenSize'); screen_width = screen_size(3); screen_height = screen_size(4);
desired_width = screen_width / 2;
desired_height = screen_height / 1;
figure('Name','EMG compared with healthy subject','Position', [screen_width/4, screen_height/4, desired_width, desired_height]);
movmeanVal = 10;

for muscle = 1:2
    for rec = 1:5
        if rec >= 4 
            if rec==4
               angles = linspace(0, 360, size(data_struct{7}.avgCycleNorm, 2));
               subplot(2,2,muscle), plot(angles,movmean(data_struct{2*rec-1}.avgCycleNorm(muscle,:),movmeanVal), 'color',Yellow(4,:),'LineWidth',1.5), 
               % per cecere: 
               % angles = linspace(0, 360, size(data_struct{2*rec}.avgCycleNorm, 2));
               % subplot(2,2,muscle), plot(angles,movmean(data_struct{2*rec}.avgCycleNorm(muscle,:),movmeanVal), 'k--','LineWidth', 1), 
               % angles = linspace(0, 360, size(data_struct{2*rec+1}.avgCycleNorm, 2));
               % subplot(2,2,muscle), plot(angles,movmean(data_struct{2*rec+1}.avgCycleNorm(muscle,:),movmeanVal), 'k-.','LineWidth',1), 
            end  
            if rec == 5
                angles = linspace(0, 360, size(data_struct_sano{1}.avgCycleNorm, 2));
                subplot(2,2,muscle), plot(angles,data_struct_sano{1}.avgCycleNorm(muscle,:), 'color','k','LineWidth',2), 
            end 
            else
            angles = linspace(0, 360, size(data_struct{2 * rec - 1}.avgCycleNorm, 2));
            subplot(2,2,muscle), plot(angles,movmean(data_struct{2*rec-1}.avgCycleNorm(muscle,:),movmeanVal), 'LineWidth', 2 , 'color',colors{rec}(5,:), 'LineStyle','--'), 
            hold on 
            %timecycle=linspace(0, size(data_struct{2*rec}.avgCycleNorm,2)/fs, size(data_struct{2*rec}.avgCycleNorm,2));
            angles = linspace(0, 360, size(data_struct{2 * rec}.avgCycleNorm, 2));
            subplot(2,2,muscle), plot(angles,movmean(data_struct{2*rec}.avgCycleNorm(muscle,:),movmeanVal), 'LineWidth',2, 'color', colors{rec}(5,:))
        end 
    end 
    xlabel('Angle (°)','FontSize', 24), ylabel('EMG amplitude', 'FontSize', 22), ylim([0,1.05]); xlim([0,360]);
    sgtitle('Normalized EMG during an averaged cycling revolution', 'FontSize', 24)
    title(titles_muscles(muscle), 'FontSize',18); set(gca, 'FontSize', 20); yticks(0:0.2:1); grid on; 
end 
%
for muscle = 5:6
    for rec = 1:5
        if rec >= 4 
            if rec==4
               angles = linspace(0, 360, size(data_struct{7}.avgCycleNorm, 2));
               subplot(2,2,muscle-2), plot(angles,movmean(data_struct{2*rec-1}.avgCycleNorm(muscle,:),movmeanVal), 'color',Yellow(4,:),'LineWidth',1.5), 
               % per cecere: 
               % angles = linspace(0, 360, size(data_struct{2*rec}.avgCycleNorm, 2));
               % subplot(1,2,muscle), plot(angles,movmean(data_struct{2*rec}.avgCycleNorm(muscle,:),movmeanVal), 'k--','LineWidth',0.8), 
               % angles = linspace(0, 360, size(data_struct{2*rec+1}.avgCycleNorm, 2));
               %  subplot(1,2,muscle), plot(angles,movmean(data_struct{2*rec+1}.avgCycleNorm(muscle,:),movmeanVal), 'k-.','LineWidth',0.8), 
            end  
            if rec == 5
                angles = linspace(0, 360, size(data_struct_sano{1}.avgCycleNorm, 2));
                subplot(2,2,muscle-2), plot(angles,data_struct_sano{1}.avgCycleNorm(muscle,:), 'color','k','LineWidth',2), 
            end 
        else
            angles = linspace(0, 360, size(data_struct{2 * rec - 1}.avgCycleNorm, 2));
            subplot(2,2,muscle-2), plot(angles,movmean(data_struct{2*rec-1}.avgCycleNorm(muscle,:),movmeanVal), 'LineWidth', 2 , 'color',colors{rec}(6,:), 'LineStyle','--'), 
            hold on 
            %timecycle=linspace(0, size(data_struct{2*rec}.avgCycleNorm,2)/fs, size(data_struct{2*rec}.avgCycleNorm,2));
            angles = linspace(0, 360, size(data_struct{2 * rec}.avgCycleNorm, 2));
            subplot(2,2,muscle-2), plot(angles,movmean(data_struct{2*rec}.avgCycleNorm(muscle,:),movmeanVal), 'LineWidth',2, 'color', colors{rec}(6,:))
        end 
    end 
    xlabel('Angle (°)','FontSize', 24), ylabel('EMG amplitude', 'FontSize',22), ylim([0,1.05]); xlim([0,360]);
    sgtitle('Normalized EMG during an averaged cycling revolution', 'FontSize', 24)
    title(titles_muscles(muscle), 'FontSize',18); set(gca, 'FontSize', 20); yticks(0:0.2:1); grid on; 
end 

%% Print Legend  
figure()
for i=1:7
    if i >= 4
        if i == 5 plot(0,0,'k--', 'LineWidth', 2); hold on
        elseif i == 4
            plot(0,0, 'color',Yellow(3,:), 'LineWidth', 2 ); hold on 
        elseif i==6
            plot(0,0, 'color','k', 'LineWidth', 2, 'LineStyle', '-.' ); hold on 
        else if i == 7 
           plot(0,0, 'color','k', 'LineWidth', 2 ); hold on 
        end
        end 
    else
        plot(0,0, 'color',colors{i}(3,:), 'LineWidth', 2 ); hold on 
        plot(0,0, 'color', colors{i}(5,:),'LineWidth',1), 
    end
    title("legend"); 
    h=legend(titles_recs); set(h,'FontSize',14);
end 