%% EMG ANALYSIS to compare muscle activation under tSCS 
% Anna Sparapani - March 2024
% EMG data analysis for tSCS + pedalling setup - data was acquired on a
% TMSI SAGA REV 2+ with 16 unipolar channels on 8 muscles (QUAD, HAMS, GAST
% and TA on each leg) during 6 cycling conditions on trike, on SCI subjects
% the 6 conditions, which are compared in the script, are: 
% tSCS 50/80/20Hz, tSCS 50/80/20 + voluntary effort for movement
clear all
close all
clc
num_recordings = 7; % Define the number of recordings

%% Import files  
% upload order: 20, 20 vol, 50, 50 vol, 80, 80 vol, passive
currpath = pwd;
data_struct = cell(num_recordings,1); % Initialize cell array to store data

for rec = 1:num_recordings
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
    data_struct{rec} = recording_data;
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

%% Filtering
for rec=1:num_recordings
    rawData=data_struct{rec}.rawData;
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
    data_struct{rec}.filteredData=filteredData;
end 

clear filteredData filteredHighPass filterFreq filterOrder freqToCut a d b  rawData filteredBandPass
%% Artefacts Removal
% 1. diff fa differenza tra punto e successivo 
% 2. findpeaks trovi tutti 
% escludere almeno 5 
% togliere offset

for rec=1:(num_recordings) 
    filteredData=data_struct{rec}.filteredData(1:end-2,:); 
    noArtData=data_struct{rec}.filteredData(1:end-2,:); %remove trigger and bipolar quad lines
    if data_struct{rec}.stim==1
        MinPeakDistance=(fs/data_struct{rec}.f_stim)-5; 
        for i=1:(size(filteredData,1)-2)
            if (i==3||i==4||i==7||i==8) MinPeakHeight = 10; 
            else MinPeakHeight = 20;
            end 
            [cycle_pks, cycle_locs]=findpeaks(filteredData(i,:),"MinPeakDistance",MinPeakDistance,"MinPeakHeight",MinPeakHeight);
            offset=mean(filteredData(i,:));
            for j=1:length(cycle_locs)
                if(cycle_locs(j)<6 && j==1)
                    noArtData(i,cycle_locs(j)-(cycle_locs(j)-2):cycle_locs(j)+5)=offset;
                else noArtData(i,cycle_locs(j)-5:cycle_locs(j)+5)=offset;
                end 
            end
            [cycle_pks, cycle_locs]=findpeaks(noArtData(i,:),"MinPeakDistance",MinPeakDistance,"MinPeakHeight",-MinPeakHeight);
            offset=mean(filteredData(i,:));
            for j=1:length(cycle_locs)
                if(cycle_locs(j)<6 && j==1)
                    noArtData(i,cycle_locs(j)-(cycle_locs(j)-2):cycle_locs(j)+5)=offset;
                else noArtData(i,cycle_locs(j)-5:cycle_locs(j)+5)=offset;
                end 
            end
        end 

        if plots_on
        figure('Name', titles_recs{rec})
        for i=1:size(noArtData,1)
            subplot(3,3,i), plot(filteredData(i,:)), ylabel('µV'),xlabel('time(s)'), title(titles_muscles(i));
            hold on; 
            subplot(3,3,i), plot(noArtData(i,:), 'Color','r'); 
            legend('Signal', 'No artefacts signal')
            hold off;
        end 
    end
    end 
    data_struct{rec}.noArtData=noArtData; clear noArtData; 
end 
clear noArtData MinPeakHeight MinPeakDistance

%% Per acquisizione (SUB02P01) - rimozione picco in passivo 
% figure(); 
% for i = 1:8 % per tutti e otto i canali 
%     noArtData = data_struct{7}.filteredData(i,:);
%     subplot(3,3,i), plot(data_struct{7}.filteredData(i,:)); hold on 
%     [peaks_passive, locs_passive] = findpeaks(data_struct{7}.filteredData(i,:),"MinPeakDistance",50000,"MinPeakHeight",500); 
%     [~, maxIndex] = max(peaks_passive);
%     offset=noArtData(locs_passive(maxIndex)-4000:locs_passive(maxIndex)-2000);
%     noArtData(locs_passive(maxIndex)-2000:locs_passive(maxIndex)) = offset;
% 
%     offset=noArtData(locs_passive(maxIndex)+2000:locs_passive(maxIndex)+4000);
%     noArtData(locs_passive(maxIndex):locs_passive(maxIndex)+2000) = offset;
% 
%     data_struct{7}.noArtData(i,:) = noArtData; 
%     subplot(3,3,i), plot(data_struct{7}.noArtData(i,:)); 
% end 
%% Offset removal
for rec=1:num_recordings
    noOffData=data_struct{rec}.noArtData;   
    noOffData = noOffData - mean(noOffData,2); 
    data_struct{rec}.noOffData = noOffData;  
    
    if plots_on
        figure('Name', titles_recs{rec})
        for i=1:size(data_struct{rec}.noOffData,1)
            subplot(3,3,i), plot(data_struct{rec}.noOffData(i,:)), ylabel('µV'),xlabel('time(s)'), title(titles_muscles(i)+" rectified");
        end 
    end
