function plotMwave(titleStr, MwaveArray, Frequency)
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
        % Plot a band around the average value (±0.025)
        hold on;
        fill([timeArray, fliplr(timeArray)], [ones(size(timeArray))*(avg_value + 0.025), fliplr(ones(size(timeArray))*(avg_value - 0.025))], 'y', 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        
        % Add a red horizontal line at y = 0.05
        hold on;
        yline(0.05, 'r', 'LineWidth', 1.5);

        % Set y-axis limits to maximum + 0.1
        ylim([min(MwaveArray(i,:)-0.1) max(MwaveArray(i,:))+0.1]) % y limit scaled to the graph values

        hold off;
    end
end
