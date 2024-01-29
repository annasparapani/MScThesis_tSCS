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
titles={'QUAD Dx mono','HAMS Dx mono', 'TA Dx mono', 'GAST Dx mono',...
    'QUAD Sx mono','HAMS Sx mono', 'TA Sx mono', 'GAST Sx mono',...
    'Trigger','QUAD Dx bip',};
plots_on=1;
if plots_on
    figure()
    for i=1:10
        subplot(4,3,i), plot(rawData(i,:)), ylabel('mV'),xlabel('time(s)'), title(titles(i));
    end 
end

%% Filtering
fcutlow=10;   
fcuthigh=900;   
[z,p,k]=butter(4,[fcutlow,fcuthigh]/(fs/2),'bandpass');
[sos,g]=zp2sos(z,p,k); %apply filter to signal

for i=1:size(rawData,1)
    rawData_filter(i,:)=filtfilt(sos,g,rawData(i,:));
end 

[b, a] = sos2tf(sos, g); % Extract coefficients
filteredData = filter(b, a, rawData_filter(:,:)); %apply filter
%[pff,ff]=pwelch(filteredData(:,1),[],[],[],fs);

f_notch = 50; % Notch filter parameters
bw_notch = 4; % Bandwidth
% Design the notch filter using designfilt
notchFilter = designfilt('bandstopiir', 'FilterOrder', 4, ...
    'HalfPowerFrequency1', (f_notch - bw_notch/2)/(fs/2), ...
    'HalfPowerFrequency2', (f_notch + bw_notch/2)/(fs/2));
for i=i:size(rawData,1)
    filteredData(i, :) = filtfilt(notchFilter, filteredData(i, :));

end 

if plots_on
    figure()
    for i=1:10
        subplot(4,3,i), plot(filteredData(i,:)), ylabel('µV'),xlabel('time(s)'), title(titles(i));
    end 
end

%% Artefacts Removal
% 1. diff fa differenza tra punto e successivo 
% 2. findpeaks trovi tutti 
% escludere almeno 5 
% togliere offset
noArtData=filteredData(1:end-2,:);
if stimOn
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
        % art_pks(i,:)= pks; 
        % art_locs(i,:)=locs; 
    end 
    
    if plots_on
        figure()
        for i=1:size(noArtData,1)
            subplot(4,3,i), plot(filteredData(i,:)), ylabel('µV'),xlabel('time(s)'), title(titles(i));
            hold on; 
            subplot(4,3,i), plot(noArtData(i,:), 'Color','r'); 
            legend('Signal', 'No artefacts signal')
            hold off;
        end 
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
envelopeData=[];
for i=1:size(rectData, 1)
    [upper_env, lower_env] = envelope(rectData(i,:));
    envelopeData(i,:)=upper_env;
end 

if plots_on
    figure();
    for i=1:size(rectData,1)
        subplot(3,3,i), plot(rectData(i,:)), ylabel('µV'),xlabel('time(s)'), title(titles(i)+" envelope");
        hold on; 
        subplot(3,3,i), plot(envelopeData(i,:));
        legend('Rectified Signal', 'Envelope');
        hold off; 
    end 
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
    figure(); 
    plot(segmentedData{1,10}); 
end 

%%
% substitution of rectified pulse with avg 
avgComputationSamples = floor((numTotSamples - numArtifactSamples)/2); % consider a number of samples equal to half of signal samples 

for i = 2: length(startIdxs)-1 
    avgRectSignal = mean([signal_rect(startIdxs(i)-avgComputationSamples: startIdxs(i)-1); ...
        signal_rect(startIdxs(i)+numArtifactSamples: startIdxs(i)+numArtifactSamples+avgComputationSamples)]);
    signal_rect(startIdxs(i): startIdxs(i)+numArtifactSamples-1) = avgRectSignal; 
end 
