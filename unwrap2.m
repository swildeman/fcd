function [ ph ] = unwrap2( ph_w, roi )
%UNWRAP2 unwrap 2D phase map
%
% Based on: V. Volkov and Y. Zhu, Deterministic phase unwrapping in the
% presence of noise, Opt. Lett. (2003)

if nargin < 2
   hasroi = false;
else
   hasroi = true;
end

Nx = size(ph_w,2);
Ny = size(ph_w,1);

if hasroi
   ph = ph_w; % don't touch regions outside roi
   ph_w = ph_w(roi);
end

% auxilary function
Z = exp(1i*ph_w);

% second order finite difference
if hasroi
    [Dx,Dy] = designgrad(roi);
    phx_w = Dx*ph_w;
    phy_w = Dy*ph_w;
    phx = Dx*Z;
    phy = Dy*Z;
else    
    Dx = designgrad1D(Nx);
    Dy = designgrad1D(Ny);
    phx_w = (Dx*ph_w.').';
    phy_w = Dy*ph_w;
    phx = (Dx*Z.').';
    phy = Dy*Z;
end

% Volkov&Zhu's trick to calculate location of phase jumps
phx = real(phx./(1i*Z));
phy = real(phy./(1i*Z));
jx = phx-phx_w;
jy = phy-phy_w;

if hasroi % integrate by matrix inversion
  j = [0;[Dx(:,2:end);Dy(:,2:end)] \ [jx;jy]];
else % integrate in fourier domain
  j = fftinvgrad(jx,jy,'gradtype','diff');
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

