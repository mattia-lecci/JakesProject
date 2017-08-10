function ch = KomninakisSimulator(fd,t,nCh,interpMethod)
% Reference A3
%
% See also: CREATECHANNEL

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
Np = ceil( N/L ); % number of samples in Tp (extra samples will be trimmed later)

[b,a,Ntrans] = getDopplerFilterCoefficients();
Ntot = Ntrans+Np; % total number of samples required

%% computations
ch = crandn(Ntot,nCh); % create 0 mean unit variance complex gauss rv
ch = filter(b,a,ch); % filter to match PSD
% eliminate transient and interpolate channel using nested function
interpolateChannel();

% trim excess samples (at the beginning, there might still be transient)
Nexcess = size(ch,1) - N;
ch(1:Nexcess,:) = [];


%% interpolation
% implemented as nested function to improve memory efficiency
    function interpolateChannel()
        
        switch interpMethod
            case 'filter'
                % parameters
                inRate = 1/Tp;
                outRate = 1/T;
                
                if inRate>outRate
                    error('An interpoletion is required')
                end
                
                Fp = fd; % filter bandwidth
                Fst = inRate - fd; % has to attenuate next fd
                Ap = 1;
                Ast = 40;
                
                % filter design and creation
                d = fdesign.lowpass('Fp,Fst,Ap,Ast',Fp,Fst,Ap,Ast,outRate);
                Hd = design(d,'equiripple');
                b_lp = Hd.Numerator;
                
                Nlp = length(b_lp);
                
                % upsampling and transient elimination
                loss = mod(L,1)/L;
                L = round(L);
                
                lpTrans = ceil( Nlp/L );
                ch( 1:(Ntrans-2*lpTrans),:) = []; % eliminate transient
                                
                if false
                    fprintf('upsampling loss: %.1f%%\n',loss*100);
                end
                
                ch = upfirdn(ch,b_lp,L)*L;
                
                % eliminate transient from low pass
                ch(1:Nlp,:) = [];
                ch(end-Nlp+1:end,:) = [];
                
            otherwise % interpolate with polynomials
                
                ch(1:Ntrans,:) = []; % eliminate transient
                
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

a = [1,...
   -4.4153,...
    8.6283,...
   -9.4592,...
    6.1051,...
   -1.3542,...
   -3.3622,...
    7.2390,...
   -7.9361,...
    5.1221,...
   -1.8401,...
    2.8706e-1];
b = [2.4203e-04,...
    1.4522e-03,...
    3.6304e-03,...
    4.8407e-03,...
    3.6304e-03,...
    1.6124e-03,...
    1.2030e-03,...
    2.4024e-03,...
    3.2033e-03,...
    2.4024e-03,...
    9.5257e-04,...
    1.0960e-04,...
   -1.2641e-04,...
   -1.6854e-04,...
   -1.2641e-04,...
   -4.5221e-05,...
    2.3618e-05,...
    8.0116e-05,...
    1.0682e-04,...
    8.0116e-05,...
    3.2046e-05,...
    5.3410e-06];

Ntrans = 300; % duration of the transient (checked with impz(b,a) )

end