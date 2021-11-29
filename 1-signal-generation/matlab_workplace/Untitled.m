clc; clear; close all;

% Time base parameters
dt = 1e-6;              % Time scale: 1us
f = 1/dt;
T = 10e-3;              % Stop time: 10ms
t = 0 : dt : T-dt;      % Discrete time vector
N = length(t);          % Points
fv = (0:N/2-1)*1/dt/N;  % Discrete frequency vector

% pulse
fp = 1e3;
omega = 2*pi*fp;
pulse = 0.5*square(omega*t, 20) + 0.5;
subplot(3, 3, 1); plot(t.*1000, pulse); title('time domain');
xlabel('time / ms'); ylabel('Amplitude / V');
