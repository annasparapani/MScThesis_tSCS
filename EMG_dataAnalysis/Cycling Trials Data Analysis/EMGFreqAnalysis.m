%% EMG FREQUENCY ANALYSIS to compare muscle activation under tSCS 
% Anna Sparapani - March 2024
% EMG data analysis for tSCS + pedalling setup - data was acquired on a
% TMSI SAGA REV 2+ with 16 unipolar channels on 8 muscles (QUAD, HAMS, GAST
% and TA on each leg) during 6 cycling conditions on trike, on SCI subjects
% the 6 conditions, which are compared in the script, are: 
% tSCS 50/80/20Hz, tSCS 50/80/20 + voluntary effort for movement

% upload order: 50, 50 vol, 80, 80 vol, 20, 20 vol, passive
clear all
close all
clc
num_recordings = 7; % Define the number of recordings
clear recording_data time Emg_Signal data_mot_emg rawData prompt dlgtitle dims bipChannels mono
plots_on = 1;
fs=2000;
%francesca :
%titles_recs = {'50Hz', '80Hz', '20 Hz', 'passive'}
titles_recs={'50Hz', '50Hz + vol','80Hz', '80Hz + vol', '20Hz', '20Hz + vol','passive', 'passive + vol', 'passive + vol finale'}; 
titles_muscles={'QUAD RIGHT','HAMS RIGHT', 'GAST RIGHT', 'TA RIGHT',...
    'QUAD LEFT','HAMS LEFT', 'GAST LEFT', 'TA LEFT', 'Trigger','QUAD RIGHT bip'};

Pink = [245, 235, 235; 244, 217, 229; 230, 176 201; 222, 140, 174; ...
    215, 98, 147; 206, 150, 160; 191, 97, 126; 207, 65, 119; 178, 46, 92; ...
    129 27 60]/255; % 2 and 7
Blue = [230, 241, 246; 203, 224, 236; 168, 201, 222; 125, 175, 208; ...
    86, 146, 188; 59, 110, 150; 35, 74, 108]/255; % 2 and 5
Green = [228, 241, 228; 209, 228, 211; 168, 204, 171; 128, 183, 132; ...
    98, 168, 101; 70, 134, 71; 40, 87, 49]/255; % 2 and 4
Yellow = [0.9290 0.6940 0.1250; 0.9290 0.6940 0.1250; 0.9290 0.6940 0.1250;
    0.9290 0.6940 0.1250; 0.9290 0.6940 0.1250;0.9290 0.6940 0.1250];
Orange = [0.8500 0.3250 0.0980; 0.8500 0.3250 0.0980;0.8500 0.3250 0.0980;
    0.8500 0.3250 0.0980; 0.8500 0.3250 0.0980;0.8500 0.3250 0.0980];
Red = [255, 255, 178; 254, 217, 118; 254, 178, 76; 221, 134, 70; ...
    252, 78, 42; 227, 26, 28; 177, 0, 38]/255;
Black = [0, 0, 0; 127, 127, 127; 254, 178, 76; 221, 134, 70; ...
    252, 78, 42; 227, 26, 28; 177, 0, 38]/255;
colors{1} = Pink; colors{2} = Blue; colors{3} = Green; colors{4} = Yellow; 
colors{5} = Orange; colors{6} = Black; colors{7} = Red; 

%% FFT power spectrum 
figure(); 
for muscle = 1:8 
    subplot(2,4,muscle);
    for rec = 1:num_recordings
        thisVec = data_struct{rec}.rectData(muscle,:);
        thisVec = thisVec - mean(thisVec);% remove DC component introduced by rectification
        N = length(thisVec);
        xdft_thisVec = fft(thisVec); xdft_thisVec = xdft_thisVec(1:N/2+1);
        psdx_thisVec = (1/(fs*N)) * abs(xdft_thisVec).^2; psdx_thisVec(2:end-1) = 2*psdx_thisVec(2:end-1);
        freq_thisVec = 0:fs/N:fs/2;
        
        if rec == 1&&2 color = colors{1}; 
            else if rec == 3&&4 color = colors{2}; 
                else if rec == 5&&6 color = colors{3};
                else if rec == 7 color = Yellow; 
                    end
                end 
            end 
        end
        if rem(rec,2)==0
                plot(freq_thisVec, movmean(psdx_thisVec/max(psdx_thisVec),10), 'color', color(5,:), 'LineWidth',1.8);  
                hold on
        else if rec == 7
             plot(freq_thisVec, movmean(psdx_thisVec/max(psdx_thisVec),20),'color', color(5,:), 'LineWidth', 2);  
        else 
            plot(freq_thisVec, movmean(psdx_thisVec/max(psdx_thisVec),10), 'color', color(3,:), 'LineWidth', 2);  
            hold on
        end 
        end 
    end 
    ylabel('Normalized Spectrum Amplitude'), xlabel('Frequency (Hz)')
    %ylim([0,0.082]),
    xlim([0.1,1]),grid on
    title(titles_muscles(muscle), 'FontSize',18); set(gca, 'FontSize', 14); %yticks(0:0.05:1); 
    grid on; 
    sgtitle('EMG power spectrum', 'FontSize', 24)

