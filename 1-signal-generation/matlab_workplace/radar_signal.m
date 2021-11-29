clc; clear; close all;

% LFM parameter
B       =   4e+6;       % Bandwidth: 4MHz
Tao     =   200e-6;     % Time width: 200us
T       =   2e-3;       % Pulse repeats period: 2ms
fs      =   8e+6;       % Sampling frequency
SNR     =   20;         % SNR: 20dB
dis     =   T*fs/2;     % Target position: middle

% Generate LFM
t = -round(Tao*fs/2) : 1 : round(Tao*fs/2)-1; 
lfm = (10^(SNR/20))*exp(1i*pi*B/Tao*(t/fs).^2);

figure;
subplot(2, 1, 1); plot(real(lfm), 'b'); title('Real part of LFM');
subplot(2, 1, 2); plot(imag(lfm), 'r'); title('Image part of LFM');

% Generate echo
echo  = zeros(1, T*fs);
echo(dis : 1 : dis+Tao*fs-1) = lfm;
noise = normrnd(0, 1, 1, T*fs) + 1i*normrnd(0, 1, 1, T*fs);
echo = echo + noise;

figure;
subplot(2, 1, 1); plot(real(echo), 'b'); title('Real part of echo');
subplot(2, 1, 2); plot(imag(echo), 'r'); title('Image part of echo');
