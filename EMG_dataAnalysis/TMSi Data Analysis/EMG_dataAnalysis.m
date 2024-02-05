%% Load data
% add to path "SAGA_interface" with all subfolders
clear all
close all
clc
currpath = pwd;
[FileName, PathName] = uigetfile('*.Poly5');
data_mot_emg = TMSiSAGA.Poly5.read(fullfile(PathName, FileName));
fs = data_mot_emg.sample_rate;
% Ask for f_stim value and toggle options
prompt = {'Enter the f_stim value:', 'Stimulation', 'Cycling'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'50', '0', '0'}; % Default values: f_stim=50, both toggles unchecked
options = inputdlg(prompt, dlgtitle, dims, definput);

% Convert the input to numeric values
f_stim = str2double(options{1}); % Convert from cell array to double
stimOn = str2double(options{2});
triggerOn = str2double(options{3});

plots_on = 1;
titles={'QUAD Dx mono','HAMS Dx mono', 'TA Dx mono', 'GAST Dx mono',...
    'QUAD Sx mono','HAMS Sx mono', 'TA Sx mono', 'GAST Sx mono',...
    'Trigger','QUAD Dx bip',};
%% Variables
Emg_Signal=data_mot_emg.samples(:,:);

for i=1:8 %monopolars subtraction
    mono(i,:) = Emg_Signal(2*i-1,:) - Emg_Signal(2*i,:);
end
bipChannels=Emg_Signal(17:18,:);
time=linspace( 0 , max(size(Emg_Signal(1,:)))/fs, max(size(Emg_Signal(1,:))) )';
rawData = [mono; bipChannels]; 
rawData=rawData(:,1:end-2000);

%% Plot Raw Data
if plots_on
    figure()
    for i=1:10
        subplot(4,3,i), plot(rawData(i,:)), ylabel('mV'),xlabel('time(s)'), title(titles(i));
    end 
end

%% Filtering

spectrumRaw=[]; figure("Name","Spectrum Raw"); % print raw spectrum
for i=1:size(rawData,1)
    spectrumRaw(i,:) = pspectrum(rawData(i,:),fs);
    subplot(4,3,i), plot((0:length(spectrumRaw(i,:))-1) * fs/length(spectrumRaw(i,:)), spectrumRaw(i,:));
    title("Raw spectrum of "+titles(i)), ylim([0,4000]);
end 

filteredHighPass = []; filterOrder = 3; filterFreq = 20; % Butterworth 3 ordine HP @10Hz
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
%filteredData=filteredBandPass;

spectrumFiltered=[]; figure("Name","Spectrum filtered"); % print spectrum of filtered data
for i=1:size(filteredData,1)
    spectrumFiltered(i,:) = pspectrum(filteredData(i,:),fs);
    subplot(4,3,i), plot((0:length(spectrumFiltered(i,:))-1) * fs/length(spectrumFiltered(i,:)), spectrumFiltered(i,:));
    ylabel('Power/Frequency (dB/Hz)'), xlabel('Frequency (Hz)'), title(titles(i));
end 

if plots_on % plot time course of filtered data
    figure()
    for i=1:10
        subplot(4,3,i), plot(filteredData(i,:)), ylabel('µV'),xlabel('time(s)'), title(titles(i));
    end 
end

if stimOn&(triggerOn==0) % calibrazione, stampo il bipolare del quadricipite dx
    figure();
    plot(time, filteredData(10,:), title(10)); 
end 

%% Artefacts Removal
% 1. diff fa differenza tra punto e successivo 
% 2. findpeaks trovi tutti 
% escludere almeno 5 
% togliere offset
noArtData=filteredData(1:end-2,:);
if stimOn&triggerOn
    MinPeakDistance=(fs/f_stim)-5; 
    for i=1:(size(filteredData,1)-2)
        [cycle_pks, cycle_locs]=findpeaks(filteredData(i,:),"MinPeakDistance",MinPeakDistance,"MinPeakHeight",20);
        offset=mean(filteredData(i,:));
        for j=1:length(cycle_locs)
            if(cycle_locs(j)<6 & j==1)
                noArtData(i,cycle_locs(j)-(cycle_locs(j)-1):cycle_locs(j)+3)=offset;
            else noArtData(i,cycle_locs(j)-5:cycle_locs(j)+3)=offset;
            end 
        end 
    end 
end 

if stimOn&(triggerOn==0)% calibrazione
    for i=1:(size(filteredData,1))
        [cycle_pks, cycle_locs]=findpeaks(filteredData(i,:),"MinPeakDistance",1000,"MinPeakHeight",20);
        offset=mean(filteredData(i,:));
        for j=1:length(cycle_locs)
            if(cycle_locs(j)<6 & j==1)
                noArtData(i,cycle_locs(j)-(cycle_locs(j)-1):cycle_locs(j)+3)=offset;
            else noArtData(i,cycle_locs(j)-5:cycle_locs(j)+5)=offset;
            end 
        end 
    end

end 

