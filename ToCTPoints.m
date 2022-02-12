function Trinct = ToCTPoints(fiducials_inCT, calibration_data, robot_data, options)
arguments
    fiducials_inCT (3,:) double 
    calibration_data (1,:) char = 'calibration_info.mat'
    robot_data (1,:) char = 'robot_localization.mat'
    options.Mode (1,:) char ...
        {ismember(options.Mode,{'world_frame','robot_frame'})} = 'world_frame'
    options.SaveLocation = 'robot_in_ct.mat'
end

load(calibration_data, 'fiducial_in_c', 'Twinc')
switch options.Mode
    case 'world_frame'
        load(robot_data, 'Trinw')
        fiducial_in_world = inv(Twinc)*[fiducial_in_c;zeros(1,size(fiducial_in_c,2));ones(1,size(fiducial_in_c,2))];
        [R,t,FRE,FREcomponents] = point_register(fiducial_in_world(1:3,:),fiducials_inCT);

        Twinct = [R t;0 0 0 1];

        Trinct = zeros(4, 4, size(Trinw,3));
        for i = 1:size(transformation_mat,3) % For loop through all robot transformations
            Trinct(:,:,i) = Twinct*Trinw(:,:,i);
        end
    case 'robot_frame'
        load(robot_data, 'fiducial_in_r')
        Trinct = zeros(4, 4, length(fiducial_in_r));
        for i = length(fiducial_in_r)
            [R,t,FRE,FREcomponents] = point_register(fiducial_in_r{i},fiducials_inCT);
            Trinct(:,:,i) = [R t; 0 0 0 1];
        end
end

save(options.SaveLocation, 'Trinct')

end