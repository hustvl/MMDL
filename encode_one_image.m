function f = encode_one_image( dict, feat, xy, sz, ispascal )
v = LLC_coding_appr(dict, feat);

if ispascal
    f = pascal_spm(v, xy, sz);
else
    f = lala_spm(v, xy, sz);
end
f = f / norm(f,2);


function f = pascal_spm(v, xy, sz)
f = zeros( 8, size(v,2) );
xy(:,1) = xy(:,1) / sz(2);
xy(:,2) = xy(:,2) / sz(1);
findex = 0;

for i = 1:2
    rmin = (i-1)/2;
    rmax = (i+0)/2;
    for j = 1:2
        cmin = (j-1)/2;
        cmax = (j+0)/2;             
            
        idx = xy(:,1)>=cmin & xy(:,1)<=cmax & xy(:,2)>=rmin & xy(:,2)<=rmax;
        v_ = v( idx, : );
        
        findex = findex + 1;
        
        if isempty(v_)
            f( findex, : ) = 0;
        else
            f( findex, : ) = max( v_, [], 1 );
        end                
    end
end

for i = 1:3
    cmin = (i-1)/3;
    cmax = (i+0)/3; 
    idx = xy(:,1)>=cmin & xy(:,1)<=cmax;
    v_ = v( idx, : );
    findex = findex + 1;
    
    if isempty(v_)
        f( findex, : ) = 0;
    else
        f( findex, : ) = max( v_, [], 1 );
    end                    
end
f(end,:) = max(f(1:4,:),[],1);
f = f(:);

function f = lala_spm(v, xy, sz)

% max-pooling and spm
level = [1,2,4];
f = zeros( sum(level.^2), size(v,2) );
xy(:,1) = xy(:,1) / sz(2);
xy(:,2) = xy(:,2) / sz(1);
findex = 0;

for i = 1:length(level)
    for r = 1:level(i)
        rmin = (r-1)/level(i);
        rmax = (r+0)/level(i);
        for c = 1:level(i)
            cmin = (c-1)/level(i);
            cmax = (c+0)/level(i);  
            
            idx = xy(:,1)>=cmin & xy(:,1)<=cmax & xy(:,2)>=rmin & xy(:,2)<=rmax;
            v_ = v( idx, : );
           
            findex = findex + 1;
            
            if isempty(v_)
                f( findex, : ) = 0;
            else
                f( findex, : ) = max( v_, [], 1 );
            end                
        end
    end
end

f = f(:);
% f = [f; pi];