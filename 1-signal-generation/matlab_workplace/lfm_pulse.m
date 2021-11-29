clc; clear; close all;

% Time base parameters
dt = 1e-6;              % Time scale: 1us
fs = 1/dt;              % Sampling frequency: 1Mhz
stop = 5e-3;            % Stop time: 5ms
t = 0 : dt : stop-dt;   % Discrete time vector
N = length(t);          % Points
fv = (0:N/2-1)*1/dt/N;  % Discrete frequency vector

% Linear FM pulse
A = 1;                  % Amplititude: 1V
f0 = 10e3;              % Carrier frequency: 10kHz
fshift = 100e3;         % Frequency shift: 100kHz
fm = 0.4e3;             % Modulation frequency: 40Hz

mod = (0.5*square(2*pi*fm*t, 50) + 0.5).*(2*sawtooth(2*pi*fm*t) + 1);
lfm = (0.5*square(2*pi*fm*t, 50) + 0.5).*vco(mod, [f0 f0+fshift], fs);
s = 20.*log10(abs(fft(lfm))./N);

subplot(4, 1, 1); plot(t.*1000, lfm); title('time domain');
xlabel('time / ms'); ylabel('Amplitude / V');
subplot(4, 1, 2); plot(t.*1000, mod); title('time domain');
xlabel('time / ms'); ylabel('Amplitude / V');
subplot(4, 1, 3);
pspectrum(lfm, fs, 'spectrogram', 'FrequencyLimits', [0, 120e3], 'FrequencyResolution', 10e3);
subplot(4, 1, 4); plot(fv./1000, s(1:N/2)); title('spectrum');
xlabel('frequency / kHz');  ylabel('Amplitude / dBV'); % set(gca, 'xscale', 'log');

% Gaussian distributed random noise
bw = 1e3;               % Bandwidth
k = 0.0001;             % Power spectral density
grn = wgn(1, N, k*bw, 'linear');

lfm_n = lfm + grn;
s_n = 20.*log10(abs(fft(lfm_n))./N);

figure;
subplot(2, 1, 1); plot(t.*1000, lfm_n); title('time domain');
xlabel('time / ms'); ylabel('Amplitude / V');
subplot(2, 1, 2); plot(fv./1000, s_n(1:N/2)); title('spectrum');
xlabel('frequency / kHz');  ylabel('Amplitude / dBV'); % set(gca, 'xscale', 'log');
