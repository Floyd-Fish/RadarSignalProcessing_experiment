antenna = phased.IsotropicAntennaElement('FrequencyRange',[5e9 15e9]);
transmitter = phased.Transmitter('Gain',20,'InUseOutputPort',true);
fc = 10e9;
target = phased.RadarTarget('Model','Nonfluctuating',...
   'MeanRCS',1,'OperatingFrequency',fc);
txloc = [0;0;0];
tgtloc = [5000;5000;10];
transmitterplatform = phased.Platform('InitialPosition',txloc);
targetplatform = phased.Platform('InitialPosition',tgtloc);
[tgtrng,tgtang] = rangeangle(targetplatform.InitialPosition,...
   transmitterplatform.InitialPosition);

waveform = phased.RectangularWaveform('PulseWidth',25e-6,...
   'OutputFormat','Pulses','PRF',10e3,'NumPulses',1);
c = physconst('LightSpeed');
maxrange = c/(2*waveform.PRF);
SNR = npwgnthresh(1e-6,1,'noncoherent');

lambda = physconst('LightSpeed')/target.OperatingFrequency;
Ts = 290;
dbterms = db2pow(SNR - 2*transmitter.Gain);
Pt = (4*pi)^3*physconst('Boltzmann')*Ts/waveform.PulseWidth/target.MeanRCS/(lambda^2)*maxrange^4*dbterms;

transmitter.PeakPower = Pt;

radiator = phased.Radiator('PropagationSpeed',c,...
   'OperatingFrequency',fc,'Sensor',antenna);
channel = phased.FreeSpace('PropagationSpeed',c,...
   'OperatingFrequency',fc,'TwoWayPropagation',false);
collector = phased.Collector('PropagationSpeed',c,...
   'OperatingFrequency',fc,'Sensor',antenna);
receiver = phased.ReceiverPreamp('NoiseFigure',0,...
   'EnableInputPort',true,'SeedSource','Property','Seed',2e3);
filter = phased.MatchedFilter(...
   'Coefficients',getMatchedFilter(waveform),...
   'GainOutputPort',true);

wf = waveform();
[wf,txstatus] = transmitter(wf);
wf = radiator(wf,tgtang);
wf = channel(wf,txloc,tgtloc,[0;0;0],[0;0;0]);
wf = target(wf);
wf = channel(wf,tgtloc,txloc,[0;0;0],[0;0;0]);
wf = collector(wf,tgtang);
rx_puls = receiver(wf,~txstatus);
[mf_puls,mfgain] = filter(rx_puls);
Gd = length(filter.Coefficients)-1;

mf_puls=[mf_puls(Gd+1:end); mf_puls(1:Gd)];
subplot(2,1,1)
t = unigrid(0,1e-6,1e-4,'[)');
rangegates = c.*t;
rangegates = rangegates/2;
plot(rangegates,abs(rx_puls))
title('Received Pulse')
ylabel('Amplitude')
hold on
plot([tgtrng, tgtrng], [0 max(abs(rx_puls))],'r')
subplot(2,1,2)
plot(rangegates,abs(mf_puls))
title('With Matched Filtering')
xlabel('Meters')
ylabel('Amplitude')
hold on
plot([tgtrng, tgtrng], [0 max(abs(mf_puls))],'r')
hold off