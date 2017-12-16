function k = kvec( N )
%KVEC return vector of wavenumbers in FFT layout
%
% Copyright (c) 2017 Sander Wildeman
% Distributed under the MIT License, see LICENSE file

    if mod(N,2)==0 % N even
        k = [(0:N/2-1), ((N/2):(N-1)) - N];
    else % N odd
        k = [(0:(N-1)/2), ((N+1)/2:(N-1)) - N];
    end

    k = k*(2*pi)/N;

end

