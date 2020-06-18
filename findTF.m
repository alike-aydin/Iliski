function [resultStruct] = findTF(From, To, options)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

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

%% RSS1 optimization
[tf, param, opt, finalSSResid, exitFlag, hessian] = OptHRF(FromTreated, ToTreated, options);

pred = conv(FromTreated(:, 2), tf);
pred = pred(1:size(FromTreated, 1));
pred = interp1(FromTreated(:, 1), pred(1:length(FromTreated(:, 2))), ToTreated(:,1), 'linear', 'extrap');
R = corrcoef(ToTreated(:, 2), pred);

%%
resultStruct = struct();

resultStruct.Header = opt;

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
end

