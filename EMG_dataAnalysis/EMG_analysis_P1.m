%% TITLE: EMG data analysis for tSCS protocol 1 (single pulses) 
%  AUTHOR: Anna Sparpani
%  DATE: nov. 23
% The following code is used to analyse the EMG data acquired during
% transcutaneous spinal cord stimulation. The main interest of the signal
% analysis is the identification of the PRM reflex, which is observed
% around 50micros after the stimulation artefact on the EMG baseline. 


clear all 
close all
clc

%% Import data
% you have to be in the folder with the data!

[filename, pathname, filterindex] = uigetfile('*.mat', 'Pick a MATLAB  file');
load(filename)
EMG=[];
plots_on=0;

%% Format data into a time series 
for j = 1:12

    % EMGdata is a 3D matrix with 12 channels
    % for each channel take the 2D matrix of data [time,20]
    emg = squeeze(EMGdata.signals.values(j,:,:))';
    %sta is a column array with how many samples are stored in each vector
    %of 20 
    sta = EMGcount.signals.values(:,:);
    pp = EMGcount.time;

    si = size(emg);
    temp = [];
    temp2 = [];
    
    % create the vector of samples appending packages one after the other 
    for i = 1:si(1)
        if (sta(i) > 0)
        temp = [temp emg(i, 1:sta(i))];
        end
    end
    temp(end-(double(sta(end)-2)):end)=[];
    
    for i=1:si(1)-1
        if (sta(i) > 0)
        temp2=[temp2 linspace(pp(i),pp(i+1)-(0.01/(double(sta(i)))),sta(i))];
        end
    end
    EMG(:,j)=temp;
end

EMGok=[EMG(:,5),EMG(:,6),EMG(:,7),EMG(:,8),EMG(:,9),EMG(:,10),EMG(:,11),EMG(:,12)];
x=EMGok;

% Acquistion frequency EMG
Fs_EMG=1024;
time=0:1/Fs_EMG:length(EMGok)/Fs_EMG-1/Fs_EMG;

% Raw data plots
if plots_on
    figure()
    title('RIGHT Leg')
    subplot(4,1,1), plot(time,x(:,1)), ylabel('Quad DX'), grid on %17
    subplot(4,1,2), plot(time,x(:,2)), ylabel('Ham DX'), grid on %18
    subplot(4,1,3), plot(time,x(:,3)), ylabel('Gast DX'), grid on %19
    subplot(4,1,4), plot(time,x(:,4)), ylabel('TA DX'), grid on %20
    
    figure()
    title('LEFT LEG')
    subplot(4,1,1), plot(time,x(:,5)), ylabel('Quad SX'), grid on %21
    subplot(4,1,2), plot(time,x(:,6)), ylabel('Ham SX'), grid on %22
    subplot(4,1,3), plot(time,x(:,7)), ylabel('Gast SX'), grid on %23
    subplot(4,1,4), plot(time,x(:,8)), ylabel('TA SX'), grid on %24
end 
%% Signal processing
% Filtering
fcutlow=10;   
fcuthigh=450;   
[z,p,k]=butter(4,[fcutlow,fcuthigh]/(Fs_EMG/2),'bandpass');
[sos,g]=zp2sos(z,p,k); %apply filter to signal
x_filt(:,:) = filtfilt(sos,g,x(:,:));
[b, a] = sos2tf(sos, g); % Extract coefficients
xfilter = filter(b, a, x_filt(:,:)); %apply filter
[pff,ff]=pwelch(xfilter(:,1),[],[],[],Fs_EMG);

