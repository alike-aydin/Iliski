%% getIdxTime.m
% Return the index corresponding to the first element > t in timeVector
% timeVector : 1D scalar vector
% time : float

function idx = getIdxTime(timeVector, t)
    idx = min(find(timeVector >= t));
end