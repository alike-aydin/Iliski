function [resultStruct] = findTF(From, To, options)
% FINDTF Prepare the data and compute a single TF for a set of in/ouput
% signal.
%
% function [resultStruct] = findTF(From, To, options)
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
%   DESCRIPTION: Compute a single TF according to the given options after
%   having treated the data if needed. Calls OPTTF for the TF computation
%   and is called by BUILDTF to manage multiple TF computations at once.
%__________________________________________________________________________
%   PARAMETERS:
%       From ([double, double]): 2D matrix of the input data, with the time
%       vector as the first column and the datapoints as the second one.
%
%       To ([double, double]): 2D matrix of the output data, with the time 
%       vector as the first column and the datapoints as the second one.
%
%       options (struct): structure containing one field per option to
%       specify for the optimization. See BUILDTF for further details about
%       all the options.
%
%__________________________________________________________________________
%   RETURN:
%       resultStruct (struct): structure containing all the informations
%       which allowed to compute the TF and its results. BUILDTF builds
%       over this structure to accomodate for multiple TF computations. See
%       BUILDTF for details about this structure.
%__________________________________________________________________________
%   EXCEPTION:
%       Iliski:PredictionComputation:MatlabError
%           If a Matlab Error occured during the pre-treatment of the data.
%
%      Iliski:PredictionComputation:MatlabError
%           If a Matlab Error occured during the computation of the
%           prediction after the TF has been computed.
%
%      Iliski:ResultStructure:MatlabError
%           If a Matlab Error occured the creation of the Result Structure.
%__________________________________________________________________________

try
    [FromTreated(:, 1), FromTreated(:, 2)] = cutSignal(From(:, 1), From(:, 2), options.TimeIntervalRawData);
    [ToTreated(:, 1), ToTreated(:, 2)] = cutSignal(To(:, 1), To(:, 2), options.TimeIntervalRawData);
    
    if ~options.IsFromStep
        timeVector = options.TimeIntervalRawData(1):options.SamplingTime:options.TimeIntervalRawData(2);
        
        if options.MedianFilterFrom > 0
            FromTreated(:, 2) = movmedian(FromTreated(:, 2), options.MedianFilterFrom);
        end
        if options.SGolayFilterFrom > 0
            FromTreated(:, 2) = sgolayfilt(FromTreated(:, 2), 3, options.SGolayFilterFrom);
        end
        
        From_int(:, 1) = timeVector;
        From_int(:, 2) = interp1(FromTreated(:, 1), FromTreated(:, 2), timeVector, 'spline');
        FromTreated = From_int;
    else
        timeVector = FromTreated(:, 1);
    end
    
    %%
    if options.MedianFilterTo > 0
        ToTreated(:, 2) = movmedian(ToTreated(:, 2), options.MedianFilterTo);
    end
    if options.SGolayFilterTo > 0
        ToTreated(:, 2) = sgolayfilt(ToTreated(:, 2), 3, options.SGolayFilterTo);
    end
    
    % If the TF is deconvolutional, TO should have the same dT as From
    if find(strcmp(options.Algorithm, {'fourier'; 'toeplitz'}), 1)
        To_int(:, 1) = timeVector;
        To_int(:, 2) = interp1(ToTreated(:, 1), ToTreated(:, 2), timeVector, 'spline');
        ToTreated = To_int;
    end
catch ME
    if strfind(ME.identifier, 'Iliski')
        rethrow(ME);
    else
        errMsg = ['A Matlab error occured during the pre-treatment of your data. ' ...
            'For further details, see the Matlab report below. Contact the developer (see About or Help) to solve the issue.'];
        throw(MException('Iliski:DataPreTreatment:MatlabError', errMsg));
    end
end

%% RSS1 optimization
try
    [tf, param, finalSSResid, exitFlag, hessian] = OptTF(FromTreated, ToTreated, options);
    
    pred = conv(FromTreated(:, 2), tf);
    pred = pred(1:size(FromTreated, 1));
    pred = interp1(FromTreated(:, 1), pred(1:length(FromTreated(:, 2))), ToTreated(:,1), 'linear', 'extrap');
    R = corrcoef(ToTreated(:, 2), pred);
    if isnan(R(1, 2))
        R(1, 2) = -9999;
    end
    
catch ME
    if strfind(ME.identifier, 'Iliski')
        rethrow(ME);
    else
        errMsg = ['A Matlab error occured during the computation of the prediction with your optimized TF. ' ...
            'For further details, see the Matlab report below. Contact the developer (see About or Help) to solve the issue.'];
        throw(MException('Iliski:PredictionComputation:MatlabError', [errMsg, getReport(ME)]));
    end
end
%%
try
    resultStruct = struct();
    
    timeTF = [0:options.SamplingTime:(length(tf)-1)*options.SamplingTime];
    
    resultStruct.Header = options;
    resultStruct.Header.InitialTF = [];
    if isa(options.Function, 'function_handle')
       p = num2cell(options.InitialParameters);
       resultStruct.Header.InitialTF = [timeTF' options.Function(p{:}, timeTF)'];
    end
    
    resultStruct.InputData = struct();
    resultStruct.InputData.From = From;
    resultStruct.InputData.To = To;
    
    resultStruct.Computed = struct();
    resultStruct.Computed.FromTreated = FromTreated;
    resultStruct.Computed.ToTreated = ToTreated;
    resultStruct.Computed.Date = datetime;
    resultStruct.Computed.TF = [timeTF' tf'];
    resultStruct.Computed.Prediction = [ToTreated(:, 1) pred];
    resultStruct.Computed.Parameters = param';
    resultStruct.Computed.Hessian = hessian;
    resultStruct.Computed.ExitFlag = exitFlag;
    resultStruct.Computed.Pearson = R(1, 2);
    resultStruct.Computed.ResidualSumSquare = finalSSResid;
catch ME
    errMsg = ['A Matlab error occured during the creation of the result structure. ' ...
        'For further details, see the Matlab report below. Contact the developer (see About or Help) to solve the issue.'];
    ME = addCause(ME, MException('Iliski:ResultStructure:MatlabError', errMsg));%, %getReport(ME)]));
    throw(ME);
end

end

