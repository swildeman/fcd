function [kr, ku] = findorthcarrierpks( Iref, kmin, kmax, thresh )
%FINDORTHCARRIERPKS Find two orthogonal carrier peaks in k-space from a
%reference checkerboard (or otherwise 2D periodic) pattern (with sub-fft-bin
%precision)
% 
% SYNOPSIS: [kr, ku] = findorthcarrierpks( Iref, kmin, kmax, thresh )
%
% INPUT Iref: 2D periodic reference pattern (e.g. a checkerboard pattern)
%       kmin, kmax: restrict search range to kmin < |k| < kmax
%       thresh: threshold value for peak detection as fraction of the maximum
%               value in the search range
%
% OUTPUT kr,ku: Locations of two peaks in k-space that maximize the 
%               normalized cross product kr x ku / |ku| among the four
%               strongest peaks detected within the given range
%
% See also:
% FINDPEAKS2
%
% Copyright (c) 2017 Sander Wildeman
% Distributed under the MIT License, see LICENSE file

[rows, cols] = size(Iref);
Iref = double(Iref);
Iref = Iref - mean(Iref(:));

wr = hamming(rows,'periodic');
wc = hamming(cols,'periodic');
w2d = wr(:)*wc(:)';

% get blurred 2d fft
f_h = abs(fftshift(fft2(Iref.*w2d)));

% get k-space coordinates
kx = fftshift(kvec(cols));
ky = fftshift(kvec(rows));
[kxgrid,kygrid] = meshgrid(kx,ky);

% pre-calculate k^2
k2 = kxgrid.^2 + kygrid.^2;

% exclude some user defined region
f_h(k2>kmax^2 | k2<=kmin^2) = 0;

% find 4 largest local peaks in k-space (corresponding to carrier signals)
if(nargin < 4) 
    thresh = .5*max(f_h(:));
else
    thresh = thresh*max(f_h(:));
end
[peakrows,peakcols] = findpeaks2(f_h, thresh, 4, true); % subpixel accuracy

if numel(peakrows) < 4
   error('Could not detect carrier signal.') 
end

% get subpixel rows and columns
fl_peakrows = floor(peakrows);
fl_peakcols = floor(peakcols);
alphar = peakrows - fl_peakrows;
alphac = peakcols - fl_peakcols;

% linear interpolation
kyPeaks = (1-alphar).*ky(fl_peakrows) + alphar.*ky(fl_peakrows+1);
kxPeaks = (1-alphac).*kx(fl_peakcols) + alphac.*kx(fl_peakcols+1);

% calculate angle with respect to image x-direction in range [-pi,pi]
peakAngles = atan2(kyPeaks,kxPeaks);

% find most rightward pointing peak kr0
[~,krInd] = min(abs(peakAngles));
kr = [kxPeaks(krInd), kyPeaks(krInd)];

% find ku0 perpendicular to kr0 (rotated cc by 90 degrees, pointing 'up')
% krAngle = peakAngles(krInd);
% [~,kuInd] = min(abs(krAngle + pi/2 - peakAngles));

% maximize cross product
[~,kuInd] = max((kr(1)*kyPeaks - kr(2)*kxPeaks)./sqrt(kxPeaks.^2 + kyPeaks.^2));
ku = [kxPeaks(kuInd), kyPeaks(kuInd)];

end

