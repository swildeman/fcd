function fcd_preview( vid )
%FCD_PREVIEW Live preview of displacement field extracted from a video
%stream of a checkerboard pattern that is being distorted
% 
% SYNOPSIS: fcd_preview( vid )
%
% INPUT vid: Video input object
%
% Keyboard controls during preview: 
%   'Spacebar' Pauze/resume preview
%   'r' Reset reference
%   'p' Increase CLim by 50%
%   'l' Decrease CLim by 50%
%
% See also:
% FCD_DISPFIELD
% VIDEOINPUT
%
% Copyright (c) 2017 Sander Wildeman
% Distributed under the MIT License, see LICENSE file

figTitle = 'WMPreview';
hFig = figure('Name', figTitle);
hFig.KeyPressFcn = @keypress_callback;

% take a snapshot to use as reference
Iref = double(getsnapshot(vid));
[rows,cols] = size(Iref);

figTitle = [figTitle ' - ' num2str(cols) 'x' num2str(rows)];

% obtain carrier signal used for demodulation
[kr, ku] = findorthcarrierpks(Iref, 4*pi/min(size(Iref)), Inf);
krad = sqrt(sum((kr-ku).^2))/2;
fIref = fft2(Iref);
cr = getcarrier(fIref, kr, krad);
cu = getcarrier(fIref, ku, krad);

% init filtering window for fft preview
kxvec = fftshift(kvec(cols));
kyvec = fftshift(kvec(rows));
wr = hann(rows,'periodic');
wc = hann(cols,'periodic');
win2d = wr(:)*wc(:)';

% init raw footage preview
axRaw = axes('Position', [0, 0, 1/3, 1]);
colormap(axRaw, gray(256))
iRaw = image(Iref); % set reference image as place holder
axis image
axis off

% fft preview
axFFT = axes('Position', [1/3, 0, 1/3, 1]);
colormap(axFFT, flip(gray(256)))
fftIm = fftshift(abs(fft2((Iref-mean(Iref(:))).*win2d)));
iFFT = image(kxvec, kyvec, fftIm);
iFFT.CDataMapping = 'scaled';
axFFT.CLim = [0,max(fftIm(:))/50];
hold on
crh = cr.plot('color','y','marker','none');
cuh = cu.plot('color','g','marker','none');
hold off
axis image
axis off

% profile preview
axH = axes('Position', [2/3, 0, 1/3, 1]);
colormap(axH, parula(256))
iH = image(zeros(rows, cols));
iH.CDataMapping = 'scaled';
axH.CLim = [0,pi/sqrt(sum(kr.^2))];
axis image
axis off

% start preview
timerh = tic;
tprev = 0;
prev_running = true;
setappdata(iRaw,'UpdatePreviewWindowFcn',@preview_callback);
preview(vid, iRaw)

    function preview_callback(~, event, hImage)
        Idef = double(event.Data);
        % update previews
        
        % raw
        hImage.CData = Idef;
        
        % fft
        absFFT = fftshift( abs( fft2( (Idef-mean(Idef(:))).*win2d ) ) );
        iFFT.CData = absFFT;
        axFFT.CLim = [0,max(absFFT(:))/50];
        
        % profile
        [u,v] = fcd_dispfield(fft2(Idef), cr, cu);
        nrmU = sqrt(u.^2+v.^2);
        iH.CData = nrmU;
        
        % display frame rate in title
        tcur = toc(timerh);
        hFig.Name = [figTitle ' - ' num2str(1/(tcur-tprev),'%.1f') ' FPS'];
        tprev = tcur;
    end
    
    function keypress_callback(~, event)
        switch event.Key
            case 'space'
                if prev_running
                    stoppreview(vid)
                else
                    preview(vid,iRaw)
                end
                prev_running = ~prev_running;
            case 'r'
                stoppreview(vid)
                Iref = iRaw.CData;
                [kr, ku] = findorthcarrierpks(Iref, 4*pi/min(size(Iref)), Inf);
                krad = sqrt(sum((kr-ku).^2))/2;
                fIref = fft2(Iref);
                cr = getcarrier(fIref, kr, krad);
                cu = getcarrier(fIref, ku, krad);
                delete(crh); delete(cuh);
                axes(axFFT);
                hold on;
                crh = cr.plot('color','y','marker','none');
                cuh = cu.plot('color','g','marker','none');
                hold off;
                disp('Iref is reset')
                preview(vid,iRaw);
            case 'p'
                axH.CLim = axH.CLim/1.5;
            case 'l'
                axH.CLim = axH.CLim*1.5;
        end
    end

end

