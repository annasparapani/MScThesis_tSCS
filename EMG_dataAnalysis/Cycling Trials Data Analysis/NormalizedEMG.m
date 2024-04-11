%% EMG Normalization w.r.t. no movement EMG baseline
% baseline exctracted from the calibration phase data
clear all
close all
clc
num_recordings = 9; % Define the number of recordings

%% Import files  
% upload order: 20, 20 vol, 50, 50 vol, 80, 80 vol, passive
currpath = pwd;
%data_struct = cell(num_recordings,1); % Initialize cell array to store data

for rec = 1:1
    [FileName, PathName] = uigetfile('*.Poly5', ['Select recording ', num2str(rec)]);
    data_mot_emg=[];
    data_mot_emg = TMSiSAGA.Poly5.read(fullfile(PathName, FileName));
    fs = data_mot_emg.sample_rate;
    
    % Ask for f_stim value and toggle options
    prompt = {'Enter the f_stim value:', 'Stimulation', 'Cycling', 'Voluntary'};
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {'50', '0', '0','0'}; % Default values: f_stim=50, both toggles unchecked
    options = inputdlg(prompt, dlgtitle, dims, definput);
    
    % Convert the input to numeric values
    f_stim = str2double(options{1}); % Convert from cell array to double
    stimOn = str2double(options{2});
    triggerOn = str2double(options{3});
    volOn = str2double(options{4});
    
    Emg_Signal=[];
    mono=[];
    % Variables
    Emg_Signal=data_mot_emg.samples(:,:);

    for i=1:8 %monopolars subtraction
        mono(i,:) = Emg_Signal(2*i-1,:) - Emg_Signal(2*i,:);
    end
    bipChannels=Emg_Signal(17:18,:);
    time=linspace( 0 , max(size(Emg_Signal(1,:)))/fs, max(size(Emg_Signal(1,:))) )';
    rawData = [mono; bipChannels]; 
    rawData=rawData(:,1:end-2000);
    
    % Save data to structure
    recording_data.rawData = rawData; 
    recording_data.f_stim = f_stim;
    recording_data.vol = volOn;
    recording_data.stim=stimOn;
    
    % Save the data for this recording into the structure array
    data_struct_calibration{rec} = recording_data;
end
clear RawData f_stim volOn triggerOn stimOn
%%
clear recording_data time Emg_Signal data_mot_emg rawData prompt dlgtitle dims bipChannels mono
plots_on = 1;
fs=2000;
% francesca : titles_recs = {'50Hz', '80Hz', '20 Hz', 'passive'}
titles_recs={'20Hz', '20Hz + vol','50Hz', '50Hz + vol','80Hz', '80Hz + vol','passive', 'passive + vol', 'passive + vol finale'}; 
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
%% Process Calibration data
% filtering
for rec=1:1
    rawData=data_struct_calibration{rec}.rawData;
    % spectrumRaw=[]; figi ure("Name","Spectrum Raw"); % print raw spectrum
    % for i=1:size(rawData,1)
    %     spectrumRaw(i,:) = pspectrum(rawData(i,:),fs);
    %     subplot(4,3,i), plot((0:length(spectrumRaw(i,:))-1) * fs/length(spectrumRaw(i,:)), spectrumRaw(i,:));
    %     title("Raw spectrum of "+titles(i)), ylim([0,4000]);
    % end 
    
    filteredHighPass = []; filterOrder = 3; filterFreq = 10; % Butterworth 3 ordine HP @10Hz
    [b, a] = butter(filterOrder, filterFreq/(fs/2), 'high'); 
    for j = 1:size(rawData,1)
        filteredHighPass(j,:)=filtfilt(b, a, rawData(j,:)); 
    end
    
    filteredBandPass = []; filterOrder = 5; filterFreq = 500; % Butterworth 3 ordine LP @750Hz
    [b, a] = butter(filterOrder, filterFreq/(fs/2), 'low'); 
    for j = 1:size(rawData,1)
        filteredBandPass(j,:)=filtfilt(b, a, filteredHighPass(j,:)); 
    end 
    
    filteredData = filteredBandPass; filterOrder = 6; freqToCut=50; % Notch 50 Hz
    for i=1:1
        d = designfilt('bandstopiir', 'FilterOrder', filterOrder, 'HalfPowerFrequency1',(freqToCut*i)-1, ...
            'HalfPowerFrequency2', (freqToCut*i)+1, 'DesignMethod', 'butter', 'SampleRate', fs);
        for j=1:size(rawData,1)
            filteredData(j,:) = filtfilt(d, filteredData(j,:)); 
        end 
    end 
    
    % spectrumFiltered=[]; figure("Name","Spectrum filtered");
    % for i=1:size(filteredData,1)
    %     spectrumFiltered(i,:) = pspectrum(filteredData(i,:),fs);
    %     subplot(4,3,i), plot((0:length(spectrumFiltered(i,:))-1) * fs/length(spectrumFiltered(i,:)), spectrumFiltered(i,:));
    %     ylabel('Power/Frequency (dB/Hz)'), xlabel('Frequency (Hz)'), title(titles(i));
    % end 
    
    if plots_on % plot time course of filtered data
        figure('Name', titles_recs{rec})
        for i=1:10
            subplot(4,3,i), plot(filteredData(i,:)), ylabel('µV'),xlabel('time(s)'), title(titles_muscles(i));
        end 
    end
    data_struct_calibration{rec}.filteredData=filteredData;
