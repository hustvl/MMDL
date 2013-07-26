

function f = extr_patch_feat( im, rect, para )

f = [];

patch = im( rect(1):rect(2), rect(3):rect(4), : );
patch = imresize( patch, [para.basesize, para.basesize] );

if size(patch,3) > 1
    gray = rgb2gray(patch);
else
    gray = patch;
    
    im3(:,:,1) = gray;
    im3(:,:,2) = gray;
    im3(:,:,3) = gray;
    patch = im3;
end


if para.bow_on
    x = para.codemap.x;
    y = para.codemap.y;
    c = para.codemap.code;
    f_sift = hist( c( y>=rect(1) & y<=rect(2) & x>=rect(3) & x<=rect(4) ), 1:size(para.codebook.dict,1) );
    f_sift = f_sift / (sum(f_sift)+eps);
    f = [f; f_sift'];
end

if para.hog_on
    f_hog = vl_hog( im2single(patch), para.hogcellsz );
    f_hog = f_hog(:);
    f_hog = f_hog / (norm(f_hog,2)+eps);
    f = [f; f_hog];
end

if para.lbp_on
    f_lbp = vl_lbp( im2single(gray), para.lbpcellsz );
    f_lbp = f_lbp(:);
    f_lbp = f_lbp / (norm(f_lbp,2)+eps);
    f = [f; f_lbp];
end

if para.lab_on
    lab = RGB2Lab(patch);
    f_lab = LabHistogram(lab);
    f_lab = f_lab(:);
    f_lab = f_lab / (norm(f_lab,1)+eps);
    f = [f; f_lab];
end

if para.gist_on
    output = prefilt(double(gray), 4);
    f_gist = gistGabor(output, 4, para.gabor);
    f_gist = f_gist / (norm(f_gist,2)+eps);
    f = [f; f_gist];
end

f = f / (norm(f,2));