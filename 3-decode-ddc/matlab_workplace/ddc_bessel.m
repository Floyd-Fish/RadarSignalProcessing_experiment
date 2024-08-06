clc; clear; close all;

% Time base parameters -------------------------------------------------- %
fs = 1e6;               % Sampling frequency: 1Mhz
dt = 1/fs;              % Time scale
N = 4000;               % Points
tv = 0:dt:(N-1)*dt;     % Discrete time vector
fv = (0:N/2-1)*1/dt/N;  % Discrete frequency vector

% Modulation ------------------------------------------------------------ %
fb = 5e3;               % Base frequency: 5kHz
fc = 50e3;              % Carrier frequency: 50kHz
sCCos = cos(2*pi*fc*tv);% Q modulator
scSin = sin(2*pi*fc*tv);% I modulator

% Single tone ----------------------------------------------------------- %
sBaseQ = cos(2*pi*fb*tv);
sBaseI = sin(2*pi*fb*tv);

% Single tone pulse ----------------------------------------------------- %
fp = 1e3;
pulse = square(2*pi*fp*tv, 50)*0.5 + 0.5;
sBaseQ = pulse.*cos(2*pi*fb*tv);
sBaseI = pulse.*sin(2*pi*fb*tv);

% Linear FM pulse ------------------------------------------------------- %
A = 1;                  % Amplititude: 1V
f0 = 1e3;               % Carrier frequency: 1kHz
fshift = 10e3;          % Frequency shift: 10kHz
fm = 0.4e3;             % Modulation frequency: 40Hz

mod = (0.5*square(2*pi*fm*tv, 50) + 0.5).*(2*sawtooth(2*pi*fm*tv) + 1);
lfm = (0.5*square(2*pi*fm*tv, 50) + 0.5).*vco(mod, [f0 f0+fshift], fs);
sBaseQ = lfm;
sBaseI = lfm;

% BPSK pulse ------------------------------------------------------------ %
A = 1;                  % Amplititude: 1V
fc = 5e3;               % Carrier frequency: 5kHz
Rb = 1e3;               % Baudrate: 1kbps

code = '1101010001';

cellv = 0:dt:(N/length(code)-1)*dt;
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

sBaseQ = bpsk;
sBaseI = bpsk;

% Modulation ------------------------------------------------------------ %
sMod = sBaseQ.*sCCos + sBaseI.*scSin;
sModFftAbs = abs(fft(sMod))./(N/2);

figure;
subplot(6, 1, 1); plot(tv.*1000, sBaseQ, 'B', tv.*1000, sBaseI, 'R'); title('base');
xlabel('time / ms'); ylabel('Amplitude / V');
subplot(6, 1, 2); plot(tv.*1000, sMod); title('modulation');
xlabel('time / ms'); ylabel('Amplitude / V');
subplot(6, 1, 3); plot(fv./1000, sModFftAbs(1:N/2)); title('spectrum');
xlabel('frequency / kHz');  ylabel('Amplitude / dBV'); % set(gca, 'xscale', 'log');

% Demodulation ---------------------------------------------------------- %
% fo = 50kHz, B = 10kHz, defs > 2B
% defs = 4fo/(2m-1), defs = 200kHz, m = 1
% Odd: (-1)^m(-1)^((n+1)/2)Qn
% Even: (-1)^(n/2)In

rfs = 200e3;                % Resampling frequency: 200kHz
rdt = 1/rfs;
rRatio = fs/rfs;
rN = N/rRatio;
rtv = 0:rdt:(rN-1)*rdt;     % Discrete time vector
rfv = (0:rN/2-1)*1/rdt/rN;  % Discrete frequency vector

rSMod = resample(sMod, rfs, fs);
rSModFftAbs = abs(fft(rSMod))./(rN/2);

subplot(6, 1, 4); plot(rtv.*1000, rSMod); title('Resampling');
xlabel('time / ms'); ylabel('Amplitude / V');
subplot(6, 1, 5); plot(rfv./1000, rSModFftAbs(1:rN/2)); title('spectrum');
xlabel('frequency / kHz');  ylabel('Amplitude / dBV'); % set(gca, 'xscale', 'log');

rSSign = rSMod;
for i = 1 : rN/2
    j = 2*i-1;
    rSSign(j) = rSMod(j) / (-1)^((j-1)/2);
    j = 2*i;
    rSSign(j) = rSMod(j) / (-1)*(-1)^((j)/2);
end

rSSignZero = [zeros(1, 4), rSSign, zeros(1, 3)];
deBaseQ = zeros(1, rN/2);
deBaseI = zeros(1, rN/2);

for i = 1 : rN/2
    j = 2*(i-1);
    deBaseI(i) = rSSignZero(j+4);
    deBaseQ(i) = ((-1)*rSSignZero(j+1) ...
                   + 9*rSSignZero(j+3) ...
                   + 9*rSSignZero(j+5) ...
                 +(-1)*rSSignZero(j+7))/16;
end

subplot(6, 1, 6); plot(rtv(1:rN/2).*1000, deBaseQ, 'B', rtv(1:rN/2).*1000, deBaseI, 'R'); title('Demodulation');
xlabel('time / ms'); ylabel('Amplitude / V');

sRBaseQ = resample(sBaseQ, rfs/2, fs);
sRBaseI = resample(sBaseI, rfs/2, fs);
corrQ = corrcoef(sRBaseQ, deBaseQ);
corrI = corrcoef(sRBaseI, deBaseI);

figure;
subplot(2, 1, 1);
plot(tv.*1000, sBaseQ, 'B', tv.*1000, sBaseI, 'R'); title('base');
xlabel('time / ms'); ylabel('Amplitude / V');
subplot(2, 1, 2);
plot(rtv(1:rN/2).*1000, deBaseQ, 'B', rtv(1:rN/2).*1000, deBaseI, 'R'); title('Demodulation');
xlabel('time / ms'); ylabel('Amplitude / V');
