function [sortedResults] = sortTFComputations(results, direction)
%function [sortedResults] = sortTFComputations(results)
%
%   Author : Ali-Kemal Aydin, PhD student
%   Date : June 1st, 2020
%   Mail: ali-kemal.aydin@inserm.fr
%   Affiliation : INSERM U1128, Paris & U968, Institut de la Vision, Paris
%   License:  Creative Commons Attribution 4.0 International (CC BY 4.0)
%       See LICENSE.txt or <a href="matlab:web('https://creativecommons.org/licenses/by/4.0/')">here</a> 
%       for a human-readable version.
%
%   DESCRIPTION:  Sort the results of multiple TF computations by their
%   residual sum values.
%__________________________________________________________________________
%   PARAMETERS:
%       results ({}): Output of the buildTF function.
%
%       direction (str): Sorting direction, specified as 'ascend' or 
%       'descend'.
%__________________________________________________________________________
%   RETURN:
%       sortedResults ({}): Sorted cell array of the TF
%       computation. 
%__________________________________________________________________________

% If there is more than a single run
if length(results) > 1
    SSResids = [];
    
    for i=1:length(results)
        SSResids(i) = results{i}.finalSSResid;
    end
    [~, sortedIdx] = sort(SSResids, direction);
    
    sortedResults = {};

    for i=1:length(sortedIdx)
        sortedResults{i} = results{sortedIdx(i)};
    end
else
   sortedResults = results; 
end

end

