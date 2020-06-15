function [f, p, opt, finalSSResid, exitFlag, hessian] = OptHRF(From, To, options)
%
%
%
% options (struct)
%   options.Algorithm : 'fminsearch'/'fminunc'/'simulannealbnd'/'fmincon' algorithm to use
%   options.optAlgo : structure to send to the algo function, see algo
%   help.
%   Same as options from ssresidEval.
%
%
%

% if ~isfield(options, 'func')
%     options.Function = 'gamma';
% end
% if ~isfield(options, 'InterpolationMethod')
%     options.InterpolationMethod = 'spline';
% end
% if ~isfield(options, 'ruleOutImag')
%     options.ruleOutImag = false;
% end

optionsMinSearch = optimset('Display','off',...     % change iter-> off to display no output
    'FunValCheck','off',...  % check objective values
    'MaxFunEvals', 10000,...  % max number of function evaluations allowed
    'MaxIter', 10000,...      % max number of iteration allowed
    'TolFun',1e-8,...        % termination tolerance on the function value
    'TolX',1e-8,...          % termination tolerance on x
    'UseParallel','always'); % always use parallel computation

optionsAnneal = saoptimset('Display','off',...     % change iter-> off to display no output
    'MaxFunEval', 10000,...  % max number of function evaluations allowed
    'MaxIter', 10000,...      % max number of iteration allowed
    'TolFun',1e-10, ... % termination tolerance on the function value
    'ObjectiveLimit', 0);

optionsNunc = optimset('Display', 'off', ...
    'MaxFunEval', 10000,...
    'MaxIter', 10000,...
    'TolFun',1e-8,...
    'TolX',1e-8,...
    'algorithm', 'trust-region', ...
    'UseParallel','always');

optionsCon = optimset('Display', 'off', ...
    'MaxFunEval', 10000,...
    'MaxIter', 10000,...
    'TolFun',1e-8,...
    'TolX',1e-8,...
    'algorithm', 'sqp', ...
    'UseParallel','always');

if strcmp(options.Algorithm, 'fminsearch')
    options.optAlgo = optionsMinSearch;
elseif strcmp(options.Algorithm, 'simulannealbnd')
    options.optAlgo = optionsAnneal;
elseif strcmp(options.Algorithm, 'fminunc')
    options.optAlgo = optionsNunc;
elseif strcmp(options.Algorithm, 'fmincon')
    options.optAlgo = optionsCon;
end


if isa(options.Function, 'function_handle')
    p = options.InitialParameters;
end

anonFunction = @(param)ssresidEval(param, From, To, options);

if strcmp(options.Algorithm, 'fminsearch')
    [Variables, finalSSResid, exitFlag] = fminsearch(anonFunction, p, options.optAlgo);
    hessian = NaN;
elseif strcmp(options.Algorithm, 'simulannealbnd')
    [Variables, finalSSResid, exitFlag, ~] = simulannealbnd(anonFunction, p, options.LowerBoundParameters, options.UpperBoundParameters, options.optAlgo);
    hessian = NaN;
elseif strcmp(options.Algorithm, 'fminunc')
    [Variables, finalSSResid, exitFlag, ~, ~, hessian] = fminunc(anonFunction, p, options.optAlgo);
elseif strcmp(options.Algorithm, 'fmincon')
    [Variables, finalSSResid, exitFlag, ~, ~, hessian] = fmincon(anonFunction, p, [], [], [], [], options.LowerBoundParameters, options.UpperBoundParameters, [], options.optAlgo);
elseif strcmp(options.Algorithm, 'toeplitz')
    p = 'toeplitz';
    f = calculateTF(From(:, 2)', To(:, 2)', 'toeplitz');
    finalSSResid = 1;
    exitFlag = 0; hessian = NaN;
elseif strcmp(options.Algorithm, 'fourier')
    p = 'fourier';
    f = calculateTF(From(:, 2)', To(:, 2)', 'fourier');
    finalSSResid = 1;
    exitFlag = 0; hessian = NaN;
end

if isa(options.Function, 'function_handle')
    time = [0:options.SamplingTime:options.DurationTF];
    cellParams = num2cell(Variables);
    f = options.Function(cellParams{:}, time);
    p = Variables;
end

opt = options;

end