end
clear noOffData

%% Rectification
for rec=1:num_recordings
    data_struct{rec}.rectData=abs(data_struct{rec}.noOffData);
    if plots_on
        figure('Name', titles_recs{rec})
        for i=1:size(data_struct{rec}.rectData,1)
            subplot(3,3,i), plot(data_struct{rec}.rectData(i,:)), ylabel('µV'),xlabel('time(s)'), title(titles_muscles(i)+" rectified");
        end 
    end
end

%% Envelope
for rec=1:num_recordings
    envelopeData=[];filterFreq = 10; filterOrder = 5; % Low-pass filtering 100 Hz, 5 order
    [B, A] = butter(filterOrder, filterFreq/(fs/2), 'low'); 
    for i=1:size(data_struct{rec}.rectData,1)
        envelopeData(i,:) = filtfilt(B, A, data_struct{rec}.rectData(i,:)); 
    end 

    if plots_on
        figure('Name', titles_recs{rec});
        for i=1:size(data_struct{rec}.rectData,1)
            subplot(3,3,i), plot(data_struct{rec}.rectData(i,:)), ylabel('µV'),xlabel('time(s)'), title(titles_muscles(i)+" envelope");
            hold on; 
            subplot(3,3,i), plot(envelopeData(i,:));
            legend('Rectified Signal', 'Envelope');
            hold off; 
        end 
    end
    data_struct{rec}.envelopeData = envelopeData; clear envelopeData; 
end 
clear filterFreq filterOrder A B

%% COMPARE ACTIVATIONS 
% align on the 1st trigger
triggerLocsAll = cell(num_recordings,1);
smoothedDataAll = cell(num_recordings,1);
figure; plot(data_struct{rec}.rawData(9,:), 'b'); % Plot raw data
%% set sign of trigger
for rec = 1:num_recordings
    % add later trigger on if data_struct{rec}.
    [cycle_pks,cycle_locs]=findpeaks(-data_struct{rec}.rawData(9,:),"MinPeakDistance",1000,"MinPeakHeight",10000); 
    triggerLocsAll{rec} = cycle_locs; 
    % smooth signal over for plot
    smoothedData=[]; 
    for i = 1:size(data_struct{rec}.envelopeData,1)
        smoothedData(i,:) = movmean(data_struct{rec}.envelopeData(i,:), 10000);
    end
    data_struct{rec}.smoothedData = smoothedData;
     %Plot raw data with identified peaks
    % figure;
    % plot(data_struct{rec}.rawData(9,:), 'b'); % Plot raw data
    % hold on;
    % scatter(cycle_locs, cycle_pks, 'ro'); % Add circles at peak locations   
    % hold off;
end 
clear smoothedData
%%
for i=1:8
    figure('Name', titles_muscles{i})
    for rec = 1:num_recordings
        %xAxis = time(1:length(data_struct{rec}.smoothedData(i,triggerLocsAll{rec}(2):end)));
        if rec==7
            plot(data_struct{rec}.smoothedData(i,triggerLocsAll{rec}(2):end),'r','LineWidth',2)
        else plot(data_struct{rec}.smoothedData(i,triggerLocsAll{rec}(2):end),'LineWidth',0.8)
        end 
        title(titles_muscles(i));
        ylabel("EMG Amplitude [µV]"); xlabel("Time (s)")
        hold on
    end 
    legend(titles_recs)
end 

%% Cycling segmentation
for rec=1:num_recordings
    cycle_locs = triggerLocsAll{rec};
    for j=1:size(data_struct{rec}.envelopeData,1)
        for i=1:(length(cycle_locs)-1)
            segmentedData{j,i}=data_struct{rec}.envelopeData(j, cycle_locs(i):(cycle_locs(i+1)-1));
        end 
    end 
    data_struct{rec}.segmentedData=segmentedData; clear segmentedData; 
