%%
clear all
close all
clc


%Fs_EMG=100; %Hz

%%
[filename, pathname, filterindex] = uigetfile('*.mat', 'Pick a MATLAB  file');

load(filename)

tempo_tra_campionamenti = mean(diff(EMGdata.time));
Fs_EMG = 1 / tempo_tra_campionamenti;
%% Signal processing

%Band-pass filter (preso da 'EMGcode')
%fcutlow=10; %Hz
%fcuthigh=250;  %Hz
%fcuthigh non va bene perchè deve essere al massimo la metà della frequenza
%di campionamento (50 Hz)

fcutlow=10; %Hz
fcuthigh=50;  %Hz

[B,A]=butter(5,[fcutlow,fcuthigh]/(Fs_EMG/2),'bandpass');
EMG_f(:,:) = filtfilt(B,A,EMG(:,:));

%% Rectification (preso da 'EMGcode')
EMG_abs(:,:) = abs(EMG_f(:,:));

%% Envelope (preso da 'EMGcode')
%low pass 5 Hz - 5 order
[B1,A1] = butter(5,5/(Fs_EMG/2),'low');
EMG_en1 = filtfilt(B1,A1,EMG_abs(:,:));

%% low pass 20 Hz - 20 order (preso da 'EMGcode')
[B2,A2] = butter(5,20/(Fs_EMG/2),'low');
EMG_en2 = filtfilt(B2,A2,EMG_abs(:,:));
% with LP at lower frequency (5Hz) we get a smoother signal compared to
% using higher frequency 

%% moving avarage (preso da 'EMGcode')
EMG_en3 = movmean(EMG_abs(:,:),50);
EMG_en4 = movmean(EMG_abs(:,:),100);

%% plot preso da 'plot_data'

figure
plot(EMGcount.signals.values)

[b,a] = butter(3,10/(1024/2),'high');
 

EMG=[];

for j = 1:9

    emg = squeeze(EMGdata.signals.values(j,:,:))';
    sta = EMGcount.signals.values(:,:);

    si = size(emg);
    temp = [];
    for i = 1:si(1)
        if (sta(i) > 0)
        temp = [temp emg(i, 1:sta(i))];
        end
    end

   
    EMG(:,j)=temp;
    
end

EMGok=EMG(:,1:9);

figure

for j = 1:9
    subplot(9,1,j)
    hold on

    EMGok_f(:,j)=filtfilt(b,a,EMGok(:,j)); 
    
    plot(EMGok_f(:,j),'b')
   
end
