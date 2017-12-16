% generate artificial reference and deformed image Iref and Idef
[Iref, Idef, hgt, ugt, vgt] = fcd_testimages();

% convert images to double to prevent rounding errors
Iref = double(Iref);
Idef = double(Idef);

% get two independent carrier peaks from reference image
[kr, ku] = findorthcarrierpks(Iref, 4*pi/min(size(Iref)), Inf);

% extract carrier signals from reference image and store them for later use
krad = sqrt(sum((kr-ku).^2))/2;
fIref = fft2(Iref);
cr = getcarrier(fIref, kr, krad);
cu = getcarrier(fIref, ku, krad);

% get displacement field and height profile
tic

fIdef = fft2(Idef);
[u,v] = fcd_dispfield(fIdef,cr,cu);
h = fftinvgrad(-u,-v);
% h = invgrad2(-u,-v);

toc

% display results
close all;

figure(1)
imshowpair(Iref,Idef,'montage')

figure(2)
[rows,cols] = size(Idef);
kxvec = fftshift(kvec(cols));
kyvec = fftshift(kvec(rows));
wr = hann(rows,'periodic');
wc = hann(cols,'periodic');
win2d = wr(:)*wc(:)';
fftIm = fftshift(abs(fft2((Idef-mean(Idef(:))).*win2d)));
imagesc(kxvec, kyvec, fftIm,[0,max(fftIm(:))/50/4]);
hold on
cr.plot('color','y','marker','none')
cu.plot('color','g','marker','none')
hold off
axis image

figure(3)
quiver(u,v)
axis ij
axis image

figure(4)
imshowpair(hgt,h, 'montage','scaling','joint');

figure(5)
plot(ugt(200,:))
hold on
plot(u(200,:),'.')
hold off