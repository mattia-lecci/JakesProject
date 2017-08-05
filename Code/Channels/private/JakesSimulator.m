function ch = JakesSimulator(fd,t,nSin,nChannels)
% Reference A2, Eq.s (5-6-7)
%
% See also: CREATECHANNEL

% arg check
if nChannels>1
    warning(['Jakes Simulator does not support multiple independent channels. '...
        'The channels will be replicated using repmat']);
end

%% create channels
Ntot = 4*nSin+2;
[a,b,omega]= getVariables(nSin,fd);

% computations
cosine = cos(omega.*t); % compute only once
uc = 2/sqrt(Ntot)*sum( a.*cosine ,2);
us = 2/sqrt(Ntot)*sum( b.*cosine ,2);

% channel
ch = repmat( uc+1j*us ,1,nChannels);

end

%% Utility functions

function [a,b,omega]= getVariables(M,fd)

N = 4*M+2;
n = 1:M;

% init
a = zeros(1,M+1);
b = a;
beta = a;
omega = a;

% omega
omega(1) = 2*pi*fd;
omega(n+1) = 2*pi*fd*cos( 2*pi*n/N );

% beta
beta(1) = pi/4;
beta(n+1) = pi*n/M;

% a
a(1) = cos( beta(1) );
a(n+1) = sqrt(2)*cos( beta(n+1) );

% b
b(1) = sin( beta(1) );
b(n+1) = sqrt(2)*sin( beta(n+1) );

end