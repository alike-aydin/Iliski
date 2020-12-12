function test_Iliski()
% TEST_ILISKI
%
% function test_Iliski()
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
%   DESCRIPTION: This is an example script of how to use Iliski as scripts.
%__________________________________________________________________________
%   PARAMETERS:
%
%__________________________________________________________________________
%   RETURN:
%
%__________________________________________________________________________
%   EXCEPTION:
%
%__________________________________________________________________________

%% Loading your data
% If the GUI loads the data for the user, here you have to obtain them by
% yourself. We'll use an HDF5 as with the GUI for the sake of the
% example.

inputFile = 'XV4.h5';

From(:, 1) = h5read(inputFile, '/Delta/Ca/ET_200mV_5sec/time');
From(:, 2) = h5read(inputFile, '/Delta/Ca/ET_200mV_5sec/avg');


To(:, 1) = h5read(inputFile, '/DeltaOverBSL/RBC/ET_200mV_5sec/time');
To(:, 2) = h5read(inputFile, '/DeltaOverBSL/RBC/ET_200mV_5sec/avg');

%% Visualizing the data
% So that the example makes more sense

figure; title('Normalized input signals for the TF computation')
hold on;
plot(From(:, 1), From(:, 2)/max(From(:, 2)), 'LineWidth', 2, ...
    'DisplayName', 'From - \Delta Ca^{2+} (a.u.)');
plot(To(:, 1), To(:, 2)/max(To(:, 2)), 'LineWidth', 2, ...
    'DisplayName', 'To - Relative change in RBC velocity');
xlabel('Time (s)'); ylabel('Normalized response'); legend();
set(gca, 'FontSize', 13);
hold off;

%% Defining the optimization parameters
% Parameters are stored in a single structure. Each one is described in the
% documentation of the ILISKI_TF function (see Iliski_TF.m).
% Below we'll use a non-deterministic algorithm to optimize the parameters
% of a single-gamma function.

% Running the algorithm 5 times in a row with the same initial parameters
options.Iterations= 5;
% A median filter over 5 points will be applied to the To signal before
% computing
options.MedianFilterTo = 5;
% No Savitzky-Golay filtering for the To signal
options.SGolayFilterTo = 0;
% No median filter for the From signal
options.MedianFilterFrom = 0;
% The framelen of the 3rd order Savitzky-Golay filter is 99 for the From
% signal
options.SGolayFilterFrom = 99;
% interp1 interpolation method for the From signal (only if it is not a
% boxcar function)
options.InterpolationMethod = 'pchip'; % 'nearest', 'next', 'previous', 'linear','spline','pchip', 'makima', or 'cubic'
% 100 ms of sampling time for the TF and the interpolated From signal
options.SamplingTime = 0.1;
% Working on the 5 to 29 seconds time interval of the From and To signals
options.TimeIntervalRawData = [5 29];
% TF will be computed over 15 seconds
options.DurationTF = 15;
% From signal is not a step function. If you want to generate a Step
% Function, see GenerateStepFunction.m
options.IsFromStep = false;
% Using only the non-deterministic algorithm Simulated Annealing
options.FMinUncAfterSimulAnl = false;


options.Algorithm = 'simulannealbnd'; % 'simulannealbnd', 'fminunc', 'fminsearch', 'fmincon', 'fourier', 'toeplitz'
% Function handle of the single-gamma function to optimize, refer to the
% User Manual for rules to follow to write it.
options.Function = @(p1, p2, p3, p4, t)...
    ((t-p3)>=0).*p4.*(t-p3).^(p1-1).*(p2^p1).*exp(-p2.*(t-p3))./(gamma(p1));

% Starting parametes for the optimization
options.InitialParameters = [6 1 0 1];
% Since SA is a constrainable algorithm, we can use lower and upper bounds
% for the parameters
options.LowerBoundParameters = [0.001 0.001 0.001 0.001];
% 3rd upper bound is 1 because it is the delay between Calcium and RBC
% velocity responses which we know is < 1 sec.
options.UpperBoundParameters = [10 10 1 10];

