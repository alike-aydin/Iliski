function [time, sign] = cutSignal(time, sign, range)
% CUTSIGNAL Reduces the duration of a signal to a given time interval. 
%
% function [time, sign] = cutSignal(time, sign, range)
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
%   DESCRIPTION: Reduces the length of a timeserie to a given range,
%   returning the new time vector and timeserie.
%__________________________________________________________________________
%   PARAMETERS:
%       time ([double]): Time vector of the original signal.
%
%       sign ([]): Timeserie of the original signal.
%
%       range ([double, double]): Lower and upper value of the new time
%       range, must be inside the original time range or an
%       UnadaptedTimeRange exception will be raised.
%__________________________________________________________________________
%   RETURN:
%       time ([double]): New time vector after cutting down to the wanted
%       range.
%
%       sign ([]): New timeserie afeter cutting down to the wanted range.
%__________________________________________________________________________
%   EXCEPTION:
%       Iliski:CutSignal:UnadaptedTimeRange
%           If the desired time range is outside the current one for the
%           signal.
%__________________________________________________________________________

    if range(1) < min(time) || range(1) > max(time) || ... 
        range(2) < min(time) || range(2) > max(time)
        errID = 'Iliski:CutSignal:UnadaptedTimeRange';
        errMsg = 'The desired time range is outside the actual one. Check your values.';
        throw(MException(errID, errMsg));
    end
    
    underTime = min(find(time >= range(1)));
    aboveTime = min(find(time >= range(2)));
    
    time = time(underTime:aboveTime);
    sign = sign(underTime:aboveTime);
end