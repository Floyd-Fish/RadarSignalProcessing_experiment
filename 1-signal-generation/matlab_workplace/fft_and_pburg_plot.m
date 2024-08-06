Fs = 32e3;   
t = 0:1/Fs:2.96;
x = cos(2*pi*t*1.24e3)+ cos(2*pi*t*10e3)+ randn(size(t));
nfft = 2^nextpow2(length(x));
Pxx = abs(fft(x,nfft)).^2/length(x)/Fs;
Hpsd = PBURG(Pxx,'Fs',Fs,'SpectrumType','twosided');
plot(Hpsd)
