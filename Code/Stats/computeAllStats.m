function stats = computeAllStats(ch)

stats.pdf = computePdf( ch, size(ch,1) ); % compute pdf on last sample
stats.xcorr = computeXcorr(ch); % compute all type of auto and cross correlation

end