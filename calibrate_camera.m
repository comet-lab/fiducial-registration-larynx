function [mm_per_pixel, fiducial_in_c, Twinc] =...
    calibrate_camera(img, fiducial_size, num_fiducials, options)
%CALIBRATE_CAMERA - takes in an image and the width and height of the
%fiducials. The script will ask you to put a box around each fiducial, and
%mark the origin of your world reference frame. It will return the pixel to
%millimeter conversion factor, the world frame with respect to
%the camera frame, and the fiducial position with respect to the camera in
%mm.
%   img - the image the select fiducial locations
%   fiducial_size - [n x 2] set of known fiducial sizes as [width, height]
%   num_fiducials - [1 x 1] the number of fiducials to look at
%   'ax' - the axis to display the image
%   'style' - the type of method to analyze the fiducials (points,
%   rectangle)
%   'save_loc' - the file name of the mat file
%   'World_Rotation' - the rotation matrix between the world reference
%   frame and the camera reference frame
arguments
    img (:,:,:) uint8
    fiducial_size (1, 2) double = [5, 5];
    num_fiducials (1, 1) double = 4;
    options.ax = gca;
    options.style = 'points';
    options.save_loc = 'calibration_info.mat'
    options.World_Rotation = eye(3,3);
end

mm_per_pixel = [0;0];
world_pos = zeros(1,2);
fiducial_in_c = zeros(2,num_fiducials);
I = imshow(img,'Parent',options.ax);
%% Select fiducials with boxes
title(sprintf("Select Fiducials"));
width = 0;
height = 0;
drawn_objs = cell(4,1);
for i = 1:num_fiducials
    while(1)
        switch options.style
            % Choose between selecting the 
            case 'points'
                title(sprintf("Select the corners of the fiducial"));
                point1 = drawpoint('Color','magenta','Parent',options.ax,'MarkerSize',2);
                point2 = drawpoint('Color','magenta','Parent',options.ax,'MarkerSize',2);
                fid_size = abs([point1.Position(1) - point2.Position(1), ...
                            point1.Position(2) - point2.Position(2)]);
                % Draw a rectangle based on the points selected
                rect = drawrectangle('Position',[point1.Position(1), ...
                    point1.Position(2), fid_size], ...
                    'Color', 'magenta', 'Parent', options.ax, ...
                    'MarkerSize', 2, 'LineWidth', 1.5);
                point1.delete; point2.delete; 
            case 'rectangle'
                % Draw rectangle around fiducial
                rect = drawrectangle('Color','magenta','Parent',options.ax,...
                    'MarkerSize',2,'LineWidth',1,'Rotatable',true);
        end
        
        % Perform Satisfaction Check on drawn elements
        quest = sprintf("Are you happy with your %s",options.style);
        satisfied = questdlg(quest,...
            'Satisfaction Check','Yes','No','Yes');
        if satisfied == "Yes"
            break; % User is satisfied break out of loop
        end
        rect.delete
    end
    % Store the temporary objects into permanent objects
    drawn_objs{i} = rect;
    % average the width and height of all the measured fiducial widths for
    % a more accurate measurement
    width = width + (rect.Position(3) - width)/i;
    height = height + (rect.Position(4) - height)/i;
    % locate fiducial locations in pixels
    fiducial_in_c(:,i) = [rect.Position(1) + rect.Position(3)/2;...
                    rect.Position(2) + rect.Position(4)/2];
end
% determine mm_per_pixel value
mm_per_pixel = [fiducial_size(1)/width; fiducial_size(2)/height];
fiducial_in_c = fiducial_in_c.*mm_per_pixel; % fiducials in camera frame

%% Select origin location
title(sprintf("Select the Origin of the World Reference Frame"));
while(1)
    point = drawpoint('Color','magenta','Parent',options.ax,...
        'MarkerSize',5);
    % average the width and height of all the measured fiducial widths for
    % a more accurate measurement
    world_pos = [point.Position(1); point.Position(2)];
    satisfied = questdlg('Are you happy with your origin selection',...
        'Satisfaction Check','Yes','No','Yes');
    if satisfied == "Yes"
        break;
    end
    point.delete
end
% world frame in camera frame
Twinc = [options.World_Rotation [world_pos.*mm_per_pixel; 0]; zeros(1,3) 1];

%% Cleanup
% Delete Point
point.delete
% Delete Fiducials
for i = 1:size(drawn_objs,1)
    drawn_objs{i}.delete
end
%% Save values to a mat file
save(options.save_loc,'mm_per_pixel','Twinc','fiducial_in_c')
close all
end