function stats = computeAllStats(ch)

stats.pdf = computePdf( ch, size(ch,1) ); % compute pdf on last sample
stats.xcorr = computeXcorr(ch); % compute all type of auto and cross correlation
[stats.LCR.values,stats.LCR.thresh,stats.LCR.stdev] =...
    computeLCR(ch,t,thresh); % compute LCR
[stats.AFD.values,stats.AFD.thresh,stats.AFD.stdev] =...
    computeAFD(ch,t,thresh); % compute AFD

end