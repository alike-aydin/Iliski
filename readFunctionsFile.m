function [fctNames,fctHandles] = readFunctionsFile(filename)
%function [fctNames,fctHandles] = readFunctionsFile(filename)
%
%   Author : Ali-Kemal Aydin, PhD student
%   Date : May 28th, 2020
%   Mail: ali-kemal.aydin@inserm.fr
%   Affiliation : INSERM U1128, Paris & U968, Institut de la Vision, Paris
%   License:  Creative Commons Attribution 4.0 International (CC BY 4.0)
%       See LICENSE.txt or <a href="matlab:web('https://creativecommons.org/licenses/by/4.0/')">here</a> 
%       for a human-readable version.
%
%   DESCRIPTION : Read and parse the file containing the default parametric
%   functions one can optimize with Ilsiki. The functions returns both the 
%   names of the functions and their handles in two different cell arrays.
%   The file has the following properties:
%       - named 'DefaultParametricFunctions_Iliski.txt' (first parameter);
%       - one function per line, without any header;
%       - FUNCTION NAME: HANDLE
%           * The name of the function is everything that comes before the
%           colon. It can be spaced and with special characters, it is
%           meant to be displayed in the GUI.
%           * The handle is a MATLAB-compatible function handle, without
%           any limitations on the number of parameters. The order and
%           names of the parameters will be kept inside the GUI. The last
%           parameter is _always_ the time.
%           * See below for an example.
%
%   EXAMPLE of file content:
%       1-Gamma: @(p1, p2, p3, p4, t) heaviside(t-p3).*p4.*(t-p3).^(p1-1).*(p2^p1).*exp(-p2.*(t-p3))./(gamma(p1))
%       2-Logit: @
%__________________________________________________________________________
%   PARAMETERS:
%       filename (str) : name and path if needed to the file.
%
%__________________________________________________________________________
%   RETURN:
%       fctNames ({}) : cell array of the functions name.
%
%       fctHandles ({}) : cell array of the functions handle.
%__________________________________________________________________________

try
    fileID = fopen(filename);
    content = textscan(fileID, '%s%s', 'Delimiter', {':'}, 'CollectOutput', 1);
    fclose(fileID);
catch ME
    msg = ['Error while reading the functions file: ', filename,'.'];
    causeException = MException(...
        'Iliski:ParametricFunctions:FileReadingError', msg);
    rethrow(addCause(ME, MException));
end

content = content{1};
nbFcts = size(content, 1);
fctNames = {};
fctHandles = {};

for i=1:nbFcts
    fctNames{i} = content{i, 1};
    try
        fctHandles{i} = str2func(content{i, 2});
    catch ME
        msg = ['Error while creating the function handle, in line ', ...
            num2str(i), ' of ', filename, '.'];
        causeException = MException(...
            'Iliski:ParametricFunctions:ParsingHandleError', msg);
        rethrow(addCause(ME, causeException));
    end
end

end

