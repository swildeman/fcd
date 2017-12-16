function h = fcd_profil( fftIdef, cr, cu, tryunwrap )
%FCD_PROFIL Extract displacement field from distorted checkerboard image
%and integrate it, assuming it represents a gradient of a scalar height field
% 
% SYNOPSIS: h = fcd_profil( fftIdef, cr, cu, tryunwrap )
%
% INPUT fftIdef: fft2(Idef), where Idef is a distorted reference pattern of
%                approximate form I(r) = c0 + cos(cr.k*r) + cos(cu.k*r)
%       cr, cu: orthogonal carrier signals extracted from an undistorted
%               reference image, see also <a href="matlab:help findorthcarrierpks">findorthcarrierpks</a>
%       tryunwrap: (default: false) if set true, calls <a href="matlab:help unwrap2">unwrap2</a> on extracted
%                  phasefields
%
% OUTPUT h: profile such that [u,v] = -grad(h) (in a least square sense)
%
% REMARK This function is a simple wrapper for calling
%           [u,v] = fcd_dispfield(...) 
%           h = fftinvgrad(-u,-v)
%
% See also:
% FCD_DISPFIELD
% FFTINVGRAD
% FINDORTHCARRIERPKS
% UNWRAP2
% FFT2
%
% Copyright (c) 2017 Sander Wildeman
% Distributed under the MIT License, see LICENSE file

% WMPROFIL Find the heightfield h such that Idef(r) = Iref(r + grad(h))
% given fft2(Idef), where Iref is a periodic background pattern

if nargin < 4
   tryunwrap = false; 
end

% get gradient field
[u, v] = fcd_dispfield(fftIdef, cr, cu, tryunwrap);

% invert gradient field
h = fftinvgrad(-u,-v);

end

