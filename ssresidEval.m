function SSResid = ssresidEval(param, FromOrig, From, ToOrig, To, options)
% Computes a transfer function and return the residual sum of the squares
% when using this TF on From to get To.
%
% param (vector of double) : numerical parameters to generate the TF
% duration (double) : duration of the TF vector
% DT (double) : delta T of the TF vector
% From & FromOrig & To (vector of double) : datasets
% options (struct) : options to be used by the function.
%   options.func = '1-gamma'/'2-logit' TF shape to generate (number of
%   param depends on it)
%   options.interpMethod = 'spline'/'pchip'/... method of interpolation for
%   the convolution between From & TF
%   options.ruleOutImag = true/false  Remainer from Davis and I's tests.

if strcmp(options.func, 'gamma')
    [f, ~] = computehrf(options.smoothDT, options.durationTF, param);
elseif strcmp(options.func, 'logit')
    [f, ~] = computeLogit(options.smoothDT, options.durationTF, param);
elseif strcmp(options.func, 'toeplitz')
    f = calculateTF(From, To, 'toeplitz');
else
    [f, ~] = computehrf(options.smoothDT, options.durationTF, param);
end

SSPredic = 0;
SSSmooth = 0;

for i=1:size(From, 3) 
    convolution = conv(From(:, 2, i), f); 
    convolution = interp1(From(:, 1, i), convolution(1:length(From(:, 2, i))), To(:, 1, i), options.interpMethod);
    SSPredic = SSPredic + sum((To(1:end-1, 2, i) - convolution(1:end-1)).^2);
    
    TMP = interp1(From(:, 1, i), From(:, 2, i)  , FromOrig(:, 1), 'linear');
    %SSSmooth = SSSmooth + sum((FromOrig(1:end-1, 2) - TMP(1:end-1)).^2);
end

SSResid = SSPredic + SSSmooth;

if (isfield(options, 'ruleOutImag') && options.ruleOutImag) && imag(SSResid) ~= 0
    SSResid = Inf;
    disp(['Complex SSRBC : ' num2str(SSResid) ' params :' param]);
end
%disp(SSResid);
end