function results = buildTF(From, To, options, savingName, savingFile)
optionsMinSearch = optimset('Display','off',...     % change iter-> off to display no output
    'FunValCheck','off',...  % check objective values
    'MaxFunEvals', 10000,...  % max number of function evaluations allowed
    'MaxIter', 10000,...      % max number of iteration allowed
    'TolFun',1e-8,...        % termination tolerance on the function value
    'TolX',1e-8,...          % termination tolerance on x
    'UseParallel','always'); % always use parallel computation

optionsAnneal = saoptimset('Display','off',...     % change iter-> off to display no output
    'MaxFunEval', Inf,...  % max number of function evaluations allowed
    'MaxIter', Inf,...      % max number of iteration allowed
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
            
            resultStruct = findTF(From, To, options);
            
            options.InitialParameters = resultStruct.Computed.Parameters;
            options.InitialParameters_FirstStep = resultStruct.Computed.Parameters;
            
            options.Algorithm = 'fminunc';
            options.optAlgo = optionsNunc;
            resultStruct = findTF(From, To, options);
            
            % has the second algorithm changed anything?
            optParamDiff = resultStruct.Computed.Parameters - options.InitialParameters_FirstStep;
            % disp(['Param Diff: ', num2str(optParamDiff)])
        else
            if strcmp(options.Algorithm, 'simulannealbnd')
                options.optAlgo = optionsAnneal;
            elseif strcmp(options.Algorithm, 'fmincon')
                options.optAlgo = optionsCon;
            elseif strcmp(options.Algorithm, 'fminunc')
                options.optAlgo = optionsNunc;
            elseif strcmp(options.Algorithm, 'fminsearch')
                options.optAlgo = optionsMinSearch;
            end
            
            resultStruct = findTF(From, To, options);
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
catch ME
    if strfind(ME.identifier, 'Iliski')
        rethrow(ME)
    else
        errMsg = ['A Matlab error occured during the computation of the TF. ' ...
            'For further details, see the Matlab report below. Contact the developer (see About or Help) to solve the issue.\n\n'];
        throw(MException('Iliski:TFComputation:MatlabError', [errMsg, getReport(ME)]));
    end
end
% if options.Iterations > 1
%     load handel
%     sound(y,Fs)
% end
end

