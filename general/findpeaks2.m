function [ r, c, vals ] = findpeaks2( A, thresh, n, subpixel  )
%FINDPEAKS2 Find the n largest peaks (larger than thresh) in an image
% 
% SYNOPSIS: [ r, c, vals ] = findpeaks2( A, thresh, n, subpixel  )
%
% INPUT A: 2D matrix containing peaks
%       thresh: peaks are defined as regions with A > thresh
%       n: number of peaks to return (sorted from high to low)
%       subpixel: (default: true) perform subpixel gaussian peak-fit?
%
% OUTPUT r,c: (sub-pixel) row and column coordinates of found peaks
%        vals: heights of the peaks
%
% Copyright (c) 2017 Sander Wildeman
% Distributed under the MIT License, see LICENSE file

[rows,cols] = size(A);

% threshold
peakRegions = bwconncomp(A > thresh);

% find local maxima in remaining connected areas
vals = zeros(1,peakRegions.NumObjects);
inds = zeros(1,peakRegions.NumObjects);
for ii = 1:peakRegions.NumObjects
    ids = peakRegions.PixelIdxList{ii};
    [vals(ii),regionalMaxId] = max( A(ids) );
    inds(ii) = ids(regionalMaxId);
end

% convert to subscripts
[r, c] = ind2sub([rows,cols], inds);

% disregard peaks on border
borderpks = (r == 1) | (r == rows) | (c == 1) | (c == cols);
r(borderpks) = [];
c(borderpks) = [];
inds(borderpks) = [];
vals(borderpks) = [];

% sort from high to low
[vals,order] = sort(vals,'descend');
inds = inds(order);
r = r(order);
c = c(order);

% select n largest
if n < numel(inds)
   inds = inds(1:n);
   vals = vals(1:n);
   r = r(1:n);
   c = c(1:n);
end

if(subpixel)
    lv = A(inds-rows);
    rv = A(inds+rows);
    tv = A(inds-1);
    bv = A(inds+1);
    c = subpxpeak(c, vals, lv, rv);
    r = subpxpeak(r, vals, tv, bv);
end

    function ii = subpxpeak(ii, iiv, lv, rv)
        % assume gaussian peak
        ii = ii - .5*( (log(rv)-log(lv))./(log(lv)+log(rv)-2*log(iiv)) );
    end

end

