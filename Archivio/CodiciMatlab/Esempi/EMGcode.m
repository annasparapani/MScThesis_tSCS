clc
clear all
close all

c = pwd;

Fs_EMG=1024; %Hz
Fs_angle=100; %Hz


%% Load data
[filename, pathname, filterindex] = uigetfile('*.mat', 'Pick a MATLAB  file');


cd(pathname)
load(filename)


cd(c)

%% Plot RAW DATA

% Right Leg (1-9)
% 1. Gluteus max
% 2. Biceps femoris caput longum
% 3. Biceps femoris caput brevis
% 4. Lateral gastrocnemius
% 5. Soleus
% 6. Tensor fascia latae
% 7. Rectus femoris
% 8. Vastus lateralis
% 9. Tibialis anterior

%RIGHT LEG
figure()

ax1=subplot(3,2,1);
plot(CrankAngle_time,CrankAngle), xlabel('time [s]'), ylabel('Crank angle [°]'), xlim([0 max(CrankAngle_time)]),sgtitle('Right Leg','FontSize',14,'FontWeight','b');
set(gca,'FontSize',12);

ax2=subplot(3,2,2);
plot(EMG_time,EMG(:,1),'b'), xlabel('time [s]'), ylabel('raw EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
hold on
plot(EMG_time,EMG(:,2),'r')
h=legend('GluMax','BF-long');
set(h,'FontSize',12), set(gca,'FontSize',12);

ax3=subplot(3,2,3);
plot(EMG_time,EMG(:,3),'b'), xlabel('time [s]'), ylabel('raw EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
hold on
plot(EMG_time,EMG(:,4),'r')
h=legend('BF-short','GastLat');
set(h,'FontSize',12), set(gca,'FontSize',12);


ax4=subplot(3,2,4);
plot(EMG_time,EMG(:,5),'b'), xlabel('time [s]'), ylabel('raw EMG [mV]','FontSize',12), xlim([0 max(EMG_time)]);
hold on
plot(EMG_time,EMG(:,6),'r')
h=legend('Soleus','TFL');
set(h,'FontSize',12), set(gca,'FontSize',12);

ax5=subplot(3,2,5);
plot(EMG_time,EMG(:,7),'b'), xlabel('time [s]'), ylabel('raw EMG [mV]','FontSize',12), xlim([0 max(EMG_time)]);
hold on
plot(EMG_time,EMG(:,8),'r')
h=legend('RF','VL');
set(h,'FontSize',12), set(gca,'FontSize',12);

ax6=subplot(3,2,6);
plot(EMG_time,EMG(:,9)), xlabel('time [s]'), ylabel('raw EMG [mV]','FontSize',12), xlim([0 max(EMG_time)]);
h=legend('TA');
set(h,'FontSize',12), set(gca,'FontSize',12);


linkaxes([ax1, ax2, ax3, ax4, ax5, ax6],'x')

% Left Leg (10-12)
% 10. Biceps femoris caput longum
% 11. Rectus femoris
% 12. Vastus lateralis

%LEFT LEG
figure()
ax1=subplot(3,2,1);
plot(CrankAngle_time,CrankAngle), xlabel('time [s]'), ylabel('Crank angle [°]'), xlim([0 max(CrankAngle_time)]),sgtitle('Left Leg','FontSize',14,'FontWeight','b');
set(gca,'FontSize',12);

ax2=subplot(3,2,2);
plot(EMG_time,EMG(:,1),'b'), xlabel('time [s]'), ylabel('raw EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
h=legend('BF-long');
set(h,'FontSize',12), set(gca,'FontSize',12);

ax3=subplot(3,2,3);
plot(EMG_time,EMG(:,2),'b'), xlabel('time [s]'), ylabel('raw EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
h=legend('RF');
set(h,'FontSize',12), set(gca,'FontSize',12);

ax4=subplot(3,2,4);
plot(EMG_time,EMG(:,3),'b'), xlabel('time [s]'), ylabel('raw EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
h=legend('VL');
set(h,'FontSize',12), set(gca,'FontSize',12);

linkaxes([ax1, ax2, ax3, ax4],'x')


%% Signal processing

%Band-pass filter
fcutlow=10; %Hz
fcuthigh=250;  %Hz
[B,A]=butter(5,[fcutlow,fcuthigh]/(Fs_EMG/2),'bandpass');
EMG_f(:,:) = filtfilt(B,A,EMG(:,:));

%Rectification
EMG_abs(:,:) = abs(EMG_f(:,:));

%Envelope
%low pass 5 Hz - 5 order
[B1,A1] = butter(5,5/(Fs_EMG/2),'low');
EMG_en1 = filtfilt(B1,A1,EMG_abs(:,:));

%low pass 20 Hz - 20 order
[B2,A2] = butter(5,20/(Fs_EMG/2),'low');
EMG_en2 = filtfilt(B2,A2,EMG_abs(:,:));
% with LP at lower frequency (5Hz) we get a smoother signal compared to
% using higher frequency 

%moving avarage
EMG_en3 = movmean(EMG_abs(:,:),50);
EMG_en4 = movmean(EMG_abs(:,:),100);

%PLOT OF THE STEPS OF EMG pre-processing
figure
ax1=subplot(411);
plot(CrankAngle_time,CrankAngle), xlabel('time [s]'), ylabel('Crank angle [°]'), xlim([0 max(CrankAngle_time)])
set(gca,'FontSize',12);

ax2=subplot(412);
plot(EMG_time,EMG(:,7)), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
title('Right Leg - Rectus Femoris - Raw EMG','FontSize',14,'FontWeight','b');

ax3=subplot(413);
plot(EMG_time,EMG_f(:,7)), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
title('Right Leg - Rectus Femoris - Filtered EMG','FontSize',14,'FontWeight','b');

ax4=subplot(414);
plot(EMG_time,EMG_abs(:,7)), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
hold on
plot(EMG_time,EMG_en1(:,7),'r','LineWidth',2), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
plot(EMG_time,EMG_en2(:,7),'--k','LineWidth',2), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
plot(EMG_time,EMG_en3(:,7),'m','LineWidth',2), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
plot(EMG_time,EMG_en4(:,7),'--b','LineWidth',2), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
title('Right Leg - Rectus Femoris - EMG Envelope','FontSize',14,'FontWeight','b');
h=legend('Rectified','LP,5Hz','LP,20Hz','MA-50ms','MA-100ms'); 
set(h,'FontSize',12), set(gca,'FontSize',12);

linkaxes([ax1, ax2, ax3, ax4],'x')

%% PLOT FILTERED DATA

%RIGHT LEG
figure()

ax1=subplot(411);
plot(CrankAngle_time,CrankAngle), xlabel('time [s]'), ylabel('Crank angle [°]'), xlim([0 max(CrankAngle_time)]),sgtitle('Right Leg','FontSize',14,'FontWeight','b');
set(gca,'FontSize',12);

ax2=subplot(412);
plot(EMG_time,EMG_f(:,1)), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
title('Glu Max','FontSize',12)
hold on
plot(EMG_time,EMG_en1(:,1),'k','LineWidth',2)
h=legend('filf','env');
set(h,'FontSize',12), set(gca,'FontSize',12);

ax3=subplot(413);
plot(EMG_time,EMG_f(:,2)), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
title('BF-long','FontSize',12)
hold on
plot(EMG_time,EMG_en1(:,2),'k','LineWidth',2)
set(gca,'FontSize',12);

ax4=subplot(414);
plot(EMG_time,EMG_f(:,3)), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
title('BF-short','FontSize',12)
hold on
plot(EMG_time,EMG_en1(:,3),'k','LineWidth',2)
set(gca,'FontSize',12);

linkaxes([ax1, ax2, ax3, ax4],'x')


figure()

ax1=subplot(411);
plot(CrankAngle_time,CrankAngle), xlabel('time [s]'), ylabel('Crank angle [°]'), xlim([0 max(CrankAngle_time)]),sgtitle('Right Leg','FontSize',14,'FontWeight','b');
set(gca,'FontSize',12);

ax2=subplot(412);
plot(EMG_time,EMG_f(:,4)), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
title('Gast Lat','FontSize',12)
hold on
plot(EMG_time,EMG_en1(:,4),'k','LineWidth',2)
h=legend('filf','env');
set(h,'FontSize',12), set(gca,'FontSize',12);

ax3=subplot(413);
plot(EMG_time,EMG_f(:,5)), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
title('Soleus','FontSize',12)
hold on
plot(EMG_time,EMG_en1(:,5),'k','LineWidth',2)
set(gca,'FontSize',12);

ax4=subplot(414);
plot(EMG_time,EMG_f(:,6)), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
title('TFL','FontSize',12)
hold on
plot(EMG_time,EMG_en1(:,6),'k','LineWidth',2)
set(gca,'FontSize',12);

linkaxes([ax1, ax2, ax3, ax4],'x')


figure()

ax1=subplot(411);
plot(CrankAngle_time,CrankAngle), xlabel('time [s]'), ylabel('Crank angle [°]'), xlim([0 max(CrankAngle_time)]),sgtitle('Right Leg','FontSize',14,'FontWeight','b');
set(gca,'FontSize',12);

ax2=subplot(412);
plot(EMG_time,EMG_f(:,7)), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
title('RF','FontSize',12)
hold on
plot(EMG_time,EMG_en1(:,7),'k','LineWidth',2)
h=legend('filf','env');
set(h,'FontSize',12), set(gca,'FontSize',12);

ax3=subplot(413);
plot(EMG_time,EMG_f(:,8)), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
title('VL','FontSize',12)
hold on
plot(EMG_time,EMG_en1(:,8),'k','LineWidth',2)
set(gca,'FontSize',12);

ax4=subplot(414);
plot(EMG_time,EMG_f(:,9)), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
title('TA','FontSize',12)
hold on
plot(EMG_time,EMG_en1(:,9),'k','LineWidth',2)
set(gca,'FontSize',12);

linkaxes([ax1, ax2, ax3, ax4],'x')


%Left Leg
figure()

ax1=subplot(411);
plot(CrankAngle_time,CrankAngle), xlabel('time [s]'), ylabel('Crank angle [°]'), xlim([0 max(CrankAngle_time)]),sgtitle('Left Leg','FontSize',14,'FontWeight','b');
set(gca,'FontSize',12);

ax2=subplot(412);
plot(EMG_time,EMG_f(:,10)), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
title('BF-long','FontSize',12)
hold on
plot(EMG_time,EMG_en1(:,10),'k','LineWidth',2)
h=legend('filf','env');
set(h,'FontSize',12), set(gca,'FontSize',12);

ax3=subplot(413);
plot(EMG_time,EMG_f(:,11)), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
title('RF','FontSize',12)
hold on
plot(EMG_time,EMG_en1(:,11),'k','LineWidth',2)
set(gca,'FontSize',12);

ax4=subplot(414);
plot(EMG_time,EMG_f(:,12)), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
title('VL','FontSize',12)
hold on
plot(EMG_time,EMG_en1(:,12),'k','LineWidth',2)
set(gca,'FontSize',12);

linkaxes([ax1, ax2, ax3, ax4],'x')


%comparison Right - Left legs
figure()

ax1=subplot(411);
plot(CrankAngle_time,CrankAngle), xlabel('time [s]'), ylabel('Crank angle [°]'), xlim([0 max(CrankAngle_time)])
set(gca,'FontSize',12);

ax2=subplot(412);
plot(EMG_time,EMG_en1(:,2)), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
title('BF-long','FontSize',12)
hold on
plot(EMG_time,EMG_en1(:,10),'k')
h=legend('right','left');
set(h,'FontSize',12), set(gca,'FontSize',12);

ax3=subplot(413);
plot(EMG_time,EMG_en1(:,7)), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
title('RF','FontSize',12)
hold on
plot(EMG_time,EMG_en1(:,11),'k')
set(gca,'FontSize',12);

ax4=subplot(414);
plot(EMG_time,EMG_en1(:,8)), xlabel('time [s]'), ylabel('EMG [mV]','FontSize',12), xlim([0 max(EMG_time)])
title('VL','FontSize',12)
hold on
plot(EMG_time,EMG_en1(:,12),'k')
set(gca,'FontSize',12);

linkaxes([ax1, ax2, ax3, ax4],'x')




%% Select a period of the voluntary pedaling

[ii,ang]=ginput(2);

[m,locsxi]=min(abs(CrankAngle_time-ii(1)));
[m,locsei]=min(abs(EMG_time-ii(1)));
[m,locsxf]=min(abs(CrankAngle_time-ii(2)));
[m,locsef]=min(abs(EMG_time-ii(2)));

CrankAngle_time=CrankAngle_time(locsxi:locsxf);
CrankAngle= CrankAngle(locsxi:locsxf);

EMG_time=EMG_time(locsei:locsef);
EMG_en1=EMG_en1(locsei:locsef,:);

% plot only the selected part of the acquisition for the RIGHT LEG

figure()
subplot(10,1,1), plot(CrankAngle_time,CrankAngle),ylabel('Crank angle'), xlim([min(CrankAngle_time) max(CrankAngle_time)]),title('Right Leg');
subplot(10,1,2), plot(EMG_time,EMG_en1(:,1)), ylabel('EMG-GlMax'), xlim([min(EMG_time) max(EMG_time)]);
subplot(10,1,3), plot(EMG_time,EMG_en1(:,2)), ylabel('EMG-BFlong'), xlim([min(EMG_time) max(EMG_time)]);
subplot(10,1,4), plot(EMG_time,EMG_en1(:,3)), ylabel('EMG-BFshort'), xlim([min(EMG_time) max(EMG_time)]);
subplot(10,1,5), plot(EMG_time,EMG_en1(:,4)), ylabel('EMG-GL'), xlim([min(EMG_time) max(EMG_time)]);
subplot(10,1,6), plot(EMG_time,EMG_en1(:,5)), ylabel('EMG-So'), xlim([min(EMG_time) max(EMG_time)]);
subplot(10,1,7), plot(EMG_time,EMG_en1(:,6)), ylabel('EMG-TFL'), xlim([min(EMG_time) max(EMG_time)]);
subplot(10,1,8), plot(EMG_time,EMG_en1(:,7)), ylabel('EMG-RF'), xlim([min(EMG_time) max(EMG_time)]);
subplot(10,1,9), plot(EMG_time,EMG_en1(:,8)), ylabel('EMG-VL'), xlim([min(EMG_time) max(EMG_time)]);
subplot(10,1,10), plot(EMG_time,EMG_en1(:,9)), ylabel('EMG-TA'), xlim([min(EMG_time) max(EMG_time)]);


%% Identification of pedaling cycle
% Find the end of each pedaling cycling based on the CrankAngle
[pks_angle,locs_angle] = findpeaks(-diff(CrankAngle), 'MinPeakHeight', 310);

figure()
ax1=subplot(211);
plot(CrankAngle_time,CrankAngle), ylabel('Crank Angle'), xlabel('Time [s]'),title('Peaks Angle');
hold on, plot(CrankAngle_time(locs_angle),CrankAngle(locs_angle),'o')

%% Locate the same peaks on the EMG data

locs_emg=zeros(size(locs_angle));

for j=1:size(locs_angle)
    [m,locs_emg(j)]=min(abs(EMG_time-CrankAngle_time(locs_angle(j))));
end

ax2=subplot(212);
plot(EMG_time,EMG_en1(:,7)), ylabel('EMG-RF'), xlabel('Time [s]'),title('Cycles identification on EMG signals');
hold on, plot(EMG_time(locs_emg),EMG_en1(locs_emg,7),'o')

linkaxes([ax1, ax2],'x')


%% Time normalization of all pedaling cycles

AngBase=linspace(0,359,360);

for n=1:12 %number of EMG channels
    EMG_mat{n}.values=zeros(360,size(locs_emg,1)-1);
    EMG_matOK{n}.values=zeros(360,30);
    EMG_matOK_norm{n}.values=zeros(360,30);
end


for i = 1: size(locs_emg)-1
    
    t_orig = linspace(locs_emg(i)+1,locs_emg(i+1),locs_emg(i+1)-locs_emg(i));
    t_N = linspace(locs_emg(i)+1,locs_emg(i+1),360);
    
    for n=1:12
        EMG_mat{n}.values(:,i) = interp1(t_orig,EMG_en1(locs_emg(i)+1:locs_emg(i+1),n), t_N, 'spline');
    end
    
end

c = [0 0.4470 0.7410];

figure(30)
ax1=subplot(521);
plot(AngBase,EMG_mat{1}.values,'Color',c), ylabel('EMG - GlMax'), xlim([0  360]), xlabel('Crank angle [°]');
ax2=subplot(522);
plot(AngBase,EMG_mat{2}.values,'Color',c), ylabel('EMG - BFlong'), xlim([0  360]), xlabel('Crank angle [°]');
ax3=subplot(523);
plot(AngBase,EMG_mat{3}.values,'Color',c), ylabel('EMG - BFshort'), xlim([0  360]), xlabel('Crank angle [°]');
ax4=subplot(524);
plot(AngBase,EMG_mat{4}.values,'Color',c), ylabel('EMG - GL'), xlim([0  360]), xlabel('Crank angle [°]');
ax5=subplot(525);
plot(AngBase,EMG_mat{5}.values,'Color',c), ylabel('EMG - So'), xlim([0  360]), xlabel('Crank angle [°]');
ax6=subplot(526);
plot(AngBase,EMG_mat{6}.values,'Color',c), ylabel('EMG - TFL'), xlim([0  360]), xlabel('Crank angle [°]');
ax7=subplot(527);
plot(AngBase,EMG_mat{7}.values,'Color',c), ylabel('EMG - RF'), xlim([0  360]), xlabel('Crank angle [°]');
ax8=subplot(528);
plot(AngBase,EMG_mat{8}.values,'Color',c), ylabel('EMG - VL'), xlim([0  360]), xlabel('Crank angle [°]');
ax9=subplot(529);
plot(AngBase,EMG_mat{9}.values,'Color',c), ylabel('EMG - TA'), xlim([0  360]), xlabel('Crank angle [°]');


%% Identification of pedaling cycles at target cadence +/- 4RPM

time_CYCLE=CrankAngle_time(locs_angle);
mean_cadence=60./diff(time_CYCLE); %mean cadence in RPM

target_cadence=str2num(filename(8:9));
good_cycle=find(and(mean_cadence<=target_cadence+4, mean_cadence>=target_cadence-4),30);


figure
plot(time_CYCLE(1:end-1),mean_cadence,'--*'), xlabel ('#cycles'),ylabel('cadence [rpm]')
hold on
plot(time_CYCLE(good_cycle),mean_cadence(good_cycle),'--r*'), xlabel ('#cycles'),ylabel('cadence [rpm]')


%% Selection of good cycles on EMGmat and amplitude normalization

EMG_mean=zeros(9,360);

figure(30)
for n=1:12
    EMG_matOK{n}.values(:,1:30)=EMG_mat{n}.values(:,good_cycle);
    
    norm_value(n)=median(max(EMG_matOK{n}.values));
    EMG_matOK_norm{n}.values(:,:)=EMG_matOK{n}.values(:,:)./norm_value(n);
    
    EMG_mean(n,:)= mean(EMG_matOK_norm{n}.values');
    EMG_std(n,:)= std(EMG_matOK_norm{n}.values');
    
    
    if (n<10)
        subplot(5,2,n)
        hold on
        plot(AngBase,EMG_matOK{n}.values,'r')
    end
end

figure
sgtitle('Right leg','FontSize',14, 'FontWeight','b')
for n=1:9
    subplot(5,2,n);
    plot(AngBase,EMG_matOK_norm{n}.values,'Color',c),  xlim([0  360]), xlabel('Crank angle [°]');
    hold on
    plot(AngBase,EMG_mean(n,:),'Color','k','LineWidth',2)
    plot(AngBase,EMG_mean(n,:)-EMG_std(n,:),'--k','LineWidth',2)
    plot(AngBase,EMG_mean(n,:)+EMG_std(n,:),'--k','LineWidth',2)
    
    switch n
        case 1
            ylabel('EMG norm - GlMax')
        case 2
            ylabel('EMG norm - BFlong')
        case 3
            ylabel('EMG norm - BFshort')
        case 4
            ylabel('EMG norm - GL')
        case 5
            ylabel('EMG norm - So')
        case 6
            ylabel('EMG norm - TFL')
        case 7
            ylabel('EMG norm - RF')
        case 8
            ylabel('EMG - VL')
        case 9
            ylabel('EMG - TA')
    end
    
    
    
end


%%
temp = EMG_mean(9, :); % line 9 is VL 

figure()
plot(AngBase, temp, 'Color', 'k', 'LineWidth', 2); 

M = max(temp);

th = 0.1*M;

ON = find(temp > th, 'first'); 
OFF = find(temp > th, 'last'); 

%% power spectral density estimate

[P_EMG,F] = periodogram(EMG_f, rectwin(max(size(EMG_f))),512,Fs_EMG); 

periodogram(EMG_f(:,7), rectwin(max(size(EMG_f))),512,Fs_EMG); 

%estimates the mean frequency in terms of the sample rate, fs 
Mean_freq1 = meanfreq( EMG_f(:,7) , Fs_EMG );

%returns the mean frequency of a power spectral density (PSD) estimate, pxx
Mean_freq2 = meanfreq( P_EMG(:,7) , F ); 

%estimates the mean frequency in terms of the sample rate, fs 
Med_freq1 = medfreq( EMG_f(:,7) , Fs_EMG );

%returns the mean frequency of a power spectral density (PSD) estimate, pxx 
Med_freq2 = medfreq( P_EMG(:,7) , F ); 
