%% getR2.m
% Return the R² value for the given parameters
% 
% Y : 1D scalar vector, real data
% Yfit : 1D scalar vector, fitted data

function rsq = getR2(Y, Yfit)
% GETR2 Calculate the R² between two timeseries.
%
% function rsq = getR2(Y, Yfit)
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
%   DESCRIPTION: Compute the R² between two timeseries, Y and Y_fit.
%   R² = 1 - (Residual Sum of the Squares between Y and Y_fit) /
%   (Variance(Y) * (Number of values - 1 ))
%__________________________________________________________________________
%   PARAMETERS:
%       Y ([]): Timeserie no.1 
%
%       Yfit ([]): Timeserie no.2
%__________________________________________________________________________
%   RETURN:
%       rsq (double): R² value.
%__________________________________________________________________________

    ssresid = sum((Y - Yfit).^2);
    sstotal = (length(Y)-1) * var(Y);
    rsq = 1 - ssresid/sstotal;
end