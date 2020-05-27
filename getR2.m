%% getR2.m
% Return the R² value for the given parameters
% 
% Y : 1D scalar vector, real data
% Yfit : 1D scalar vector, fitted data

function rsq = getR2(Y, Yfit)
    ssresid = sum((Y - Yfit).^2);
    sstotal = (length(Y)-1) * var(Y);
    rsq = 1 - ssresid/sstotal;
end