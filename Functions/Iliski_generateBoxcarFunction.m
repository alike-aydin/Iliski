function [timeVector, boxcarVector] = Iliski_generateBoxcarFunction(dT, bslDuration, stimDuration, totalDuration)
% ILISKI_GENERATEBOXCARFUNCTION Generate a boxcar timecourse given the parameters. 
%
% function [timeVector, stepVector] = Iliski_generateBoxcarFunction(dT, bslDuration,
%   stimDuration, totalDuration)
%
%   Author: Ali-Kemal Aydin, PhD student
%   Date: May 26th, 2020
%   Mail: ali-kemal.aydin@inserm.fr
%   Affiliation: 
%       * INSERM U1128, Laboratory of Neurophysiology and New Microscopy, Université de Paris, Paris, France
%       * INSERM, CNRS, Institut de la Vision, Sorbonne Université, Paris, France
%   License:  Creative Commons Attribution 4.0 International (CC BY 4.0)
%       See LICENSE.txt or <a href="matlab:web('https://creativecommons.org/licenses/by/4.0/')">here</a>
%       for a human-readable version.
%
%   DESCRIPTION: Generate a Boxcar function as a down-state baseline,
%   up-state stimulation and down-state end of the timecourse. First point
%   is at t = dT (s). Throw an exception if the function parameters
%   durations are not a multiple of dT.   
%__________________________________________________________________________
%   PARAMETERS:
%       dT (float): interpoint duration (s).
%
%       bslDuration (float): length of the baseline down-state (s).
%
%       stimDuration (float): length of the stimulation up-state (s).
%
%       totalDuration (float): length of the total timecourse (s).
%
%__________________________________________________________________________
%   RETURN:
%       timeVector ([]): 1D array of all the timepoints (ceiled value of
%       totalDuration/dT number of points)
%
%       stepVector ([]): values of the function, either 0 (down) or 1
%       (up).
%__________________________________________________________________________
%   EXCEPTION:
%       Iliski:StepFunctionGenerator:IncorrectParameters
%           If the total duration of the function, the boxcar duration or
%           the baseline length aren't multiple of dT.
%__________________________________________________________________________

if mod(totalDuration, dT) || mod(bslDuration, dT) || ...
        mod(stimDuration, dT)
    msgError = ['Your Boxcar function parameters should be multiple of the dT.'];
    err = MException('Iliski:BoxcarFunctionGenerator:IncorrectParameters', ...
        msgError);
    throw(err);
else
    boxcarVector = zeros(1, ceil(totalDuration/dT)+1);
    timeVector = 0:dT:dT*length(boxcarVector)-dT;
    boxcarVector(round(bslDuration/dT)+1:round(bslDuration/dT)+round(stimDuration/dT)+1) = ...
        ones(1, round(stimDuration/dT)+1);
end

end