if plots_on
        figure()
        for i=1:size(noArtData,1)
            subplot(3,4,i), plot(filteredData(i,:)), ylabel('µV'),xlabel('time(s)'), title(titles(i));
            hold on; 
            subplot(3,4,i), plot(noArtData(i,:), 'Color','r'); 
            legend('Signal', 'No artefacts signal')
            hold off;
        end 
    end

%% Rectification

rectData=abs(noArtData);
if plots_on
    figure()
    for i=1:size(rectData,1)
        subplot(3,3,i), plot(rectData(i,:)), ylabel('µV'),xlabel('time(s)'), title(titles(i)+" rectified");
    end 
end

%% Envelope
% Low-pass filtering 
% Filter1: 100 Hz, 5 order
envelopeData=[];filterFreq = 10; filterOrder = 5; 
[B, A] = butter(filterOrder, filterFreq/(fs/2), 'low'); 
for i=1:size(rectData,1)
    envelopeData(i,:) = filtfilt(B, A, rectData(i,:)); 
end 

 figure()
 plot(rectData(1,:)), ylabel('µV'),xlabel('time(s)'), title(titles(i)+" envelope");
 hold on
 plot(envelopeData(1,:)), legend('Rectified Data', 'Envelope')

% if plots_on
%     figure();
%     for i=1:size(rectData,1)
%         subplot(3,3,i), plot(rectData(i,:)), ylabel('µV'),xlabel('time(s)'), title(titles(i)+" envelope");
%         hold on; 
%         subplot(3,3,i), plot(envelopeData(i,:));
%         legend('Rectified Signal', 'Envelope');
%         hold off; 
%     end 
% end

%% Compare with passive activation
[FileName_passive, PathName_passive] = uigetfile('*.Poly5');
data_mot_emg_passive = TMSiSAGA.Poly5.read(fullfile(PathName_passive, FileName_passive));

% extracting data 
Emg_Signal_passive=data_mot_emg_passive.samples(:,:);
for i=1:8 
    mono_passive(i,:) = Emg_Signal_passive(2*i-1,:) - Emg_Signal_passive(2*i,:);
end
bipChannels_passive=Emg_Signal_passive(17:18,:);
rawData_passive = [mono_passive; bipChannels_passive]; 
rawData_passive=rawData_passive(:,1:end-2000);

if plots_on
    figure("Name","Raw data")
    for i=1:10
        subplot(4,3,i), plot(rawData_passive(i,:)), ylabel('mV'),xlabel('time(s)'), title(titles(i));
        hold on 
        subplot(4,3,i), plot(rawData(i,:)), ylabel('mV'),xlabel('time(s)'), title(titles(i));
    end 
end
% Filtering
filteredHighPass_passive = []; filterOrder = 3; filterFreq = 10; % Butterworth 3 ordine HP @10Hz
[b, a] = butter(filterOrder, filterFreq/(fs/2), 'high'); 
for j = 1:size(rawData,1)
    filteredHighPass_passive(j,:)=filtfilt(b, a, rawData_passive(j,:)); 
end

if plots_on
    figure()
    for i=1:10
        subplot(4,3,i), plot(filteredHighPass(i,:)), ylabel('mV'),xlabel('time(s)'), title(titles(i));
        hold on 
        subplot(4,3,i), plot(filteredHighPass_passive(i,:)), ylabel('mV'),xlabel('time(s)'), title(titles(i));
    end 
end

filteredBandPass_passive = []; filterOrder = 3; filterFreq = 750; % Butterworth 3 ordine LP @750Hz
[b, a] = butter(filterOrder, filterFreq/(fs/2), 'low'); 
for j = 1:size(rawData,1)
    filteredBandPass_passive(j,:)=filtfilt(b, a, filteredHighPass_passive(j,:)); 
end 
if plots_on
    figure()
    for i=1:10
        subplot(4,3,i), plot(filteredBandPass(i,:)), ylabel('mV'),xlabel('time(s)'), title(titles(i));
        hold on 
        subplot(4,3,i), plot(filteredBandPass_passive(i,:)), ylabel('mV'),xlabel('time(s)'), title(titles(i));
    end 
end
%filteredData_passive=filteredBandPass_passive;

filteredData_passive = filteredBandPass_passive; filterOrder = 6; freqToCut = 50; % Notch 50 Hz
for i=1:1
    d = designfilt('bandstopiir', 'FilterOrder', filterOrder, 'HalfPowerFrequency1',(freqToCut*i)-1, ...
        'HalfPowerFrequency2', (freqToCut*i)+1, 'DesignMethod', 'butter', 'SampleRate', fs);
    for j=1:size(rawData,1)
        filteredData_passive(j,:) = filtfilt(d, filteredData_passive(j,:)); 
    end 
end 
if plots_on
    figure()
    for i=1:10
        subplot(4,3,i), plot(filteredData(i,:)), ylabel('mV'),xlabel('time(s)'), title(titles(i));
        hold on 
        subplot(4,3,i), plot(filteredData_passive(i,:)), ylabel('mV'),xlabel('time(s)'), title(titles(i));
        subplot(4,3,i), plot(noArtData(i,:)), ylabel('mV'),xlabel('time(s)'), title(titles(i));

    end 
end

