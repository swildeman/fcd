function mask = fixmask( mask )
%FIXMASK Recursively close small gaps of 0's in a binary image, useful for
%defining masked design matrices for taking image derivates
% 
% SYNOPSIS: mask = fixmask( mask )
%
% INPUT mask: mask to fix
%
% OUTPUT mask: fixed mask
%
% EXAMPLE To prepare a roi-matrix before calling designgrad(roi) call
%         roi = ~fixmask(~roi)
%
% See also:
% DESIGNGRAD
%
% Copyright (c) 2017 Sander Wildeman
% Distributed under the MIT License, see LICENSE file

% make sure boundaries are also fixed
mask = padarray(mask,[1,1],true);

% dilate + erode mask to make sure there are no narrow 1-2px gaps
mask_try = imclose(mask, [1 1 1]);
mask_try = imclose(mask_try, [1; 1; 1]);

% recursively close gaps in the mask until it stops changing
mask_changing = true;
while mask_changing
    mask = imclose(mask_try, [1 1 1]);
    mask = imclose(mask, [1; 1; 1]);
    if mask == mask_try
        mask_changing = false;
    else
        mask_try = mask;
    end
end

% return used mask (before padding)
mask = mask(2:end-1,2:end-1);

end

