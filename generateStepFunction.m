function [timeVector, stepVector] = generateStepFunction(dT, bslDuration, stimDuration, totalDuration)
%function [timeVector, stepVector] = generateStepFunction(dT, bslDuration,
%   stimDuration, totalDuration)
%
%   Author : Ali-Kemal Aydin, PhD student
%   Date : May 26th, 2020
%   Mail: ali-kemal.aydin@inserm.fr
%   Affiliation : INSERM U1128, Paris & U968, Institut de la Vision, Paris
%   License:  Creative Commons Attribution 4.0 International (CC BY 4.0)
%       See LICENSE.txt or <a href="matlab:web('https://creativecommons.org/licenses/by/4.0/')">here</a>
%       for a human-readable version.
%
%   DESCRIPTION : Generate a Step function as a down-state baseline,
%   up-state stimulation and down-state end of the timecourse. First point
%   is at t = dT (s).
%__________________________________________________________________________
%   PARAMETERS:
%       dT (float) : interpoint duration (s).
%
%       bslDuration (float) : length of the baseline down-state (s).
%
%       stimDuration (float) : length of the stimulation up-state (s).
%
%       totalDuration (float) : length of the total timecourse (s).
%
%__________________________________________________________________________
%   RETURN:
%       timeVector ([]) : 1D array of all the timepoints (ceiled value of
%       totalDuration/dT number of points)
%
%       stepVector ([]) : values of the function, either 0 (down) or 1
%       (up).
%__________________________________________________________________________

if mod(totalDuration, dT) || mod(bslDuration, dT) || ...
        mod(stimDuration, dT)
    msgError = ['Your step function parameters should be multiple of the dT.'];
    err = MException('Iliski:StepFunctionGenerator:IncorrectParameters', ...
        msgError);
    throw(err);
else
    stepVector = zeros(1, ceil(totalDuration/dT));
    timeVector = dT:dT:dT*length(stepVector);
    stepVector(ceil(bslDuration/dT):ceil((bslDuration+stimDuration)/dT)-1) = ...
        ones(1, ceil(stimDuration/dT));
end

end

