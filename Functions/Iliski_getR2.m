function rsq = Iliski_getR2(Y, Yfit)
% ILISKI_GETR2 Calculate the R� between two timeseries.
%
% function rsq = Iliski_getR2(Y, Yfit)
%
%   Author: Ali-Kemal Aydin, PhD student
%   Mail: ali-kemal.aydin@inserm.fr
%   Affiliations:
%       * INSERM U1128, Laboratory of Neurophysiology and New Microscopy, Universit� de Paris, Paris, France
%       * INSERM, CNRS, Institut de la Vision, Sorbonne Universit�, Paris, France
%   License:  Creative Commons Attribution 4.0 International (CC BY 4.0)
%       See LICENSE.txt or <a href="matlab:web('https://creativecommons.org/licenses/by/4.0/')">here</a>
%       for a human-readable version.
%
%   DESCRIPTION: Compute the R� between two timeseries, Y and Y_fit.
%   R� = 1 - (Residual Sum of the Squares between Y and Y_fit) /
%   (Variance(Y) * (Number of values - 1 ))
%__________________________________________________________________________
%   PARAMETERS:
%       Y ([]): Timeserie no.1 
%
%       Yfit ([]): Timeserie no.2
%__________________________________________________________________________
%   RETURN:
%       rsq (double): R� value.
%__________________________________________________________________________

    ssresid = sum((Y - Yfit).^2);
    sstotal = (length(Y)-1) * var(Y);
    rsq = 1 - ssresid/sstotal;
end