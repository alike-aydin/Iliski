function SSResid = Iliski_ssresidEval(param, From, To, options)
% ILISKI_SSRESIDEVAL Cost-function for the computation of the Transfer Function.
%
% function SSResid = Iliski_ssresidEval(param, From, To, options)
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
%   DESCRIPTION: Calculate the residual sum of the squares, as a cost
%   function, for the prediction of a TF. TF is computed and convoluted
%   with the input (From). Result of the convolution is interpolated to 
%   match the timevector of the output (To) before comparing them, by 
%   computing the RSS. If the parameters of the TF contains an imaginary 
%   part, the convolution and the RSS does too and the function returns
%   +Inf to get rid of this TF. 
%__________________________________________________________________________
%   PARAMETERS:
%       param ([]): Parameters of the TF.
%
%       From ([double, double]): Timeserie of the input signal, first
%       column being the time vector.
%
%       To ([double, double]): Timeserie of the output signal, first colmun
%       being the time vector.
%
%       options (struct): Options structure for the computation, see 
%       BUILDTF for further details.
%__________________________________________________________________________
%   RETURN:
%       SSResid (double): Residual sum of the squares between the
%       prediction, i.e. the convolution of the TF and the input signal,
%       and the actual output signal. +Inf if there is any imaginary part
%       to the TF.
%__________________________________________________________________________


time = [0:options.SamplingTime:options.DurationTF];
cellParams = num2cell(param);
f = options.Function(cellParams{:}, time);

convolution = conv(From(:, 2), f); 
convolution = interp1(From(:, 1), convolution(1:length(From(:, 2))), To(:, 1), options.InterpolationMethod);
SSPredic = sum((To(1:end-1, 2) - convolution(1:end-1)).^2);

SSResid = SSPredic;

if imag(SSResid) ~= 0
    SSResid = Inf;
    warning(['Some of the computed parameters contain an imaginary part.']);
end

end