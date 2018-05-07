function [ u, v ] = fcd_dispfield( fftIdef, cr, cu, tryunwrap )
%FCD_DISPFIELD Find the displacement field that warps a periodic reference 
% image (Iref) into the deformed (i.e. phase modulated) image (Idef)
% 
% SYNOPSIS: [ u, v ] = fcd_dispfield( fftIdef, cr, cu, tryunwrap )
%
% INPUT fftIdef: fft2(Idef), where Idef is a distorted reference pattern of
%                approximate form I(r) = c0 + cos(cr.k*r) + cos(cu.k*r)
%       cr, cu: orthogonal carrier signals extracted from an undistorted
%               reference image, see also <a href="matlab:help findorthcarrierpks">findorthcarrierpks</a>
%       tryunwrap: (default: false) if set true, calls <a href="matlab:help unwrap2">unwrap2</a> on extracted
%                  phasefields
%
% OUTPUT u, v: local deformation such that Idef = Iref(x - u, y - v);
%
% See also:
% FINDORTHCARRIERPKS
% UNWRAP2
% FFT2
%
% Copyright (c) 2017 Sander Wildeman
% Distributed under the MIT License, see LICENSE file

% (1) extract phase modulation from carrier peaks in deformed image
phi_r = fcd_phasefield(fftIdef, cr);  % phi_r = cr.k(:)' * (u;v)
phi_u = fcd_phasefield(fftIdef, cu);  % phi_u = cu.k(:)' * (u;v)

% (2, optional) unwrap the phases
if nargin < 4
    if all(phi_r(:) < 3) && all(phi_u(:) < 3)
        tryunwrap = false;
    else
        tryunwrap = true; 
    end
end

if tryunwrap
    phi_r = unwrap2(phi_r);
    phi_u = unwrap2(phi_u);
end

% (3) project phases onto x (left to right) and y (up to down)
% displacements (u,v)
[u, v] = phase2disp(phi_r, phi_u, cr, cu);

end

