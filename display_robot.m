function [robot_refs] = display_robot(options)
arguments
    options.RobotFile (1,:) char = 'robot_in_ct.mat'
    options.DisplayFiducials (1,1) logical = false
    options.FiducialFile (1,:) char = 'robot_localization.mat'
end

load(options.RobotFile,'Trinct');
robot_refs = cell(1,size(Trinct,3));
if options.DisplayFiducials
    load(options.FiducialFile,'fiducial_in_r');
end
% fiducials = cell(1,size(Trinct,3));
for i = 1:size(Trinct,3)
    robot_refs{1,i} = triad('matrix', Trinct(:,:,i), 'Scale', 4, 'linewidth', 2);
    if options.DisplayFiducials
        fiducial_in_mesh = Trinct(:,:,i)*[fiducial_in_r{i}; ones(1,size(fiducial_in_r{i},2))];
        legend_entry = sprintf("Image %d",i);
        plot3(fiducial_in_mesh(1,:), fiducial_in_mesh(2,:),...
            fiducial_in_mesh(3,:), '.', 'MarkerSize', 30,...
            'DisplayName', legend_entry);
    end
%     fiducials{1,i} = 
end
end