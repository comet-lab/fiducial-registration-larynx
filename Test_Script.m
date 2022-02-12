% clc; clear; close all;
img = imread("Real_test_images\real_world_test.png");

[mm_per_pixel, fiducial_pos, Twinp] = calibrate_camera(img,'Style',...
    'rectangle','World_Rotation', [1 0 0; 0 -1 0; 0 0 -1]);
%%

[Tr_in_c, Tb_in_c] = locate_robot(img,'Robot_rotation',rotz(90)*rotx(90),...
    'mm_per_pix',mm_per_pixel,'ApproachVector','tangent');

%% Get Fiducials in world frame
% fiducial_pos_c = (fiducial_pos.*mm_per_pixel)';
% fiducial_pos_w = (Tc_in_w*[fiducial_pos_c;zeros(1,4);ones(1,4)]);
% 
% fiducial_pos_r = Tr_in_w*fiducial_pos_w;
fiducial_pos_r_2 = inv(Tr_in_c)*[fiducial_pos';zeros(1,4);ones(1,4)]

%% Full RUN
img = imread("Real_test_images\real_world_test.png");

calibrate_camera(img,'Style',...
    'rectangle','World_Rotation', [1 0 0; 0 -1 0; 0 0 -1]);

[fid_results, T_results] = AnalyzeImages("Real_test_images\",'Recalibrate',false,'ApproachVector','tangent')


load('mesh_fiducials.mat','fiducial_in_mesh');
Trinct = ToCTPoints(fiducial_in_mesh)


%% TESTING
known_fiducial_pos = [20 20; 70 35; 160 25; 50 100; 105 85; 140 110];
known_fiducial_pos = known_fiducial_pos + [2.5 2.5];

robot_0_pose = [rotz(0) [30+cosd(0)*16 + sind(0)*1.1; 65+sind(0)*16 + cosd(0)*1.1; 0]; zeros(1,3) 1]*[rotz(90)*rotx(90) zeros(3,1); zeros(1,3) 1];
robot_15_pose = [rotz(15) [60+cosd(15)*16 + sind(15)*1.1; 65+sind(15)*16 + cosd(15)*1.1; 0]; zeros(1,3) 1]*[rotz(90)*rotx(90) zeros(3,1); zeros(1,3) 1];
robot_90_pose = [rotz(90) [90+cosd(90)*16 + sind(90)*1.1; 65+sind(90)*16 + cosd(90)*1.1; 0]; zeros(1,3) 1]*[rotz(90)*rotx(90) zeros(3,1); zeros(1,3) 1];

known_fiducial_in_0robot = inv(robot_0_pose)*[known_fiducial_pos';zeros(1,6);ones(1,6)];
known_fiducial_in_15robot = inv(robot_15_pose)*[known_fiducial_pos';zeros(1,6);ones(1,6)];
known_fiducial_in_90robot = inv(robot_90_pose)*[known_fiducial_pos';zeros(1,6);ones(1,6)];