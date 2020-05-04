function [resultStruct]= buildTF_GUIFunc_Full(fileFrom, pathFrom, fileTo, pathTo,...
    options)


% Ex:

% Modality = 'ET_250mV_5sec_ZeroTimeShift';
% Tech = 'Step_fUS_HP';
% MatFile = 'Init_1p15_0p36_0p001_0p04.mat';  % Init_6_1_0_1.mat
% Mouse = 'VT43';

%FILE = 'VT43_Dom.h5';
%to perform optimization on multiple trials just add the trials names to
%the following cell arrays
%PATH_From = {'/DeltaOverBSL/FUS/HighSpeed/SV/ET_250mV_5sec/ROI2/avg'};  %PATH_From = {'/DeltaOverBSL/Ca/ET_250mV_120msec/avg'};  '/DeltaOverBSL/FUS/LowSpeed/SV/ET_250mV_5sec/ROI2/avg'

% Step or RBC? If StepON is true, Calcium become the 'To' signal, if false calcium is 'From' signal
%stepON= true; 
%PATH_To = {'/DeltaOverBSL/FUS/HighSpeed/SV/ET_250mV_5sec/ROI2/avg'}; %PATH_To = {'/DeltaOverBSL/RBC/ET_250mV_120msec/avg'}; {'/DeltaOverBSL/FUS/LowSpeed/SV/ET_1p5V_120msec/ROI2/avg'};
%PATH_step = {'/5sec'};
%FILE_step = 'steps_samp40ms.h5'; 

%dt = 0.04; % 0.05 for all BUT step 120ms (set 0.04); for convolution; if you want to optimize on smoothing, change cost function (in findTF.m)!
%range = [5, 27]; % [5, 27]; for ET 1% 5sec. [5, 20]; ET 1% single sniff
%durationTF = 15; % 15sec


%twiceOpt = false;
%saveOut = true;
% Number of runs, set it >1 is you want it to be run more than once 
% (useful only if you choose simannealing algorithm)
%Nrun= 20; % ATTENTION: increasing this number turns into a very long computation time!

% Options structure
% options.medianFilterN = 5;
% options.sgolayPoints_To = 299;
options.applyMedianToRBC = false;
options.applySGolayRBC = false;
options.interpMethod = 'spline'; %'spline'/'pchip'
options.ruleOutImag = false;
options.smoothDT = dt;
options.range = range;
options.durationTF = durationTF;
options.func = 'gamma'; % 'gamma'/'logit'/'toeplitz'/'fourier'
options.paramsTF = startParams; % p = [6, 1, 0, 1] for 1-gamma, p = [2 4 1 2 0.3 0.3]; for 2-logit

if strcmp(options.func, 'gamma')
    options.upBnd = [10, 10, 0.001, 10]; %ones(1, 4) * 7; %ones(1, 4) * 7; only if algo allow it (simmulated annealing for ex) for stpe increase 7 to 10
    options.lwBnd = [0.001, 0.001, 0.001, 0.001]; %zeros(1, 4)+0.001;
    %options.lwBnd(3) = 0.3;
elseif strcmp(options.func, 'logit')
    options.upBnd = ones(1, 6) * 10;
    options.lwBnd = zeros(1, 6)+0.001; options.lwBnd(5) = 1;   
end


optionsAnneal = saoptimset('Display','off',...     % change iter-> off to display no output
    'MaxFunEval', Inf,...  % max number of function evaluations allowed
    'MaxIter', Inf,...      % max number of iteration allowed
    'TolFun',1e-8, ... % termination tolerance on the function value
    'ObjectiveLimit', 0);
options.algo = 'simulannealbnd'; %simulannealbnd/fmincon/fminunc/fminsearch/toeplitz/fourier
options.optAlgo = optionsAnneal;


% TF computing
clear resultStruct
resultStruct = findTF(fileFrom, pathFrom, fileTo, pathTo, options, false);
end





