function [resultStruct] = findTF(fileFrom, pathFrom, fileTo, pathTo, options, showFig)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

clear CaStart RBCStart
for i=1:length(pathFrom)
    quack= getTimeFromPath(fileFrom, pathFrom{i});
    maxTime= quack(end); 
    minTime= quack(1); 
    [CaStart(:, 1, i), CaStart(:, 2, i)] = cutSignal(getTimeFromPath(fileFrom, pathFrom{i}), h5read(fileFrom, pathFrom{i}), options.range);
    [RBCStart(:, 1, i), RBCStart(:, 2, i)] = cutSignal(getTimeFromPath(fileTo, pathTo{i}),  h5read(fileTo, pathTo{i}), options.range);
end

% figure; subplot(221); plot(CaStart(:, 1), CaStart(:, 2));
% title('Calcium at start');
% subplot(222); plot(RBCStart(:, 1), RBCStart(:, 2));
% title('RBC velocity at start');
% 
% %% Create the standard HRF
if strcmp(options.func, 'gamma')
    [HRF, ~] = computehrf(options.smoothDT, options.durationTF);
%    subplot(223); plot(0:dt:(length(HRF)-1)*dt, HRF);
%    title('single-gamma')
elseif strcmp(options.func, 'logit')
    [HRF, ~] = computeLogit(options.smoothDT, options.durationTF);
%    subplot(223); plot(0:dt:(length(HRF)-1)*dt, HRF);
 %   title('two-logit');
end

%% First interpolation to 'smooth' calcium
timeVector = options.range(1):options.smoothDT:options.range(2);

for i=1:size(CaStart, 3)
    CaCh_int(:, 1, i) = timeVector;
    CaCh_int(:, 2, i) = interp1(CaStart(:, 1, i), CaStart(:, 2, i), timeVector, 'spline');
end

RBC_int = RBCStart;
    for i=1:size(RBCStart, 3)
        if options.applyMedianToRBC
            RBC_int(:, 2, i) = medfilt1(RBC_int(:, 2, i), options.medianFilterN);
        end
        if options.applySGolayRBC
            RBC_int(:, 2, i) = sgolayfilt(RBC_int(:, 2, i), 3, options.sgolayPoints_To);
        end
    end

% subplot(224); hold on; plot(timeVector, CaCh_int/max(CaCh_int));
% plot(RBCStart(:, 1), RBCStart(:, 2)/max(RBCStart(:, 2))); hold off; title('Interpolated normalized calcium + RBC');  

%% Convolution and computation of the SS
%convolution = conv(CaCh_int(:, 2, 1), HRF);
%convolution = interp1(timeVector, convolution(1:length(timeVector)), RBCStart(:, 1, 1), 'spline');

%% RSS1 computation
% SSRBC = sum((RBCStart(:, 2) - convolution).^2); % I addendum
% 
% TMP = interp1(timeVector, CaCh_int, CaStart(:, 1), 'linear');
% SSCA = sum((CaStart(1:end-1, 2) - TMP(1:end-1)).^2); % II addendum
% clear TMP;
% 
% RSS1 = SSRBC+SSCA;  
%% RSS1 optimization (using BFGS algorithm, 'fminunc' Matlab function)
[tf, param, opt, finalSSResid, exitFlag, hessian] = OptHRF(CaStart, CaCh_int, RBCStart, RBC_int, options);
% disp(opt);
% disp(param);
%% Plotting results after optimization
% figure; subplot(121); plot(0:dt:(length(tf)-1)*dt,tf); title('Optimized TF')
for i=1:length(pathFrom)
    result(:, i) = conv(CaCh_int(:, 2, i), tf);
end
%% Figure r�sum�
if exist('showFig','var') && showFig
    fig = figure; hold on;
    subplot(221); hold on;
    for i=1:length(pathFrom)
        plot(CaCh_int(:, 1, i), CaCh_int(:, 2, i)/max(CaCh_int(:, 2, i)), 'LineWidth', 2, 'DisplayName', ['Ca ' num2str(i)]);
    end
    title('Interpolated Calcium signal'); legend();
    subplot(223); hold on;
    for i=1:length(pathFrom)
        plot(RBCStart(:, 1, i), RBCStart(:, 2, i), 'LineWidth', 2, 'DisplayName', ['Original RBC ' num2str(i)]);
        plot(RBC_int(:, 1, i), RBC_int(:, 2, i), 'LineWidth', 2, 'DisplayName', ['Original RBC ' num2str(i)]);
    end
    title('RBC signal'); legend();
    subplot(222); plot(0:options.smoothDT:(length(tf)-1)*options.smoothDT,tf, 'LineWidth', 2, 'Color', 'k'); title('Optimized TF');
    subplot(224); hold on;
    for i=1:length(pathFrom)
        plot(RBCStart(:, 1, i), RBCStart(:, 2, i), 'LineWidth', 2, 'DisplayName', ['RBC ' num2str(i)]);
        plot(timeVector, result(1:length(timeVector), i), 'LineWidth', 2, 'DisplayName', ['Prediction ' num2str(i)]);
        %R2(i)= getR2(squeeze(RBCStart(1:length(timeVector), 2, i)), result(1:length(timeVector), i));
    end
    title('Optimized (Best) Prediction'); legend(); hold off;
    hold off;
    %disp(['R-squared value(s): ', num2str(R2)])
end

clear resultStruct;
resultStruct.genOptions = opt;
resultStruct.finalSSResid = finalSSResid;
resultStruct.paramTF = param;
resultStruct.TF = tf;
resultStruct.fileFrom = fileFrom;
resultStruct.fileTo = fileTo;
resultStruct.pathFrom = pathFrom;
resultStruct.pathTo = pathTo;
resultStruct.fromDataRaw = CaStart;
resultStruct.fromDataTreated = CaCh_int;
resultStruct.toDataRaw = RBCStart;
resultStruct.toDataTreated = RBC_int;
%resultStruct.fig = fig;
resultStruct.exitFlag = exitFlag;
resultStruct.hessian = hessian;
resultStruct.date = datetime;
end