% Filetered data plots
if plots_on
    figure()
    title('Right Leg')
    subplot(4,1,1), plot(time,xfilter(:,1)), ylabel('mV'), xlabel('s'), grid off, title(' DX Quad'); %17
    subplot(4,1,2), plot(time,xfilter(:,2)), ylabel('mV'),xlabel('s'), grid off, title('DX Hamstring'); %18
    subplot(4,1,3), plot(time,xfilter(:,3)), ylabel('mV'), xlabel('s'), grid off, title(' DX Gast'); %19
    subplot(4,1,4), plot(time,xfilter(:,4)), ylabel('mV'),xlabel('s'), grid off, title('DX TA'); %20
     
    figure()
    title('Left Leg')
    subplot(4,1,1), plot(time,xfilter(:,5)), ylabel('mV'), xlabel('s'), grid off, title('SX Quad'); %21
    subplot(4,1,2), plot(time,xfilter(:,6)), ylabel('mV'),xlabel('s'), grid off, title('SX Hamstring'); %22
    subplot(4,1,3), plot(time,xfilter(:,7)), ylabel('mV'), xlabel('s'), grid off, title('SX Gast'); %23
    subplot(4,1,4), plot(time,xfilter(:,8)), ylabel('mV'),xlabel('s'), grid off, title('SX TA'); %24
end
%% Peaks detection (M waves peaks) 
% Finding the Min Peak Height for every muscle, based on the std deviation
% 1. Calculate standard deviation of the filtered signal
std_dev = std(xfilter);
% 2. Set a threshold as a multiple of the standard deviation
minPeakHeight_multiplier = 5; % You can adjust this multiplier, I kept it quite 
                          % high because the stimulation artefacts are much 
                          % higher than the rest of the signal
minPeakHeight = minPeakHeight_multiplier * std_dev;

meanPeakDistance=600; % mean peak distance 1200 = 0.6s 

% Right leg
[pk1,locs1] = findpeaks(xfilter(:,1),"MinPeakDistance",meanPeakDistance,"MinPeakHeight",minPeakHeight(1,1));
 quad_dx=xfilter(:,1);
[pk2,locs2] = findpeaks(xfilter(:,2),"MinPeakDistance",meanPeakDistance,"MinPeakHeight",minPeakHeight(1,2));
 hams_dx=xfilter(:,2);
[pk3,locs3] = findpeaks(xfilter(:,3),"MinPeakDistance",meanPeakDistance,"MinPeakHeight",minPeakHeight(1,3));
gast_dx=xfilter(:,3);
[pk4,locs4] = findpeaks(xfilter(:,4),"MinPeakDistance",meanPeakDistance,"MinPeakHeight",minPeakHeight(1,4));
ta_dx=xfilter(:,4);

% Left leg
[pk5,locs5] = findpeaks(xfilter(:,5),"MinPeakDistance",meanPeakDistance,"MinPeakHeight",minPeakHeight(1,5));
  quad_sx=xfilter(:,5);
[pk6,locs6] = findpeaks(xfilter(:,6),"MinPeakDistance",meanPeakDistance,"MinPeakHeight",minPeakHeight(1,6));
  hams_sx=xfilter(:,6);
[pk7,locs7] = findpeaks(xfilter(:,7),"MinPeakDistance",meanPeakDistance,"MinPeakHeight",minPeakHeight(1,7));
  gast_sx=xfilter(:,7);
[pk8,locs8] = findpeaks(xfilter(:,8),"MinPeakDistance",meanPeakDistance,"MinPeakHeight",minPeakHeight(1,8));
  ta_sx=xfilter(:,8);

if plots_on
    figure()
    subplot(4,1,1), plot(quad_dx), hold on, plot (locs1,pk1,'o'), ylabel('mV'), title(' DX Quad');
    avg_value = mean(hams_dx(i,:));
    fill([1, length(hams_dx), length(hams_dx), 1], [avg_value + 0.025, avg_value + 0.025, avg_value - 0.025, avg_value - 0.025], 'y', 'EdgeColor', 'none', 'FaceAlpha', 0.3);
    
    subplot(4,1,2), plot(hams_dx), hold on, plot (locs2,pk2,'o'), ylabel('mV'), title(' DX Hams');
    subplot(4,1,3), plot(gast_dx), hold on, plot (locs3,pk3,'o'), ylabel('mV'), title(' DX Gast');
    subplot(4,1,4), plot(ta_dx), hold on, plot (locs4,pk4,'o'), ylabel('mV'), title(' DX TA');

    figure()
    title('Left Leg - filtered')
    subplot(4,1,1), plot(quad_sx), hold on, plot (locs5,pk5,'o'), ylabel('mV'), title(' SX Quad'); 
    subplot(4,1,2), plot(hams_sx), hold on, plot (locs6,pk6,'o'), ylabel('mV'), title(' SX Hams');
    subplot(4,1,3), plot(gast_sx), hold on, plot (locs7,pk7,'o'), ylabel('mV'), title(' SX Gast');
    subplot(4,1,4), plot(ta_sx), hold on, plot (locs8,pk8,'o'), ylabel('mV'), title(' SX TA');
