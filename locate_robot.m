function [Ttip_in_c, Tbase_in_c] = locate_robot(img,options)
%LOCATE_ROBOT - takes in an image and allows the user to use the image to
%select the location of the the tip of the robot, the approach vector of
%the robot, and the base location of the robot all in the camera's
%reference frame
%   img - the image to observe the robot in
%   'ax' - the axis to display the image
%   'Robot_rotation' - the rotation matrix to align the camera frame with
%   the robot frame before movement.
%   'mm_per_pix' - The conversion between mm to pixels. Leave empty or set
%   to 1 in order to return everything in pixels. This value can either be
%   a [1x1] vector or a [1x2] vector.
%   'base' - logical value that determines whether you want to locate the
%   base of the robot or not
%
%*Note: the y-axis for pixels is positive moving from top to bottom on the
%image and the x-axis for pixels is positive moving left to right
arguments
    img (:,:,:) uint8
    options.ax = gca
    options.Robot_rotation double = eye(3,3);
    options.mm_per_pix double = 1;
    options.base (1,1) logical = false
    options.ApproachVector (1,:) char...
        {ismember(options.ApproachVector,{'tangent','normal'})} = 'normal'
end

I = imshow(img,'Parent',options.ax);
%% Locate the robot base
if options.base
    [zoomed_img, start_rect] = ...
        SelectRegion(img,'axis',options.ax,...
        'title',"Zoom in on the base of the robot");
    I = imshow(zoomed_img,'Parent',options.ax);
    title(sprintf("Select the base of the robot"));
    while(1)
        base_point = drawpoint('Color','magenta','Parent',options.ax,'MarkerSize',3);
        quest = sprintf("Are you happy with your point selection?");
        satisfied = questdlg(quest,...
            'Satisfaction Check','Yes','No','Yes');
        if satisfied == "Yes"
            break; % User is satisfied break out of loop
        end
        base_point.delete
    end
    Tbase_in_c = [options.Robot_rotation, ...
        [(base_point.Position' + start_rect(1:2)').*options.mm_per_pix';0];...
        zeros(1,3), 1];
else
    Tbase_in_c = [options.Robot_rotation, zeros(3,1);...
        zeros(1,3), 1];
end
%% Locate the robot tip
[zoomed_img, start_rect] = ...
    SelectRegion(img,'axis',options.ax,...
    'title',"Zoom in on the tip of the robot");
I = imshow(zoomed_img,'Parent',options.ax);
title(sprintf("Select the tip of the robot"));
while(1)
    tip_point = drawpoint('Color','magenta','Parent',options.ax,'MarkerSize',3);
    quest = sprintf("Are you happy with your point selection?");
    satisfied = questdlg(quest,...
        'Satisfaction Check','Yes','No','Yes');
    if satisfied == "Yes"
        break; % User is satisfied break out of loop
    end
    tip_point.delete
end
tip_pos = tip_point.Position;
%% Find robot's approach vector

while(1)
    switch options.ApproachVector
        case 'normal'
            title(sprintf("Draw a line across the tip of the robot"));
            tip_line = drawline('Color','magenta','Parent',options.ax,'MarkerSize',3);
            diff = [tip_line.Position(2,1) - tip_line.Position(1,1),...
                tip_line.Position(2,2) - tip_line.Position(1,2)];
            diff = [-diff(2), diff(1)]; % want normal vector
            end_point = tip_pos(1,:) + diff;
            approach_vec = drawline('Position', [tip_pos(1,:); end_point],...
                'Color','magenta','Parent',options.ax,'MarkerSize',3);
        case 'tangent'
            title(sprintf("Draw a line along the laser fiber"));
            tip_line = drawline('Color','magenta','Parent',options.ax,'MarkerSize',3);
            diff = [tip_line.Position(2,1) - tip_line.Position(1,1),...
                tip_line.Position(2,2) - tip_line.Position(1,2)];
    end
    quest = sprintf("Are you happy with your line?");
    satisfied = questdlg(quest,...
        'Satisfaction Check','Yes','No','Yes');
    if satisfied == "Yes"
        break; % User is satisfied break out of loop
    end
    tip_line.delete
    approach_vec.delete
end
orient = [-diff(2), diff(1)]; % [delta x, delta y] in pixels of the approach vector
orient = orient./norm(orient);
theta = rad2deg(atan2(orient(2),orient(1)));

tip_pos = tip_point.Position + start_rect(1:2);
Ttip_in_c = [rotz(theta), [tip_pos'.*options.mm_per_pix';0]; 0 0 0 1];
Ttip_in_c = Ttip_in_c*[options.Robot_rotation zeros(3,1);zeros(1,3) 1];
end