end 

clear filteredHighPass filterFreq filterOrder freqToCut a d b  rawData filteredBandPass
%% Baseline extraction and processing
figure();
for muscle = 1:10
    baseline=[];
    baseline=data_struct_calibration{1}.filteredData(muscle,1000:11000);
    baseline = baseline - mean(baseline); % remove offset
    baseline = abs(baseline); % rectified
    filterFreq = 10; filterOrder = 5; % Envelope: Low-pass filtering 100 Hz, 5 order
    [B, A] = butter(filterOrder, filterFreq/(fs/2), 'low'); 
    baseline = filtfilt(B, A, baseline); 
    data_struct_calibration{1}.baseline(muscle,:) = baseline;
    subplot(4,3,muscle), plot(baseline) 
end 
%% Normalizzazione rispetto a mean(baseline) 
for muscle = 1:8 
    % if muscle == 1 per Davide Rho
    %     valNorm = mean(data_struct_calibration{1}.baseline(5,:));
    % else 
    %     valNorm = mean(data_struct_calibration{1}.baseline(muscle,:));
    % end 
    valNorm = mean(data_struct_calibration{1}.baseline(muscle,:));
    for rec = 1:num_recordings
        data_struct{rec}.normAvgCycle(muscle,:) = data_struct{rec}.averagedCycle(muscle,:)/valNorm; 
    end 
end 
%%
figure('WindowState','fullscreen')
movmeanVal=10;
% plotting standard deviation shades
for i = 1:8
    for rec = 1:4
        angles = linspace(0, 360, size(data_struct{2*rec-1}.normAvgCycle, 2));
        subplot(2,4,i)
        if rec == 4 % passive with bolder line
           curve1=data_struct{2*rec-1}.normAvgCycle(i,:)+ std(data_struct{2*rec-1}.normAvgCycle(i,:)) ;
           curve2=data_struct{2*rec-1}.normAvgCycle(i,:) - std(data_struct{2*rec-1}.normAvgCycle(i,:));
           inBetween = [curve1'; flipud(curve2')]; 
           xAxis = [angles'; flipud(angles')];
           fill(xAxis, movmean(inBetween,20), colors{rec}(2,:), 'LineStyle', 'none', 'FaceAlpha', 0.2);
           hold on    
        else 
            curve1=data_struct{2*rec-1}.normAvgCycle(i,:)+ std(data_struct{2*rec-1}.normAvgCycle(i,:)) ;
            curve2=data_struct{2*rec-1}.normAvgCycle(i,:) - std(data_struct{2*rec-1}.normAvgCycle(i,:));
            inBetween = [curve1'; flipud(curve2')]; 
            xAxis = [angles'; flipud(angles')];
            fill(xAxis, movmean(inBetween,20), colors{rec}(2,:), 'LineStyle', 'none', 'FaceAlpha', 0.4);
            hold on

            angles = linspace(0, 360, size(data_struct{2*rec}.normAvgCycle,2));
            subplot(2,4,i)
            curve1=data_struct{2*rec}.normAvgCycle(i,:)+ std(data_struct{2*rec}.normAvgCycle(i,:)) ;
            curve2=data_struct{2*rec}.normAvgCycle(i,:) - std(data_struct{2*rec}.normAvgCycle(i,:));
            inBetween = [curve1'; flipud(curve2')]; 
            xAxis = [angles'; flipud(angles')];
            fill(xAxis, movmean(inBetween,20), colors{rec}(2,:), 'LineStyle', 'none', 'FaceAlpha', 0.3);
        end 
    end