end 

% %% Plotting data for few revolutions 
% muscle=1; % HAMS DX  
% segment=30;
% 
% figure('Name', 'Single Cycles Activations')
% for rec = 1:num_recordings
%     timecycle=linspace(0, size(data_struct{rec}.segmentedData{muscle,segment},2)/fs, size(data_struct{rec}.segmentedData{muscle,segment},2));
%     title(titles_muscles(muscle))
%     if rec == 7 
%        plot(timecycle, movmean(data_struct{rec}.segmentedData{muscle,segment},200), 'LineWidth',2), xlabel('time(s)'), ylabel('EMG (µV)'); 
%     else plot(timecycle, movmean(data_struct{rec}.segmentedData{muscle,segment},200), 'LineWidth',1), xlabel('time(s)'), ylabel('EMG (µV)'); 
%     end 
%     hold on; 
% end 
% legend(titles_recs)

%% Averaging cycles for each muscle
for rec = 1:num_recordings  
    allCycles = data_struct{rec}.segmentedData;
    cycleLength = round(mean(cellfun(@length, allCycles(:)))); 
    % Interpolate data to have the same number of cycles in each segment
    interpolatedSegmentedData = cell(size(allCycles));
    for i = 1:size(allCycles,1) % cycling on muscles
        for j = 1:size(allCycles,2) % cycling on revolutions 
            interpolatedSegmentedData{i, j} = interp1(1:length(allCycles{i, j}), ...
                allCycles{i, j}, linspace(1, length(allCycles{i, j}), cycleLength));
        end
    end
    data_struct{rec}.interpolatedSegmentedData = interpolatedSegmentedData; 
    currentMuscle = zeros(size(allCycles, 2), cycleLength); % Initialize currentMuscle
    averagedCycles = zeros(8, cycleLength);
    for i = 1:size(allCycles, 1) % cycling on muscles 
        for j = 1:size(allCycles, 2) % cycling on revolustions 
            currentMuscle(j, :) = interpolatedSegmentedData{i, j}(1:cycleLength); % Take the first cycleLength elements
        end
        averagedCycles(i,:) = mean(currentMuscle,1);
    end 
    data_struct{rec}.averagedCycle = averagedCycles;
end 
clear averagedCycles currentMuscle allCycles interpolatedSegmentedData cycleLength
   
%% Averaged cycles plots - separated
movmeanVal = 1;
for i = 1:8
    figure('Name', titles_muscles{i})
    for rec = 1:4
        timecycle=linspace(0, size(data_struct{2*rec-1}.averagedCycle,2)/fs, size(data_struct{2*rec-1}.averagedCycle,2));
        % per sano: timecycle=linspace(0, size(data_struct{rec}.averagedCycle,2)/fs, size(data_struct{rec}.averagedCycle,2));

        if rec == 4 % passive with bolder line
           plot(timecycle,movmean(data_struct{2*rec-1}.averagedCycle(i,:),movmeanVal), 'color',Yellow(3,:), 'LineStyle', '-.', 'LineWidth', 2.5), 
           % per cecere: 
           % timecycle=linspace(0, size(data_struct{2*rec}.averagedCycle,2)/fs, size(data_struct{2*rec}.averagedCycle,2));
           % subplot(3,3,i), plot(timecycle,movmean(data_struct{2*rec}.averagedCycle(i,:),movmeanVal), 'k--','LineWidth',0.8), 
           % timecycle=linspace(0, size(data_struct{2*rec+1}.averagedCycle,2)/fs, size(data_struct{2*rec+1}.averagedCycle,2));
           % subplot(3,3,i), plot(timecycle,movmean(data_struct{2*rec+1}.averagedCycle(i,:),movmeanVal), 'k-.','LineWidth',0.8), 
           % 
           xlabel('time(s)'), ylabel('EMG (µV)'); 
        else 
            plot(timecycle,movmean(data_struct{2*rec-1}.averagedCycle(i,:),movmeanVal), 'LineWidth', 3 , 'color',colors{rec}(3,:)), 
            %per sano: subplot(3,3,i), plot(timecycle,movmean(data_struct{rec}.averagedCycle(i,:),movmeanVal), 'LineWidth', 1.5 , 'color',colors{rec}(6,:)), 

            hold on 
            timecycle=linspace(0, size(data_struct{2*rec}.averagedCycle,2)/fs, size(data_struct{2*rec}.averagedCycle,2));
            plot(timecycle,movmean(data_struct{2*rec}.averagedCycle(i,:),movmeanVal), 'LineWidth',2, 'color', colors{rec}(6,:))
            xlabel('time(s)'), ylabel('EMG (µV)');
        end 
        title(titles_muscles(i))
    end 
    title("Mean revolution EMG activation on "+titles_muscles(i));
    legend(titles_recs)
    hold off
