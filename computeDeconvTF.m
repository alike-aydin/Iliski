function TF = computeDeconvTF(From, To, method)
% COMPUTEDECONVTF Computes the different deconvolutional TFs.
%
% function TF = computeDeconvTF(From, To, method)
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
%   DESCRIPTION: Computes the deconvolutional TFs.
%__________________________________________________________________________
%   PARAMETERS:
%       From ([double]): 1D array of the input data.
%
%       To ([double]): 1D array of the output data. Shall have the same
%       time sampling than the From signal.
%
%       method (str): Deconvolutional method to use for the TF, either 
%       'toeplitz' or 'fourier'.
%
%__________________________________________________________________________
%   RETURN:
%       TF ([double]): 1D array containing the resulting TF.
%__________________________________________________________________________
%   EXCEPTION:
%        
%__________________________________________________________________________
    if strcmp(method,'toeplitz')
        N = length(From);
        Toeplitz = toeplitz([From zeros(1, N-1)], [From(1) zeros(1, N-1)]);
        Toeplitz = [ones(size(Toeplitz,1), 1) Toeplitz];
        
         if length(To) < size(Toeplitz, 1)
             To = [To zeros(1, size(Toeplitz, 1)-length(To))];
         elseif length(To) > size(Toeplitz, 1)
             To = To(1:size(Toeplitz, 1));
         end

        TF = Toeplitz\[To]';
        TF = TF';
    elseif strcmp(method, 'fourier')
        Fourier = fft(To)./ fft(From);
        TF = ifft(Fourier);
    end
    
end