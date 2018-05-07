function varargout = genchkprint(squarewidth, varargin)
%GENCHKPRINT Generate a checkerboard background pattern for printing at given 
%dimensions and resolution
% 
% SYNOPSIS: [Ichk =] genchkprint(squarewidth, 'dpi', ..., 'papersize', ..., 'margin', ...)
%
% INPUT squarewidth: target printed width of the checkerboard squares in mm
%       'dpi': (default: 600) resolution of target printer in dots per inch (DPI)
%       'papersize': (default: 'a4') size of printing paper as [w,h] (mm)
%                    or aX format string
%       'margin': (default: 10) paper margin in mm to leave blank around the pattern
%
% OUTPUT Ichk: Requested checkerboard image. If called without output argument, 
%              a TIFF file is generated in current directory
%
%
% Copyright (c) 2018 Sander Wildeman
% Distributed under the MIT License, see LICENSE file


defDPI = 600;
defPaperSize = 'a4';
defMargin = 10; % mm

p = inputParser;
p.addRequired('squarewidth',@isnumeric)
p.addParameter('dpi',defDPI,@isnumeric)
p.addParameter('papersize', defPaperSize);
p.addParameter('margin', defMargin, @isnumeric);

p.parse(squarewidth, varargin{:});

if ischar(p.Results.papersize)
    switch p.Results.papersize(1)
        case 'a'
            scalar = str2double(p.Results.papersize(2));
            area = 1e6 * 1/2^scalar;
            wMM = sqrt(area/sqrt(2));
            hMM = area/wMM;
            wMM = round(wMM);
            hMM = round(hMM);
        otherwise
            error('Unrecognized paper format.');
    end
    papstr = p.Results.papersize;
else
    wMM = p.Results.papersize(1);
    hMM = p.Results.papersize(2);
    papstr = [num2str(round(wMM)) 'x' num2str(round(hMM)) 'mm'];
end

% printer resolution
dpi = p.Results.dpi;
mmPerInch = 25.4;
dotsPerMM = dpi/mmPerInch;

% add some margin to avoid printer problems
borderMM = p.Results.margin;

% to be created file dimensions in pixels/dots
h = (hMM-borderMM)*dotsPerMM;
w = (wMM-borderMM)*dotsPerMM;

% square dimensions in pixels (dots)
squareWpx = round(squarewidth*dotsPerMM);

% number of columns and rows in checkerboard pattern
cols = ceil(w/squareWpx/2);
rows = ceil(h/squareWpx/2);

% generate checkerboard using matlab's built-in function
Ichk = checkerboard(squareWpx,rows,cols);
Ichk(Ichk > 0) = 1;
Ichk = Ichk(1:round(h),1:round(w));

if nargout == 0
    imwrite(Ichk, ['chkboard_',strrep(num2str(squarewidth),'.','_'),'mm_',papstr,'_',num2str(dpi),'dpi.tif'],'Resolution',dpi);
else
    varargout{1} = Ichk;
end

end