end
%%
% Define the interval of interest
freq_of_interest = [0.35, 0.45];

figure(); 
for muscle = 1:8 
    subplot(2,4,muscle);
    for rec = 1:num_recordings
        thisVec = data_struct{rec}.rectData(muscle,:);
        thisVec = thisVec - mean(thisVec);% remove DC component introduced by rectification
        N = length(thisVec);
        xdft_thisVec = fft(thisVec); xdft_thisVec = xdft_thisVec(1:N/2+1);
        psdx_thisVec = (1/(fs*N)) * abs(xdft_thisVec).^2; psdx_thisVec(2:end-1) = 2*psdx_thisVec(2:end-1);
        freq_thisVec = 0:fs/N:fs/2;
        
        
        % Find the indices corresponding to the frequencies of interest
        freq_indices = find(freq_thisVec >= freq_of_interest(1) & freq_thisVec <= freq_of_interest(2));
        
        % Find the maximum value and its corresponding frequency
        [max_val, max_index] = max(psdx_thisVec(freq_indices));
        max_freq = freq_thisVec(freq_indices(max_index));
        std_error_value = std(psdx_thisVec(freq_indices));
        
        if rec == 1&&2 color = colors{1}; 
            else if rec == 3&&4 color = colors{2}; 
                else if rec == 5&&6 color = colors{3};
                else if rec == 7 color = Yellow; 
                    end
                end 
            end 
        end
        % Plot the maximum value with error bars
        if rem(rec,2) == 0
            errorbar(max_freq, max_val/max(psdx_thisVec), std_error_value/max(psdx_thisVec), 'o', 'Color', color(5,:), 'MarkerSize', 8, 'LineWidth', 1.5);  
            hold on
        else
            errorbar(max_freq, max_val/max(psdx_thisVec), std_error_value/max(psdx_thisVec), 'o', 'Color', color(3,:), 'MarkerSize', 8, 'LineWidth', 1.5);  
            hold on
        end 
    end 
    
    ylabel('Normalized Spectrum Amplitude'), xlabel('Frequency (Hz)')
    %ylim([0,0.31]), 
    xlim([0.40,0.45]), grid on
    title(titles_muscles(muscle), 'FontSize', 18); 
    set(gca, 'FontSize', 14); 
    %yticks(0:0.05:1); 
    grid on; 
    sgtitle('EMG power spectrum', 'FontSize', 24)
end 

%%
figure()
for i=1:4
    if i >= 4
        if i == 5 subplot(3,3,9), plot(0,0, 'color','k', 'LineWidth', 2, 'LineStyle', '--'); hold on
        elseif i == 4
            plot(0,0, 'color',Yellow(3,:), 'LineWidth', 2 ); hold on 
        elseif i==6
            plot(0,0, 'color','k', 'LineWidth', 2, 'LineStyle', '-.' ); hold on 
        end 
    else
        plot(0,0, 'color',colors{i}(3,:), 'LineWidth', 2 ); hold on 
        plot(0,0, 'color', colors{i}(5,:),'LineWidth',1), 
    end
    title("legend"); 
    h=legend(titles_recs); set(h,'FontSize',14);
end 
%% Print Legend  
figure()
for i=1:7
    if i >= 4
        if i == 5 plot(0,0,'k--', 'LineWidth', 2); hold on
        elseif i == 4
            plot(0,0, 'color',Yellow(3,:), 'LineWidth', 2 ); hold on 
        elseif i==6
            plot(0,0, 'color','k', 'LineWidth', 2, 'LineStyle', '-.' ); hold on 
        else if i == 7 
           plot(0,0, 'color','k', 'LineWidth', 2 ); hold on 
        end
        end 
    else
        plot(0,0, 'color',colors{i}(3,:), 'LineWidth', 2 ); hold on 
        plot(0,0, 'color', colors{i}(5,:),'LineWidth',1), 
    end
    title("legend"); 
    h=legend(titles_recs); set(h,'FontSize',14);
