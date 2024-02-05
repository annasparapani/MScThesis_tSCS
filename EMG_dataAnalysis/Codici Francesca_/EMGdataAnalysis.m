function thisTest = EMGdataAnalysis(StimString, MuscleString, MuscleString2, Amp, Freq)  
    Stim = load(strcat('data/MatlabData/', StimString, '_', MuscleString, '&', MuscleString2, '_STIM_', num2str(Amp), 'mA', num2str(Freq), 'Hz.mat'));
    
    channels = [1 2]; 
    for ch = channels
        thisCh = Stim.data(Stim.datastart(ch,1): Stim.dataend(ch,1)); 
        eval(['ch' num2str(ch) ' = thisCh;']);
    end
    mySize = size(ch1, 2); % size of the 2 channels is identical 
    
    samplingF = Stim.samplerate(1,1); % 40k 
    samplingPeriod = 1/samplingF;
    thisPeriod = 1/Freq;
    acquisitionDuration = mySize/samplingF; % in seconds 
    acquisitionTime = [samplingPeriod: samplingPeriod: acquisitionDuration];
    
    commentsSamples = Stim.com(:,3); 
    commentsTimes = commentsSamples/samplingF; 
        
    % Case noSTIM to extract signal offset
    % thisMuscleString = 'RF'; thisMuscleString2 = 'BF'; 
    NoStim = load(strcat('data/MatlabData/ContSCS_', MuscleString, '&', MuscleString2, '_noSTIM1.mat'));
    
    for ch = channels
        thisCh = NoStim.data(NoStim.datastart(ch,1): NoStim.dataend(ch,1)); 
        eval(['noStim_ch' num2str(ch) ' = thisCh;']); 
    
        timeOffsetComputation = 1; %[s] 
        samplesOffsetComputation = samplingF * timeOffsetComputation; 
    
        offset_thisCh = mean(thisCh(1: samplesOffsetComputation)); 
        eval(['offset_ch' num2str(ch) ' = offset_thisCh;']); 
    end
        
    % Identify Pulses starting point and duration 
    % Identification of starting points 
    
    for ch = channels 
        eval(['thisCh = ch' num2str(ch) ';']);
        eval(['offset_thisCh = offset_ch' num2str(ch) ';']);
    
        xx = [1: mySize];
     
        if(strcmp(StimString, 'ContSCS')) 
            minProm = 1 * 10^-4; % 0.1 mV
        elseif(strcmp(StimString, 'ContNMEStibialNerve') || strcmp(StimString, 'ContNMESgastroDermatome'))
            minProm = 1 * 10^-3; % 1 mV
        end
        
        MIN_thisCh = islocalmin(thisCh, 'MinProminence', minProm); 
        minIdxs_thisCh = xx(MIN_thisCh); 
        nSamp_descPulsePhase = 50; % 50 samples of descending phase after the pulse 
        % startPulseIdxs_thisCh = minIdxs - nSamp_descPulsePhase; 
        first_startPulseIdx_thisCh = minIdxs_thisCh(1) - nSamp_descPulsePhase; 
        IPI_samples = thisPeriod * samplingF; 
        startPulseIdxs_thisCh = [first_startPulseIdx_thisCh: IPI_samples: length(thisCh)]; % in this way we're sure we have same number of samples for each pulse 
        eval(['startPulseIdxs_ch' num2str(ch) ' = startPulseIdxs_thisCh;']);
        % figure(); plot(xx, thisCh, xx(startPulseIdxs_thisCh), thisCh(startPulseIdxs_thisCh), 'r*'); 
        
    
        % Alignment and average of IPI signals 
        IPIsignals_matrix = []; 
        for i = 1: length(startPulseIdxs_thisCh)-1 
            IPIsignals_matrix = [IPIsignals_matrix; thisCh(startPulseIdxs_thisCh(i): startPulseIdxs_thisCh(i+1)-1)]; 
        end
        IPIsignalAVG_thisCh = mean(IPIsignals_matrix); 
        eval(['IPIsignalAVG_ch' num2str(ch) ' = IPIsignalAVG_thisCh;']);
        % figure(); plot(IPIsignalAVG_thisCh); 
        
        % Calculate baseline 
        timeBaselineComputation = 0.005; %[s] - selected 5ms because is interval of flat signal 
        samplesBaselineComputation = samplingF * timeBaselineComputation;
        
        if(Freq == 20) 
            % consider last 5ms of signal 
            baseline_thisCh = mean(IPIsignalAVG_thisCh( (length(IPIsignalAVG_thisCh)-samplesBaselineComputation): length(IPIsignalAVG_thisCh)));
        elseif(Freq == 50) 
            % consider interval from 10ms to 5ms before signal end 
            baseline_thisCh = mean(IPIsignalAVG_thisCh( (length(IPIsignalAVG_thisCh)-samplesBaselineComputation*2): (length(IPIsignalAVG_thisCh)-samplesBaselineComputation-1) ));
            elseif(Freq == 80) 
            % in this case no flat signal zone - fix baseline to a constant value
            baseline_thisCh = 1 * 10^-6; % 1uV selected because beseline around 2uV for 20Hz and 0.4uV for 50Hz 
        end
        
        % Find difference between signal and baseline < threshold 
        
        if(strcmp(StimString, 'ContSCS') || strcmp(StimString, 'ContNMEStibialNerve')) 
            threshold = 5 * 10^-6; % [V] = 5uV 
        elseif(strcmp(StimString, 'ContNMESgastroDermatome')) 
            threshold = 30 * 10^-6; % [V] = 30uV 
        end
        
        foundFlag = 0; 
        consideredSamplesAfterPulse = 180; % find the stop in 300 samples (duration of pulse is around 150 samples) 
        for i = 1: consideredSamplesAfterPulse
            if((abs(IPIsignalAVG_thisCh(i) - baseline_thisCh) < threshold) && foundFlag == 0) 
                idxStopPulse = i; 
                foundFlag = 1; 
            elseif((abs(IPIsignalAVG_thisCh(i) - baseline_thisCh) > threshold) && foundFlag == 1)  
                foundFlag = 0; 
        %         idxStopPulse = []; 
            end
        end
        artifactSamples_thisCh = idxStopPulse; 
        artifactDuration_thisCh = artifactSamples_thisCh/samplingF; 
        eval(['artifactSamples_ch' num2str(ch) ' = artifactSamples_thisCh;']);
        
        % xx = [1: length(IPIsignalAVG_thisCh)]; 
        % figure(); plot(xx, IPIsignalAVG_thisCh, xx(idxStopPulse), IPIsignalAVG_thisCh(idxStopPulse), '*'); 
        
        % Substitution of all artifacts with offset 
        for i = 1: length(startPulseIdxs_thisCh) 
            thisCh(startPulseIdxs_thisCh(i): startPulseIdxs_thisCh(i)+artifactSamples_thisCh-1) = offset_thisCh; 
        end
        
        
        % Offset subtraction
        thisCh = thisCh - offset_thisCh; 
        % figure(); plot(thisCh); 
        
        
        % Signal rectification 
        rect_thisCh = abs(thisCh); 
        % figure(); plot(rect_thisCh); 
        
        % substitution of rectified pulse with avg 
        avgComputationSamples = floor((IPI_samples - artifactSamples_thisCh)/2); % consider a number of samples equal to half of signal samples 
        
        for i = 2: length(startPulseIdxs_thisCh)-1
            avgRectSignal = mean([rect_thisCh(startPulseIdxs_thisCh(i)-avgComputationSamples: startPulseIdxs_thisCh(i)-1) rect_thisCh(startPulseIdxs_thisCh(i)+artifactSamples_thisCh: startPulseIdxs_thisCh(i)+artifactSamples_thisCh+avgComputationSamples)]);
            rect_thisCh(startPulseIdxs_thisCh(i): startPulseIdxs_thisCh(i)+artifactSamples_thisCh-1) = avgRectSignal; 
        end 
        % figure(); plot(rect_thisCh); 
        
        
        % scaling to uV 
        rect_thisCh = rect_thisCh * 10^6; 
        eval(['rect_ch' num2str(ch) ' = rect_thisCh;']);
        
        % Low-pass filtering 
        % Filter1: 100 Hz, 5 order
        filterFreq = 100; filterOrder = 5; 
        [B2, A2] = butter(filterOrder, filterFreq/(samplingF/2), 'low'); 
        env1_thisCh = filtfilt(B2, A2, rect_thisCh); 
        eval(['env1_ch' num2str(ch) ' = env1_thisCh;']);
    
        % Filter2: 20 Hz, 5 order
        filterFreq = 20; filterOrder = 5; 
        [B2, A2] = butter(filterOrder, filterFreq/(samplingF/2), 'low'); 
        env2_thisCh = filtfilt(B2, A2, rect_thisCh); % smoother signal compared to using higher frequency 
        eval(['env2_ch' num2str(ch) ' = env2_thisCh;']); 
    
        FEduration = 2; %[s]
        FEsize = FEduration * samplingF; 
        allFErect = []; allFEenv1 = []; allFEenv2 = []; 
        for ext = 1: 3 % 
            thisFE_rect = rect_thisCh(commentsSamples(ext): commentsSamples(ext)+FEsize-1); 
            thisFE_env1 = env1_thisCh(commentsSamples(ext): commentsSamples(ext)+FEsize-1); 
            thisFE_env2 = env2_thisCh(commentsSamples(ext): commentsSamples(ext)+FEsize-1); 
    
            eval(['FE' num2str(ext) '_ch' num2str(ch) '.rect = thisFE_rect;']); 
            eval(['FE' num2str(ext) '_ch' num2str(ch) '.env1 = thisFE_env1;']); 
            eval(['FE' num2str(ext) '_ch' num2str(ch) '.env2 = thisFE_env2;']); 

            allFErect = [allFErect; thisFE_rect]; 
            allFEenv1 = [allFEenv1; thisFE_env1]; 
            allFEenv2 = [allFEenv2; thisFE_env2]; 
        end
        avgFErect = mean(allFErect); avgFEenv1 = mean(allFEenv1); avgFEenv2 = mean(allFEenv2);
        stdFErect = std(allFErect); stdFEenv1 = std(allFEenv1); stdFEenv2 = std(allFEenv2);
        eval(['avgFE_ch' num2str(ch) '.rect = avgFErect;']); eval(['stdFE_ch' num2str(ch) '.rect = stdFErect;']); 
        eval(['avgFE_ch' num2str(ch) '.env1 = avgFEenv1;']); eval(['stdFE_ch' num2str(ch) '.env1 = stdFEenv1;']); 
        eval(['avgFE_ch' num2str(ch) '.env2 = avgFEenv2;']); eval(['stdFE_ch' num2str(ch) '.env2 = stdFEenv2;']); 
    end 
    
    %
    ch1Struct = struct(); 
    ch1Struct.artifactSamples = artifactSamples_ch1; 
    ch1Struct.startPulseIdxs = startPulseIdxs_ch1; 
    ch1Struct.rawData = ch1; 
    ch1Struct.offset = offset_ch1; 
    ch1Struct.rect = rect_ch1; 
    ch1Struct.env1 = env1_ch1; 
    ch1Struct.env2 = env2_ch1; 
    ch1Struct.IPIsignalAVG = IPIsignalAVG_ch1; 
    ch1Struct.FE1 = FE1_ch1; ch1Struct.FE2 = FE2_ch1; ch1Struct.FE3 = FE3_ch1; ch1Struct.FE_AVG = avgFE_ch1; ch1Struct.FE_STD = stdFE_ch1; 
    
    ch2Struct = struct(); 
    ch2Struct.artifactSamples = artifactSamples_ch2; 
    ch2Struct.startPulseIdxs = startPulseIdxs_ch2; 
    ch2Struct.rawData = ch2; 
    ch2Struct.offset = offset_ch2; 
    ch2Struct.rect = rect_ch2; 
    ch2Struct.env1 = env1_ch2; 
    ch2Struct.env2 = env2_ch2; 
    ch2Struct.IPIsignalAVG = IPIsignalAVG_ch2; 
    ch2Struct.FE1 = FE1_ch2; ch2Struct.FE2 = FE2_ch2; ch2Struct.FE3 = FE3_ch2; ch2Struct.FE_AVG = avgFE_ch2; ch2Struct.FE_STD = stdFE_ch2; 
    
    thisTest = struct(); 
    thisTest.samplingF = samplingF; 
    thisTest.samplingPeriod = samplingPeriod; 
    thisTest.amplitude = Amp; 
    thisTest.frequency = Freq; 
    thisTest.period = thisPeriod; 
    thisTest.commentsSamples = commentsSamples;
    thisTest.IPI_samples = IPI_samples; 
    thisTest.size = mySize; 
    thisTest.FEduration = FEduration; 
    thisTest.FEsize = FEsize; 
    thisTest.("EMG_" + MuscleString) = ch1Struct;
    thisTest.("EMG_" + MuscleString2) = ch2Struct; 

end