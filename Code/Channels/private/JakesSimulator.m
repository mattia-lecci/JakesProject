function ch = JakesSimulator(fd,t,nSin,nChannels)
% arg check
if mod(nSin-2,4)~=0
    error('Number of sinusoid must be of the form nSin=4M+2 for integer M');
end
if nChannels>1
    warning(['Jakes Simulator does not support multiple independent channels. '...
        'The channels will be replicated using repmat']);
end

%% create channels
M = (nSin-2)/4;
[a,b,omega]= getVariables(M,fd);

% computations
cosine = cos(omega.*t); % compute only once
uc = 2/sqrt(nSin)*sum( a.*cosine ,2);
us = 2/sqrt(nSin)*sum( b.*cosine ,2);

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