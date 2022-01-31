function [newImage, rectPosition] = SelectRegion(origImage,varargin)
%SELECTNOTCH Takes in an image and allows the user to select a region. The
%output is a zoomed in picture of that region.
%   'PreviousRegions' - Optional Argument is a nx4 array indicating previous
%   rectangles that have been analyzed where a row consists of
%   [xmin,ymin,xdistance,ydistance]. The previous regions will be selected
%   on the image. Default value is [].
%   'Axis' - Optional Argument which is the axis to display the image one


%****** INPUT PARSING *********************
previousRegions = [];
txt = "Select the notch you want to see";


p = inputParser();
addRequired(p,'origImage',@isnumeric);
checkmat = @(x) isnumeric(x) && (size(x,2) == 4 || size(x,2) == 0);
addOptional(p, 'previousRegions', previousRegions, checkmat);
addOptional(p,'axis',0);
addOptional(p,'title',txt,@isstring);
parse(p,origImage,varargin{:});

previousRegions = p.Results.previousRegions;
ax = p.Results.axis;
if ax == 0
    ax = gca;
end
txt = p.Results.title;
%****************************************

I = imshow(origImage,'Parent',ax);
title(txt);

% Display previously selected regions
for i= 1:size(previousRegions,1)
    rectangle('Position',previousRegions(i,:),'EdgeColor','red','LineWidth',1.5,'Parent',ax)
end

while(1)    
    % Select new region
    roi = drawrectangle('Parent',ax);
    rectPosition = roi.Position;
    xmin = round(roi.Position(1));
    ymin = round(roi.Position(2));
    xmax = round(roi.Position(1) + roi.Position(3) - 1); % -1 needed to prevent going out of the figure 
    ymax = round(roi.Position(2) + roi.Position(4) - 1); % -1 needed to prevent going out of the figure
    newImage = origImage(ymin:ymax, xmin:xmax, :);
    
    satisfied = questdlg("Confirm Zoom",...
            'Satisfaction Check','Yes','No','Yes');
        if satisfied == "Yes"
            break; % User is satisfied break out of loop
        end
    delete(roi);
end
% imshow(newImage)
end