end 
%% WELCH power spectrum
% METHOD 2: computation of Power Spectrum with Welch method
figure();
for muscle = 1:8 
    subplot(2,4,muscle);
    for rec = 1:num_recordings
    thisVec = data_struct{rec}.rectData(muscle,:);
    %segmentLength = 20000; segmentLength = floor(length(thisVec)/4.5);
    segmentLength = 4800; 
    noverlap = segmentLength/2;
    noverlap = floor(segmentLength/2);
    npoints = 500;
    npoints = max(256, 2^nextpow2(segmentLength));
    % [pxx, f] = pwelch(thisVec, hamming(segmentLength), noverlap, [], fs);
    [pxx_thisVec, f_thisVec] = pwelch(thisVec, hamming(segmentLength), noverlap, npoints, fs);
    
    if rec == 1&&2 color = colors{1}; 
        else if rec == 3&&4 color = colors{2}; 
            else if rec == 5&&6 color = colors{3};
            else if rec == 7 color = Yellow;
                end 
            end 
        end 
    end
    if rem(rec,2)==0
                plot(f_thisVec, movmean(pxx_thisVec/max(pxx_thisVec),5), 'color', color(5,:), 'LineWidth',1);  
                hold on, grid on;
        else if rec == 7
             plot(f_thisVec, movmean(pxx_thisVec/max(pxx_thisVec),40),'color', color(4,:), 'LineStyle','--', 'LineWidth', 1);  
        else 
            plot(f_thisVec, movmean(pxx_thisVec/max(pxx_thisVec),5), 'color', color(3,:), 'LineWidth', 1);  
            hold on, grid on;
        end 
    end 
    end 
    title(titles_muscles(muscle)),legend(titles_recs);
    sgtitle('Welch power spectrum', 'FontSize', 20);
end 

%% with processing as in Nielsen et al. 
figure();
for muscle = 1:8 
    for rec = 1:num_recordings
        subplot(2,4,muscle);
        thisVec = data_struct{rec}.rectData(muscle,:);
        cadence = 25; window_duration = 60 / cadence;
        window_size = floor(window_duration * fs); % Number of samples per window
        num_windows = floor(length(thisVec) / window_size);
        windows = reshape(thisVec(1:num_windows*window_size), window_size, num_windows);
        windows = windows - mean(windows); % remove offset
        hanning_window = hann(window_size); % apply hanning window
        windows = windows .* hanning_window;
        power_spectrums = abs(fft(windows)).^2; % compute spectrum and mean and std dev
        power_spectrums = power_spectrums / max(power_spectrums(:));
        mean_spectrum = mean(power_spectrums, 2);
        std_spectrum = std(power_spectrums, 0, 2);
    
        max_frequency = 18; %compute spectrum before 18Hz (no stim artefacts) 
        max_index = round(max_frequency * window_size / fs);
        mean_spectrum_up_to_18Hz = mean(power_spectrums(1:max_index, :), 2);
        std_spectrum_up_to_18Hz = std(power_spectrums(1:max_index, :), 0, 2);
        frequencies = (0:window_size-1) * fs / window_size; 
        
        if rec == 1&&2 color = colors{1}; 
            else if rec == 3&&4 color = colors{2}; 
                else if rec == 5&&6 color = colors{3};
                else if rec == 7 color = Yellow;
                    end 
                end 
            end 
        end
    
        if rem(rec,2)==0
                    plot(frequencies(1:max_index), mean_spectrum_up_to_18Hz, 'color', color(5,:), 'LineWidth',1);  
                    hold on, grid on
            else if rec == 7
                 plot(frequencies(1:max_index), mean_spectrum_up_to_18Hz,'color', color(4,:), 'LineStyle','--', 'LineWidth', 1);  
            else 
                plot(frequencies(1:max_index), mean_spectrum_up_to_18Hz, 'color', color(3,:), 'LineWidth', 1);  
                hold on, grid on
            end 
        end 
        title(titles_muscles(muscle)),legend(titles_recs);
        xlabel('Frequency (Hz)');
        ylabel('Power Spectrum');
        % Compute the cumulative sum of the power spectrum
        cumulative_spectrum = cumsum(mean_spectrum_up_to_18Hz);
        cumulative_spectrum = cumulative_spectrum / max(cumulative_spectrum);
        index_95_percent = find(cumulative_spectrum >= 0.95, 1, 'first');
        data_struct{rec}.frequency_95_percent(muscle) = frequencies(index_95_percent);
        %disp(['The value before which 95% of the spectrum lies is: ', num2str(frequency_95_percent), ' Hz']);
    end 
    title(titles_muscles(muscle)),legend(titles_recs);    
    sgtitle('Mean Power Spectrum with Standard Deviation', 'FontSize', 20);