end 

%% Averaged cycles plots - on same fig
figure()
movmeanVal=10;
% plotting standard deviation shades
for i = 1:8
    for rec = 1:4
        angles = linspace(0, 360, size(data_struct{2*rec-1}.averagedCycle, 2));
        subplot(2,4,i)
        if rec == 4 % passive with bolder line
           curve1=data_struct{2*rec-1}.averagedCycle(i,:)+ std(data_struct{2*rec-1}.averagedCycle(i,:)) ;
           curve2=data_struct{2*rec-1}.averagedCycle(i,:) - std(data_struct{2*rec-1}.averagedCycle(i,:));
           inBetween = [curve1'; flipud(curve2')]; 
           xAxis = [angles'; flipud(angles')];
           fill(xAxis, movmean(inBetween,20), colors{rec}(2,:), 'LineStyle', 'none', 'FaceAlpha', 0.2);
           hold on    
        else 
            curve1=data_struct{2*rec-1}.averagedCycle(i,:)+ std(data_struct{2*rec-1}.averagedCycle(i,:)) ;
            curve2=data_struct{2*rec-1}.averagedCycle(i,:) - std(data_struct{2*rec-1}.averagedCycle(i,:));
            inBetween = [curve1'; flipud(curve2')]; 
            xAxis = [angles'; flipud(angles')];
            fill(xAxis, movmean(inBetween,20), colors{rec}(2,:), 'LineStyle', 'none', 'FaceAlpha', 0.4);
            hold on

            angles = linspace(0, 360, size(data_struct{2*rec}.averagedCycle,2));
            subplot(2,4,i)
            curve1=data_struct{2*rec}.averagedCycle(i,:)+ std(data_struct{2*rec}.averagedCycle(i,:)) ;
            curve2=data_struct{2*rec}.averagedCycle(i,:) - std(data_struct{2*rec}.averagedCycle(i,:));
            inBetween = [curve1'; flipud(curve2')]; 
            xAxis = [angles'; flipud(angles')];
            fill(xAxis, movmean(inBetween,20), colors{rec}(2,:), 'LineStyle', 'none', 'FaceAlpha', 0.3);
        end 
    end
end 
% plotting mean EMG 
for i = 1:8 
    for rec = 1:4
        angles = linspace(0, 360, size(data_struct{2*rec-1}.averagedCycle, 2));
        % timecycle=linspace(0, size(data_struct{2*rec-1}.averagedCycle,2)/fs, size(data_struct{2*rec-1}.averagedCycle,2));
        % per sano: timecycle=linspace(0, size(data_struct{rec}.averagedCycle,2)/fs, size(data_struct{rec}.averagedCycle,2));
        subplot(2,4,i)  
        if rec == 4 % passive with bolder line
           subplot(2,4,i), plot(angles,movmean(data_struct{2*rec-1}.averagedCycle(i,:),movmeanVal), 'color', Yellow(4,:),'LineWidth',2), 
           % per cecere: 
           % timecycle=linspace(0, size(data_struct{2*rec}.averagedCycle,2)/fs, size(data_struct{2*rec}.averagedCycle,2));
           % subplot(3,3,i), plot(timecycle,movmean(data_struct{2*rec}.averagedCycle(i,:),movmeanVal), 'k--','LineWidth',0.8), 
           % timecycle=linspace(0, size(data_struct{2*rec+1}.averagedCycle,2)/fs, size(data_struct{2*rec+1}.averagedCycle,2));
           % subplot(3,3,i), plot(timecycle,movmean(data_struct{2*rec+1}.averagedCycle(i,:),movmeanVal), 'k-.','LineWidth',0.8), 
        else 
            subplot(2,4,i), plot(angles,movmean(data_struct{2*rec-1}.averagedCycle(i,:),movmeanVal), 'LineWidth', 2 , 'color',colors{rec}(5,:), 'LineStyle','-.'), hold on; 
            %per sano: subplot(3,3,i), plot(timecycle,movmean(data_struct{rec}.averagedCycle(i,:),movmeanVal), 'LineWidth', 1.5 , 'color',colors{rec}(6,:)), 

            %timecycle=linspace(0, size(data_struct{2*rec}.averagedCycle,2)/fs, size(data_struct{2*rec}.averagedCycle,2));
            angles = linspace(0, 360, size(data_struct{2*rec}.averagedCycle,2));
            subplot(2,4,i), plot(angles,movmean(data_struct{2*rec}.averagedCycle(i,:),movmeanVal), 'LineWidth',2, 'color', colors{rec}(5,:))
        end 
    end
    xlabel('Crank Angle (°)', 'FontSize', 14), ylabel('EMG (µV)','FontSize', 14);
    title(titles_muscles(i)), xlim([0,360]), set(gca, 'FontSize', 14);
    hold off