end

%% M Waves detection based on zero crossing
% looks for the first zero crosssing before the peak 
%Right leg
Mwavestart1=findMwaveStart(quad_dx,locs1);
Mwavestart2=findMwaveStart(hams_dx,locs2);
Mwavestart3=findMwaveStart(gast_dx,locs3);
Mwavestart4 = findMwaveStart(ta_dx, locs4); 
% Left leg 
Mwavestart5=findMwaveStart(quad_sx,locs5);
Mwavestart6=findMwaveStart(hams_sx,locs6);
Mwavestart7=findMwaveStart(gast_sx,locs7);
Mwavestart8 = findMwaveStart(ta_sx, locs8); 

%% M waves detection and plot

duration_quad = 100; % ~100 ms
duration_hams = 100; % Federico usava 52 (50ms) 15ms di latenza + 35ms di Mwave (1024Hz*50ms=57samples)

Mwaves1=buildMwave(Mwavestart1, duration_quad, quad_dx); 
Mwaves2=buildMwave(Mwavestart2, duration_hams, hams_dx); 
Mwaves3=buildMwave(Mwavestart3, duration_quad, gast_dx);
Mwaves4=buildMwave(Mwavestart4, duration_hams, ta_dx);
Mwaves5=buildMwave(Mwavestart5, duration_quad, quad_sx);
Mwaves6=buildMwave(Mwavestart6, duration_hams, hams_sx); 
Mwaves7=buildMwave(Mwavestart7, duration_quad, gast_sx);
Mwaves8=buildMwave(Mwavestart8, duration_hams, ta_sx);

% M-WAVES GRAPHS
if plots_on
    plotMwave("M wave Quad DX", Mwaves1, Fs_EMG, 0,0);
    plotMwave("M wave Hams DX", Mwaves2, Fs_EMG, 0,0);
    plotMwave("M wave Gast DX", Mwaves3, Fs_EMG, 0,0);
    plotMwave("M wave TA DX", Mwaves4, Fs_EMG, 0,0);
    plotMwave("M wave Quad SX", Mwaves5, Fs_EMG, 0,0);
    plotMwave("M wave Hams SX", Mwaves6, Fs_EMG, 0,0);
    plotMwave("M wave Gast SX", Mwaves7, Fs_EMG, 0,0);
    plotMwave("M wave TA SX", Mwaves8, Fs_EMG, 0,0);
end

%% Artefact detection 
% the artefact is a small peak before the M wave - it's observed only in the
% proximal muscles (quad and hams), but the hams usually have a better
% signal. So we do the artifact detection on the hamstrings for each peak
% identified and then translate the identified locs on all muscles. 
art_locs=[]; 
art_pks=[];
for i = 1:length(locs6)
   meanPeakDistance = 10; 
   minPeakHeight = 0.02; 

  [art_pk,art_loc] = findpeaks(hams_sx(locs6(i)-15:locs6(i)), ...
      "MinPeakDistance",meanPeakDistance,"MinPeakHeight",minPeakHeight);
  art_locs(i) = locs6(i)-15+art_loc; 
  art_pks(i) = art_pk; 
end 
if plots_on
    figure()
    plot(hams_sx), hold on, plot(art_locs, art_pks, 'o', 'Color','g')
    title('Artefacts identified on Hams Sx')
end 

%% Compute latency for all waves
% the function computes the latency between the positions of the artefacts
% identified on the hamstings in the previous section and the Mwaves of
% each muscle.

