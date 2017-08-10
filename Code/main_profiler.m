clear variables
close all
clc

addpath('Channels','Misc','Plots','SavedData','Stats')

%% Parameters
% createChannel parameters
fd = 10;
T = 0.002/fd;
duration = 1000;
nSin = 8;
durationType = 'Tcoh';
Nchannels = 100;
interpMethod = 'filter';
simulator = 'Komninakis';

%% Channel
tic
[ch,t] = createChannel(fd,T,duration,simulator,nSin,...
                'DurationType',durationType,'NChannels',Nchannels,...
                'InterpMethod',interpMethod);
toc