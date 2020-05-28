function [paramNames] = extractParametersFromHandle(fctHandle)
%function [paramNames] = extractParametersFromHandle(fctHandle)
%
%   Author : Ali-Kemal Aydin, PhD student
%   Date : May 28th, 2020
%   Mail: ali-kemal.aydin@inserm.fr
%   Affiliation : INSERM U1128, Paris & U968, Institut de la Vision, Paris
%   License:  Creative Commons Attribution 4.0 International (CC BY 4.0)
%       See LICENSE.txt or <a href="matlab:web('https://creativecommons.org/licenses/by/4.0/')">here</a> 
%       for a human-readable version.
%
%   DESCRIPTION : Extract the parameters name from an anonymous function
%   handle. Check the validity of the function to
%   optimize:
%       - At least 2 parameters
%       - Last parameter is named 't'
%__________________________________________________________________________
%   PARAMETERS:
%       fctHandle (handle) : handle of the function.
%
%__________________________________________________________________________
%   RETURN:
%       paramNames ({}) : cell array of the function parameters.
%__________________________________________________________________________

strFct = func2str(fctHandle);

% It should be at least 3, as the handle looks like @(param)function 
% ['@', 'param', 'function']
handleSplitted = split(strFct, ["(", ")"]);
if length(handleSplitted) < 3
    msgError = ['The handle function does not correspond to the required format.', ...
        'See help for further details about writing a correct handle function.'];
    err = MException('Iliski:ParametricFunctions:IncorrectHandleFunction', ...
        msgError);
    throw(err);
end

% There should be at least 2 parameters 
paramNames = split(handleSplitted{2}, ",");
if length(paramNames) < 2 || ~strcmp(paramNames{end}, 't')
    msgError = ['There should be at least 2 parameters and the last one ' ...,
        'has to be named "t".'];
    err = MException('Iliski:ParametricFunctions:IncorrectParameters', ...
        msgError);
    throw(err);
end

end

