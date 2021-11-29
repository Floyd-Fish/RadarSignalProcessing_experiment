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

% FIR LowPass Filter Design 
Fs = fs; 
Fpass = 10e3;
Fstop = 15e3;
Ap = 1;
Ast = 60;

d = designfilt('lowpassfir','PassbandFrequency',Fpass,...
  'StopbandFrequency',Fstop,'PassbandRipple',Ap,...
  'StopbandAttenuation',Ast,'SampleRate',Fs);

grpdelay(d,2048,Fs) 

% Apply FIR Filter to noise signal and compensate for delay cycles.
bpsk_n_f = filter(d.Coefficients, 1, [bpsk_n zeros(1,197)]);
bpsk_n_f = bpsk_n_f(197+1:end);
%bpsk_n_f = [bpsk_n_f zeros(1,197)];
%fvtool(d,'Analysis','impulse')

s_n_f = 20.*log10(abs(fft(bpsk_n_f))./N);

snr_n = -20*log10(norm(abs(bpsk_n - bpsk)) / norm(bpsk));
snr_n_f = -20*log10(norm(abs(bpsk_n_f - bpsk)) / norm(bpsk));

figure;
subplot(5, 1, 1); plot(t.*1000, bpsk_n); title('time domain');
xlabel('time / ms'); ylabel('Amplitude / V');
subplot(5, 1, 2); plot(fv./1000, s_n(1:N/2)); title('spectrum');
xlabel('frequency / kHz');  ylabel('Amplitude / dBV'); % set(gca, 'xscale', 'log');

subplot(5, 1, 3); plot(t.*1000, bpsk_n_f); title('filtered');
xlabel('time / ms'); ylabel('Amplitude / V');
subplot(5, 1, 4); plot(t.*1000, mod, 'LineWidth', 2); title('time domain');
xlabel('time / ms'); ylabel('Amplitude / V');

subplot(5, 1, 5); plot(fv./1000, s_n_f(1:N/2)); title('filtered spectrum');
xlabel('frequency / kHz');  ylabel('Amplitude / dBV'); % set(gca, 'xscale', 'log');

% Calculate Signal to Noise Ratio
r_origin = snr(bpsk_n, grn);
r_filtered = snr(bpsk_n_f, grn);

