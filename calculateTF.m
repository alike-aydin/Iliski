%% calculateTF.m
% Calculate and return the transfer function given the datasets and the
% method.
% From, To : 1D scalar vector, datasets
% Methods : 'toeplitz', 'fourier'

function TF = calculateTF(From, To, method)
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