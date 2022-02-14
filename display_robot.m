load('robot_in_ct.mat','Trinct');
for i = 1:size(Trinct,3)
    robotRef = triad('matrix', Trinct(:,:,i), 'Scale', 4, 'linewidth', 2);
end