end 
%% Print Legend
figure()
for i=1:4
    if i >= 4
        if i == 5 plot(0,0, 'color','k', 'LineWidth', 2, 'LineStyle', '--'); hold on
        elseif i == 4
            plot(0,0, 'color',Yellow(3, :), 'LineWidth', 2 ); hold on 
        elseif i==6
           plot(0,0, 'color','k', 'LineWidth', 2, 'LineStyle', '-.' ); hold on 
        end 
    else
        plot(0,0, 'color',colors{i}(3,:), 'LineWidth', 2,'LineStyle', '-.' ); hold on 
        plot(0,0, 'color', colors{i}(5,:),'LineWidth',2), 
    end
    title("legend"); 
    h=legend(titles_recs); set(h,'FontSize',14);
end 

%% RMS errorplot on all cycles 
for muscle = 1:8
    for rec = 1:num_recordings
        for i = 1:size(data_struct{rec}.interpolatedSegmentedData,2)
            data_struct{rec}.rmsAllCycles(muscle, i) = rms(data_struct{rec}.interpolatedSegmentedData{muscle,i}); 
        end
    end 
end
figure(); 
for muscle = 1:8 
    subplot(2,4,muscle);
    for rec = 1:num_recordings
        if rec == 1 color = colors{1}; 
            else if rec == 3 color = colors{2}; 
                else if rec == 5 color = colors{3};
                else if rec==7 color = Yellow; 
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
    title(titles_muscles(muscle), 'FontSize',8); grid on;ylabel('RMS EMG [µV]'), xlim([0,8]),
    set(gca, 'XTick', 1:num_recordings, 'XTickLabel', titles_recs, 'FontSize', 16); xtickangle(45);
    
end 
sgtitle('RMS of EMG during cycling', 'FontSize', 22);

%% Normalized average cycle
for muscle = 1:8
    maxVal = 0;
    for rec = 1:num_recordings
        maxVal = max(maxVal, max(data_struct{rec}.averagedCycle(muscle,:)));
    end
    
    for rec = 1:num_recordings
        data_struct{rec}.avgCycleNorm(muscle, :) = data_struct{rec}.averagedCycle(muscle,:) / maxVal;
    end
