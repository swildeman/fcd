function c = getcarrier( fftIref, kc, krad )
%GETCARRIER Extract carrier signal within radius 'krad' around vector 'kc'
% in k-space and store the result in a neat carrier object for later reuse
% 
% SYNOPSIS: c = getcarrier( fftIref, kc, krad )
%
% INPUT fftIref: fft2(Iref), where Iref is a periodic reference pattern
%       kc: location [kx, ky] of carrier peak in k-space
%       krad: filter radius in k-space
%
% OUTPUT c: Carrier object containing the extracted k-space signal
%
% See also:
% @CARRIER
% FFT2
%
% Copyright (c) 2017 Sander Wildeman
% Distributed under the MIT License, see LICENSE file

c = carrier;

[rows, cols] = size(fftIref);

[kx, ky] = meshgrid(kvec(cols), kvec(rows));

% k vector
c.k = kc;

% filtering radius
c.krad = krad;

% mask for filtering purposes in k-space
c.mask = 1.*((kx-kc(1)).^2 + (ky-kc(2)).^2 < krad^2);

% complex conjugate of carrier signal, used for demodulation
c.ccsgn = conj(ifft2(fftIref.*c.mask));

end

