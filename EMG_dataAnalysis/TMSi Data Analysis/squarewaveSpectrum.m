% Parameters
Fs = 1000;              % Sampling frequency (Hz)
f = 20;                 % Frequency of the biphasic square wave (Hz)
pulse_width = 0.001;    % Pulse width (s)
t = 0:1/Fs:1;           % Time vector

% Generate biphasic square wave
biphasic_square_wave = square(2*pi*f*t, 50);
biphasic_square_wave = biphasic_square_wave-mean(biphasic_square_wave);


% Plot biphasic square wave in the time domain
figure;
subplot(2,1,1);
plot(t, biphasic_square_wave);
title('Biphasic Square Wave in Time Domain');
xlabel('Time (s)'); ylabel('Amplitude');
ylim([-2,2]);
% Compute and plot spectrum
L = length(biphasic_square_wave);
Y = fft(biphasic_square_wave);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
frequencies = Fs*(0:(L/2))/L;

subplot(2,1,2);
plot(frequencies, P1);
title('Single-Sided Amplitude Spectrum');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