end
%%
figure()
movmeanVal=200;
for i = 1:8
    for rec = 1:4
        %timecycle=linspace(0, size(data_struct{2*rec-1}.avgCycleNorm,2)/fs, size(data_struct{2*rec-1}.averagedCycle,2));
        angles = linspace(0, 360, size(data_struct{2 * rec - 1}.avgCycleNorm, 2));
        % per sano: angles = linspace(0, 360, size(data_struct{rec}.avgCycleNorm, 2));

        if rec == 4 % passive with bolder line
           subplot(2,4,i), plot(angles,movmean(data_struct{2*rec-1}.avgCycleNorm(i,:),movmeanVal), 'color',Yellow(4,:),'LineWidth',1.5), 
          % per sano:subplot(2,4,i), plot(angles,movmean(data_struct{rec}.avgCycleNorm(i,:),movmeanVal), 'color',Yellow(4,:),'LineWidth',1.5), hold on
           % per cecere: 
           % timecycle=linspace(0, size(data_struct{2*rec}.avgCycleNorm,2)/fs, size(data_struct{2*rec}.avgCycleNorm,2));
           % subplot(3,3,i), plot(timecycle,movmean(data_struct{2*rec}.avgCycleNorm(i,:),movmeanVal), 'k--','LineWidth',0.8), 
           % timecycle=linspace(0, size(data_struct{2*rec+1}.avgCycleNorm,2)/fs, size(data_struct{2*rec+1}.avgCycleNorm,2));
           % subplot(3,3,i), plot(timecycle,movmean(data_struct{2*rec+1}.avgCycleNorm(i,:),movmeanVal), 'k-.','LineWidth',0.8), 
        else 
            subplot(2,4,i), plot(angles,movmean(data_struct{2*rec-1}.avgCycleNorm(i,:),movmeanVal), 'LineWidth', 2 , 'color',colors{rec}(3,:)), 
            %per sano: subplot(2,4,i), plot(angles,movmean(data_struct{rec}.avgCycleNorm(i,:),movmeanVal), 'LineWidth', 1.5 , 'color',colors{rec}(6,:)), 
            hold on 
            %timecycle=linspace(0, size(data_struct{2*rec}.avgCycleNorm,2)/fs, size(data_struct{2*rec}.avgCycleNorm,2));
            angles = linspace(0, 360, size(data_struct{2 * rec}.avgCycleNorm, 2));
            subplot(2,4,i), plot(angles,movmean(data_struct{2*rec}.avgCycleNorm(i,:),movmeanVal), 'LineWidth',1.5, 'color', colors{rec}(6,:))
        end
    end 
    xlabel('Angle (°)','FontSize', 24), ylabel('EMG amplitude', 'FontSize',22), ylim([0,1]); xlim([0,360]);
    sgtitle('Normalized EMG during an averaged cycling revolution', 'FontSize', 24)
    title(titles_muscles(i), 'FontSize',18); set(gca, 'FontSize', 14); yticks(0:0.2:1); grid on;
end 
%% Print Legend  
figure()
for i=1:4
    if i >= 4
        if i == 5 plot(0,0, 'color','k', 'LineWidth', 2, 'LineStyle', '--'); hold on
        elseif i == 4
            plot(0,0, 'color',Yellow(3,:), 'LineWidth', 2 ); hold on 
        elseif i==6
            plot(0,0, 'color','k', 'LineWidth', 2, 'LineStyle', '-.' ); hold on 
        end 
    else
        plot(0,0, 'color',colors{i}(3,:), 'LineWidth', 2 ); hold on 
        plot(0,0, 'color', colors{i}(5,:),'LineWidth',1), 
    end
    title("legend"); 
    h=legend(titles_recs); set(h,'FontSize',14);
end 


%% UNUSED Code
% average cycle without interpolation to mean cycle length
% for rec = 1:num_recordings  
%     allCycles = data_struct{rec}.segmentedData;
%     cycleLength = min(cellfun(@length, allCycles(:))); % Get the minimum length of vectors
%     % add mean and interpolation!
%     currentMuscle = zeros(size(allCycles, 2), cycleLength); % Initialize currentMuscle
%     averagedCycles = zeros(8, cycleLength);
% 
%     for i = 1:size(allCycles, 1) % cycling on muscles 
%         for j = 1:size(allCycles, 2) % cycling on revolustions 
%             currentMuscle(j, :) = allCycles{i, j}(1:cycleLength); % Take the first cycleLength elements
%         end
%         averagedCycles(i,:) = mean(currentMuscle,1);
%     end 
%    data_struct{rec}.averagedCycle = averagedCycles; 
%    clear currentMuscle averagedCycles allCycles cycleLength
% end

% %% boxplots to compare mean activations
% for i=1:8 % iterate for all muscles
%     figure('Name', titles_muscles{i}); 
%     for rec=1:num_recordings
%         x_pos = rec; 
%         boxplot(data_struct{rec}.envelopeData(i,:), 'Positions', x_pos, 'Widths', 0.15);
%         hold on
%     end
%     title(titles_muscles(i));
%     legend('50Hz', '50Hz + vol','80Hz', '80Hz + vol', '20Hz', '20Hz + vol','passive')
% end 

