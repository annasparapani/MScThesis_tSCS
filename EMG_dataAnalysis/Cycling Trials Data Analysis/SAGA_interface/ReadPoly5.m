%EXAMPLE - Read a Poly5 file
%   Reading Poly5 example

clear all
close all 
clc

data = TMSiSAGA.Poly5.read('Example.poly5'); 


for n=1:10
    s(n,:)=data.samples(n,:);
end 

Fs_EMG=4000; %Hz

fcutlow=10; %Hz
fcuthigh=500;  %Hz
[B,A]=butter(5,[fcutlow,fcuthigh]/(Fs_EMG/2),'bandpass');
for n=1:10 
    fs(n,:)= filtfilt(B,A,s(n,:));
end 


d1=s(2,:)-s(1,:); 
d2=s(4,:)-s(3,:); 
d3=s(6,:)-s(5,:); 
d4=s(8,:)-s(7,:); 
d5=s(10,:)-s(9,:); 

ds(1,:)= filtfilt(B,A,d1);
ds(2,:)= filtfilt(B,A,d2);
ds(3,:)= filtfilt(B,A,d3);
ds(4,:)= filtfilt(B,A,d4);
ds(5,:)= filtfilt(B,A,d5);


figure
subplot(221)
plot(fs(1,:)) 
hold on
plot(fs(2,:)) 

subplot(223)
plot(ds(1,:))

subplot(222)
plot(fs(9,:)) 
hold on
plot(fs(10,:)) 

subplot(224)
plot(ds(5,:))


figure
hold on
plot(ds(1,:))
plot(ds(5,:))


figure
hold on
for n=1:10
plot(fs(n,:))
end
legend('c1','c2','c3','c4','c5','c6','c7','c8','c9','c10')  







