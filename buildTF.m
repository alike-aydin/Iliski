function results = buildTF(FileFrom, PathFrom, FileTo, PathTo, options, savingName, savingFile)

Modality = 'ET_250mV_5sec';
Tech = 'Ca_fUS_HP';
MatFile = 'Init_5p85_13_0p32_0p018.mat';  % Init_6_1_0_1.mat
Mouse = 'XV5';

% FileFrom = 'XV5_Dom.h5';
% %to perform optimization on multiple trials just add the trials names to
% %the following cell arrays
% PathFrom = {'/DeltaOverBSL/Ca/ET_250mV_5sec/avg'};  %PATH_CA = {'/DeltaOverBSL/Ca/ET_250mV_120msec/avg'};  '/DeltaOverBSL/FUS/LowSpeed/SV/ET_250mV_5sec/ROI2/avg'
%
% % Step or RBC? If StepON is true, Calcium become the 'To' signal, if false calcium is 'From' signal
% stepON= false; % if false, it takes the info on RBC
% PathTo = {'/DeltaOverBSL/FUS/HighSpeed/SV/ET_250mV_5sec/ROI2/avg'}; %PATH_RBC = {'/DeltaOverBSL/RBC/ET_250mV_120msec/avg'}; {'/DeltaOverBSL/FUS/LowSpeed/SV/ET_1p5V_120msec/ROI2/avg'};
% PATH_step = {'/5sec'};
% FILE_step = 'steps_samp40ms.h5';
tic

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
clear matVar results resultStruct
results = cell(options.Nrun, 1);
for i= 1:options.Nrun
    if options.twiceOpt
        options.algo = 'simulannealbnd';
        options.optAlgo = optionsAnneal;
        
        resultStruct = findTF(FileFrom, PathFrom, FileTo, PathTo, options);
        
        options.paramsTF = resultStruct.paramTF;
        options.paramsTF_FirstStep = resultStruct.paramTF;
        
        options.algo = 'fminunc';
        options.optAlgo = optionsNunc;
        resultStruct = findTF(FileFrom, PathFrom, FileTo, PathTo, options);
        
        % has the second algorithm changed anything?
        optParamDiff = resultStruct.paramTF - options.paramsTF_FirstStep;
        % disp(['Param Diff: ', num2str(optParamDiff)])
    else
        if strcmp(options.algo, 'simulannealbnd')
            options.optAlgo = optionsAnneal;
        elseif strcmp(options.algo, 'fmincon')
            options.optAlgo = optionsCon;
        elseif strcmp(options.algo, 'fminunc')
            options.optAlgo = optionsNunc;
        elseif strcmp(options.algo, 'fminsearch')
            options.optAlgo = optionsMinSearch;
        end
        
        resultStruct = findTF(FileFrom, PathFrom, FileTo, PathTo, options);
    end
    results{i} = resultStruct;

    % Saving out results
    if options.saveOut
        %if input('Save ?') == 1
        try
            matVar = load(MatFile); % it looks for the output structure file
        catch
            matVar.results = struct(); % if not found, it makes a new one
        end
        if twiceOpt
            try
                matVar.results.(Modality).(Tech).(Mouse).(['DT' num2str(options.smoothDT*1000)]).(options.func).('simulannealbnd_fminunc') = ...
                    [matVar.results.(Modality).(Tech).(Mouse).(['DT' num2str(options.smoothDT*1000)]).(options.func).('simulannealbnd_fminunc') ...
                    resultStruct];
            catch ME
                if strcmp(ME.identifier, 'MATLAB:nonExistentField')
                    matVar.results.(Modality).(Tech).(Mouse).(['DT' num2str(options.smoothDT*1000)]).(options.func).('simulannealbnd_fminunc') = ...
                        resultStruct;
                else
                    rethrow(ME);
                end
            end
        else
            try
                matVar.results.(Modality).(Tech).(Mouse).(['DT' num2str(options.smoothDT*1000)]).(options.func).(options.algo) = ...
                    [matVar.results.(Modality).(Tech).(Mouse).(['DT' num2str(options.smoothDT*1000)]).(options.func).(options.algo) ...
                    resultStruct];
            catch ME
                if strcmp(ME.identifier, 'MATLAB:nonExistentField')
                    matVar.results.(Modality).(Tech).(Mouse).(['DT' num2str(options.smoothDT*1000)]).(options.func).(options.algo) = ...
                        resultStruct;
                else
                    rethrow(ME);
                end
            end
        end
        results = matVar.results;
        save(MatFile, 'results');
        %end
        if options.Nrun>1
            close all
        end
    end
end

if options.Nrun>1
    load handel
    sound(y,Fs)
end
end

%% Testing TFs

% %useTF(fileFrom, pathFrom, fileTo, pathTo, options);
% clear options
% options.medianFilterN = 5;
% options.applyMedianToRBC = false;
% options.sgolayPoints_To = 299;
% options.applySGolayRBC = true;
% options.interpMethod = 'spline'; %'spline'/'pchip'
% options.ruleOutImag = false;
% options.smoothDT = 0.04;
% options.range = [5, 27];
% options.durationTF = 15;
% options.func = 'gamma'; % 'gamma'/'logit'
% options.AmpliOptON= true;
% options.paramsTF = [1, 0.3, 1.00E-03, 0.04];
% options.AmpliOptRange= [12, 18]; % for our TF [12, 18], for HRF [12, 30], although it does not change anything in the P coeff
% options.title= {'Interpolated Calcium signal','Optimized TF vs classic HRF',...
%     'Interpolated RBC signal', 'Optimized (Best) Prediction (optimized amplit.)'};
%
% %PATH_CA = {'/DeltaOverBSL/RBC/ET_250mV_5sec/avg'};
%
% useTF('steps_samp40ms.h5', {'/5sec'}, 'VT43_Dom.h5', {'/DeltaOverBSL/FUS/HighSpeed/SV/ET_250mV_5sec/ROI2/avg'}, options);


