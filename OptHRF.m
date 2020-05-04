function [f, p, opt, finalSSResid, exitFlag, hessian] = OptHRF(FromOrig, From, ToOrig, To, options)
%
%
%
% options (struct)
%   options.algo : 'fminsearch'/'fminunc'/'simulannealbnd'/'fmincon' algorithm to use
%   options.optAlgo : structure to send to the algo function, see algo
%   help.
%   Same as options from ssresidEval.
%
%
%

if ~isfield(options, 'func')
    options.func = 'gamma';
end
if ~isfield(options, 'interpMethod')
    options.interpMethod = 'spline';
end
if ~isfield(options, 'ruleOutImag')
    options.ruleOutImag = false;
end

if ~isfield(options, 'optAlgo')
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
    
    if ~isfield(options, 'algo')
        options.algo = 'fminunc';
    end
    
    if strcmp(options.algo, 'fminsearch')
        options.optAlgo = optionsMinSearch;
    elseif strcmp(options.algo, 'simulannealbnd')
        options.optAlgo = optionsAnneal;
    elseif strcmp(options.algo, 'fminunc')
        options.optAlgo = optionsNunc;
    elseif strcmp(options.algo, 'fmincon')
        options.optAlgo = optionsCon;
    end
end


% The last param corresponds to the smoothing param, the first ones are for
% the TF
if strcmp(options.func, 'gamma')
    p = options.paramsTF;
    if length(p) ~= 4
        p = [6 1 0 1];
    end
elseif strcmp(options.func, 'logit')
    p = options.paramsTF;
    if length(p) ~= 6
        p = [10 7 1 2 0.3 0.3];
    end
elseif ~strcmp(options.func, 'toeplitz') & ~strcmp(options.func, 'fourier')
    error('Unknown TF function. Use "gamma" or "logit".');
    return;
end

if ~isfield(options, 'upBnd')
    options.upBnd = [];
end

if ~isfield(options, 'lwBnd')
    options.lwBnd = [];
end



anonFunction = @(param)ssresidEval(param, FromOrig, From, ToOrig, To, options);

if strcmp(options.algo, 'fminsearch')
    [Variables, finalSSResid, exitFlag] = fminsearch(anonFunction, p, options.optAlgo);
    hessian = NaN;
elseif strcmp(options.algo, 'simulannealbnd')
    [Variables, finalSSResid, exitFlag, ~] = simulannealbnd(anonFunction, p, options.lwBnd, options.upBnd, options.optAlgo);
    hessian = NaN;
elseif strcmp(options.algo, 'fminunc')
    [Variables, finalSSResid, exitFlag, ~, ~, hessian] = fminunc(anonFunction, p, options.optAlgo);
elseif strcmp(options.algo, 'fmincon')
    [Variables, finalSSResid, exitFlag, ~, ~, hessian] = fmincon(anonFunction, p, [], [], [], [], options.lwBnd, options.upBnd, [], options.optAlgo);
elseif strcmp(options.algo, 'toeplitz')
    p = 'toeplitz';
    f = calculateTF(From(:, 2)', To(:, 2)', 'toeplitz');
    finalSSResid = 1; %ssresidEval(p, FromOrig(:, 2)', From(:, 2)', To(:, 2)', options);
    exitFlag = 0; hessian = NaN;
elseif strcmp(options.algo, 'fourier')
    p = 'fourier';
    f = calculateTF(From(:, 2)', To(:, 2)', 'fourier');
    finalSSResid = 1; %ssresidEval(p, FromOrig(:, 2)', From(:, 2)', To(:, 2)', options);
    exitFlag = 0; hessian = NaN;
end

%re-evaluate TF and prediction using optimized TF variables
if strcmp(options.func, 'gamma')
    [f, p] = computehrf(options.smoothDT, options.durationTF, Variables);
elseif strcmp(options.func, 'logit')
    [f, p] = computeLogit(options.smoothDT, options.durationTF, Variables);
end

opt = options;

end