%% Computing the TF

f = waitbar(0, 'Progress stays at 0, it is normal, wait while computation occurs.', 'Name', 'Computing your TF(s)...');
try
    resultsTF = Iliski_TF(From, To, options);
    close(f);
catch ME
    close(f);
    rethrow(ME)
end

%% Plotting the resulting TFs and Predictions

% If it was an optimization and not a deconvolutional approach, the TF
% corresponding to the initial parameters can be plotted alongside the
% computed one.
showInitialTF = false;

figure;
subplot(221); title('From'); hold on;
plot(resultsTF.InputData.From(:, 1), resultsTF.InputData.From(:, 2), ...
    'LineWidth', 2, 'DisplayName', 'Raw');
plot(resultsTF.Computed.FromTreated(:, 1), ...
    resultsTF.Computed.FromTreated(:, 2), 'LineWidth', 2, ...
    'DisplayName', 'Treated');
xlabel('Time (s)'); ylabel('\Delta Ca^{2+} (a.u.)'); legend();
set(gca, 'FontSize', 13);
hold off;

subplot(222); title('To'); hold on;
plot(resultsTF.InputData.To(:, 1), resultsTF.InputData.To(:, 2), ...
    'LineWidth', 2, 'DisplayName', 'Raw');
plot(resultsTF.Computed.ToTreated(:, 1), ...
    resultsTF.Computed.ToTreated(:, 2), 'LineWidth', 2, ...
    'DisplayName', 'Treated');
xlabel('Time (s)'); ylabel('Relative change in RBC velocity'); legend();
set(gca, 'FontSize', 13);
hold off;

subplot(223); title('TF(s)'); hold on;
if isfield(resultsTF.Header, 'InitialTF') && showInitialTF
    % Displayed only if the field exists, i.e. if it was an optimization
    % and not a deconvolutional approach
    plot(resultsTF.Header.InitialTF(:, 1), ...
        resultsTF.Header.InitialTF(:, 2), 'LineWidth', 2, ...
        'DisplayName', 'Starting TF');
else
    % Plotting a single point, to keep the colors coherent between the TFs
    % and the Predictions
    legend('AutoUpdate', 'off'); %Not to show it in the legend
    plot(0, 0, 'LineWidth', 0.00001);
    legend('AutoUpdate', 'on');
end
for i=1:resultsTF.Header.Iterations
    % Plotting every TF computed
    plot(resultsTF.Computed.TF(:, 1, i), resultsTF.Computed.TF(:, 2, i), ...
        'LineWidth', 2, 'DisplayName', ['Computed TF n°' num2str(i)]);
end
xlabel('Time (s)'); ylabel('TF Amplitude (a.u.)'); legend();
set(gca, 'FontSize', 13);
hold off;

subplot(224); title('Prediction(s) vs. Reality'); hold on;
plot(resultsTF.Computed.ToTreated(:, 1), ...
    resultsTF.Computed.ToTreated(:, 2), 'LineWidth', 2, ...
    'DisplayName', 'Treated To');
for i=1:resultsTF.Header.Iterations
    plot(resultsTF.Computed.Prediction(:, 1, i), ...
        resultsTF.Computed.Prediction(:, 2, i), 'LineWidth', 2, ...
        'DisplayName', ['Prediction with TF n°' num2str(i)]);
end
xlabel('Time (s)'); ylabel('Relative change in RBC velocity'); legend();
set(gca, 'FontSize', 13);
hold off;
suptitle('Summary of the computation');

%% Saving the results in an XLS file and sending them to the MATLAB workspace
n = ['IliskiOutput_' datestr(now, 'ddmmyy_hhMMss')];

assignin('base', n, resultsTF);

f = waitbar(0, 'Progress stays at 0, it is normal, wait while saving occurs.', 'Name', 'Saving your TF(s)...');
try
    %Iliski_saveResultsAsXLS(resultsTF, [n '.xlsx']);
    close(f);
catch ME
    close(f);
    rethrow(ME);
end

end