[meanLatency_quadDx, Latency_quadDx] = computeLatency(art_locs, locs1); 
[meanLatency_hamsDx, Latency_hamsDx] = computeLatency(art_locs, locs2); 
[meanLatency_gastDx, Latency_gastDx] = computeLatency(art_locs, locs3); 
[meanLatency_taDx, Latency_taDx] = computeLatency(art_locs, locs4); 
[meanLatency_quadSx, Latency_quadSx] = computeLatency(art_locs, locs5); 
[meanLatency_hamsSx, Latency_hamsSx] = computeLatency(art_locs, locs6); 
[meanLatency_gastSx, Latency_gastSx] = computeLatency(art_locs, locs7); 
[meanLatency_taSx, Latency_taSx] = computeLatency(art_locs, locs8); 

% Create a table
MeanLatency = table(meanLatency_quadDx',meanLatency_hamsDx', meanLatency_gastDx', ...
    meanLatency_taDx', meanLatency_quadSx', meanLatency_hamsSx', ...
    meanLatency_gastSx', meanLatency_taSx', 'VariableNames', ...
    {'quadDx (ms)', 'hamsDx (ms)', 'gastDx (ms)','taDx (ms)','quadSx(ms)', ...
    'hamsSx (ms)','gastSx (ms)', 'taSx (ms)',});

% Display the table
disp(MeanLatency);
%%

Mwaves5_art=buildMwave(locs5-meanLatency_hamsSx-5, 50, hams_sx); 
plotMwave("M wave Hams SX", Mwaves5_art, Fs_EMG, meanLatency_hamsSx, 1);

% Mwaves1_art=buildMwave(locs1-meanLatency_hamsSx-5, 50, quad_dx); 
% plotMwave("M wave Quad DX", Mwaves1_art, Fs_EMG, meanLatency_quadDx, 1);

Mwaves8_art=buildMwave(locs8-meanLatency_taSx-5,50,ta_sx); 
plotMwave("M wave Ta SX", Mwaves8_art, Fs_EMG, meanLatency_taSx, 1);

%% Envelope of M Wave --> not used at the moment 
% PRM_A_quadDx = EnvelopeMWave(Mwaves1, Fs_EMG, "Quad DX");
% PRM_A_hamsDx = EnvelopeMWave(Mwaves2, Fs_EMG, "Hams DX");
% PRM_A_gastDx = EnvelopeMWave(Mwaves3, Fs_EMG, "Gast DX");
% PRM_A_taDx = EnvelopeMWave(Mwaves4, Fs_EMG, "TA DX");
% 
% PRM_A_quadSx = EnvelopeMWave(Mwaves5, Fs_EMG, "Quad SX");
% PRM_A_hamsSx = EnvelopeMWave(Mwaves6, Fs_EMG, "Hams SX");
% PRM_A_gastSx = EnvelopeMWave(Mwaves7, Fs_EMG, "Gast SX");
% PRM_A_taSx = EnvelopeMWave(Mwaves8, Fs_EMG, "TA SX");

%% Detection of M waves above threshold
% studio del riflesso PRM a valle del protocollo 1 e 2 che indichi il 
% valore di soglia motoria per gli 8 gruppi muscolari e la % di 
% depressione post-sinaptica nel caso del protocollo 2.

s=struct('W1',Mwaves1,'W2',Mwaves2,'W3',Mwaves3(:,10:end),'W4',Mwaves4,'W5', ...
    Mwaves5,'W6',Mwaves6,'W7',Mwaves7,'W8',Mwaves8);

[peaksM1, locsM1]=findMwavePeak(s.W1, 0.05, 50); 
[peaksM2, locsM2]=findMwavePeak(s.W2, 0.05, 50); 
[peaksM3, locsM3]=findMwavePeak(s.W3, 0.05, 50); 
[peaksM4, locsM4]=findMwavePeak(s.W4, 0.05, 50); 
[peaksM5, locsM5]=findMwavePeak(s.W5, 0.05, 50); 
[peaksM6, locsM6]=findMwavePeak(s.W6, 0.05, 50); 
[peaksM7, locsM7]=findMwavePeak(s.W7, 0.05, 50); 
[peaksM8, locsM8]=findMwavePeak(s.W8, 0.05, 50); 

