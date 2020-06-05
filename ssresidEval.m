function SSResid = ssresidEval(param, From, To, options)
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
%   options.InterpolationMethod = 'spline'/'pchip'/... method of interpolation for
%   the convolution between From & TF
%   options.ruleOutImag = true/false  Remainer from Davis and I's tests.

time = [0:options.SamplingTime:options.durationTF];
cellParams = num2cell(param);
f = options.func(cellParams{:}, time);

convolution = conv(From(:, 2), f); 
convolution = interp1(From(:, 1), convolution(1:length(From(:, 2))), To(:, 1), options.InterpolationMethod);
SSPredic = sum((To(1:end-1, 2) - convolution(1:end-1)).^2);

SSResid = SSPredic;

if (isfield(options, 'ruleOutImag') && options.ruleOutImag) && imag(SSResid) ~= 0
    SSResid = Inf;
    disp(['Complex SSRBC : ' num2str(SSResid) ' params :' param]);
end

end