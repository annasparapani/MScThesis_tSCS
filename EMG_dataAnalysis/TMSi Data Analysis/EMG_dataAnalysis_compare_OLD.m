%% Load data for multiple recordings
clear all
close all
clc
num_recordings = 7; % Define the number of recordings

%%
% Get file names for multiple recordings
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
plots_on = 1;
titles_recs={'50Hz', '50Hz + vol','80Hz', '80Hz + vol', '20Hz', '20Hz + vol','passive'}; 
titles_muscles={'QUAD Dx mono','HAMS Dx mono', 'GAST Dx mono', 'TA Dx mono',...
    'QUAD Sx mono','HAMS Sx mono', 'GAST Sx mono', 'TA Sx mono',...
    'Trigger','QUAD Dx bip',};

%% Filtering
filteredDataAll=cell(num_recordings,1); 
for rec=1:num_recordings
    rawData=data_struct{rec}.rawData;
    % spectrumRaw=[]; figure("Name","Spectrum Raw"); % print raw spectrum
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
    
    filteredBandPass = []; filterOrder = 3; filterFreq = 750; % Butterworth 3 ordine LP @750Hz
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

% if stimOn&(triggerOn==0) % calibrazione, stampo il bipolare del quadricipite dx
%     figure();
%     plot(time, filteredData(10,:), title(10)); 
% end
clear filteredData
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
            else MinPeakHeight = 50;
            end 
            [cycle_pks, cycle_locs]=findpeaks(filteredData(i,:),"MinPeakDistance",MinPeakDistance,"MinPeakHeight",MinPeakHeight);
            offset=mean(filteredData(i,:));
            for j=1:length(cycle_locs)
                if(cycle_locs(j)<6 && j==1)
                    noArtData(i,cycle_locs(j)-(cycle_locs(j)-2):cycle_locs(j)+4)=offset;
                else noArtData(i,cycle_locs(j)-5:cycle_locs(j)+3)=offset;
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

% if stimOn&(triggerOn==0)% calibrazione
%     for i=1:(size(filteredData,1))
%         [cycle_pks, cycle_locs]=findpeaks(filteredData(i,:),"MinPeakDistance",1000,"MinPeakHeight",20);
%         offset=mean(filteredData(i,:));
%         for j=1:length(cycle_locs)
%             if(cycle_locs(j)<6 & j==1)
%                 noArtData(i,cycle_locs(j)-(cycle_locs(j)-1):cycle_locs(j)+3)=offset;
%             else noArtData(i,cycle_locs(j)-5:cycle_locs(j)+5)=offset;
%             end 
%         end 
%     end
% 
% end 
clear noArtData
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
    data_struct{rec}.rectData=abs(data_struct{rec}.noArtData);
    if plots_on
        figure('Name', titles_recs{rec})
        for i=1:size(data_struct{rec}.rectData,1)
            subplot(3,3,i), plot(data_struct{rec}.rectData(i,:)), ylabel('µV'),xlabel('time(s)'), title(titles_muscles(i)+" rectified");
        end 
    end
end

%% Envelope
for rec=1:num_recordings
    envelopeData=[];filterFreq = 50; filterOrder = 5; % Low-pass filtering 100 Hz, 5 order
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
%% COMPARE ACTIVATIONS 
% align on the 1st trigger
triggerLocsAll = cell(num_recordings,1);
smoothedDataAll = cell(num_recordings,1);
for rec = 1:num_recordings
    % add later trigger on if data_struct{rec}.
    [cycle_pks,cycle_locs]=findpeaks(data_struct{rec}.rawData(9,:),"MinPeakDistance",1000,"MinPeakHeight",10000); 
    triggerLocsAll{rec} = cycle_locs; 
    % smooth signal over for plot
    smoothedData=[]; 
    for i = 1:size(data_struct{rec}.envelopeData,1)
        smoothedData(i,:) = movmean(data_struct{rec}.envelopeData(i,:), 10000);
    end
    data_struct{rec}.smoothedData = smoothedData;
     % Plot raw data with identified peaks
    figure;
    plot(data_struct{rec}.rawData(9,:), 'b'); % Plot raw data
    hold on;
    scatter(cycle_locs, cycle_pks, 'ro'); % Add circles at peak locations
    title(['Raw Data with Identified Peaks - Recording ', num2str(rec)]);
    xlabel('Sample Index');
    ylabel('Amplitude');
    legend('Raw Data', 'Identified Peaks');
    hold off;
