function I = sinefill( I, Iref, mask, rad, kn )
%SINEFILL Fit F(r) = a0 + Sum[ a_n*cos(k_n*r) + b_n*sin(k_n*r) ] to a
%region around the masked area in Iref, and substitute the solution in the
%mask its place in I
% 
% SYNOPSIS: I = sinefill( I, Iref, mask, rad, kn )
%
% INPUT I: image with masked area
%       Iref: reference image to extract the pattern from
%       mask: logical mask of size(I), with 1's at places to be filled
%       rad: thickness of the region around the masked area to be used for
%            fitting
%       kn: wavenumbers of the pattern to fit
%
% OUTPUT I: In-painted image
%
% See also:
% HELMFILL
%
% Copyright (c) 2017 Sander Wildeman
% Distributed under the MIT License, see LICENSE file

I = double(I);

% number of wavenumbers to include
Nk = size(kn, 1);

% get mask for pixels in the neigbhorhood of the masked area(s)
ext_mask = imdilate(mask, strel('disk', rad, 8));
nbr = ext_mask & ~mask;
Nnbr = sum(nbr(:));

% set up the matrix for a least squares fit
[rows, cols] = size(I);
[x,y] = meshgrid(1:cols, 1:rows);
kr = [x(:) y(:)]*kn';
A = [ones(Nnbr,1), cos( kr(nbr(:),:) ), sin( kr(nbr(:),:) ) ];

% solve for the coefficients
c = A \ Iref(nbr);

% substitute the solution in place of the mask
I(mask) = c(1) + cos( kr(mask(:),:) )*c(2:Nk+1) + sin( kr(mask(:),:) )*c(Nk+2:end);

end