end 
%% 
figure('WindowState','fullscreen')
% plotting mean EMG 
for i = 1:8 
    for rec = 1:4
        angles = linspace(0, 360, size(data_struct{2*rec-1}.normAvgCycle, 2));
        % timecycle=linspace(0, size(data_struct{2*rec-1}.averagedCycle,2)/fs, size(data_struct{2*rec-1}.averagedCycle,2));
        % per sano: timecycle=linspace(0, size(data_struct{rec}.averagedCycle,2)/fs, size(data_struct{rec}.averagedCycle,2));
        subplot(2,4,i)  
        if rec == 4 % passive with bolder line
           subplot(2,4,i), plot(angles,movmean(data_struct{2*rec-1}.normAvgCycle(i,:),movmeanVal), 'color', Yellow(4,:),'LineWidth',2), 
           % per cecere: 
           %timecycle=linspace(0, size(data_struct{2*rec}.averagedCycle,2)/fs, size(data_struct{2*rec}.averagedCycle,2));
           angles = linspace(0, 360, size(data_struct{2*rec}.normAvgCycle, 2));
           subplot(2,4,i), plot(angles,movmean(data_struct{2*rec}.normAvgCycle(i,:),movmeanVal), 'k--','LineWidth',1.5), 
           %timecycle=linspace(0, size(data_struct{2*rec+1}.averagedCycle,2)/fs, size(data_struct{2*rec+1}.averagedCycle,2));
           angles = linspace(0, 360, size(data_struct{2*rec+1}.normAvgCycle, 2));
           subplot(2,4,i), plot(angles,movmean(data_struct{2*rec+1}.normAvgCycle(i,:),movmeanVal), 'k-.','LineWidth',1.5), 
        else 
            subplot(2,4,i), plot(angles,movmean(data_struct{2*rec-1}.normAvgCycle(i,:),movmeanVal), 'LineWidth', 2 , 'color',colors{rec}(5,:), 'LineStyle','-.'), hold on; 
            %per sano: subplot(3,3,i), plot(timecycle,movmean(data_struct{rec}.averagedCycle(i,:),movmeanVal), 'LineWidth', 1.5 , 'color',colors{rec}(6,:)), 

            %timecycle=linspace(0, size(data_struct{2*rec}.averagedCycle,2)/fs, size(data_struct{2*rec}.averagedCycle,2));
            angles = linspace(0, 360, size(data_struct{2*rec}.normAvgCycle,2));
            subplot(2,4,i), plot(angles,movmean(data_struct{2*rec}.normAvgCycle(i,:),movmeanVal), 'LineWidth',2, 'color', colors{rec}(5,:))
        end 
    end 
    title(titles_muscles(i), 'FontSize', 20), xlim([0,360]);  set(gca, 'FontSize', 18); 
    ylim([0,24])
    if i > 4 xlabel('Right Crank Angle (°)', 'FontSize' , 20); end 
    if i == 1 || i == 5 ylabel('EMG (times wrt baseline)', 'FontSize' , 20); end
    hold off
end 
legend('','','','','','','',titles_recs, 'Orientation','Horizontal')
%% RMS Normalized errorplot

for muscle = 1:8
    if muscle == 1 
        valNorm = mean(data_struct_calibration{1}.baseline(5,:));
    else 
        valNorm = mean(data_struct_calibration{1}.baseline(muscle,:));
    end  
    %valNorm = mean(data_struct_calibration{1}.baseline(muscle,:));
    for rec = 1:num_recordings
        for i = 1:size(data_struct{rec}.interpolatedSegmentedData,2)
            data_struct{rec}.rmsAllCycles(muscle, i) = rms(data_struct{rec}.interpolatedSegmentedData{muscle,i}/valNorm); 
        end
    end 
end
figure('WindowState','fullscreen')
for muscle = 1:8 
    subplot(2,4,muscle);
    for rec = 1:num_recordings
        if rec == 1 color = colors{1}; 
            else if rec == 3 color = colors{2}; 
                else if rec == 5 color = colors{3};
                else if rec==7 color = Yellow; 
                else if rec == 8 color = zeros(5,3);
                end
                    end 
                end
            end 
        end
        if rem(rec,2)==0
        errorbar(rec, mean(data_struct{rec}.rmsAllCycles(muscle,:)),std(data_struct{rec}.rmsAllCycles(muscle,:)), ...
            'o', 'MarkerSize',15, 'MarkerFaceColor', color(2,:), 'LineWidth', 1.5, 'color', color(5,:)); hold on;
        else if rec == 1 
            errorbar(rec, mean(data_struct{rec}.rmsAllCycles(muscle,:)),std(data_struct{rec}.rmsAllCycles(muscle,:)), ...
            'o', 'MarkerSize', 15, 'LineWidth', 1.5, 'color', color(5,:)); hold on; 
            else if rec > 1
                errorbar(rec, mean(data_struct{rec}.rmsAllCycles(muscle,:)),std(data_struct{rec}.rmsAllCycles(muscle,:)), ...
                'o', 'MarkerSize', 15, 'LineWidth', 1.5, 'color', color(5,:), 'LineStyle', '--'); hold on;
            end 
        end 
    end
    end 
    title(titles_muscles(muscle), 'FontSize',20); grid on;
    if muscle == 1 || muscle == 5 
        ylabel('RMS EMG (times wrt baseline)', 'FontSize' , 20, 'Position', [-1 7 0]); end
    xlim([0,9.5]),
    set(gca, 'FontSize', 18); 
    if muscle > 4 
    set(gca, 'XTick', 1:num_recordings, 'XTickLabel', titles_recs, 'FontSize', 14); xtickangle(45);
    else 
        set(gca,'Xticklabel',[]); 
    end

    ylim([0,14]); 
end 
sgtitle('RMS of EMG during cycling', 'FontSize', 22);