%% calculateTF.m
% Calculate and return the transfer function given the datasets and the
% method.
% From, To : 1D scalar vector, datasets
% Methods : 'toeplitz', 'fourier', '2gamma', '1gamma', '2logit, 

function TF = calculateTF(From, To, method, smoothing, timeVect)
% size(From)
% size(To)
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
    elseif strcmp(method, 'fourier')
        Fourier = fft(To)./ fft(From);
        TF = ifft(Fourier);
    elseif strcmp(method, '2gamma')
        TF = Gamma(From, To, timeVect);
    end
    
    if exist('smoothing', 'var')
        TF = smooth(TF, smoothing);
    end
end