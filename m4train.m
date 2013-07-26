
function svmm = m4train( features, labels, bag_indexs, para )

K = para.num_cluster;
max_iter = para.max_iter;
sigma = para.sigma;
rho = para.rho;
options = para.options;

% run kmeans using all positive instances
positive_instance_indexs = find(labels > 0);
positive_instance_features = features(positive_instance_indexs, :);

% [~, A] = vl_kmeans( positive_instance_features(:,1:200)', K );
[nc, A] = vl_kmeans( positive_instance_features', K );

% compute the bag labels
ui = unique( bag_indexs );
Y = zeros( length(ui), 1 );
for i = 1:length(ui)
    helpi = bag_indexs==ui(i);
    Y(i) = max( labels( helpi ) );
    bag_indexs(helpi) = i;
end

% initialize the latent variable
y = labels;
y(positive_instance_indexs) = A;

% initialize the weight for all instance
c = ones(size(y))/length(y);

% iteratively optimization
iter = 0;
converge = false;

while ~converge
    iter = iter + 1;
    fprintf('In iteration %d.\n', iter);
    
    fprintf('Training SVM: \n');
    tic
    svmm = optimize_s( features, y, c, options, rho );
    [c, y2] = optimize_l( features, y, svmm, sigma );
    fprintf('Time costs %f min.\n', toc/60);
    
    fprintf('Testing SVM: \n');
    tic
    ydiff = sum(abs(y(positive_instance_indexs) - y2(positive_instance_indexs)));
    fprintf('Time costs %f min.\n', toc/60);

    
    if iter >= max_iter || ydiff == 0
        converge = true;
    end
    
    y(positive_instance_indexs) = y2(positive_instance_indexs);
        
end

if para.show
    figure, plot(likelihood);
    xlabel('iterations');
    ylabel('log-likelihood');
    grid on;
end

function svmm = optimize_s( x, y, c, options, sample_ratio )

c_pos = c(y>0);
x_pos = x(y>0, :);
y_pos = y(y>0);
x_neg = x(y<0, :);
y_neg = y(y<0);

clear x;

sample_index = resample(c_pos, round(sample_ratio*length(c_pos)) );
x_pos = x_pos(sample_index, :);
y_pos = y_pos(sample_index);

x = [x_pos; x_neg];
y = [y_pos; y_neg];

svmm = train( y, x, options );

% w = svmm.w;


function [c, y2] = optimize_l( x, y, svmm, sigma )

% prepare for the output
c = zeros(size(y));
y2 = y;

positive_instance_indexs = find(y > 0);
xp = x(positive_instance_indexs, :);
yp = y(positive_instance_indexs, :);

[yp, nc, v] = predict(sparse(double(yp)), sparse(double(xp)), svmm);
fprintf('Percentage of negative patches in positive images: %f.\n', length(find(yp<0))/length(yp) );

vdiff = bsxfun( @minus, v( :,svmm.Label>0 ), v( :,svmm.Label<0 ) );
[vdiff_max, idx_max] = max( vdiff, [], 2 );

% instance level probability
pij = 1  ./ (1 + exp( -vdiff_max/sigma ));
c(positive_instance_indexs) = pij;

% update labels
positive_labels = svmm.Label( svmm.Label>0 );
y2(positive_instance_indexs) = positive_labels( idx_max );



















