%% TITLE: EMG data analysis for tSCS protocol 2 (double pulses) 
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

% Filtered data plots
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
%% Peaks detection
% Finding the Min Peak Height for every muscle, based on the std deviation
% 1. Calculate standard deviation of the filtered signal
std_dev = std(xfilter);
% 2. Set a threshold as a multiple of the standard deviation
minPeakHeight_multiplier = 5; % You can adjust this multiplier, I kept it quite 
                          % high because the stimulation artefacts are much 
                          % higher than the rest of the signal
minPeakHeight = minPeakHeight_multiplier * std_dev;
meanPeakDistance=10; % mean peak distance 1200 = 0.6s 

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

%% Double artifacts detection and grouping
% if artifacts are approximately 50 ms from each other -> in one single
% group

% Right Leg
[DoubletGroup_quadDx, peakLocsGroup_quadDx, peakValuesGrouped_quadDx, ...
    peakLocsLocalGroup_quadDx] = buildDoubletsGroups(quad_dx, locs1); 
[DoubletGroup_hamsDx, peakLocsGroup_hamsDx, peakValuesGrouped_hamsDx, ...
    peakLocsLocalGroup_hamsDx] = buildDoubletsGroups(hams_dx, locs2); 
[DoubletGroup_gastDx, peakLocsGroup_gastDx, peakValuesGrouped_gastDx, ...
    peakLocsLocalGroup_gastDx] = buildDoubletsGroups(gast_dx, locs3); 
[DoubletGroup_taDx, peakLocsGroup_taDx, peakValuesGrouped_taDx, ...
    peakLocsLocalGroup_taDx] = buildDoubletsGroups(ta_dx, locs4); 
% Left Leg
[DoubletGroup_quadSx, peakLocsGroup_quadSx, peakValuesGrouped_quadSx, ...
    peakLocsLocalGroup_quadSx] = buildDoubletsGroups(quad_dx, locs5); 
[DoubletGroup_hamsSx, peakLocsGroup_hamsSx, peakValuesGrouped_hamsSx, ...
    peakLocsLocalGroup_hamsSx] = buildDoubletsGroups(hams_sx, locs6); 
[DoubletGroup_gastSx, peakLocsGroup_gastSx, peakValuesGrouped_gastSx, ...
    peakLocsLocalGroup_gastSx] = buildDoubletsGroups(gast_sx, locs7); 
[DoubletGroup_taSx, peakLocsGroup_taSx, peakValuesGrouped_taSx, ...
    peakLocsLocalGroup_taSx] = buildDoubletsGroups(ta_sx, locs8); 

% Plot stimulations and respective M waves
if plots_on
    plotDoubleWave("Quad DX", DoubletGroup_quadDx, Fs_EMG); 
    plotDoubleWave("Hams DX", DoubletGroup_hamsDx, Fs_EMG); 
    plotDoubleWave("Gast DX", DoubletGroup_gastDx, Fs_EMG); 
    plotDoubleWave("TA DX", DoubletGroup_taDx, Fs_EMG); 

    plotDoubleWave("Quad SX", DoubletGroup_quadSx, Fs_EMG); 
    plotDoubleWave("Hams SX", DoubletGroup_hamsSx, Fs_EMG); 
    plotDoubleWave("Gast SX", DoubletGroup_gastSx, Fs_EMG); 
    plotDoubleWave("TA SX", DoubletGroup_taSx, Fs_EMG); 
end

%% Detect the locations of the two highest peaks

artfactsLocs_quadDx=computeArtefactsPositions(peakValuesGrouped_quadDx, peakLocsLocalGroup_quadDx);
artfactsLocs_hamsDx=computeArtefactsPositions(peakValuesGrouped_hamsDx, peakLocsLocalGroup_hamsDx);
artfactsLocs_gastDx=computeArtefactsPositions(peakValuesGrouped_gastDx, peakLocsLocalGroup_gastDx);
artfactsLocs_taDx=computeArtefactsPositions(peakValuesGrouped_taDx, peakLocsLocalGroup_taDx);

artfactsLocs_quadSx=computeArtefactsPositions(peakValuesGrouped_quadSx, peakLocsLocalGroup_quadSx);
artfactsLocs_hamsSx=computeArtefactsPositions(peakValuesGrouped_hamsSx, peakLocsLocalGroup_hamsSx);
artfactsLocs_gastSx=computeArtefactsPositions(peakValuesGrouped_gastSx, peakLocsLocalGroup_gastSx);
artfactsLocs_taSx=computeArtefactsPositions(peakValuesGrouped_taSx, peakLocsLocalGroup_taSx);

%% Detect the M wave after each artifact and compute the PAD 