end 
%% Bar plots to compare values where 95% of spectrum lies for each stimulation
for muscle = 1:8
    for rec = 1:num_recordings
        freq95(muscle,rec) = data_struct{rec}.frequency_95_percent(muscle);
    end 
end

figure();
for muscle = 1:8
    muscle_rms = freq95(muscle, :);
    subplot(2, 4, muscle);
    for rec = 1:4
        if rec == 4
            plot(2*rec-1, muscle_rms(2*rec-1), 'o', 'MarkerFaceColor', Yellow(3,:), 'MarkerEdgeColor', 'none', 'MarkerSize', 14); hold on
        else 
            plot(2*rec-1, muscle_rms(2*rec-1), 'o', 'MarkerFaceColor', colors{rec}(3, :), 'MarkerEdgeColor', 'none', 'MarkerSize', 14); hold on
            plot(2*rec, muscle_rms(2*rec), 'o', 'MarkerFaceColor', colors{rec}(5, :), 'MarkerEdgeColor', 'none', 'MarkerSize', 14);
        end
    end
    ylabel('RMS Value'); title(titles_muscles(muscle), 'FontSize',16), grid on;
    set(gca, 'XTick', 1:num_recordings, 'XTickLabel', titles_recs, 'FontSize', 14); xtickangle(45);
    xlim([0.5 7.5]), %ylim([0 20])
end
sgtitle('Frequency values before which 95% of the power spectrum lies', 'FontSize', 20);

%% 
% thisVec = data_struct{rec}.rectData(muscle,:);
% cadence = 25; % Cadence (revolutions per minute)
% window_duration = 60 / cadence; % Duration of one revolution (in seconds)
% 
% % Assuming thisVec is your rectified EMG signal
% 
% % 1. Cut the signal into windows
% window_size = floor(window_duration * Fs); % Number of samples per window
% num_windows = floor(length(thisVec) / window_size);
% windows = reshape(thisVec(1:num_windows*window_size), window_size, num_windows);
% 
% % 2. Subtract the mean of each window
% windows = windows - mean(windows);
% 
% % 3. Apply Hanning window
% hanning_window = hann(window_size);
% windows = windows .* hanning_window;
% 
% % 4. Compute power spectrum using FFT
% power_spectrums = abs(fft(windows)).^2;
% 
% % 5. Normalize power spectrum
% power_spectrums = power_spectrums / max(power_spectrums(:));
% 
% % 6. Compute mean and standard deviation
% mean_spectrum = mean(power_spectrums, 2);
% std_spectrum = std(power_spectrums, 0, 2);
% 
% % Plotting
% frequencies = (0:window_size-1) * Fs / window_size; % Frequency axis
% 
% figure;
% plot(frequencies, mean_spectrum); % Convert to dB
% hold on; 
% % plot(frequencies, 10*log10(mean_spectrum + std_spectrum), '--');
% % plot(frequencies, 10*log10(mean_spectrum - std_spectrum), '--');
% xlabel('Frequency (Hz)');
% ylabel('Power Spectrum (dB)');
% title('Mean Power Spectrum with Standard Deviation');
% legend('Mean Spectrum', 'Mean + Std', 'Mean - Std');
% 
% % Define the maximum frequency to consider
% max_frequency = 18; % Hz
% 
% % Find the index corresponding to the maximum frequency
% max_index = round(max_frequency * window_size / Fs);
% 
% % Compute mean and standard deviation for frequencies up to 18 Hz
% mean_spectrum_up_to_18Hz = mean(power_spectrums(1:max_index, :), 2);
% std_spectrum_up_to_18Hz = std(power_spectrums(1:max_index, :), 0, 2);
% 
% figure;
% plot(frequencies(1:max_index), mean_spectrum_up_to_18Hz); % Convert to dB
% hold on; 
% % plot(frequencies, 10*log10(mean_spectrum + std_spectrum), '--');
% % plot(frequencies, 10*log10(mean_spectrum - std_spectrum), '--');
% xlabel('Frequency (Hz)');
% ylabel('Power Spectrum (dB)');
% title('Mean Power Spectrum with Standard Deviation');
% legend('Mean Spectrum', 'Mean + Std', 'Mean - Std');
% 
% % Compute the cumulative sum of the power spectrum
% cumulative_spectrum = cumsum(mean_spectrum_up_to_18Hz);
% cumulative_spectrum = cumulative_spectrum / max(cumulative_spectrum);
% index_95_percent = find(cumulative_spectrum >= 0.95, 1, 'first');
% frequency_95_percent = frequencies(index_95_percent);
% disp(['The value before which 95% of the spectrum lies is: ', num2str(frequency_95_percent), ' Hz']);

