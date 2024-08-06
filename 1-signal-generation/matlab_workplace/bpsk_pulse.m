clc; clear; close all;

% Time base parameters
dt = 1e-6;              % Time scale: 1us
fs = 1/dt;              % Sampling frequency: 1Mhz
stop = 5e-3;            % Stop time: 5ms
t = 0 : dt : stop-dt;   % Discrete time vector
N = length(t);          % Points
fv = (0:N/2-1)*1/dt/N;  % Discrete frequency vector

% BPSK pulse
A = 1;                  % Amplititude: 1V
fc = 10e3;              % Carrier frequency: 5kHz
Rb = 1e3;               % Baudrate: 1kbps

code = '1101010001';

cellv = 0 : dt : stop/length(code)-dt;
cellp =  cos(2*pi*fc*cellv);
celln = -cos(2*pi*fc*cellv);
mod = zeros(1, N);
bpsk = zeros(1, N);

for i = 1 : length(code)
    temp = str2num(code(i));
    for j = 1 : length(cellv)
        if temp == 0
            bpsk(1, (i - 1)*length(cellv) + j) =  celln(1, j);
            mod(1, (i - 1)*length(cellv) + j) = -1;
        else
            bpsk(1, (i - 1)*length(cellv) + j) =  cellp(1, j);
            mod(1, (i - 1)*length(cellv) + j) = 1;
        end
    end
end

s = 20.*log10(abs(fft(bpsk))./N);

subplot(3, 1, 1); plot(t.*1000, mod, 'LineWidth', 2); title('time domain');
xlabel('time / ms'); ylabel('Amplitude / V');
subplot(3, 1, 2); plot(t.*1000, bpsk, 'LineWidth', 2); title('time domain');
xlabel('time / ms'); ylabel('Amplitude / V');
subplot(3, 1, 3); plot(fv./1000, s(1:N/2)); title('spectrum');
xlabel('frequency / kHz');  ylabel('Amplitude / dBV'); % set(gca, 'xscale', 'log');

% Gaussian distributed random noise
bw = 1e3;               % Bandwidth
k = 0.0001;             % Power spectral density
grn = wgn(1, N, k*bw, 'linear');

bpsk_n = bpsk + grn;
s_n = 20.*log10(abs(fft(bpsk_n))./N);

figure;
subplot(2, 1, 1); plot(t.*1000, bpsk_n); title('time domain');
xlabel('time / ms'); ylabel('Amplitude / V');
subplot(2, 1, 2); plot(fv./1000, s_n(1:N/2)); title('spectrum');
xlabel('frequency / kHz');  ylabel('Amplitude / dBV'); % set(gca, 'xscale', 'log');
