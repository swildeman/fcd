function I = helmfill(I, mask, k2, ghostbc)
% HELMFILL Fill a portion of an image by the solution of Helmholtz equation
% (Dxx^2 + Dyy^2) f + k^2 f = 0, taking the surrounding pixels as boundary
% conditions.
% 
% SYNOPSIS: I = helmfill(I, mask, k2, ghostbc)
%
% INPUT I: image which contains gaps which have to be restored
%       mask: binary image of size(I) with 1's on the locations to be
%             painted in from the boundary values
%       k2: wavenumber^2 in the Helmholtz equation 
%           (k2 = 0 corresponds to Laplace equation)
%       ghostbc: boundary conditions ('circular' or 'replicate')
%
% OUTPUT I: In-painted image
%
% See also:
% SINEFILL
%
% Copyright (c) 2017 Sander Wildeman
% Distributed under the MIT License, see LICENSE file

allowed_ghostbc = {'circular','replicate'};
ghostbc = validatestring(ghostbc,allowed_ghostbc);

origclass = class(I);

% cast to double for calculations
I = double(I);

%% 1. Set up some useful matrixes for converting between linear indices

% number of rows and columns in the image
[M,N] = size(I);

% total number of unknowns to solve for
Nun = sum(mask(:));

% define linear indices for referring to the unknowns, store them at the
% NaN locations in the image for easy look-up
I(mask) = (1:Nun);

% look-up table for the linear indices in the full matrix I
indFull = reshape(1:M*N,[M,N]);

%% 2. Implement periodic boundary conditions by cyclic padding
% (this could probably be easily changed to neuman bc by padding with copies instead)
% indFull = padarray(indFull, [1,1], 'circular');
indFull = padarray(indFull, [1,1], ghostbc);

% find the linear indices of the unknowns in the cyclic matrix
unknInd = find(padarray(mask, [1,1]));

%% 3. Find all neighboring indices for each unknown entry:

% indexes of the unknowns for which we want to find the up, down, left and
% right neighbors
ctr = [1:Nun; 1:Nun; 1:Nun; 1:Nun]';

% get linear indexes (in I) of ALL neigbhors for each unknown
nbr = [indFull(unknInd-1),... % up
       indFull(unknInd+1),... % down
       indFull(unknInd-(M+2)),... % left
       indFull(unknInd+(M+2))]; % right

%% 4. Extract the unknowns which have neighbors which are also unknowns :)
% (used for A in the final A*x = b system)

% indices of the unknowns which have another unknown as neighbor
unkNbrRow = ctr(mask(nbr));

% actual indices of the neighboring unknowns (remember we stored the linear
% indices of the unknowns in the original image to safe some memory)
unkNbrCol = I(nbr(mask(nbr)));

%% 5. Set up the sparse matrix for finite difference laplacian Dxx + Dyy
A = sparse( [(1:Nun)' ; unkNbrRow], ...
            [(1:Nun)'; unkNbrCol],...
            [(-4+k2)*ones(Nun,1); 1*ones(length(unkNbrRow), 1)], ... % (diagonal; off diagonal)
            Nun, Nun);

%% 6. Use the neighbors with known values on the rhs of A*x=b
I(mask) = 0;
b = -sum((~mask(nbr)).*I(nbr), 2);

%% 7. Solve the system and use it to fill the gaps in the image
I(mask) = A\b;
I = cast(I, origclass);

end