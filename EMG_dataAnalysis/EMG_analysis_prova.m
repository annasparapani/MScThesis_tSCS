%% TITLE: EMG data analysis for tSCS 
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
[filename, pathname, filterindex] = uigetfile('*.mat', 'Pick a MATLAB  file');
load(filename)

EMG=[];
%x=EMGdata.signals.values; %save EMG values in variable x

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

% Draw plots of raw data
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

%% Frequency plots
% [pxx,fx]=pwelch(x(:,1),[],[],[],Fs_EMG);
% figure()
% plot(fx,pxx);
% -> seems to give no information, can we remove it?

%% Signal processing

% Filtering
fcutlow=10;   
fcuthigh=250;   
[z,p,k]=butter(4,[fcutlow,fcuthigh]/(Fs_EMG/2),'bandpass');
[sos,g]=zp2sos(z,p,k); %apply filter to signal
x_filt(:,:) = filtfilt(sos,g,x(:,:));
[b, a] = sos2tf(sos, g); % Extract coefficients
xfilter = filter(b, a, x_filt(:,:)); %apply filter
[pff,ff]=pwelch(xfilter(:,1),[],[],[],Fs_EMG);

% Filtered graphs
figure()
% subplot(2,1,1), plot(time,xfilter(:,1)), ylabel('mV'), xlabel('s'), grid off, title(' DX Quad')
% subplot(2,1,2), plot(time,xfilter(:,2)), ylabel('mV'), xlabel('s'), grid off, title(' DX TA')

title('Right Leg')
subplot(4,1,1), plot(time,xfilter(:,1)), ylabel('mV'), xlabel('s'), grid off, title(' DX Quad'); %17
subplot(4,1,2), plot(time,xfilter(:,2)), ylabel('mV'),xlabel('s'), grid off, title('DX Hamstring'); %18
subplot(4,1,3), plot(time,xfilter(:,3)), ylabel('mV'), xlabel('s'), grid off, title(' DX Gast'); %17
subplot(4,1,4), plot(time,xfilter(:,4)), ylabel('mV'),xlabel('s'), grid off, title('DX TA'); %18
 
figure()
title('Left Leg')
subplot(4,1,1), plot(time,xfilter(:,5)), ylabel('mV'), xlabel('s'), grid off, title('SX Quad'); %17
subplot(4,1,2), plot(time,xfilter(:,6)), ylabel('mV'),xlabel('s'), grid off, title('SX Hamstring'); %18
subplot(4,1,3), plot(time,xfilter(:,7)), ylabel('mV'), xlabel('s'), grid off, title('SX Gast'); %17
subplot(4,1,4), plot(time,xfilter(:,8)), ylabel('mV'),xlabel('s'), grid off, title('SX TA'); %18  

%% Peaks detection
% Right leg
[pk1,locs1] = findpeaks(xfilter(:,1),"MinPeakDistance",300,"MinPeakHeight",0.1);
 quad_dx=xfilter(:,1);
[pk2,locs2] = findpeaks(xfilter(:,2),"MinPeakDistance",300,"MinPeakHeight",0.1);
 hams_dx=xfilter(:,2);
[pk3,locs3] = findpeaks(xfilter(:,3),"MinPeakDistance",300,"MinPeakHeight",0.01);
gast_dx=xfilter(:,3);
[pk4,locs4] = findpeaks(xfilter(:,4),"MinPeakDistance",1000,"MinPeakHeight",0.01);
ta_dx=xfilter(:,4);

% Left leg
[pk5,locs5] = findpeaks(xfilter(:,5),"MinPeakDistance",300,"MinPeakHeight",0.01);
  quad_sx=xfilter(:,5);
[pk6,locs6] = findpeaks(xfilter(:,6),"MinPeakDistance",300,"MinPeakHeight",0.2);
  hams_sx=xfilter(:,6);
[pk7,locs7] = findpeaks(xfilter(:,7),"MinPeakDistance",300,"MinPeakHeight",0.2);
  gast_sx=xfilter(:,7);
[pk8,locs8] = findpeaks(xfilter(:,8),"MinPeakDistance",1000,"MinPeakHeight",0.05);
  ta_sx=xfilter(:,8);

figure()
title('Right Leg - filtered')
subplot(4,1,1), plot(quad_dx), hold on, plot (locs1,pk1,'o'), ylabel('mV'), title(' DX Quad'); %17
subplot(4,1,2), plot(hams_dx), hold on, plot (locs2,pk2,'o'), ylabel('mV'), title(' DX Hams');
subplot(4,1,3), plot(gast_dx), hold on, plot (locs3,pk3,'o'), ylabel('mV'), title(' DX Gast');
subplot(4,1,4), plot(ta_dx), hold on, plot (locs4,pk4,'o'), ylabel('mV'), title(' DX TA');

