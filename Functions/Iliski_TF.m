function results = Iliski_TF(From, To, options)
% ILISKI_TF Framework function to compute a TF.
%
% function results = Iliski_TF(From, To, options)
%
%   Author: Ali-Kemal Aydin, PhD student
%   Mail: ali-kemal.aydin@inserm.fr
%   Affiliations: 
%       * INSERM U1128, Laboratory of Neurophysiology and New Microscopy, Université de Paris, Paris, France
%       * INSERM, CNRS, Institut de la Vision, Sorbonne Université, Paris, France
%   License:  Creative Commons Attribution 4.0 International (CC BY 4.0)
%       See LICENSE.txt or <a href="matlab:web('https://creativecommons.org/licenses/by/4.0/')">here</a>
%       for a human-readable version.
%
%   DESCRIPTION: Initialize the optimization parameters and launch the
%   computation process. Apart from specific parameters in the options
%   structure, optimization parameters are defined in this function. Output
%   structure contains every information needed to compute the TF and how
%   it turned out.
%__________________________________________________________________________
%   PARAMETERS:
%       From ([double, double]): 2D matrix of the input data, with the time
%       vector as the first column and the datapoints as the second one.
%
%       To ([double, double]): 2D matrix of the output data, with the time 
%       vector as the first column and the datapoints as the second one.
%
%       options (struct): structure containing one field per option to
%       specify for the optimization. Fields:
%           * Iterations (int): Number of iterations to perform, applicable to
%           non-deterministic optimization algorithm (Simulated Annealing)
%           * MedianFilterFrom (int): 0 to not apply a median filter, the
%           number of points to use for the median filter otherwise (see 
%           MEDFILT1) to the From signal.
%           * SGolayFilterFrom (int): 0 to not apply a 3rd order 
%           savitzky-golay filter, the impair number of points to use as a 
%           window otherwise (see SGOLAYFILTER) to the From signal.
%           * MedianFilterTo (int): 0 to not apply a median filter, the
%           number of points to use for the median filter otherwise (see 
%           MEDFILT1) to the To signal.
%           * SGolayFilterTo (int): 0 to not apply a 3rd order 
%           savitzky-golay filter, the impair number of points to use as a 
%           window otherwise (see SGOLAYFILTER) to the To signal.
%           * InterpolationMethod (str): If the From signal is
%           interpolated, the method to be used will be this one (see
%           INTERP1 for all the possiblities of the method parameter).
%           * SamplingTime (double): Duration in millisecond of the new deltaT
%           for the interpolation. Use the current dT to
%           avoid doing any interpolation.
%           * TimeIntervalRawData ([double double]): Time interval in second
%           to cut the From and To signals to before pre-treating and 
%           computing TFs.
%           * DurationTF (double): Duration of your TF in second.
%           * IsFromStep (bool): 
%
%__________________________________________________________________________
%   RETURN:
%       resultStruct (struct): structure containing all the informations
%       which allowed to compute the TF and its results. Separated in 3
%       substructures:
%           * Header: contains all the fields from the options structure
%           and the eventual InitialTF matrix, in case the computed TF was
%           computed from a set of pre-defined parameters, i.e. with an
%           optimization algorithm
%           * InputData: contains the From and To data in their raw form.
%           * Computed: contains the treated input data, every computed TFs
%           (both their timeseries and their parameters if they were
%           optimized), the resulting informations (RSS, Pearsons, etc.)
%           from the optimization algorithms and some metadata (date and 
%           such). For the TFs and corresponding informations, the last
%           dimension of the matrices corresponds to the computation
%           iteration (e.g. first TF is at Computed.TF(:, :, 1)).
%           
%__________________________________________________________________________
%   EXCEPTION:
%       Iliski:PredictionComputation:MatlabError
%           If a Matlab Error occured during the pre-treatment of the data.
%
%      Iliski:PredictionComputation:MatlabError
%           If a Matlab Error occured during the computation of the TF
%           (ILISKI_OPTTF function).
%
%      Iliski:ResultStructure:MatlabError
%           If a Matlab Error occured the creation of the Result Structure.        
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
    'TolFun',1e-8, ... % termination tolerance on the function value
    'ObjectiveLimit', 0);

optionsNunc = optimset('Display', 'off', ...
    'MaxFunEval', 10000,...
    'MaxIter', 10000,...
    'TolFun',1e-8,...
    'TolX',1e-8,...
    'algorithm', 'quasi-newton', ...
    'UseParallel','always');

optionsCon = optimset('Display', 'off', ...
    'MaxFunEval', 10000,...
    'MaxIter', 10000,...
    'TolFun',1e-8,...
    'TolX',1e-8,...
    'algorithm', 'sqp', ...
    'UseParallel','always');

%% TF computing
try
    for i = 1:options.Iterations
        if options.FMinUncAfterSimulAnl
            options.Algorithm = 'simulannealbnd';
            options.optAlgo = optionsAnneal;
            
            resultStruct = Iliski_findTF(From, To, options);
            
            options.InitialParameters = resultStruct.Computed.Parameters';
            options.InitialParameters_FirstStep = resultStruct.Computed.Parameters;
            
            options.Algorithm = 'fminunc';
            options.optAlgo = optionsNunc;
            resultStruct = Iliski_findTF(From, To, options);
            
            % has the second algorithm changed anything?
            optParamDiff = resultStruct.Computed.Parameters - options.InitialParameters_FirstStep;
            % disp(['Param Diff: ', num2str(optParamDiff)])
        else
            if isfield(options, 'optAlgo')
                ; % Do not redefine the optimizations parameters if there are already defined
            elseif strcmp(options.Algorithm, 'simulannealbnd')
                options.optAlgo = optionsAnneal;
            elseif strcmp(options.Algorithm, 'fmincon')
                options.optAlgo = optionsCon;
            elseif strcmp(options.Algorithm, 'fminunc')
                options.optAlgo = optionsNunc;
            elseif strcmp(options.Algorithm, 'fminsearch')
                options.optAlgo = optionsMinSearch;
            end
            
            resultStruct = Iliski_findTF(From, To, options);
        end
        
        if options.Iterations > 1 && i == 1
            results = resultStruct;
            results.Computed.Parameters = [];
            results.Computed.Parameters(:, i) = resultStruct.Computed.Parameters';
            results.Computed.Hessian = [];
            results.Computed.Hessian(:, :, i) = resultStruct.Computed.Hessian;
        elseif options.Iterations > 1
            results.Computed.TF(:, :, i) = resultStruct.Computed.TF;
            results.Computed.Prediction(:, :, i) = resultStruct.Computed.Prediction;
            results.Computed.Parameters(:, i) = resultStruct.Computed.Parameters';
            results.Computed.Hessian(:, :, i) = resultStruct.Computed.Hessian;
            results.Computed.ExitFlag(i) = resultStruct.Computed.ExitFlag;
            results.Computed.Pearson(i) = resultStruct.Computed.Pearson;
            results.Computed.ResidualSumSquare(i) = resultStruct.Computed.ResidualSumSquare;
        else
            results = resultStruct;
        end
    end
    
    % Sorting the results by their sum of the square residual values, the first being the best one.
    results = Iliski_sortTFComputations(results, 'ascend');
catch ME
    if strfind(ME.identifier, 'Iliski')
        rethrow(ME);
    else
        errMsg = ['A Matlab error occured during the computation of the TF. ' ...
            'For further details, see the Matlab report below. Contact the developer (see About or Help) to solve the issue.\n\n'];
        ME = addCause(ME, MException('Iliski:TFComputation:MatlabError', errMsg));
        throw(ME);
    end
end
end

