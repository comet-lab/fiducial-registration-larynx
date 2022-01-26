function [mm_per_pixel, world_pos, fiducial_pos] = calibrate_camera(img, fiducial_size, num_fiducials, options)
%CALIBRATE_CAMERA - takes in an image and the width and height of the
%fiducials. The script will ask you to put a box around each fiducial, and
%mark the origin of your world reference frame. It will return the pixel to
%millimeter conversion factor as well as the pixel location of the world
%frame and fiducials.
%   img - the image the select fiducial locations
%   fiducial_size - [n x 2] set of known fiducial sizes as [width, height]
%   num_fiducials - [1 x 1] the number of fiducials to look at
arguments
    img double
    fiducial_size (1, 2) double = [5, 5];
    num_fiducials (1, 1) double = 4;
    options.ax = gca;
    options.style = 'rect';
end

mm_per_pixel = [0,0];
world_pos = zeros(1,2);
fiducial_pos = zeros(num_fiducials, 2);
I = imshow(img,'Parent',options.ax);
%% Select fiducials with boxes
title(sprintf("Select Fiducials"));
width = 0;
height = 0;
drawn_rects = cell(4,1);
for i = 1:num_fiducials
    % Draw rectangle around fiducial
    rect = drawrectangle('Color','magenta','Parent',options.ax,...
                            'MarkerSize',2,'LineWidth',1.5);
    drawn_rects{i} = rect;
    % average the width and height of all the measured fiducial widths for
    % a more accurate measurement
    width = width + (rect.Position(3) - width)/i;
    height = height + (rect.Position(4) - height)/i;
    % locate fiducial locations in pixels 
    fiducial_pos(i,:) = [rect.Position(1) + rect.Position(3)/2,...
                         rect.Position(2) + rect.Position(4)/2];
end
% determine mm_per_pixel value
mm_per_pixel = [fiducial_size(1)/width, fiducial_size(2)/height];
% Delete Fiducials
for i = 1:size(drawn_rects,1)
    drawn_rects{i}.delete
end

%% Select origin location
title(sprintf("Select the Origin of the World Reference Frame"));
point = drawpoint('Color','magenta','Parent',options.ax,...
                        'MarkerSize',2);
% average the width and height of all the measured fiducial widths for
% a more accurate measurement
world_pos = [point.Position(1), point.Position(2)];
point.delete
end