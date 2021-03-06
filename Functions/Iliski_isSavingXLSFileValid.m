function [errMsg] = Iliski_isSavingXLSFileValid(filePath)
% ILISKI_ISSAVINGXLSFILEVALID Check the validity of a file to save results in.
%
% function [valid] = Iliski_isSavingXLSFileValid(filePath)
%
%   Author: Ali-Kemal Aydin, PhD student
%   Created: December 3rd, 2020
%   Mail: ali-kemal.aydin@inserm.fr
%   Affiliation: 
%       * INSERM U1128, Laboratory of Neurophysiology and New Microscopy, Université de Paris, Paris, France
%       * INSERM, CNRS, Institut de la Vision, Sorbonne Université, Paris, France
%   License:  Creative Commons Attribution 4.0 International (CC BY 4.0)
%       See LICENSE.txt or <a href="matlab:web('https://creativecommons.org/licenses/by/4.0/')">here</a>
%       for a human-readable version.
%
%   DESCRIPTION: Check if the path exists, if the file has a name and if the
%   file is a .mat. Return the corresponding error message if needed, an
%   empty char if everything is ok.
%__________________________________________________________________________
%   PARAMETERS:
%       filePath (str): path to the file.
%_____________________________________________________________
%   RETURN:
%       errMsg (str): empty if valid, contains the error message otherwise.
%__________________________________________________________________________

errMsg = '';

[path, name, ext] = fileparts(filePath);
if ~strcmp(ext, '.xlsx') && ~strcmp(ext, '.xls')
    errMsg = 'Output file must be an excel file (*.xlsx or *.xls).';
elseif isempty(name)
    errMsg = 'You have to specify a filename.';
elseif ~isfolder(path)
    errMsg = 'You have to specify an existing folder.';
end

end

