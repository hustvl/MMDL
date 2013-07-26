

sift = [ 165, 74.74 ];
hog = [165, 75.77];
lbp = [165, 81.23];

mmcl = [ 60, 83.77; 90, 85.28; 165, 85.95; 300, 85.75 ];

mil_km = [ 165, 81.02; 750, 83.17; 1500, 84.56 ];
km = [ 165, 78.64; 1024, 82.62; 2048, 83.07 ];

ert = [ 358, 77.76; 1028,  81.38; 2013,  82.7];

yang = [1024, 81.53];

figure, hold;
grid on;
xlabel('Number of codewords', 'FontSize', 16);
ylabel('Classification accuracy (%)', 'FontSize', 16)

plot( sift(:,1), sift(:,2), '-or', 'LineWidth', 2, 'MarkerSize',10 );
plot( hog(:,1), hog(:,2), '-og', 'LineWidth', 2, 'MarkerSize',10 );
plot( lbp(:,1), lbp(:,2), '-ob', 'LineWidth', 2, 'MarkerSize',10 );
plot( mmcl(:,1), mmcl(:,2), '-+r', 'LineWidth', 2, 'MarkerSize',10 );
plot( mil_km(:,1), mil_km(:,2), '-xg', 'LineWidth', 2, 'MarkerSize',10 );
plot( km(:,1), km(:,2), '-*b', 'LineWidth', 2 , 'MarkerSize',10);
plot( ert(:,1), ert(:,2), '-sm', 'LineWidth', 2 , 'MarkerSize',10);

xlim([0 2200])
ylim([74 86])

h = legend( 'SIFT + MMDL', 'HoG + MMDL', 'LBP + MMDL', ...
    'Multi-features + MMDL', 'mi-SVM + k-means', 'k-means', 'ERC-Forests', ...
    'FontSize', 16, 'Location', 'SouthEast' );

set(h,'FontSize',16);

print('-painters', '-depsc', 's15.eps')