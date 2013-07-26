function [rgn_feat, rgn_xy, sz, im] = extr_img_feat(im, nmax, para)

sz = size(im);
r = para.max_imsz/max(sz);
if r < 1
    im = imresize(im, r);
    sz = size(im);
end

patchsize = para.patchsize;
step = para.step;

rect = [];
for i = 1:length(patchsize)
    xs = 1 : step : sz(2)-patchsize(i); 
    ys = 1 : step : sz(1)-patchsize(i);
    [x, y] = meshgrid(xs, ys);
    x = x(:);
    y = y(:);
    rect = [rect; [ y, y+patchsize(i)-1, x, x+patchsize(i)-1]];
end

if nmax ~= inf
    nmax = min( nmax, size(rect,1) );
    rid = randperm( size(rect,1) );
    rid = rid(1:nmax);
    rect = rect( rid(1:nmax), : );
end

len = size( rect,1 );
rgn_feat = zeros( len, 0 );
rgn_xy   = zeros( len, 2 );

if para.bow_on
    if size(im, 3) > 1
        gray = rgb2gray(im);
    else
        gray = im;
    end
    para.codemap = extr_encode_sift(gray, para.codebook);
end

if para.gist_on
    if ~isfield(para, 'gabor')
        orientationsPerScale = [6 6 4];
        para.gabor = createGabor(orientationsPerScale, para.basesize);
    end
end

for i = 1:len
    r = rect(i,:);
    f = extr_patch_feat(im, r, para);
    rgn_feat(i, 1:length(f)) = f;
    rgn_xy(i,:) = [ (r(3)+r(4))/2, (r(1)+r(2))/2 ];
end