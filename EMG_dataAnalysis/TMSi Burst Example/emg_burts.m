%% Load data
% add to path "SAGA_interface" with all subfolders
clear all
close all 
clc
currpath=pwd;
[FileName,PathName] = uigetfile('*.Poly5');
data_mot_emg = TMSiSAGA.Poly5.read(FileName);
fs=data_mot_emg.sample_rate;
%% Variables
Emg_Signal=data_mot_emg.samples(2,:); % acquisizione con canale "Bipolare 2"
time=linspace( 0 , max(size(Emg_Signal(1,:)))/fs, max(size(Emg_Signal(1,:))) )';
%% Plot raw data
figure; 
plot(time,Emg_Signal);title('Muscle bip02');xlabel('Time [sec]');ylabel('mV');xlim([time(1) time(end)])
%%