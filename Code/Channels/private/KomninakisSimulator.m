function ch = KomninakisSimulator(fd,t,nCh,interpMethod)

% check special cases
if size(t,1)<2
    ch = crandn( size(t,1),nCh );
    return
end
% now t has at least 2 elements

%% init
T = t(2)-t(1); % required sampling period
Tp = .1/fd; % filtering sampling period
N = size(t,1); % number of samples required

L = Tp/T; % sampling ratio
Np = ceil( N/L ); % number of samples in Tp

[b,a,Ntrans] = getDopplerFilterCoefficients();
Ntot = Ntrans+Np; % total number of samples required

%% computations
ch = crandn(Ntot,nCh); % create 0 mean unit variance complex gauss rv
ch = filter(b,a,ch); % filter to match PSD
ch(1:Ntrans,:) = []; % eliminate transient
% interpolate channel using nested function
interpolateChannel();


%% interpolation
% implemented as nested function to improve memory efficiency
    function interpolateChannel()
        
        switch interpMethod
            case 'filter'
                % parameters
                BW = 2*fd; % filter bandwidth
                inRate = 1/Tp;
                outRate = 1/T;
                tolerance = .01;
                attenuation = 40; % dB
                
                % create filter
                h = dsp.SampleRateConverter('Bandwidth',BW,...
                    'InputSampleRate',inRate,'OutputSampleRate',outRate,...
                    'OutputRateTolerance',tolerance,'StopbandAttenuation',attenuation);
                
                % interpolate
                ch = h.step(ch);
                
            otherwise % interpolate with polynomials
                tp = (0:Np-1)*Tp + t(1); % filter's time vector
                ch = interp1(tp,ch,t,interpMethod);
        end
        
    end

end

%% Utility methods

function [b,a,Ntrans] = getDopplerFilterCoefficients()
% Classical doppler spectrum for f_d*T_p=0.1

% ref: Anastasopoulos and Chugg (1997). (c) 1997 IEEE
% from: Algorithms for Communication Systems and their Applications,
% Benvenuto-Cherubini, p.317

a = [1 -4.4153 8.6283 -9.4592,...
    6.1051 -1.3542 -3.3622 7.2390,...
    -7.9361 5.1221 -1.8401 2.8706e-1];
b = [1.3651e-4 8.1905e-4 2.0476e-3 2.7302e-3,...
    2.0476e-3 9.0939e-4 6.7852e-4 1.3550e-3,...
    1.8067e-3 1.3550e-3 5.3726e-4 6.1818e-5,...
    -7.1294e-5 -9.5058e-5 -7.1294e-5 -2.5505e-5,...
    1.3321e-5 4.5186e-5 6.0248e-5 4.5186e-5,...
    1.8074e-5 3.0124e-6];

b = b/filternorm(b,a); % normalizing to unit energy

Ntrans = length( impz(b,a) ); % duration of the transient

end