%%
% maxima 
M1=max(s.W1,[],2); M2=max(s.W2,[],2); M3=max(s.W3,[],2); M4=max(s.W4,[],2);
M5=max(s.W5,[],2); M6=max(s.W6,[],2); M7=max(s.W7,[],2); M8=max(s.W8,[],2);

% minima
m1=min(s.W1,[],2); m2=min(s.W2,[],2); m3=min(s.W3,[],2); m4=min(s.W4,[],2);
m5=min(s.W5,[],2); m6=min(s.W6,[],2); m7=min(s.W7,[],2); m8=min(s.W8,[],2);

%indici
n1=0; n2=0; n3=0; n4=0; n5=0; n6=0; n7=0; n8=0;

n1 = ((sum((M1-m1) >= 0.5))/length(m1))*100;
n2 = ((sum((M2-m2) >= 0.5))/length(m2))*100;
n3 = ((sum((M3-m3) >= 0.5))/length(m3))*100;
n4 = ((sum((M4-m4) >= 0.5))/length(m4))*100;
n5 = ((sum((M5-m5) >= 0.5))/length(m5))*100;
n6 = ((sum((M6-m6) >= 0.5))/length(m6))*100;
n7 = ((sum((M7-m7) >= 0.5))/length(m7))*100;
n8 = ((sum((M8-m8) >= 0.5))/length(m8))*100;


formatSpec1="N° of Mwave above 50uV is %4.2f/100 for Quad Dx\n";
formatSpec2="N° of Mwave above 50uV is %4.2f/100 for Hams Dx\n";
formatSpec3="N° of Mwave above 50uV is %4.2f/100 for Gast Dx\n";
formatSpec4="N° of Mwave above 50uV is %4.2f/100 for TA Dx\n\n";
formatSpec5="N° of Mwave above 50uV is %4.2f/100 for Quad Sx\n";
formatSpec6="N° of Mwave above 50uV is %4.2f/100 for Hams Sx\n";
formatSpec7="N° of Mwave above 50uV is %4.2f/100 for Gast Sx\n";
formatSpec8="N° of Mwave above 50uV is %4.2f/100 for TA Sx\n";

fprintf(formatSpec1,n1);
fprintf(formatSpec2,n2);
fprintf(formatSpec3,n3);
fprintf(formatSpec4,n4);
fprintf(formatSpec5,n5);
fprintf(formatSpec6,n6);
fprintf(formatSpec7,n7);
fprintf(formatSpec8,n8);

%% ************************************************************************
% ************************ FUNCTIONS **************************************
% *************************************************************************

function plotMwave(titleStr, MwaveArray, Frequency, meanLatency, latencyFlag)
    % Function to plot the M wave
    timeArray= (0:1/Frequency:length(MwaveArray)/Frequency-1/Frequency)*1000; %ms
    figure;
    for i = 1:size(MwaveArray,1)
        if (rem(size(MwaveArray),10))~=0
            flag=1;
        else flag=0;
        end 
        subplot(fix(size(MwaveArray,1)/10)+flag, 10, i);
        plot(timeArray, MwaveArray(i,:),'LineWidth',1.2);
        title(titleStr);
        grid on;
        ylabel('mV');
        xlabel('time[ms]');
        
        % Calculate the average value
        avg_value = mean(MwaveArray(i,:));
        % Plot a band around the average value (±0.25)
        hold on;

        fill([timeArray, fliplr(timeArray)], [ones(size(timeArray))*(avg_value + 0.25), fliplr(ones(size(timeArray))*(avg_value - 0.25))], 'y', 'EdgeColor', 'none', 'FaceAlpha', 0.3);

        % Set y-axis limits to maximum + 0.1
        ylim([min(MwaveArray(i,:)-0.1) max(MwaveArray(i,:))+0.1]) % y limit scaled to the graph values
        
        if latencyFlag
            xline(10, 'r', 'LineWidth', 2);
            yValue = -0.3;
            line([10, 10 + meanLatency], [yValue, yValue], 'Color', 'b', 'LineWidth', 2);
            text(10 + meanLatency/2, yValue - 0.1, ['Latency ' num2str(meanLatency)], 'HorizontalAlignment', 'center');

        end 

        hold off;
    end
