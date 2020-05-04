function [resultStruct] = findTF(fileFrom, pathFrom, fileTo, pathTo, options)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

clear CaStart RBCStart
for i=1:length(pathFrom)
    quack= getTimeFromPath(fileFrom, pathFrom{i});
    maxTime= quack(end); %disp(['Max time: ', num2str(maxTime)]);
    minTime= quack(1); %disp(['Min time: ', num2str(minTime)]);
    [FromStart(:, 1, i), FromStart(:, 2, i)] = cutSignal(getTimeFromPath(fileFrom, pathFrom{i}), h5read(fileFrom, pathFrom{i}), options.range);
    [ToStart(:, 1, i), ToStart(:, 2, i)] = cutSignal(getTimeFromPath(fileTo, pathTo{i}),  h5read(fileTo, pathTo{i}), options.range);
end

%% First interpolation to 'smooth' calcium
% This should not be done if the From is a step
if ~ options.stepON
    timeVector = options.range(1):options.smoothDT:options.range(2);    
    for i=1:size(FromStart, 3)
        From_int(:, 1, i) = timeVector;
        From_int(:, 2, i) = interp1(FromStart(:, 1, i), FromStart(:, 2, i), timeVector, 'spline');
    end
else
    timeVector = FromStart(:, 1, i);
    From_int = FromStart;
end

%%
To_int = ToStart;
for i=1:size(ToStart, 3)
    if options.applyMedianToRBC
        To_int(:, 2, i) = medfilt1(To_int(:, 2, i), options.medianFilterN);
    end
    if options.applySGolayRBC
        To_int(:, 2, i) = sgolayfilt(To_int(:, 2, i), 3, options.sgolayPoints_To);
    end
end

%% RSS1 optimization
[tf, param, opt, finalSSResid, exitFlag, hessian] = OptHRF(FromStart, From_int, ToStart, To_int, options);


for i=1:length(pathFrom)
    result(:, i) = conv(squeeze(From_int(:, 2, i)), tf);
    int_res = interp1(timeVector(1:end), squeeze(result(1:length(timeVector), i)), squeeze(ToStart(1:end, 1, i)), 'linear');
    R2(i)= getR2(squeeze(ToStart(1:end-1, 2, i)), int_res(1:end-1));
end

%%
clear resultStruct;
resultStruct.genOptions = opt;
resultStruct.finalSSResid = finalSSResid;
resultStruct.R2 = R2;
resultStruct.paramTF = param;
resultStruct.TF = tf;
resultStruct.fileFrom = fileFrom;
resultStruct.fileTo = fileTo;
resultStruct.pathFrom = pathFrom;
resultStruct.pathTo = pathTo;
resultStruct.fromDataRaw = FromStart;
resultStruct.fromDataTreated = From_int;
resultStruct.toDataRaw = ToStart;
resultStruct.toDataTreated = To_int;
%resultStruct.fig = fig;
resultStruct.exitFlag = exitFlag;
resultStruct.hessian = hessian;
resultStruct.date = datetime;
end