figure()
title('Left Leg - filtered')
subplot(4,1,1), plot(quad_sx), hold on, plot (locs5,pk5,'o'), ylabel('mV'), title(' SX Quad'); %17
subplot(4,1,2), plot(hams_sx), hold on, plot (locs6,pk6,'o'), ylabel('mV'), title(' SX Hams');
subplot(4,1,3), plot(gast_sx), hold on, plot (locs7,pk7,'o'), ylabel('mV'), title(' SX Gast');
subplot(4,1,4), plot(ta_sx), hold on, plot (locs8,pk8,'o'), ylabel('mV'), title(' SX TA');

%% M waves detection
startIdx1 = locs1 +6 ; %7 samples di artefatto
startIdx2 = locs2 +3; %+ 3;
startIdx3 = locs3 -15;
startIdx4 = locs4 -15;
duration_quad = 52;
duration_hams = 52; %15ms di latenza + 35ms di Mwave (1024Hz*50ms=57samples)

% Right Leg M-wave
Mwaves1 = [];
for i = 1: length(startIdx1-1) 
    Mwaves1(i, :) = quad_dx(startIdx1(i): startIdx1(i)+duration_quad);
end
Mwaves2 = [];
for i = 1: length(startIdx2) 
    Mwaves2(i, :) = hams_dx(startIdx2(i): startIdx2(i)+duration_hams);
end
Mwaves3 = [];
for i = 1: length(startIdx3) 
    Mwaves3(i, :) = gast_dx(startIdx3(i): startIdx3(i)+duration_quad);
end
Mwaves4 = [];
for i = 1: length(startIdx4) 
    Mwaves4(i, :) = ta_dx(startIdx4(i): startIdx4(i)+duration_hams);
end

% Right Leg M-wave
Mwaves5 = [];
for i = 1: length(startIdx1) 
    Mwaves5(i, :) = quad_sx(startIdx1(i): startIdx1(i)+duration_quad);
end
Mwaves6 = [];
for i = 1: length(startIdx2) 
    Mwaves6(i, :) = hams_sx(startIdx2(i): startIdx2(i)+duration_hams);
end
Mwaves7 = [];
for i = 1: length(startIdx3) 
    Mwaves7(i, :) = gast_sx(startIdx3(i): startIdx3(i)+duration_quad);
end
Mwaves8 = [];
for i = 1: length(startIdx4) 
    Mwaves8(i, :) = ta_sx(startIdx4(i): startIdx4(i)+duration_hams);
end

time_Quad=(0:1/Fs_EMG:length(Mwaves1)/Fs_EMG-1/Fs_EMG)*1000; %ms
time_Hams=(0:1/Fs_EMG:length(Mwaves2)/Fs_EMG-1/Fs_EMG)*1000;

close all
% M-WAVES GRAPHS
figure()
%Mwaves1=Mwaves1'; % transposing otherwise it doesn't work -> check!
for i=1:10
    subplot(2,5,i)
    plot(time_Quad,Mwaves1(i,:))
    grid on
    title('M wave Quad DX')
    ylabel ('mV')
    xlabel('ms')
end

% figure() % M wave Hams DX
% for i=1:10
%     subplot(2,5,i)
%     plot(time_Hams,Mwaves2(i,:))
%     grid on
%     title('M wave Hams DX')
%     ylabel ('mV')
%     xlabel('ms')
% end
% 
% figure() % M wave GAST D
% for i=1:10
%     subplot(2,5,i)
%     plot(time_Quad,Mwaves3(i,:))
%     grid on
%     title('M wave GAST DX')
%     ylabel ('mV')
%     xlabel('ms')
% end
% 
% figure() % M wave TA DX
% for i=1:10
%     subplot(2,5,i)
%     plot(time_Hams,Mwaves4(i,:))
%     title('M wave TA DX')
%     grid on    
%     ylabel ('mV')
%     xlabel('ms')
% end
% 
% figure() % M wave Quad SX
% for i=1:10
%     subplot(2,5,i)
%     plot(time_Quad,Mwaves5(i,:))
%     grid on
%     title('M wave Quad SX')
%     ylabel ('mV')
%     xlabel('ms')
% end
% 
% figure() % M wave Hams SX
% for i=1:10
%     subplot(2,5,i)
%     plot(time_Hams,Mwaves6(i,:))
%     grid on
%     title('M wave Hams SX')
%     ylabel ('mV')
%     xlabel('ms')
% end
% 
% figure() % M wave GAST SX
% for i=1:10
%     subplot(2,5,i)
%     plot(time_Quad,Mwaves7(i,:))
%     grid on
%     title('M wave GAST SX')
%     ylabel ('mV')
%     xlabel('ms')
% end
% 
% figure() % M wave TA SX
% for i=1:10
%     subplot(2,5,i)
%     plot(time_Hams,Mwaves8(i,:))
%     title('M wave TA SX')
%     grid on    
%     ylabel ('mV')
%     xlabel('ms')
% end
 
