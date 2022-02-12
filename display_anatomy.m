addpath('stlTools');
%% Display the anatomy
% path = fullfile('anatomical-model', 'larynx-model.stl');
path = "Y:\NIDCD-2020\IROS22\Experiments\Reachability Experiments\LarynxModel\tissue-L1.stl";
[vertices, faces, ~, ~] = stlRead(path);
stlPlot(vertices, faces, 'Human larynx');
hold on, grid on, axis equal
       
xlabel('X [mm]'), ylabel('Y [mm]'), zlabel('Z [mm]')
set(gca, 'Clipping', 'off');

load('mesh_fiducials.mat','fiducial_in_mesh')
plot3(fiducial_in_mesh(1,:), fiducial_in_mesh(2,:), fiducial_in_mesh(3,:), 's', 'MarkerSize', 20, 'MarkerFaceColor', 'b');
legend(["Patient Anatomy", "Fiducials"]);