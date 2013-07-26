

addpath include\liblinear-1.7-single\matlab\
addpath include\vlfeat\toolbox\
addpath include\utils\
addpath include\gist\
addpath include\bow\
vl_setup;

experiment_index = 'release';    %%!!!!

para.max_n_neg = 1400;      % number of randomly selected negative images for training
para.max_n_pos = 100;       % number of randomly selected positive images for training
para.max_m_neg = 100;       % number of randomly selected negative patches for training per image
para.max_m_pos = 300;       % number of randomly selected positive patches for training per image
para.nround = 5;           

para.max_imsz = 500;
para.step = 16;                 % step size for computing feature
para.patchsize = [48, 72, 96];  % size of patch for computing feature
para.basesize = 48;             % standard size for computing feature

para.hog_on = 1;                % using hog or not
para.hogcellsz = 16;
para.lbp_on = 1;                % using lbp or not
para.lbpcellsz = 16;
para.gist_on = 1;               % using gist or not
para.bow_on = 1;                % using encoded sift or not

para.lab_on = 0;                % using lab color histogram or not

para.poolsize = 4;

para.options = '-s 2 -c 1 -w-1 0.01 -q';    % svm option for optimizing w
para.options2 = '-s 2 -c 20';               % svm option for image classfication
para.num_cluster = 10;
para.max_iter = 5;
para.rho = 0.7;
para.sigma = 1;
para.show = 0;

load('data\sceneft_codebook.mat');
para.codebook = codebook;

para.path_db = 'data\scene_categories\';
para.fmt = '*.jpg';
para.path_svm_models = sprintf( 'data\\sceneft_model_%s.mat', experiment_index );
para.path_rgnfeat = sprintf( 'data\\sceneft_rgnfeat_%s\\', experiment_index );
para.path_results = sprintf( 'data\\sceneft_results_%s.mat', experiment_index );

mkdir(para.path_rgnfeat);

sceneft_rgnfeat(para);
sceneft_learning(para);





