function [ Iref, Idef, h, u, v ] = fcd_testimages()
%TESTIMAGES Generate pair of test images for FCD analysis
%
% SYNOPSIS: [ Iref, Idef, h, u, v ] = fcd_testimages()
%
% OUTPUT Iref: Reference checkerboard pattern
%        Idef: Iref distorted by wave-like disturbance
%        h: Ground-truth height field so that [u,v] = grad(-h);
%        u,v: Ground-truth displacement field
% 
% See also:
% FCD_DISPFIELD
%
% Copyright (c) 2017 Sander Wildeman
% Distributed under the MIT License, see LICENSE file


[x,y] = meshgrid(0:512-1,0:512-1);

k0 = 2*pi/8;

xs = x-150;
ys = y-200;

kwave = 2*pi/(40);
r = sqrt(xs.^2 + ys.^2);
a = 20;
h = a*besselj(0,kwave*r);
% [u,v] = gradient(-h);
u = a * kwave * xs .* besselj(1,kwave*r) ./ r;
v = a * kwave * ys .* besselj(1,kwave*r) ./ r;

u(isnan(u)) = 0;
v(isnan(v)) = 0;

% add some angle to the background grid
th = (pi/4)*.2;
xd = x - u;
yd = y - v;

xp = cos(th)*x + sin(th)*y;
yp = -sin(th)*x + cos(th)*y;
xpd = cos(th)*xd + sin(th)*yd;
ypd = -sin(th)*xd + cos(th)*yd;

Iref = .5+(cos(k0*xp) + cos(k0*yp))/4;
Idef = .5+(cos(k0*xpd) + cos(k0*ypd))/4;

end
