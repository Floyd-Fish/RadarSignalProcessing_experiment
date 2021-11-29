clc; clear; close all;

% Time base parameters
dt = 1e-6;              % Time scale: 1us
f = 1/dt;               % Sampling frequency: 1Mhz
T = 10e-3;              % Stop time: 10ms
t = 0 : dt : T-dt;      % Discrete time vector
N = length(t);          % Points
fv = (0:N/2-1)*1/dt/N;  % Discrete frequency vector

% Uniformly distributed random noise
a = -1; b = 1;
urn = (b - a)*rand(1, N) + a;
urnFftAbs = 20.*log10(abs(fft(urn))./N);

subplot(3, 3, 1); plot(t.*1000, urn); title('time domain');
xlabel('time / ms'); ylabel('Amplitude / V');
subplot(3, 3, 2); histogram(urn, 50); title('histogram');
xlabel('Amplitude / V'); ylabel('quantity');
subplot(3, 3, 3); plot(fv./1000, urnFftAbs(1:N/2)); title('spectrum');
xlabel('frequency / kHz');  ylabel('Amplitude / dBV'); % set(gca, 'xscale', 'log');

% Gaussian distributed random noise
bw = 1e3;               % Bandwidth
k = 0.0001;             % Power spectral density
grn = wgn(1, N, k*bw, 'linear');
grnFftAbs = 20.*log10(abs(fft(grn))./N);

subplot(3, 3, 4); plot(t.*1000, grn); title('time domain');
xlabel('time / ms'); ylabel('Amplitude / V');
subplot(3, 3, 5); histogram(grn, 50); title('histogram');
xlabel('Amplitude / V'); ylabel('quantity');
subplot(3, 3, 6); plot(fv./1000, grnFftAbs(1:N/2)); title('spectrum');
xlabel('frequency / kHz');  ylabel('Amplitude / dBV'); % set(gca, 'xscale', 'log');

% Rayleigh distributed random noise
rrn = raylrnd(1, 1, N);
dc = mean(rrn);
rrn = rrn - dc;
rrnFftAbs = 20.*log10(abs(fft(rrn))./N);

subplot(3, 3, 7); plot(t.*1000, rrn); title('time domain');
xlabel('time / ms'); ylabel('Amplitude / V');
subplot(3, 3, 8); histogram(rrn, 50); title('histogram');
xlabel('Amplitude / V'); ylabel('quantity');
subplot(3, 3, 9); plot(fv./1000, rrnFftAbs(1:N/2)); title('spectrum');
xlabel('frequency / kHz');  ylabel('Amplitude / dBV'); % set(gca, 'xscale', 'log');
