function [time] = getTimeFromPath(file, path)
% GETTIMEFROMPATH Recover the time vector inside the HDF5 file for a given
% timeserie.
%
% function [time] = getTimeFromPath(file, path)
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
%   DESCRIPTION: Return the matching time vector corresponding to a
%   timeserie from the same HDF5 file. Time vector is supposed to be in the
%   same folder as the timeserie inside the HDF5 file and to be called
%   'time'.
%__________________________________________________________________________
%   PARAMETERS:
%       file (str): HDF5 file containing both the timeserie and the
%       timevector.
%
%       path (str): Path to the timeserie inside the HDF5 file.
%__________________________________________________________________________
%   RETURN:
%       time ([double]): Corresponding time vector.
%__________________________________________________________________________
%   EXCEPTION:
%       Iliski:RecoverTimeVector:TimeNotFound
%           If the time vector has not been found at the expected location
%           in the HDF5 file.
%__________________________________________________________________________

splitted = strsplit(path, '/');
splitted(end) = {'time'};
path = strjoin(splitted, '/');
try
    time = h5read(file, path);
catch ME
    if strfind(ME.message, 'not found')
        errID = 'Iliski:RecoverTimeVector:TimeNotFound';
        errMsg = ['Time vector for your data was not found at the expected ' ...
            'place in the HDF5 file. Check the arborescence of your file.\n' ...
            'Expected path was : ' path];
        throw(MException(errID, errMsg));
    else
        rethrow(ME);
    end
end
end

