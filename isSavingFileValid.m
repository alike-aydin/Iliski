function [errMsg] = isSavingFileValid(filePath)
% ISSAVINGFILEVALID Check the validity of a file to save results in.
%
% function [valid] = isSavingFileValid(filePath)
%
%   Author: Ali-Kemal Aydin, PhD student
%   Created: June 17th, 2020
%   Mail: ali-kemal.aydin@inserm.fr
%   Affiliation: INSERM U1128, Paris & U968, Institut de la Vision, Paris
%   License:  Creative Commons Attribution 4.0 International (CC BY 4.0)
%       See LICENSE.txt or <a href="matlab:web('https://creativecommons.org/licenses/by/4.0/')">here</a>
%       for a human-readable version.
%
% DESCRIPTION : Check if the path exists, if the file has a name and if the
% file is a .mat. Return the
%__________________________________________________________________________
% PARAMETERS:
%   filePath (str): path to the file.
%_____________________________________________________________
% RETURN:
%	errMsg (str): empty if valid, contains the error message otherwise.
%__________________________________________________________________________

errMsg = '';

[path, name, ext] = fileparts(filePath);
if ~strcmp(ext, '.mat')
    errMsg = 'Output file must be a .mat file.';
elseif isempty(name)
    errMsg = 'You have to specify a filename.';
elseif ~isfolder(path)
    errMsg = 'You have to specify an existing folder.';
end

end

