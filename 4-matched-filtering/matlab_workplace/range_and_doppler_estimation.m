fc = 3e9;
fs = 1e6;
c = physconst('LightSpeed');

antenna = phased.IsotropicAntennaElement('FrequencyRange',[1e8 10e9]);
transmitter = phased.Transmitter('Gain',20,'InUseOutputPort',true);
txloc = [0;0;0];
tgtloc = [5000;5000;0]; % Radial Dist ~= 7071 m
tgtvel = [25;25;0]; % Radial Speed ~= 35.4 m/s
target = phased.RadarTarget('Model','Nonfluctuating','MeanRCS',1,'OperatingFrequency',fc);
antennaplatform = phased.Platform('InitialPosition',txloc);
targetplatform = phased.Platform('InitialPosition',tgtloc,'Velocity',tgtvel);
radiator = phased.Radiator('PropagationSpeed',c,...
   'OperatingFrequency',fc,'Sensor',antenna);
channel = phased.FreeSpace('PropagationSpeed',c,...
   'OperatingFrequency',fc,'TwoWayPropagation',false);
collector = phased.Collector('PropagationSpeed',c,...
   'OperatingFrequency',fc,'Sensor',antenna);
receiver = phased.ReceiverPreamp('NoiseFigure',0,...
   'EnableInputPort',true,'SeedSource','Property','Seed',2e3);

waveform = phased.LinearFMWaveform('PulseWidth',10e-6,'PRF',10e3,'OutputFormat','Pulses','NumPulses',1,'SweepBandwidth',1e5);
wav = waveform();
c = physconst('LightSpeed');
maxrange = c/(2*waveform.PRF);
SNR = npwgnthresh(1e-6,1,'noncoherent');
lambda = c/fs;
tau = waveform.PulseWidth;
Ts = 290;
dbterm = db2pow(SNR - 2*transmitter.Gain);
Pt = (4*pi)^3*physconst('Boltzmann')*Ts/tau/target.MeanRCS/lambda^2*maxrange^4*dbterm;

filter = phased.MatchedFilter(...
   'Coefficients',getMatchedFilter(waveform),...
   'GainOutputPort',true);

numPulses = 64;
rxsig = zeros(length(wav),numPulses);

for n = 1:numPulses
    [tgtloc,tgtvel] = targetplatform(1/waveform.PRF);
    [tgtrng,tgtang] = rangeangle(tgtloc,txloc);
    
    [txsig, txstatus] = transmitter(wav);
    txsig = radiator(txsig,tgtang);
    txsig = channel(txsig,txloc,tgtloc,[0;0;0],tgtvel);
    txsig = target(txsig);
    txsig = channel(txsig,tgtloc,txloc,tgtvel,[0;0;0]);
    txsig = collector(txsig,tgtang);
    rxsig(:,n) = receiver(txsig,~txstatus);
end

prf = waveform.PRF;
fs = waveform.SampleRate;
response = phased.RangeDopplerResponse('DopplerFFTLengthSource','Property','DopplerFFTLength',2048,'SampleRate',fs,'DopplerOutput','Speed','OperatingFrequency',fc,'PRFSource','Property','PRF',prf);
filt = getMatchedFilter(waveform);
[resp,rng_grid,dop_grid] = response(rxsig,filt);

figure;
plotResponse(response,rxsig,filt,'Unit','db')
ylim([0 12000])

fasttime = unigrid(0,1/fs,1/prf,'[)');
rangebins = (physconst('Lightspeed')*fasttime/2);

figure;
plot(rangebins,abs(rxsig(:,1)))

pfa = 1e-6;
NoiseBandwidth = 5e6/2;
npower = noisepow(NoiseBandwidth, receiver.NoiseFigure,receiver.ReferenceTemperature);
thresh = npwgnthresh(pfa,numPulses,'noncoherent');
thresh = npower*db2pow(thresh);
[pks,range_detect] = findpeaks(pulsint(rxsig,'noncoherent'),'MinPeakHeight',thresh,'SortStr','descend');
range_estimate = rangebins(range_detect(1));
fprintf("Range Estimate: %3.2f m", range_estimate);

figure;
ts = rxsig(range_detect(1),:).';
periodogram(ts,[],256,prf,'centered')

[Pxx,F] = periodogram(ts,[],256,prf,'centered');

[Y,I] = max(Pxx);
lambda = physconst('Lightspeed')/fc;
tgtspeed = dop2speed(F(I)/2,lambda);
fprintf("Doppler Shift Estimate: %2.2f Hz",F(I)/2)
fprintf("Speed Estimate: %2.2f m/s",tgtspeed)