% %% Fourier transform of the entire signal
% for rec = 1:num_recordings
%     for i = 1:8
%         data_struct{rec}.psData(i,:) = pspectrum(data_struct{rec}.rectData(i,:),fs)';
%     end 
% end
% 
% figure();
% for i=1:8
%     for rec = 1:4
%         freq = (0:length(data_struct{2*rec-1}.psData(i,:))-1) * fs / length(data_struct{2*rec-1}.psData(i,:));
%         if rec==4
%             subplot(2,4,i); loglog(freq, data_struct{2*rec-1}.psData(i,:).^2,'k--','LineWidth',1)
%         else  
%             subplot(2,4,i); loglog(freq,data_struct{2*rec-1}.psData(i,:), 'LineWidth', 2 , 'color',colors{rec}(3,:)), 
%             hold on 
%             freq = (0:length(data_struct{2*rec}.psData(i,:))-1) * fs / length(data_struct{2*rec}.psData(i,:));
%             subplot(2,4,i); loglog(freq,data_struct{2*rec}.psData(i,:), 'LineWidth', 1, 'color', colors{rec}(6,:))
%             xlabel('time(s)'), ylabel('EMG (µV)');
%         end 
%         title(titles_muscles(i));
%         ylabel("EMG Amplitude [µV]"); xlabel("Frequency (Hz)"),
%         hold on
%     end 
%     legend('50 Hz', '50Hz + vol', '80 Hz', '80Hz + vol', '20 Hz', '20Hz + vol', 'passive', 'passive + vol', 'passive + vol finale');
% end 
% 
% %% Fourier transform of the average cycle
% data_struct{rec}.psData = [];
% for rec = 1:num_recordings
%     for i = 1:8
%         data_struct{rec}.psAveragedCycle(i,:) = pspectrum(data_struct{rec}.averagedCycle(i,:),fs)';
%     end 
% end
% 
% figure();
% for i=1:8
%     for rec = 1:4
%         freq = (0:length(data_struct{2*rec-1}.psAveragedCycle(i,:))-1) * fs / length(data_struct{2*rec-1}.psAveragedCycle(i,:));
%         if rec==4
%             subplot(2,4,i); loglog(freq, data_struct{2*rec-1}.psAveragedCycle(i,:).^2,'k--','LineWidth',1)
%         else  
%             subplot(2,4,i); loglog(freq,data_struct{2*rec-1}.psAveragedCycle(i,:), 'LineWidth', 2 , 'color',colors{rec}(3,:)), 
%             hold on 
%             freq = (0:length(data_struct{2*rec}.psAveragedCycle(i,:))-1) * fs / length(data_struct{2*rec}.psAveragedCycle(i,:));
%             subplot(2,4,i); loglog(freq,data_struct{2*rec}.psAveragedCycle(i,:), 'LineWidth', 1, 'color', colors{rec}(6,:))
%             xlabel('time(s)'), ylabel('EMG (µV)');
%         end 
%         title(titles_muscles(i));
%         ylabel("EMG Amplitude [µV]"); xlabel("Frequency (Hz)"),
%         hold on
%     end 
%     legend('50 Hz', '50Hz + vol', '80 Hz', '80Hz + vol', '20 Hz', '20Hz + vol', 'passive', 'passive + vol', 'passive + vol finale');
% end 
