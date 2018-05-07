function roi = fixroi( roi )
%FIXMASK Recursively close <3px small gaps in binary ROI, 
%useful for defining masked design matrices for taking image derivates
% 
% SYNOPSIS: roi = fixroi( roi )
%
% INPUT roi: roi to fix
%
% OUTPUT roi: fixed roi
%
% EXAMPLE To prepare a roi-matrix before calling designgrad(roi) call
%         roi = fixroi(roi)
%
% See also:
% DESIGNGRAD
%
% Copyright (c) 2017 Sander Wildeman
% Distributed under the MIT License, see LICENSE file

roi = ~fixmask(~roi);

end

