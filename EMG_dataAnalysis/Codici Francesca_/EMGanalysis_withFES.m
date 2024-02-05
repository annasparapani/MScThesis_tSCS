clear all; close all; clc; 

%%
filename = "Giancarlo_FES_Twin2.mat"; % Paolo_FES_Twin1 Giancarlo_FES_Twin1 
load(filename); 

EMG = []; 

for j = 1:9
    emg = squeeze(EMGdata.signals.values(j,:,:))';
    sta = EMGcount.signals.values(:,:); 

    temp = [];
    for i = 1: size(emg, 1) % number of rows 
        if (sta(i) > 0) 
            temp = [temp emg(i, 1:sta(i))];
        end
    end
    EMG(:, j)=temp; 
end

EMGok = EMG(:,1:9);

%%
samplingF = 1024; 

EMG_f1 = []; 
filterOrder = 3; filterFreq = 10; % Butterworth 3 ordine HP @10Hz
[b, a] = butter(filterOrder, filterFreq/(samplingF/2), 'high'); 
for j = 1:9
    EMG_f1(:,j)=filtfilt(b, a, EMGok(:,j)); 
end

EMG_f2 = []; 
filterOrder = 3; filterFreq = 500; % Butterworth 3 ordine LP @500Hz
[b, a] = butter(filterOrder, filterFreq/(samplingF/2), 'low'); 
for j = 1:9
    EMG_f2(:,j)=filtfilt(b, a, EMG_f1(:,j)); 
end 

% EMG_f3 = []; 
% filterOrder = 6; freqToCut = 50; 
%     d = designfilt('bandstopiir', 'FilterOrder', filterOrder, 'HalfPowerFrequency1',freqToCut-1, ...
%         'HalfPowerFrequency2', freqToCut+1, 'DesignMethod', 'butter', 'SampleRate', samplingF);
% EMG_f3 = filtfilt(d, EMG_f2); 
% 
% EMG_f = EMG_f3; 

EMG_f3 = []; 
stimFreq = 50; 
frequenciesToCut = [stimFreq: stimFreq: samplingF/2-1]; filterOrder = 6; 

for f = frequenciesToCut
    freqToCut = f; 
    d = designfilt('bandstopiir', 'FilterOrder', filterOrder, 'HalfPowerFrequency1',freqToCut-1, ...
    'HalfPowerFrequency2', freqToCut+1, 'DesignMethod', 'butter', 'SampleRate', samplingF);
    
    EMG_f3 = filtfilt(d, EMG_f2); 
end 

EMG_f = EMG_f3; 

%% 
figure() 

for j = 1:9
    ax = subplot(9,1,j); 
    eval(['ax' num2str(j) ' = ax;']);
    hold on; 
    plot(EMG_f(:,j), 'b')
end
linkaxes([ax1, ax2, ax3, ax4, ax5, ax6, ax7, ax8, ax9],'x');


% figure()
% plot(EMG_f(:,2), 'b');
% 
% figure()
% periodogram(EMG_f(:,2), [], [], samplingF)

%%
idxStartStep = find(islocalmin(EMG_f(: ,2), 'MinProminence', 100) == 1); 
% idxStart = find(diff(emgRaw_filtered) > 1000, 1, 'first'); % EMG trigger 
numsteps = length(idxStartStep);
stepDuration = 3; %[s]

thisStep = 5; % todo: ciclare su tutti gli step

startI = idxStartStep(thisStep); stopI = idxStartStep(thisStep) + stepDuration*samplingF - 1; 
thisIdxs = [startI:stopI]; 
thisCh = 2; 

signal = EMG_f(thisIdxs, thisCh); 

%% Artifacts identification 
minIdxs = thisIdxs(find(islocalmin(signal, 'MinProminence',20) == 1)) - startI + 1; 
minIdxs = minIdxs(2: end);

startIdxs = minIdxs - 2; 
stopIdxs = minIdxs + 4; 
numArtifactSamples = 7; 
numTotSamples = floor(mean(diff(startIdxs))); 

signal = signal(startIdxs(1): startIdxs(end)-1); 

startOffset = startIdxs(1);
minIdxs = minIdxs - startOffset + 1; minIdxs(end) = [];
startIdxs = startIdxs - startOffset + 1; startIdxs(end) = [];
stopIdxs = stopIdxs - startOffset + 1; stopIdxs(end) = [];

%%
figure();
plot(signal); hold on; 
plot(minIdxs, signal(minIdxs), 'o'); 
plot(startIdxs, signal(startIdxs), '*'); 
plot(stopIdxs, signal(stopIdxs), '*'); 

%%
startOffSample = 1; stopOffSample = 1000; % consider first 1000samples without stimulation 
offset = mean(signal(startOffSample: stopOffSample)); 

signal2 = signal; 
for i = 1: length(startIdxs)
    signal2(startIdxs(i): stopIdxs(i)) = offset;
end
signal2 = signal2 - offset; 

%%
figure()
plot(signal); hold on; 
plot(signal2); 

%% 
signal3 = signal2; 

% Cut stim frequency and its multiples 
stimFreq = 40; 
frequenciesToCut = [stimFreq: stimFreq: samplingF/2-1]; filterOrder = 6; 

for f = frequenciesToCut
    freqToCut = f; 
    d = designfilt('bandstopiir', 'FilterOrder', filterOrder, 'HalfPowerFrequency1',freqToCut-1, ...
    'HalfPowerFrequency2', freqToCut+1, 'DesignMethod', 'butter', 'SampleRate', samplingF);
    
    signal3 = filtfilt(d, signal3); 
end

%% 
figure()
plot(signal2); hold on; 
plot(signal3, '--'); 

signal = signal3; 

%%
% Signal rectification 
signal_rect = abs(signal);  

figure()
plot(signal); hold on; 
plot(signal_rect, '--'); 

%%
% substitution of rectified pulse with avg 
avgComputationSamples = floor((numTotSamples - numArtifactSamples)/2); % consider a number of samples equal to half of signal samples 

for i = 2: length(startIdxs)-1 
    avgRectSignal = mean([signal_rect(startIdxs(i)-avgComputationSamples: startIdxs(i)-1); ...
        signal_rect(startIdxs(i)+numArtifactSamples: startIdxs(i)+numArtifactSamples+avgComputationSamples)]);
    signal_rect(startIdxs(i): startIdxs(i)+numArtifactSamples-1) = avgRectSignal; 
end 

%%
% Low-pass filtering 
% Filter1: 100 Hz, 5 order
filterFreq = 100; filterOrder = 5; 
[B, A] = butter(filterOrder, filterFreq/(samplingF/2), 'low'); 
signal_env1 = filtfilt(B, A, signal_rect); 

% Filter2: 20 Hz, 5 order
filterFreq = 20; filterOrder = 5; 
[B, A] = butter(filterOrder, filterFreq/(samplingF/2), 'low'); 
signal_env2 = filtfilt(B, A, signal_rect); % smoother signal compared to using higher frequency 

%% 
figure(); 
plot(signal_rect); hold on; 
plot(signal_env1); 
plot(signal_env2); 


%% 
figure(); 
plot(signal_rect); hold on; 
plot(signal_env1, 'LineWidth', 1); 
plot(signal_env2, 'LineWidth', 2); 