% %% RMS, mean and variance computation on AVERAGE CYCLE
% for rec=1:num_recordings
%     data_struct{rec}.meanAvgCycleEMG= mean(data_struct{rec}.averagedCycle,2);
%     data_struct{rec}.rmsAvgCycleEMG = rms(data_struct{rec}.averagedCycle,2);
%     data_struct{rec}.varAvgCycleEMG= var(data_struct{rec}.averagedCycle,0,2);
% end
% 
% column_names={'Muscle', '50Hz','50 Hz + vol', '80Hz', '80Hz+vol','20Hz',...
%     '20Hz+vol', 'Passive Cyling'};
% 
% % Trms = table(titles_muscles(1:8)', data_struct{1}.rmsEMG, data_struct{2}.rmsEMG, ...
% %     data_struct{3}.rmsEMG, data_struct{4}.rmsEMG, data_struct{5}.rmsEMG, data_struct{6}.rmsEMG, ...
% %     data_struct{7}.rmsEMG, 'VariableNames', column_names)
% %% RMS on average cyclebar plots 
% for i = 1:8
%     for rec = 1:num_recordings
%         rms(i,rec) = data_struct{rec}.rmsAvgCycleEMG(i);
%     end 
% end
% figure();
% for muscle = 1:8
%     muscle_rms = rms(muscle, :);
%     subplot(2, 4, muscle);
%     for rec = 1:4
%         if rec == 4
%             bar(2*rec-1, muscle_rms(2*rec-1), 'FaceColor', [.7 .7 .7], 'EdgeColor', 'none'); hold on
%         else 
%             bar(2*rec-1, muscle_rms(2*rec-1), 'FaceColor', colors{rec}(3, :), 'EdgeColor', 'none'); hold on
%             bar(2*rec, muscle_rms(2*rec), 'FaceColor', colors{rec}(5, :), 'EdgeColor', 'none');
%         end
%     end
%     ylabel('RMS Value'); title(titles_muscles(muscle), 'FontSize',16); 
%     set(gca, 'XTick', 1:num_recordings, 'XTickLabel', titles_recs, 'FontSize', 14); xtickangle(45);
%     xlim([0.5 7.5]), %ylim([0 20])
% end
% sgtitle('RMS Values for EMG Acquisitions in Different Muscles during a mean cycle', 'FontSize', 20);

% %% RMS, mean and variance computation
% for rec=1:num_recordings
%     data_struct{rec}.meanEMG= mean(data_struct{rec}.envelopeData,2);
%     data_struct{rec}.rmsEMG = rms(data_struct{rec}.envelopeData,2);
%     data_struct{rec}.varEMG= var(data_struct{rec}.envelopeData,0,2);
% end
% 
% column_names={'Muscle', '50Hz','50 Hz + vol', '80Hz', '80Hz+vol','20Hz',...
%     '20Hz+vol', 'Passive Cyling'};

% Trms = table(titles_muscles(1:8)', data_struct{1}.rmsEMG, data_struct{2}.rmsEMG, ...
%     data_struct{3}.rmsEMG, data_struct{4}.rmsEMG, data_struct{5}.rmsEMG, data_struct{6}.rmsEMG, ...
%     data_struct{7}.rmsEMG, 'VariableNames', column_names)
% %% RMS bar plots on mean cycle
% for i = 1:8
%     for rec = 1:num_recordings
%         rms(i,rec) = data_struct{rec}.rmsEMG(i);
%     end 
% end
% figure();
% for muscle = 1:8
%     muscle_rms = rms(muscle, :);
%     subplot(2, 4, muscle);
%     for rec = 1:4
%         if rec == 4
%            %per sano: bar(rec, muscle_rms(rec), 'FaceColor', Yellow(2,:),'FaceAlpha',0.7,'EdgeColor', 'none'); hold on
%            bar(2*rec-1, muscle_rms(2*rec-1), 'FaceColor', Yellow(2,:),'FaceAlpha',0.6, 'EdgeColor', 'none'); hold on
%         else 
%             %per sano: bar(rec, muscle_rms(rec), 'FaceColor', colors{rec}(3, :), 'EdgeColor', 'none'); hold on
%             bar(2*rec-1, muscle_rms(2*rec-1), 'FaceColor', colors{rec}(3, :), 'EdgeColor', 'none'); hold on
%             bar(2*rec, muscle_rms(2*rec), 'FaceColor', colors{rec}(5, :), 'EdgeColor', 'none');
%         end
%     end
%     ylabel('RMS Value'); title(titles_muscles(muscle), 'FontSize',16); 
%     set(gca, 'XTick', 1:num_recordings, 'XTickLabel', titles_recs, 'FontSize', 14); xtickangle(45);
%     xlim([0.5 7.5]), %ylim([0 20])
% end
% sgtitle('RMS Values for EMG Acquisitions in Different Muscles', 'FontSize', 20);
