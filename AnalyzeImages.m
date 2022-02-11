function [fiducial_mat, transformation_mat] = AnalyzeImages(path,calibrationFile,options)
%ANALYZEFOLDER Takes in a path to a folder which contains images to analyze
%and goes through each image one by one.
%
%   To run:
%       AnalyzeImages("Test_images\","fiducial_info.mat")

%   calibrationFile - Optional Argument determines where to load the
%   calibration info from
%   'Axis' - Optional Argument which is the axis to display the image
%   onemot
%   'RelativePath' - Optional Argument sets whether the passed in path is
%   relative. Default value is true.
%   'SaveLocation' - Optional Argument which determines where to save the
%   output. Abides by the 'isRelative' flag.
%   'StartFile' - Name-Argument par which denotes what file in the
%   directory we want to start analysis on

%****** INPUT PARSING *********************
arguments
    path (1,1) string
    calibrationFile (1,1) string = "calibration_info.mat"
    options.axis = gca
    options.RelativePath logical = true
    options.SaveLocation string = "robot_localization.mat"
    options.SingleFile logical = false
    options.StartFile string = "";
    options.Robot_Rotation (3,3) double = rotz(90)*rotx(90)
    options.ApproachVector (1,:) char...
        {ismember(options.ApproachVector,{'tangent','normal'})} = 'normal'
    options.Recalibrate (1,1) logical = false
end
%*********************************************

load(calibrationFile,'mm_per_pixel','Twinc','fiducial_in_c');
if options.RelativePath
    path = pwd + "\" + path;
    options.SaveLocation = pwd + "\" + options.SaveLocation;
end
if ~options.SingleFile
    % Analyzing multiple files in the directory
    filesAndFolders = dir(path);
    filesInDir = filesAndFolders(~([filesAndFolders.isdir]));
    numOfFiles = length(filesInDir);
    startIndex = 1;
    for f = 1:numOfFiles
        % Goes through the files to determine where to start analyzing
        % images from.
        if strcmp(options.StartFile,filesInDir(f).name)
            startIndex = f;
            break;
        end
    end
    fiducial_array = cell(numOfFiles-startIndex + 1, 1);
    transformation_mat = zeros(4,4,numOfFiles-startIndex + 1);
    for i = startIndex:numOfFiles
        % For loop through the files in the directory and analyze each file
        [fiducial_array{i-startIndex + 1}, transformation_mat(:,:,i-startIndex + 1)] = ...
            AnalyzeSingleFile(path+filesInDir(i).name,...
            mm_per_pixel, fiducial_in_c, Twinc, options.Recalibrate,...
            options.Robot_Rotation, options.ApproachVector);
    end
else
    % We are only analyzing a single file
    [fiducial_array, transformation_mat] = ...
            AnalyzeSingleFile(path,...
            mm_per_pixel, fiducial_in_c, Twinc, options.Recalibrate,...
            options.Robot_Rotation, options.ApproachVector);
end

fiducial_mat = cell2mat(fiducial_array); % Conver the cell array to a matrix for saving
% Overwrite current csv file
try
    save(options.SaveLocation,'fiducial_array','transformation_mat')
catch
    sprintf("failed save")
end
close gcf
end
%% Helper Function
function [fiducial_mat, transformation_mat] = ...
    AnalyzeSingleFile(path, mm_per_pixel, fiducial_in_c, Twinc,...
    recalibrate, robot_rotation, approach_vector)
fiducial_mat = [];
transformation_mat = zeros(4,4);
try
    % This is in case someone decides the are done analyzing images but
    % doesn't want to lose their progress.
    img = imread(path);
    if recalibrate
        [mm_per_pixel, fiducial_in_c, Twinc] = calibrate_camera(img,'Style',...
            'rectangle','World_Rotation', [1 0 0; 0 -1 0; 0 0 -1]);
    end
    Ttip_in_c = locate_robot(img,'Robot_rotation',...
        robot_rotation,'mm_per_pix',mm_per_pixel,...
        'ApproachVector', approach_vector);
    fiducial_pos_r = inv(Ttip_in_c)*[fiducial_in_c';zeros(1,4);ones(1,4)];
    fiducial_mat = fiducial_pos_r(1:3,:);
    transformation_mat = inv(Twinc)*Ttip_in_c;
catch e
    errorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
        e.stack(1).name, e.stack(1).line, e.message);
    fprintf(2, '%s\n', errorMessage);
    fprintf(2,'The identifier was:\n%s\n',e.identifier);
%             break;
end
end