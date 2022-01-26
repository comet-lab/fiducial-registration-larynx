function [tip_pos, orient, base_pos] = locate_robot(img,options)
%LOCATE_ROBOT - takes in an image and allows the user to use the image to
%select the location of the the tip of the robot, the approach vector of 
%the robot, and the base location of the robot all in pixels 
%   img - the image to observe the robot in
%   'ax' - the axis to display the image
%
%*Note: the y-axis for pixels is positive moving from top to bottom on the
%image and the x-axis for pixels is positive moving left to right
arguments
    img double
    options.ax = gca
end

I = imshow(img,'Parent',options.ax);
%% Locate the robot tip
title(sprintf("Select the tip of the robot, then the tip"));
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
%% Locate the robot base
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
base_pos = base_point.Position;
%% Find robot's approach vector 
title(sprintf("Draw a line across the tip of the robot"));
while(1) 
    tip_line = drawline('Color','magenta','Parent',options.ax,'MarkerSize',3);
    diff = [tip_line.Position(2,1) - tip_line.Position(1,1),...
            tip_line.Position(2,2) - tip_line.Position(1,2)];
    end_point = tip_pos(1,:) + [-diff(2), diff(1)];
    approach_vec = drawline('Position', [tip_pos(1,:); end_point],...
        'Color','magenta','Parent',options.ax,'MarkerSize',3);
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
end