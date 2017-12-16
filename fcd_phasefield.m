function phi = fcd_phasefield( fftIdef, car )
%FCD_PHASEFIELD Extract the phase modulation signal at given carrier peak 
%location in k-space
% 
% SYNOPSIS: phi = fcd_phasefield( fftIdef, car )
%
% INPUT fftIdef: fft2(Idef), where Idef is a distorted reference pattern of
%                approximate form I(r) = c0 + cos(car.k*r) + ...
%       car: carrier signal extracted from an undistorted reference image, 
%            see also <a href="matlab:help getcarrier">getcarrier</a>
%
% OUTPUT phi: Extracted phase signal
%
% See also:
% GETCARRIER
% FFT2
%
% Copyright (c) 2017 Sander Wildeman
% Distributed under the MIT License, see LICENSE file

% apply filter in kspace, selecting the signal around the carrier peak
fftIdef = fftIdef.*car.mask;

% go back to rspace
f_flt = ifft2(fftIdef);

% extract modulation of carrier signal
phi = -angle(f_flt.*car.ccsgn);

end