%% M waves peaks detection
s=struct('W1',Mwaves1,'W2',Mwaves2,'W3',Mwaves3,'W4',Mwaves4); %'W5',Mwaves5,'W6',Mwaves6,'W7',Mwaves7,'W8',Mwaves8);
% maxima 
M1=max(s.W1,[],2);
% M2=max(s.W2,[],2);
% M3=max(s.W3,[],2);
% M4=max(s.W4,[],2);
% M5=max(s.W5,[],2);
% M6=max(s.W6,[],2);
% M7=max(s.W7,[],2);
% M8=max(s.W8,[],2);

% minima
m1=min(s.W1,[],2);
% m2=min(s.W2,[],2);
% m3=min(s.W3,[],2);
% m4=min(s.W4,[],2);
% m5=min(s.W5,[],2);
% m6=min(s.W6,[],2);
% m7=min(s.W7,[],2);
% m8=min(s.W8,[],2);

%ampiezza
tot1=M1-m1;
% tot2=M2-m2;
% tot3=M3-m3;
% tot4=M4-m4;
% tot5=M5-m5;
% tot6=M6-m6;
% tot7=M7-m7;
% tot8=M8-m8;

%indici
n1=0; n2=0; n3=0; n4=0;

for i=1:10
    if(tot1(i)>=0.05) 
        n1=n1+1;
    end
%     if(tot2(i)>=0.05) 
%         n2=n2+1;
%     end
%     if(tot3(i)>=0.05) 
%         n3=n3+1;
%     end
%     if(tot4(i)>=0.05) 
%         n4=n4+1;
%     end
%     if(tot5(i)>=0.05) 
%         n5=n5+1;
%     end
%     if(tot6(i)>=0.05) 
%         n6=n6+1;
%     end
%     if(tot7(i)>=0.05) 
%         n7=n7+1;
%     end
%     if(tot8(i)>=0.05) 
%         n8=n8+1;
%     end
end

n1=(n1/length(m1))*100;  
% n2=(n2/length(m1))*100; 
% n3=(n3/length(m1))*100; 
% n4=(n4/length(m1))*100; 
% n5=(n5/length(m1))*100;  
% n6=(n6/length(m1))*100; 
% n7=(n7/length(m1))*100; 
% n8=(n8/length(m1))*100; 

formatSpec1="N° of Mwave above 50uV is %4.2f/100 for Quad Dx\n";
% formatSpec2="N° of Mwave above 50uV is %4.2f/100 for Hams Dx\n";
% formatSpec3="N° of Mwave above 50uV is %4.2f/100 for Gast Dx\n";
% formatSpec4="N° of Mwave above 50uV is %4.2f/100 for TA Dx\n\n";
% formatSpec5="N° of Mwave above 50uV is %4.2f/100 for Quad Sx\n";
% formatSpec6="N° of Mwave above 50uV is %4.2f/100 for Hams Sx\n";
% formatSpec7="N° of Mwave above 50uV is %4.2f/100 for Gast Sx\n";
% formatSpec8="N° of Mwave above 50uV is %4.2f/100 for TA Sx\n";

fprintf(formatSpec1,n1);
% fprintf(formatSpec2,n2);
% fprintf(formatSpec3,n3);
% fprintf(formatSpec4,n4);
% fprintf(formatSpec5,n5);
% fprintf(formatSpec6,n6);
% fprintf(formatSpec7,n7);
% fprintf(formatSpec8,n8);

% s1= struct('W5',Mwaves5,'W6',Mwaves6,'W7',Mwaves7,'W8',Mwaves8);
% 
% M5=max(s1.W5,[],2);
% M6=max(s1.W6,[],2);
% M7=max(s1.W7,[],2);
% M8=max(s1.W8,[],2);

%minima
% m5=min(s1.W5,[],2);
% m6=min(s1.W6,[],2);
% m7=min(s1.W7,[],2);
% m8=min(s1.W8,[],2);

%ampiezza
% tot5=M5-m5;
% tot6=M6-m6;
% tot7=M7-m7;
% tot8=M8-m8;

%indexes
% n5=0; n6=0; n7=0; n8=0;
% 
% for i=1:10
% 
%     if(tot5(i)>=0.05) 
%         n5=n5+1;
%     end
%     if(tot6(i)>=0.05) 
%         n6=n6+1;
%     end
%     if(tot7(i)>=0.05) 
%         n7=n7+1;
%     end
%     if(tot8(i)>=0.05) 
%         n8=n8+1;
%     end
% end
% 
% n5=(n5/length(m1))*100;  
% n6=(n6/length(m1))*100; 
% n7=(n7/length(m1))*100; 
% n8=(n8/length(m1))*100; 
% 
% 
% formatSpec5="N° of Mwave above 50uV is %4.2f/100 for Quad Sx\n";
% formatSpec6="N° of Mwave above 50uV is %4.2f/100 for Hams Sx\n";
% formatSpec7="N° of Mwave above 50uV is %4.2f/100 for Gast Sx\n";
% formatSpec8="N° of Mwave above 50uV is %4.2f/100 for TA Sx\n";
% 
% fprintf(formatSpec5,n5);
% fprintf(formatSpec6,n6);
% fprintf(formatSpec7,n7);
% fprintf(formatSpec8,n8);