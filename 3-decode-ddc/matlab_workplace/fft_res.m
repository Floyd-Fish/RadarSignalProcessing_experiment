clc; clear; close all;

% Time base parameters
fs = 1e6;                       % Sampling frequency: 1Mhz
dt = 1/fs;                      % Time scale
N = 4000;                       % Points
fftN = 4096;                    % FFT points
t = 0 : dt : (N-1)*dt;          % Discrete time vector
tv = 0 : dt : (fftN-1)*dt;          % Discrete time vector
fv = (0:fftN/2-1)*1/dt/fftN;    % Discrete frequency vector

% Signal
f1 = 10e3;
f2 = 20e3;
fftPoints = 4096;

sgn1 = cos(2*pi*f1*t);
sgn2 = cos(2*pi*f2*t);
sgn = sgn1 + sgn2;
sgn = [sgn, zeros(1, fftPoints-N)];

sgnFftAbs = abs(fft(sgn))./(N/2);

subplot(2, 1, 1); plot(tv.*1000, sgn); title('time domain');
xlabel('time / ms'); ylabel('Amplitude / V');
subplot(2, 1, 2); plot(fv./1000, sgnFftAbs(1:fftN/2)); title('spectrum');
xlabel('frequency / kHz');  ylabel('Amplitude / dBV'); % set(gca, 'xscale', 'log');
