function sceneft_learning(para)

db = retr_database_dir(para.path_db, para.fmt);
n = para.nround;
acc = zeros(1,n);
for i = 1:n
    acc(i) = run_one_time(db, para);
end
sacc = std(acc);
macc = mean(acc);
fprintf('Final accuracy: %f +- %f.\n', macc, sacc);
save(para.path_results, 'macc', 'acc', 'sacc');


function acc = run_one_time( db, para )

% divide the images into training and testing
tr = zeros( size(db.label) );
for i = 1:db.nclass
    idx = find( db.label == i );
    idx = idx( randperm(length(idx)) );
    tr( idx(1:100) ) = 1;
end
db.tr = tr;

model = cell(db.nclass, 1);

% training procedure
for i = 1:db.nclass   
    fprintf('loading training features for class %d.\n', i);
    % reduce some of the negative 
    tr_pos = find( db.tr==1 & db.label==i );
    tr_neg = find( db.tr==1 & db.label~=i );
    
    ri = randperm( length(tr_pos) );
    ri = ri( 1:min(length(ri), para.max_n_pos) );
    tr_pos = tr_pos( ri );
    
    ri = randperm( length(tr_neg) );
    ri = ri( 1:min(length(ri), para.max_n_neg) );
    tr_neg = tr_neg( ri );
    
    tr = [tr_pos; tr_neg]; 
    
    features = cell( length(tr), 1 );
    labels = cell( length(tr), 1 );
    indexs = [];
    for j = 1:length(tr)
        
        imid = tr(j);
        
        [nc, fname] = fileparts( db.path{imid} );
        p = fullfile( para.path_rgnfeat, db.cname{db.label(imid)}, fname );
        feat = load_feat(p);

        if db.label(imid) == i
            max_m = para.max_m_pos;
            cur_l = 1;
        else
            max_m = para.max_m_neg;
            cur_l = -1;
        end
        
        ri = randperm( size(feat,1) );
        ri = ri( 1: min(length(ri), max_m) );
        feat = feat(ri, :);

        features{j} = feat;
        labels{j} = single( ones(size(feat,1),1) * cur_l );
        indexs = [indexs; j*ones(size(feat,1),1) ];
    end
    
    features = cell2mat( features );
    labels  = cell2mat( labels );

    fprintf('training model for class %d.\n', i);
    model{i} = m4train( features, labels, indexs, para ); 
    fprintf('\n\n');
end

save(para.path_svm_models, 'model', 'db');

load(para.path_svm_models, 'model', 'db');

W = merge_w(model);

% encoding image using attribute classifier
fv = zeros( db.imnum, 0 );
for i = 1:db.imnum
    fprintf( 'Scoring %d of %d.\n', i, db.imnum );
    [nc, fname] = fileparts( db.path{i} );
    p = fullfile( para.path_rgnfeat, db.cname{db.label(i)}, fname );
    load(p, 'feat', 'xy', 'sz');
    f = score_one_image( W, feat, xy, sz, 0 );
    fv(i, 1:length(f)) = f;
end
label = db.label;

% testing procedure
fv_tr = single(fv( db.tr==1, : ));
fv_te = sparse(fv( db.tr==0, : ));
label_tr = single(label( db.tr==1 ));
label_te = sparse(label( db.tr==0 ));

m2 = train( label_tr, fv_tr, para.options2 );
[nc, a, nc] = predict( label_te, fv_te, m2 );

acc = a(1);

tr = db.tr;
save('data\v_scene_15.mat', 'fv', 'label', 'tr', 'acc');

function feat = load_feat(p)
f = load(p, 'feat');
feat = f.feat;
