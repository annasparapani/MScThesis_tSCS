figure('Name','Forces on pedals');
for rec=1:num_recordings    
% Right 
    numSamples = length(importData{rec}.xR) - triggerLocsRight{rec}(2)+1;
    xAxis=[]; xAxis = linspace(0,180, numSamples);
    angle = importData{rec}.rightAngle(triggerLocsRight{rec}(2):end); 
    force = importData{rec}.rightForce(triggerLocsRight{rec}(2):end);
    subplot(2,1,1), 
    hold on
    movAvgForce = movmean(force,30*(numSamples/100));
    if rec==1   plot(xAxis,movAvgForce, 'r', 'LineWidth',2); 
    else  plot(xAxis,movAvgForce,'LineWidth',1);
    end
    title('Forces on left pedal')
    legend('Passive MA', '50Hz + vol MA', '50Hz MA', '80Hz + vol MA', ...
        '80Hz MA', '20Hz + vol MA','20Hz MA');
end 
 

for rec=1:num_recordings    
% Left 
    numSamples = length(importData{rec}.xL) - triggerLocsLeft{rec}(2)+1;
    xAxis=[]; xAxis = linspace(0,180, numSamples);
    angle = importData{rec}.leftAngle(triggerLocsLeft{rec}(2):end); 
    force = importData{rec}.leftForce(triggerLocsLeft{rec}(2):end);
    subplot(2,1,2), 
    hold on
    movAvgForce = movmean(force,30*(numSamples/100));
    if rec==1   plot(xAxis,movAvgForce, 'r', 'LineWidth',2); 
    else  plot(xAxis,movAvgForce, 'LineWidth',1);
    end
    title('Forces on left pedal')
    legend('Passive MA', '50Hz + vol MA', '50Hz MA', '80Hz + vol MA', ...
        '80Hz MA', '20Hz + vol MA','20Hz MA');
end 