%%
% rectification
rectData_passive=abs(filteredData_passive);
% envelope with low-pass filtering 
envelopeData_passive=[];filterFreq = 10; filterOrder = 5; 
[B, A] = butter(filterOrder, filterFreq/(fs/2), 'low'); 
for i=1:size(rectData_passive,1)
    envelopeData_passive(i,:) = filtfilt(B, A, rectData_passive(i,:)); 
end 

% align on the 1st trigger
if triggerOn 
    [cycle_pks,cycle_locs]=findpeaks(-rawData(9,:),"MinPeakDistance",1000,"MinPeakHeight",10000); 
    [cycle_pks_passive,cycle_locs_passive]=findpeaks(-rawData_passive(9,:),"MinPeakDistance",1000,"MinPeakHeight",10000); 
end 
figure('Name', "EMG activation during passive and tSCS cycling"); 
for i=1:8
    subplot(4,3,i), plot(envelopeData(i,cycle_locs(2):end));
    hold on
    subplot(4,3,i), plot(envelopeData_passive(i,cycle_locs_passive(2):end));
    title(titles(i));
end

figure()
plot(envelopeData(2,cycle_locs(2):end)); hold on
plot(envelopeData_passive(2,cycle_locs_passive(2):end));
title(titles(2)), legend('tSCS cycling', 'passive cycling')

%% compare mean activations
if triggerOn
    mean_stim = mean(envelopeData,2);
    mean_passive=mean(envelopeData_passive(1:8,:),2); 
    column_names=['Muscle', 'tSCS Cycling', 'Passive Cyling'];
    T = table(titles(1:8)',mean_stim, mean_passive)
end

%% Cycling segmentation
if triggerOn
    [cycle_pks,cycle_locs]=findpeaks(-rawData(9,:),"MinPeakDistance",1000,"MinPeakHeight",10000); 
    figure();
    plot(rawData(9,:)), hold on, plot (cycle_locs,-cycle_pks,'o'), ylabel('mV'), title(titles(9));
    
    window_size = round(mean(diff(cycle_locs)));
    average_cadence = 60/(window_size/fs);
    
    segmentedData={};
    for j=1:size(envelopeData,1)
        for i=1:(length(cycle_locs)-1)
            segmentedData{j,i}=envelopeData(j, cycle_locs(i):(cycle_locs(i+1)-1));
        end 
    end 
    
    segmentedData_passive={};
    for j=1:size(envelopeData_passive,1)
        for i=1:(length(cycle_locs_passive)-1)
            segmentedData_passive{j,i}=envelopeData_passive(j, cycle_locs_passive(i):(cycle_locs_passive(i+1)-1));
        end 
    end 

%%
    
    muscle=2; 
    segment=33; 
    timecycle=linspace(0, size(segmentedData{muscle,segment},2)/fs, size(segmentedData{muscle,segment},2));
    timecycle_passive=linspace(0, size(segmentedData_passive{muscle,segment},2)/fs, size(segmentedData_passive{muscle,segment},2));
    figure(); 
    plot(timecycle, segmentedData{muscle,segment},'b'), xlabel('time(s)'), ylabel('EMG (µV)'); 
    hold on; 
    plot(timecycle_passive, segmentedData_passive{muscle,segment},'r');
    
    for i=1:10
        timecycle=linspace(timecycle(end), timecycle(end)+size(segmentedData{muscle,segment+i},2)/fs, size(segmentedData{muscle,segment+i},2));
        timecycle_passive=linspace(timecycle_passive(end), timecycle_passive(end)+size(segmentedData_passive{muscle,segment+i},2)/fs, size(segmentedData_passive{muscle,segment+i},2));
        plot(timecycle, segmentedData{muscle,segment+i},'b')
        plot(timecycle_passive, segmentedData_passive{muscle,segment+i},'r'); 
    end
    title(titles(muscle));
    legend('tSCS cycling', 'passive cycling')
end 


%% UNUSED CODE
% substitution of rectified pulse with avg 
% avgComputationSamples = floor((numTotSamples - numArtifactSamples)/2); 
% for i = 2: length(startIdxs)-1 
%     avgRectSignal = mean([signal_rect(startIdxs(i)-avgComputationSamples: startIdxs(i)-1); ...
%         signal_rect(startIdxs(i)+numArtifactSamples: startIdxs(i)+numArtifactSamples+avgComputationSamples)]);
%     signal_rect(startIdxs(i): startIdxs(i)+numArtifactSamples-1) = avgRectSignal; 
% end 

% OLD FILTERING
% fcutlow=10;   
% fcuthigh=750;   
% [z,p,k]=butter(4,[fcutlow,fcuthigh]/(fs/2),'bandpass');
% [sos,g]=zp2sos(z,p,k); %apply filter to signal
% 
% for i=1:size(rawData,1)
%     rawData_filter(i,:)=filtfilt(sos,g,rawData(i,:));
% end 
% 
% [b, a] = sos2tf(sos, g); % Extract coefficients
% filteredData = filter(b, a, rawData_filter(:,:)); %apply filter
% %[pff,ff]=pwelch(filteredData(:,1),[],[],[],fs);
