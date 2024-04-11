%% HEALTHY SUB ANALYSIS
% data acquired on the non motorized trike from a healthy subject
% import dataSano.mat from MScThesis_tSCS_gitHub/EMG_dataAnalysis/TMSi Data Analysis/Dati
clear all 
close all
plots_on=1;
fs=2000;
titles_muscles={'QUAD SX', 'HAMS SX', 'QUAD DX', 'HAMS DX'}; 
%% Filtering  
    rawData=dataS2.samples;
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
    
    filteredBandPass = []; filterOrder = 3; filterFreq = 750; % Butterworth 3 ordine LP @750Hz
    [b, a] = butter(filterOrder, filterFreq/(fs/2), 'low'); 
    for j = 1:size(rawData,1)
        filteredBandPass(j,:)=filtfilt(b, a, filteredHighPass(j,:)); 
    end 
    filteredData = filteredBandPass; 
    % filterOrder = 6; freqToCut=50; % Notch 50 Hz
    % for i=1:1
    %     d = designfilt('bandstopiir', 'FilterOrder', filterOrder, 'HalfPowerFrequency1',(freqToCut*i)-1, ...
    %         'HalfPowerFrequency2', (freqToCut*i)+1, 'DesignMethod', 'butter', 'SampleRate', fs);
    %     for j=1:size(rawData,1)
    %         filteredData(j,:) = filtfilt(d, filteredData(j,:)); 
    %     end 
    % end 
    
    % spectrumFiltered=[]; figure("Name","Spectrum filtered");
    % for i=1:size(filteredData,1)
    %     spectrumFiltered(i,:) = pspectrum(filteredData(i,:),fs);
    %     subplot(4,3,i), plot((0:length(spectrumFiltered(i,:))-1) * fs/length(spectrumFiltered(i,:)), spectrumFiltered(i,:));
    %     ylabel('Power/Frequency (dB/Hz)'), xlabel('Frequency (Hz)'), title(titles(i));
    % end 
    
    if plots_on % plot time course of filtered data
        for i=2:size(dataS2.samples,1)
            subplot(2,2,i-1), plot(filteredData(i,:)), ylabel('µV'),xlabel('time(s)'), title(titles_muscles(i-1));
        end 
    end
    dataS2.filteredData=filteredData;

    %% Offset removal and rectification
    noOffData=dataS2.filteredData;   
    noOffData = noOffData - mean(noOffData,2); 
    dataS2.noOffData = noOffData;  
    
    if plots_on
        figure('Name','Data with Offset Removed')
        for i=2:size(dataS2.noOffData,1)
            subplot(2,2,i-1), plot(dataS2.noOffData(i,:)), ylabel('µV'),xlabel('time(s)'), title(titles_muscles(i-1)+" no offset");
        end 
    end
    dataS2.rectData=abs(dataS2.noOffData);
    if plots_on
        figure('Name','Data Rectified')
        for i=2:size(dataS2.rectData,1)
            subplot(2,2,i-1), plot(dataS2.rectData(i,:)), ylabel('µV'),xlabel('time(s)'), title(titles_muscles(i-1)+" rectified");
        end 
    end
    %% Envelope
    envelopeData=[];filterFreq = 50; filterOrder = 5; % Low-pass filtering 100 Hz, 5 order
    [B, A] = butter(filterOrder, filterFreq/(fs/2), 'low'); 
    for i=1:size(dataS2.rectData,1)
        envelopeData(i,:) = filtfilt(B, A, dataS2.rectData(i,:)); 
    end 

    if plots_on
        figure('Name', 'Envelope of data');
        for i=2:size(dataS2.rectData,1)
            subplot(2,2,i-1), plot(dataS2.rectData(i,:)), ylabel('µV'),xlabel('time(s)'), title(titles_muscles(i-1)+" envelope");
            hold on; 
            subplot(2,2,i-1), plot(envelopeData(i,:));
            legend('Rectified Signal', 'Envelope');
            hold off; 
        end 
    end
    dataS2.envelopeData = envelopeData; clear envelopeData; 

   %% Cycling segmentation
    % triggers identification
    [cycle_pks,cycle_locs]=findpeaks(dataS2.samples(1,:),"MinPeakDistance",1000,"MinPeakHeight",10000); 
    figure; plot(dataS2.samples(1,:), 'b'); hold on;
    scatter(cycle_locs, cycle_pks, 'ro'); % Add circles at peak locations
    title(['Raw Data with Identified Peaks - Recording ', num2str(1)]);
    xlabel('Sample Index'); ylabel('Amplitude'); hold off;
    
    %% segmentation
    segmentedData=cell(4,length(cycle_locs)-1);
    for j = 1:4 
        for i=1:(length(cycle_locs)-1)
            segmentedData{j,i}=dataS2.envelopeData(j+1, cycle_locs(i):(cycle_locs(i+1)-1));
        end 
    end 
    dataS2.segmentedData=segmentedData; 

    %%  Average cycling revolution
    % interpolate data to have the same number of cycles in each segment  
    avg_samples = zeros(1, 4);
    for j = 1:4
        muscle_samples = cellfun(@length, dataS2.segmentedData(j, :));
        avg_samples(j) = mean(muscle_samples);
    end
    interpolatedSegmentedData = cell(4, length(cycle_locs)-1);
    for j = 1:4
        for i = 1:(length(cycle_locs)-1)
            interpolatedSegmentedData{j, i} = interp1(1:length(dataS2.segmentedData{j, i}), ...
                dataS2.segmentedData{j, i}, linspace(1, length(dataS2.segmentedData{j, i}), avg_samples(j)));
        end
    end
    dataS2.interpolatedSegmetedData = interpolatedSegmentedData;
    %% compute the mean
    averageCycle = cell(1, 4); 
    for j = 1:4
        muscle_cycles = zeros(length(interpolatedSegmentedData{j, 1}), length(cycle_locs)-1); 
        for i = 1:(length(cycle_locs)-1)
            muscle_cycles(:, i) = interpolatedSegmentedData{j, i}(:); % Store the current cycle in the matrix
        end
        averageCycle{j} = mean(muscle_cycles, 2); 
    end
    dataS2.avgCycle = averageCycle;

    figure('Name','Average EMG activation cycle')
    for i = 1:4
        subplot(2,2,i), plot(dataS2.avgCycle{i}, 'LineWidth',2); title(titles_muscles(i));
        xlabel('Cycling revolution'), ylabel('EMG activation [µV]'),

    end 

