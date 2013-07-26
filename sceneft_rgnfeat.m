function sceneft_rgnfeat(para)

database = retr_database_dir(para.path_db, para.fmt);

% if matlabpool('size') ~= para.poolsize
%     if matlabpool('size') > 0
%         matlabpool close;
%     end
%     matlabpool(para.poolsize);
% end

parfor i=1:database.imnum
    fprintf('Extracting patch level features: %d of %d.\n', i, database.imnum);
    
    tic
    im = imread( database.path{i} );    
    [feat, xy, sz] = extr_img_feat( im, inf, para);
    toc
    
    feat = single(feat);
    xy = single(xy);
    sz = single(sz);
    
    [nc, fname] = fileparts( database.path{i} );
    p0 = fullfile( para.path_rgnfeat, database.cname{database.label(i)} );
    if ~exist( p0, 'dir' )
        mkdir(p0);
    end
    
    p = fullfile( para.path_rgnfeat, database.cname{database.label(i)}, fname );
    savefeat( feat, xy, sz, p );
end
% matlabpool close;

function savefeat( feat, xy, sz, p )
save( [p, '.mat'], 'feat', 'xy', 'sz' );