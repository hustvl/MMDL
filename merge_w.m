function W = merge_w(model)

W = [];
for i = 1:length(model)
    W = [W; model{i}.w];
end
W = single(W');