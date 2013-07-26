function db = parse_db_scene15(fld)

fmt = '*.jpg';
ntr = 100;

db = struct( 'class', [], 'index', [], 'train', [], 'test', [] );
index = 0;

subflds = dir(fullfile(fld));

for i = 1:length(subflds)
    if (~strcmp(subflds(i).name, '.')) && (~strcmp(subflds(i).name, '..'))
        index = index + 1;
        db(index).class = subflds(i).name;
        db(index).index = index;
        
        fld_ = fullfile( fld, subflds(i).name );
        imgs = dir( fullfile(fld_, fmt) );
        filenames = cell(1, length(imgs) );
        
        for j = 1:length(imgs)
            filenames{j} = fullfile( fld_, imgs(j).name );
        end
        
        % rind = randperm( length(filenames) );
        rind = 1:length(filenames);
        db(index).train = filenames( rind(1:ntr) );
        db(index).test  = filenames( rind(ntr+1:end) );
            
    end
end