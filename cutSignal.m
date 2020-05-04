%% cutSignal.m
% Return a signal and timeVector corresponding to the given time range.
% time : 1D scalar vector, original time vector
% signal : 1D scalar vector, original data
% range : (int, int), range to cut the signal to, corresponding to
% timepoints

function [time, sign] = cutSignalShift(time, sign, range)
    underTime = getIdxTime(time, range(1));
    aboveTime = getIdxTime(time, range(2));
    
    time = time(underTime:aboveTime);
    sign = sign(underTime:aboveTime);
end