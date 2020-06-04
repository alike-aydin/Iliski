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
if results.Header.Nrun > 1
    [~, sortedIdx] = sort(results.Computed.ResidualSumSquare, direction);
    
    sortedResults = results;
    
    sortedResults.Computed.TF = results.Computed.TF(:, :, sortedIdx);
    sortedResults.Computed.Prediction = results.Computed.Prediction(:, :, sortedIdx);
    sortedResults.Computed.Parameters = results.Computed.Parameters(:, sortedIdx);
    sortedResults.Computed.Hessian = results.Computed.Hessian(:, sortedIdx);
    sortedResults.Computed.ExitFlag = results.Computed.ExitFlag(sortedIdx);
    sortedResults.Computed.Pearson = results.Computed.Pearson(sortedIdx);
    sortedResults.Computed.ResidualSumSquare = results.Computed.ResidualSumSquare(sortedIdx);
else
    sortedResults = results;
end

end