[PAD_quadDx,A1_quadDx, A2_quadDx] = computePAD(DoubletGroup_quadDx, artfactsLocs_quadDx, "Quad DX"); 
[PAD_hamsDx,A1_hamsDx, A2_hamsDx] = computePAD(DoubletGroup_hamsDx, artfactsLocs_hamsDx, "Hams DX");
[PAD_gastDx,A1_gastDx, A2_gastDx] = computePAD(DoubletGroup_gastDx, artfactsLocs_gastDx, "Gast DX");
[PAD_taDx,A1_taDx, A2_taDx] = computePAD(DoubletGroup_taDx, artfactsLocs_taDx, "TA DX");

[PAD_quadSx,A1_quadSx, A2_quadSx] = computePAD(DoubletGroup_quadSx, artfactsLocs_quadSx, "Quad SX"); 
[PAD_hamsSx,A1_hamsSx, A2_hamsSx] = computePAD(DoubletGroup_hamsSx, artfactsLocs_hamsSx, "Hams SX");
[PAD_gastSx,A1_gastSx, A2_gastSx] = computePAD(DoubletGroup_gastSx, artfactsLocs_gastSx, "Gast SX");
[PAD_taSx,A1_taSx, A2_taSx] = computePAD(DoubletGroup_taSx, artfactsLocs_taSx, "TA DX");

%% Print PAD for each muscle
% Find the maximum length among the arrays
max_length = max([length(PAD_gastDx), length(PAD_gastSx), length(PAD_hamsDx), ...
    length(PAD_hamsSx), length(PAD_quadDx), length(PAD_quadSx), length(PAD_taSx), ...
    length(PAD_taDx)]);

% Pad arrays with NaN to make them have the same length
PAD_gastDx(end+1:max_length) = NaN;
PAD_gastSx(end+1:max_length) = NaN;
PAD_hamsDx(end+1:max_length) = NaN;
PAD_hamsSx(end+1:max_length) = NaN;
PAD_quadSx(end+1:max_length) = NaN;
PAD_quadDx(end+1:max_length) = NaN;
PAD_taSx(end+1:max_length) = NaN;
PAD_taDx(end+1:max_length) = NaN;

% Create a table
T = table(PAD_quadDx',PAD_hamsDx', PAD_gastDx',PAD_taDx', ...
    PAD_quadSx', PAD_hamsSx',PAD_gastSx', PAD_taSx', ...
    'VariableNames', {'PAD_quadDx','PAD_hamsDx', 'PAD_gastDx','PAD_taDx', ...
    'PAD_quadSx', 'PAD_hamsSx','PAD_gastSx', 'PAD_taSx',});

