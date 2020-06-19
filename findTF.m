function [resultStruct] = findTF(From, To, options)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

try
    [FromTreated(:, 1), FromTreated(:, 2)] = cutSignal(From(:, 1), From(:, 2), options.TimeIntervalRawData);
    [ToTreated(:, 1), ToTreated(:, 2)] = cutSignal(To(:, 1), To(:, 2), options.TimeIntervalRawData);
    
    if ~options.IsFromStep
        timeVector = options.TimeIntervalRawData(1):options.SamplingTime:options.TimeIntervalRawData(2);
        
        if options.MedianFilterFrom > 0
            FromTreated(:, 2) = medfilt1(FromTreated(:, 2), options.MedianFilterFrom);
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
        ToTreated(:, 2) = medfilt1(ToTreated(:, 2), options.MedianFilterTo);
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
    errMsg = ['A Matlab error occured during the pre-treatment of your data. ' ...
        'For further details, see the Matlab report below. Contact the developer (see About or Help) to solve the issue.'];
    throw(MException('Iliski:DataPreTreatment:MatlabError', [errMsg, getReport(ME)]));
end

%% RSS1 optimization
try
    [tf, param, finalSSResid, exitFlag, hessian] = OptTF(FromTreated, ToTreated, options);
    
    pred = conv(FromTreated(:, 2), tf);
    pred = pred(1:size(FromTreated, 1));
    pred = interp1(FromTreated(:, 1), pred(1:length(FromTreated(:, 2))), ToTreated(:,1), 'linear', 'extrap');
    R = corrcoef(ToTreated(:, 2), pred);
    
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
    
    resultStruct.Header = options;
    
    resultStruct.InputData = struct();
    resultStruct.InputData.From = From;
    resultStruct.InputData.To = To;
    
    resultStruct.Computed = struct();
    resultStruct.Computed.FromTreated = FromTreated;
    resultStruct.Computed.ToTreated = ToTreated;
    resultStruct.Computed.Date = datetime;
    resultStruct.Computed.TF = [[0:options.SamplingTime:(length(tf)-1)*options.SamplingTime]' tf'];
    resultStruct.Computed.Prediction = [ToTreated(:, 1) pred];
    resultStruct.Computed.Parameters = param';
    resultStruct.Computed.Hessian = hessian;
    resultStruct.Computed.ExitFlag = exitFlag;
    resultStruct.Computed.Pearson = R(1, 2);
    resultStruct.Computed.ResidualSumSquare = finalSSResid;
catch ME
    errMsg = ['A Matlab error occured during the creation of the result structure. ' ...
        'For further details, see the Matlab report below. Contact the developer (see About or Help) to solve the issue.'];
    throw(MException('Iliski:ResultStructure:MatlabError', [errMsg, getReport(ME)]));
end

end