end 
clear smoothedData
%%
for i=1:8
    figure('Name', titles_muscles{i})
    for rec = 1:num_recordings
        xAxis = time(1:length(data_struct{rec}.smoothedData(i,triggerLocsAll{rec}(2):end)));
        if rec==7
            plot(xAxis, data_struct{rec}.smoothedData(i,triggerLocsAll{rec}(2):end),'r','LineWidth',2)
        else plot(xAxis, data_struct{rec}.smoothedData(i,triggerLocsAll{rec}(2):end),'LineWidth',0.8)
        end 
        title(titles_muscles(i));
        ylabel("EMG Amplitude [µV]"); xlabel("Time (s)")
        hold on
    end 
    legend('50 Hz', '50Hz + vol', '80 Hz', '80Hz + vol', '20 Hz', '20Hz + vol', 'passive')
end 

%% Table to compare mean activations
meanActivations = cell(num_recordings,1);
for rec=1:num_recordings
    meanActivations{rec} = mean(data_struct{rec}.envelopeData,2);
end
column_names={'Muscle', '50Hz','50 Hz + vol', '80Hz', '80Hz+vol','20Hz',...
    '20Hz+vol', 'Passive Cyling'};
Tmean = table(titles_muscles(1:8)', meanActivations{1}, meanActivations{2}, ...
    meanActivations{3}, meanActivations{4}, meanActivations{5}, meanActivations{6}, ...
    meanActivations{7}, 'VariableNames', column_names)

% variance computation and table
varActivations = cell(num_recordings,1);
for rec=1:num_recordings
    varActivations{rec} = var(data_struct{rec}.envelopeData,0,2);
end

column_names={'Muscle', '50Hz','50 Hz + vol', '80Hz', '80Hz+vol','20Hz',...
    '20Hz+vol', 'Passive Cyling'};
Tvar = table(titles_muscles(1:8)', varActivations{1}, varActivations{2}, ...
    varActivations{3}, varActivations{4}, varActivations{5}, varActivations{6}, ...
    varActivations{7}, 'VariableNames', column_names)

%% boxplots to compare mean activations
for i=1:8 % iterate for all muscles
    figure('Name', titles_muscles{i}); 
    for rec=1:num_recordings
         x_pos = rec; 
        boxplot(envelopeDataAll{rec}(i,:), 'Positions', x_pos, 'Widths', 0.15);
        hold on
    end
    title(titles_muscles(i));
    legend('50Hz', '50Hz + vol','80Hz', '80Hz + vol', '20Hz', '20Hz + vol','passive')
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

%% Plotting data for few revolutions 
    
muscle=5; % HAMS DX  
segment=65;

figure('Name', 'Single Cycles Activations')
for rec = 1:num_recordings
    timecycle=linspace(0, size(data_struct{rec}.segmentedData{muscle,segment},2)/fs, size(data_struct{rec}.segmentedData{muscle,segment},2));
    title(titles_muscles(muscle))
    if rec == 7 
       plot(timecycle, movmean(data_struct{rec}.segmentedData{muscle,segment},200), 'LineWidth',2), xlabel('time(s)'), ylabel('EMG (µV)'); 
    else plot(timecycle, movmean(data_struct{rec}.segmentedData{muscle,segment},200), 'LineWidth',1), xlabel('time(s)'), ylabel('EMG (µV)'); 
    end 
    hold on; 
end 
legend(titles_recs)

%% Averaging cycles for each muscle

for rec = 1:num_recordings  
    allCycles = data_struct{rec}.segmentedData;
    cycleLength = min(cellfun(@length, allCycles(:))); % Get the minimum length of vectors
    
    currentMuscle = zeros(size(allCycles, 2), cycleLength); % Initialize currentMuscle
    averagedCycles = zeros(8, cycleLength);

    for i = 1:size(allCycles, 1) % cycling on muscles 
        for j = 1:size(allCycles, 2) % cycling on revolustions 
            currentMuscle(j, :) = allCycles{i, j}(1:cycleLength); % Take the first cycleLength elements
        end
        % at the end of revolutions I save the average, each revolution is a
        % row, we average it and save it in the row corresponding to the
        % muscle
        averagedCycles(i,:) = mean(currentMuscle,1);
    end 
   data_struct{rec}.averagedCycle = averagedCycles; 
   clear currentMuscle averagedCycles allCycles cycleLength
end
%%
for i = 1:8 
    figure('Name', titles_muscles{i})
    for rec = 1:num_recordings
        timecycle=linspace(0, size(data_struct{rec}.averagedCycle,2)/fs, size(data_struct{rec}.averagedCycle,2));
        title(titles_muscles(muscle))
        if rec == 7 % passive with bolder line
           plot(timecycle,movmean(data_struct{rec}.averagedCycle(i,:),30), 'LineWidth',1.5), 
           xlabel('time(s)'), ylabel('EMG (µV)'); 
        else plot(timecycle,movmean(data_struct{rec}.averagedCycle(i,:),30), 'LineWidth',0.8), 
            xlabel('time(s)'), ylabel('EMG (µV)'); 
        end 
        hold on; 
    end 
    title("Mean revolution EMG activation on "+titles_muscles(i));
    legend(titles_recs)
    hold off
end 