end

function Mwavestart = findMwaveStart(signal, locs)
    Mwavestart = zeros(size(locs));
    for i = 1:length(locs)
        for j = 1:100 % Find zero-crossings in the 100 samples before the artifact
            if (signal(locs(i) - j) * signal(locs(i) - j + 1)) < 0
                Mwavestart(i) = locs(i) - j - 5; % add 5 samples to give some space in the graph
                break;
            end
        end
     end
end

function steepness = calculateSteepness(signal, index)
    % Calculate the steepness (slope) at the specified index
    steepness = (signal(index + 1) - signal(index)) / 1; % Assuming a unit step
end

% Function to build the Mwaves from the starting points computed in the
% previous function
function Mwaves = buildMwave(Mwavestart, duration, signal)
    Mwaves1 = [];
    for i = 1:length(Mwavestart)
        Mwaves(i, :) = signal(Mwavestart(i):Mwavestart(i)+duration);
    end
end

% Find peaks within in an M wave 
function [peaks, locs] = findMwavePeak(signal, MinPeakHeight, MinPeakDistance)
    Frequency = 1024; 
    timeArray= (0:1/Frequency:length(signal)/Frequency-1/Frequency)*1000; %ms
    figure;
    for i = 1:size(signal,1)
        [peaks, locs] = findpeaks(signal(i,:),"MinPeakDistance", ...
                      MinPeakDistance, "MinPeakHeight",MinPeakHeight);
        if (rem(size(signal),10))~=0
            flag=1;
        else flag=0;
        end 
        subplot(fix(size(signal,1)/10)+flag, 10, i);
        plot(timeArray, signal(i,:),'LineWidth',1.2);
        title("trial");
        grid on;
        ylabel('mV');
        xlabel('time[ms]');

        % Calculate the average value
        avg_value = mean(signal(i,:));
        % Plot a band around the average value (±0.025)
        hold on;
        fill([timeArray, fliplr(timeArray)], [ones(size(timeArray))* ...
            (avg_value + 0.025), fliplr(ones(size(timeArray))*(avg_value - ...
            0.025))], 'y', 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        % Add a red horizontal line at y = 0.05
        hold on;
        yline(0.05, 'r', 'LineWidth', 1.5);
        hold on
        plot (locs, peaks, 'o'), ylabel('mV');
        hold off;
    end
end 

function [A] = EnvelopeMWave(MWaveArray, Frequency, titleStr)

    Frequency=1024;
    timeArray= (0:1/Frequency:length(MWaveArray)/Frequency-1/Frequency)*1000; %ms
    figure();
    A=[];

    for i = 1:size(MWaveArray,1)
    
        if (rem(size(MWaveArray),10))~=0
                flag=1;
        else flag=0;
        end 
        
        subplot(fix(size(MWaveArray,1)/10)+flag, 10, i);
        plot(timeArray, MWaveArray(i,:),'LineWidth',1.2, 'Color','b');
        title(titleStr);
        grid on;
        ylabel('mV');
        xlabel('time[ms]');
        hold on
        t = 1:length(MWaveArray);
        [upper_env, lower_env] = envelope(MWaveArray(i,:));
        plot(t, upper_env, 'r--', 'LineWidth', 1.2);
        plot(t, lower_env, 'r--', 'LineWidth', 1.2);
        
        A(i) = mean(upper_env - lower_env);
    end 
end 

function [mean_latency, latency_ms] = computeLatency(art_locs, locs)
    if length(locs)>length(art_locs)
       locs=locs(1:length(art_locs)); 
    end

    latency_samples=[];
    latency_ms=[];
    for i = 1:length(locs)
        latency_samples(i) = locs(i)-art_locs(i); 
        latency_ms(i) = (latency_samples(i)/1024)*1000; 
    end 
    mean_latency = mean(latency_ms); 
end 