% Display the table
disp(T);
%% ************************************************************************
% ************************ FUNCTIONS **************************************
% *************************************************************************

 function [doubletsGroup, peakLocsGroup, peakValuesGrouped, peakLocsLocalGroup] = buildDoubletsGroups(signal, peaks)
  % Function to find the peaks near to each other and to construct the
  % groups for each doublet application 
    max_distance_between_peaks = 200; % define peak groups
   
    peakLocsGroup = cell(0); % Initialize variables to store the groups
    peakLocsLocalGroup=cell(0); % save positions of peaks respective of the local wave
    peakValuesGrouped=cell(0); 
    current_group = [];
    
    % Iterate through the peak locations
    for i = 1:length(peaks)-1
        % Check if the distance between the current peak and the next peak is within the limit
        if peaks(i+1) - peaks(i) < max_distance_between_peaks
            % Add the current peak to the current group
            current_group = [current_group, peaks(i)];
        else
            % If the distance is larger, finalize the current group and start a new one
            if ~isempty(current_group)
                current_group = [current_group, peaks(i)]; % Add the last peak to the group
                for j=1:length(current_group)
                    peakValues=signal(current_group); 
                end 
                peakLocsGroup{end+1} = current_group; % Save the current group
                peakValuesGrouped{end+1}=peakValues;
                current_group = []; % Reset for the next group
            else % is the current group is empty
                peakLocsGroup{end+1} = peaks(i);
                peakValuesGrouped{end+1} = signal(peaks(i));
            end
        end
    end
    
    peak_groups_size=size(peakLocsGroup); 
    groups_number=peak_groups_size(2); 
    doubletsGroup=cell(1,groups_number);
    for i=1:groups_number
        doubletsGroup{i}= signal((peakLocsGroup{i}(1)-10):(peakLocsGroup{i}(end)+100));
    end 
    for i = 1:size(peakLocsGroup,2)
         peakLocsLocalGroup{i}=peakLocsGroup{i}-peakLocsGroup{i}(1)+10; 
    end
 end

 function plotDoubleWave(titleStr, DoubletGroup, Frequency)
    % Function to plot the double stimatulation + m waves
    figure;
    for i = 1:size(DoubletGroup,2)
        if (rem(size(DoubletGroup),5))~=0
            flag=1;
        else flag=0;
        end 
        timeArray= (0:1/Frequency:length(DoubletGroup{i})/Frequency-1/Frequency)*1000; %ms
        subplot(fix(size(DoubletGroup,2)/5)+flag, 5, i);
        plot(timeArray, DoubletGroup{i},'LineWidth',1.2);
        title(titleStr);
        grid on;
        ylabel('mV');
        xlabel('time[ms]');
        % Add a red horizontal line at y = 0.05
        hold on;
        yline(0.05, 'r', 'LineWidth', 1.5);
        hold off;
    end
 end 

 function Mwavestart = findMwaveStart(signal, locs)
    Mwavestart = zeros(1,2);
    Mwavestart(1) = locs(1) + 5;
    Mwavestart(2)=locs(2) + 5;
    % for i = 1:length(locs)
    %     for j = 1:10 % Find zero-crossings in the 40 samples before the artifact
    %         if (signal(locs(i) - j) * signal(locs(i) - j + 1)) < 0
    %             Mwavestart(i) = locs(i) - j - 5; % add 5 samples to give some space in the graph
    %             break;
    %         end
    %     end
    % end
 end

 function steepness = calculateSteepness(signal, index)
    % Calculate the steepness (slope) at the specified index
    steepness = (signal(index + 1) - signal(index)) / 1; % Assuming a unit step
 end


 function artefactsLocs = computeArtefactsPositions(peakValuesGrouped, peakLocsLocalGroup)
    artefactsLocs=cell(0);
        
    for i=1:size(peakValuesGrouped,2)
        artefactsLocs{i}(1)=peakLocsLocalGroup{i}(1); 
        if size(peakLocsLocalGroup,2)>1
            artefactsLocs{i}(2)=peakLocsLocalGroup{i}(1)+51; % approssimato!
                % if size(peakValuesGrouped{i},1) > 1
                %     % Find the two highest peaks and their locations
                %     [~, sortedIndices] = maxk(peakValuesGrouped{i}, 2);
                %     sortedIndices = sort(sortedIndices, 'ascend'); 
                %     artefactsLocs{i}=peakLocsLocalGroup{i}(sortedIndices); 
                % end 
        end 
    end
 end
%%
function [PAD, A1, A2] = computePAD(signal, artefactLocs, titleStr)
    Frequency=1024; 
    M1 = [];
    M2 = [];
    Mlength = 20;
    figure(); 
    
    if size(artefactLocs,2)==0
        PAD=0; 
        A1=0;
        A2=0;
        plot(signal{1}); 
        text(mean(xlim), mean(ylim), sprintf(['No Double Stimulation detected \n in ' ...
            'any of the stimulation sequences for this muscle']), ...
             'Horiz','center', 'Vert','middle','FontSize', 16, 'BackgroundColor','w')
        title(titleStr);
        return;
    end 
    
    for i = 1:size(artefactLocs, 2)
        if isempty(artefactLocs{i}) || all(size(artefactLocs{i}) == [1, 1])
            subplot(3, 4, i);
            timeArray= (0:1/Frequency:length(signal{i}(:,1))/Frequency-1/Frequency)*1000; %ms
            plot(timeArray, signal{i}(:, 1));
            title(titleStr);
            text(mean(xlim), mean(ylim), sprintf('No Double \n Stimulation \n detected', i), ...
                'Horiz','center', 'Vert','middle','FontSize', 12, 'BackgroundColor','w')
            grid on;
            continue; % Skip the rest of the loop for this iteration
        end
        
        startM(1:2,1) = findMwaveStart(signal{i}, artefactLocs{i});
        
        if startM(1,1)==0 
            startM(1,1)=1; 
        end 

        if startM(2,1)==0 
            startM(2,1)=1; 
        end 

        M1 = signal{i}(startM(1):startM(1) + Mlength, 1);
        M2 = signal{i}(startM(2):startM(2) + Mlength, 1);

        A1(i) = max(M1)-min(M1);
        A2(i) = max(M2)-min(M2); 
        PAD(i) = (A2/A1)*100; 
        
        subplot(3, 4, i), plot(signal{i}(:, 1)), hold on, 
        plot(artefactLocs{i}, signal{i}(artefactLocs{i}(:)), 'o'), 
        ylabel('mV'), title(titleStr);
        plot(startM(1):startM(1) + Mlength, M1, 'Color', 'r');
        plot(startM(2):startM(2) + Mlength, M2, 'Color', 'r'); 
        grid on
    end 
end