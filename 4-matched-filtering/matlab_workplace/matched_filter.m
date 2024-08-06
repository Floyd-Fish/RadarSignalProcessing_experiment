waveform = phased.LinearFMWaveform('PulseWidth',1e-4,'PRF',5e3,...
    'SampleRate',1e6,'OutputFormat','Pulses','NumPulses',1,...
    'SweepBandwidth',1e5);          %   Generate LFM Waveform
wav = getMatchedFilter(waveform);

filter = phased.MatchedFilter('Coefficients',wav);
taylorfilter = phased.MatchedFilter('Coefficients',wav,...
    'SpectrumWindow','Taylor');     %   Generate Taylor-Windowed Matched filter
hammingfilter = phased.MatchedFilter('Coefficients', wav, ...
    'SpectrumWindow', 'Hamming');   %   Generate Hamming-Windowed Matched filter
kaiserfilter = phased.MatchedFilter('Coefficients', wav, ...
    'SpectrumWindow', 'Kaiser');   %   Generate Kaiser-Windowed Matched filter


%   Generate Noisy LFM Waveform
sig = waveform();
rng(17)
x = sig + 0.5*(randn(length(sig),1) + 1j*randn(length(sig),1));

%   Apply matched-filter to noisy LFM waveform
y = filter(x);
%   Apply Taylor-Windowed matched filter to noisy LFM waveform
y_taylor = taylorfilter(x);

y_hamming = hammingfilter(x);
y_kaiser  = kaiserfilter(x);

t = linspace(0,numel(sig)/waveform.SampleRate,...
    waveform.SampleRate/waveform.PRF);

figure;
subplot(2,1,1)
plot(t,real(sig))
title('Input Signal')
xlim([0 max(t)])
grid on
ylabel('Amplitude')
subplot(2,1,2)
plot(t,real(x))
title('Input Signal + Noise')
xlim([0 max(t)])
grid on
xlabel('Time (sec)')
ylabel('Amplitude')

figure;

plot(t,abs(y),'b--')
title('Matched Filter Output')
xlim([0 max(t)])
grid on
hold on
plot(t,abs(y_taylor),'r-')
plot(t, abs(y_hamming), 'g-')
plot(t, abs(y_kaiser), 'k-')
ylabel('Magnitude')
xlabel('Seconds')
legend('No Spectrum Weighting','Taylor Window', 'Hamming Window', 'Kaiser Window')
hold off