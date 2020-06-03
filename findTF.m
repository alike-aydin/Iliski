function [resultStruct] = findTF(From, To, options)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[FromTreated(:, 1), FromTreated(:, 2)] = cutSignal(From(:, 1), From(:, 2), options.range);
[ToTreated(:, 1), ToTreated(:, 2)] = cutSignal(To(:, 1), To(:, 2), options.range);

if ~options.stepON
    timeVector = options.range(1):options.smoothDT:options.range(2);
       
    if options.medianFilter_From > 0
        FromTreated(:, 2) = medfilt1(FromTreated(:, 2), options.medianFilter_From);
    end
    if options.sgolayPoints_From > 0
        FromTreated(:, 2) = sgolayfilt(FromTreated(:, 2), 3, options.sgolayPoints_From);
    end
    
    From_int(:, 1) = timeVector;
    From_int(:, 2) = interp1(FromTreated(:, 1), FromTreated(:, 2), timeVector, 'spline');
    FromTreated = From_int;
else
    timeVector = FromTreated(:, 1);
end

%%
if options.medianFilter_To > 0
    ToTreated(:, 2) = medfilt1(ToTreated(:, 2), options.medianFilter_To);
end
if options.sgolayPoints_To > 0
    ToTreated(:, 2) = sgolayfilt(ToTreated(:, 2), 3, options.sgolayPoints_To);
end

% If the TF is deconvolutional, TO should have the same dT as From
if find(strcmp(options.algo, {'fourier'; 'toeplitz'}), 1)
    To_int(:, 1) = timeVector;
    To_int(:, 2) = interp1(ToTreated(:, 1), ToTreated(:, 2), timeVector, 'spline');
    ToTreated = To_int;
end

%% RSS1 optimization
[tf, param, opt, finalSSResid, exitFlag, hessian] = OptHRF(FromTreated, ToTreated, options);

pred = conv(FromTreated(:, 2), tf);
pred = interp1(FromTreated(:, 1), pred(1:length(FromTreated(:, 2))), ToTreated(:,1), 'linear');
R = corrcoef(ToTreated(1:end-1,2), pred(1:end-1));

%%
clear resultStruct;
resultStruct.genOptions = opt;
resultStruct.finalSSResid = finalSSResid;
resultStruct.pearson = R(1, 2);
resultStruct.paramTF = param;
resultStruct.TF = tf;
resultStruct.fromDataRaw = From;
resultStruct.fromDataTreated = FromTreated;
resultStruct.toDataRaw = To;
resultStruct.toDataTreated = ToTreated;
%resultStruct.fig = fig;
resultStruct.exitFlag = exitFlag;
resultStruct.hessian = hessian;
resultStruct.date = datetime;
end

