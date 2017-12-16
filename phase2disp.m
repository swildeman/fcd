function [ u, v ] = phase2disp( phi_r, phi_u, cr, cu )
%PHASE2DISP Convert extracted phase moduluation field to displacement field 
%in image coordinates x (left to right) and y (top to bottom)
% 
% SYNOPSIS: [ u, v ] = phase2disp( phi_r, phi_u, cr, cu )
%
% INPUT phi_r, phi_u: phase fields extracted from two linearly independent
%                     carrier peaks, see <a href="matlab:help fcd_phasefield">fcd_phasefield</a>
%       cr, cu: orthogonal carrier signals extracted from an undistorted
%               reference image, see also <a href="matlab:help findorthcarrierpks">findorthcarrierpks</a>
%
% OUTPUT u, v: displacement field projected in x and y direction (image coordinates)
%
% See also:
% FCD_PHASEFIELD
% FINDORTHCARRIERPKS
% 
% Copyright (c) 2017 Sander Wildeman
% Distributed under the MIT License, see LICENSE file

% solve 2x2 linear system for each pixel
detA = cr.k(1)*cu.k(2) - cr.k(2)*cu.k(1);
u = (cu.k(2)*phi_r - cr.k(2)*phi_u) / detA;
v = (cr.k(1)*phi_u - cu.k(1)*phi_r) / detA;

end

