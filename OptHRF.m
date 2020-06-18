function [f, p, finalSSResid, exitFlag, hessian] = OptTF(From, To, options)
% OPTTF Optimize a parametric TF given the input/ouput timecourses and the options.
%
% function [f, p, finalSSResid, exitFlag, hessian] = OptTF(From, To, options)
%
%   Author: Ali-Kemal Aydin, PhD student
%   Mail: ali-kemal.aydin@inserm.fr
%   Affiliation: 
%       * INSERM U1128, Laboratory of Neurophysiology and New Microscopy, Université de Paris, Paris, France
%       * INSERM, CNRS, Institut de la Vision, Sorbonne Université, Paris, France
%   License:  Creative Commons Attribution 4.0 International (CC BY 4.0)
%       See LICENSE.txt or <a href="matlab:web('https://creativecommons.org/licenses/by/4.0/')">here</a>
%       for a human-readable version.
%
%   DESCRIPTION: Optimize the transfer function linking the input and the
%   output signal by the convolutional operation. There are many options,
%   see BUILDTF for detailed informations. 
%__________________________________________________________________________
%   PARAMETERS:
%       From ([double, double]): 2D matrix of the input data, with the time vector as 
%       the first column and the datapoints as the second one.
%
%       To ([double, double]): 2D matrix of the output data, with the time vector as 
%       the first column and the datapoints as the second one.
%
%       options (struct): structure containing one field per option to
%       specify for the optimization. See BUILDTF for further details about
%       all the options.
%__________________________________________________________________________
%   RETURN:
%       f ([double]): 1D array of the TF points (only the Y axis, not the
%       time vector).
%
%       p ([double]): 1D array containing the optimized parameters of the
%       parametric function. It is NaN if the function is not parametric 
%       (toeplitz or fourier).
%
%       finalSSResid (double): Residual square sum corresponding to the
%       prediction made with the optimized TF.
%
%       exitFlag (int): Depending on the algorithm used, this is the
%       exitFlag parameters of the corresponding Matlab functions. For
%       Topelitz and Fourier, it systematically is 1.
%
%       hessian ([double]): fmincon and fminunc algorithms return a hessian
%       matrix. If antoher algorithm is used, the returned value is NaN.
%
%__________________________________________________________________________
%   EXCEPTION:
%       Iliski:TFComputation:UnknownAlgorithm
%           If the computation algorithm is not of the programed.
%
%       Iliski:TFOptimization:MatlabError
%           Any Matlab error during the optimization process will raise
%           this exception.
%__________________________________________________________________________

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

hessian = NaN;
p = NaN;
exitFlag = 1;

anonFunction = @(param)ssresidEval(param, From, To, options);
try
    if strcmp(options.Algorithm, 'fminsearch')
        [p, finalSSResid, exitFlag] = fminsearch(anonFunction, p, options.optAlgo);
    elseif strcmp(options.Algorithm, 'simulannealbnd')
        [p, finalSSResid, exitFlag, ~] = simulannealbnd(anonFunction, p, options.LowerBoundParameters, options.UpperBoundParameters, options.optAlgo);
    elseif strcmp(options.Algorithm, 'fminunc')
        [p, finalSSResid, exitFlag, ~, ~, hessian] = fminunc(anonFunction, p, options.optAlgo);
    elseif strcmp(options.Algorithm, 'fmincon')
        [p, finalSSResid, exitFlag, ~, ~, hessian] = fmincon(anonFunction, p, [], [], [], [], options.LowerBoundParameters, options.UpperBoundParameters, [], options.optAlgo);
    elseif strcmp(options.Algorithm, 'toeplitz') || strcmp(options.Algorithm, 'fourier')
        f = calculateTF(From(:, 2)', To(:, 2)', options.Algorithm);
        convolution = conv(From(:, 2)', f);
        finalSSResid = sum((To(1:end, 2) - convolution(1:size(To, 1))).^2);
    else
        errMsg = 'The computation algorithm is unknown. Contact the developer (see Help or About) to solve the issue.';
        err = MException('Iliski:TFOptimization:UnknownAlgorithm', errMsg);
        throw(err);
    end

    if isa(options.Function, 'function_handle')
        time = [0:options.SamplingTime:options.DurationTF];
        cellParams = num2cell(p);
        f = options.Function(cellParams{:}, time);
    end
catch ME
    if strfind(ME, 'Iliski')
        throw(ME)
    else
        throw(MException('Iliski:TFOptimization:MatlabError', getReport(ME)));
    end
end

end