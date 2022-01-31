function save_mat = AnalyzeImages(path,calibrationFile,options)
%ANALYZEFOLDER Takes in a path to a folder which contains images to analyze
%and goes through each image one by one.
%
%   To run:
%       theta_mat = AnalyzeFolder("C:\users\nickp\pictures\",false,5)

%   calibrationFile - Optional Argument determines where to load the
%   calibration info from
%   'Axis' - Optional Argument which is the axis to display the image one
%   'RelativePath' - Optional Argument sets whether the passed in path is
%   relative. Default value is true.
%   'SaveLocation' - Optional Argument which determines where to save the
%   output. Abides by the 'isRelative' flag.
%   'StartFile' - Name-Argument par which denotes what file in the
%   directory we want to start analysis on

%****** INPUT PARSING *********************
arguments
    path (1,1) string
    calibrationFile (1,1) string = "fiducial_info.mat"
    options.axis = gca
    options.RelativePath logical = true
    options.SaveLocation string = "testOutput.mat"
    options.SingleFile logical = false
    options.StartFile string = "";
    options.Robot_Rotation (3,3) double = rotz(90)*rotx(90)
end
%*********************************************

load(calibrationFile,'mm_per_pixel','world_pos','fiducial_pos');
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
    results_array = cell(numOfFiles-startIndex + 1, 1);
    for i = startIndex:numOfFiles
         % For loop through the files in the directory and analyze each file
        try
            % This is in case someone decides the are done analyzing images but
            % doesn't want to lose their progress.
            img = imread(path+filesInDir(i).name);
            Ttip_in_c = locate_robot(img,'Robot_rotation',...
                options.Robot_Rotation,'mm_per_pix',mm_per_pixel);
            fiducial_pos_r = inv(Ttip_in_c)*[fiducial_pos';zeros(1,4);ones(1,4)];
            results_array{i-startIndex + 1} = fiducial_pos_r(1:3,:);
        catch e
            errorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
                e.stack(1).name, e.stack(1).line, e.message);
            fprintf(2, '%s\n', errorMessage);
            fprintf(2,'The identifier was:\n%s\n',e.identifier);
%             break;
        end
    end
else
    % We are only analyzing a single file
    img = imread(path);
    Ttip_in_c = locate_robot(img,'Robot_rotation',...
        options.Robot_Rotation,'mm_per_pix',mm_per_pixel);
    fiducial_pos_r = inv(Ttip_in_c)*[fiducial_pos';zeros(1,4);ones(1,4)];
    results_array{i} = fiducial_pos_r(1:3,:);
end

save_mat = cell2mat(results_array); % Conver the cell array to a matrix for saving
% Overwrite current csv file
try
    save(options.SaveLocation,'results_array')
    writematrix(save_mat,"Results.csv");
catch
    sprintf("failed save")
end

