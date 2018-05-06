function [ ph ] = unwrap2( ph_w, roi )
%UNWRAP2 unwrap a 2D phase map
%
% SYNOPSIS: ph = unwrap2( ph_w, [roi] )
% 
% INPUT ph_w: 2D wrapped phase map (phase map with 2*pi discontinuities)
%       roi:  (optional) binary ROI matrix of same size as ph_w 
%             (true = valid region, false = masked region). 
%
% OUTPUT ph: Unwrapped phase map 
%
% REMARK If a ROI is specified, a slower real space (instead of FFT) 
%        inversion is used in the unwrap algorithm.
%
% REFERENCE: V. Volkov and Y. Zhu, Deterministic phase unwrapping in the
% presence of noise, Opt. Lett. (2003)
%
%
% Copyright (c) 2018 Sander Wildeman
% Distributed under the MIT License, see LICENSE file

if nargin < 2
   hasroi = false; % flag to determine which integration method to use
else
   hasroi = true;
end

Nx = size(ph_w,2);
Ny = size(ph_w,1);

if hasroi
   ph = ph_w; % don't touch regions outside roi
   ph_w = ph_w(roi);
end

% auxiliary complex function without phase jumps
Z = exp(1i*ph_w);

% calculate derivatives
if hasroi
    % use central difference
    [Dx,Dy] = designgrad(roi);
    phx_w = Dx*ph_w;
    phy_w = Dy*ph_w;
    phx = Dx*Z;
    phy = Dy*Z;
else
    % perform differentiation in fourier domain
    [KX,KY] = meshgrid(kvec(Nx),kvec(Ny));
    fph_w = fft2(ph_w);
    phx_w = real(ifft2(1i*KX.*fph_w));
    phy_w = real(ifft2(1i*KY.*fph_w));
    fZ = fft2(Z);
    phx = ifft2(1i*KX.*fZ);
    phy = ifft2(1i*KY.*fZ);
end

% Volkov&Zhu's trick to calculate location of phase jumps using the
% auxiliary function
phx = real(phx./(1i*Z));
phy = real(phy./(1i*Z));
jx = phx-phx_w;
jy = phy-phy_w;

if hasroi % integrate by matrix inversion
  j = [0;[Dx(:,2:end);Dy(:,2:end)] \ [jx;jy]];
else % integrate in fourier domain
  j = fftinvgrad(jx,jy,'gradtype','spectral','bcfix','none');
end

% make sure correction is integer number of 2pi 
j = 2*pi*round(j/(2*pi));

% unwrap phase
if hasroi
   ph(roi) = ph_w + j;
else
   ph = ph_w + j;
end

end

