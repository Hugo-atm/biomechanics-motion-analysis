clear all
close all
clc
%% DLT calibration
[filename_cal,pathname_cal] = uigetfile({'*.png;*.jpeg;*.jpg;*.bmp','Frame Files(*.png, *.jpeg, *.bmp)'},'OPEN CALIBRATION','multiselect','off');
CalibrationFrame1 = strcat(pathname_cal,filename_cal);

CalibrationFrame2 = imread(CalibrationFrame1);
imshow(CalibrationFrame2);
ic = ginput(4);
rc = [0 0;
    504 0;
    504 441;
    0 441]; %dalam mm

n = size(rc,1); % n = jumlah titik kontrol
A = zeros(2*n,8);
b = zeros(2*n,1);

for i=1:n
    b(2*i-1,1) = ic(i,1);
    b(2*i,1) = ic(i,2);
    
    A(2*i-1,1) = rc(i,1);
    A(2*i-1,2) = rc(i,2);
    A(2*i-1,3) = 1;
    A(2*i-1,7) = -rc(i,1)*ic(i,1);
    A(2*i-1,8) = -rc(i,2)*ic(i,1);
    A(2*i,4) = rc(i,1);
    A(2*i,5) = rc(i,2);
    A(2*i,6) = 1;
    A(2*i,7) = -rc(i,1)*ic(i,2);
    A(2*i,8) = -rc(i,2)*ic(i,2);
end
Ap = pinv(A);
L = Ap*b;
close all;

% Save all variables to a specified path
[filename_save, pathname_save] = uiputfile('*.mat', 'Save Calibration As');
save_path = strcat(pathname_save, filename_save);
save(save_path);

%% Convert 2D pixel coordinates to real world coordinates
% Load the CSV file
[file, path] = uigetfile('*.csv', 'Select CSV file');
data = csvread(strcat(path, file), 1, 0); % Skip the first row (headers)

% Extract the marker coordinates
ic2 = transpose(data);

% Loading calibration result
load('D:\Tugas Akhir\Calibration\S43FRCALIBRATION\S43FRCALIBRATIONRESULT.mat')

frame_start = 1; % Start from the first frame
frame_stop = size(ic2, 2); % Last frame is the number of columns

PositionREAL_x = zeros(frame_stop, 3);
PositionREAL_y = zeros(frame_stop, 3);

for cf = frame_start:frame_stop
    A_recon = zeros(2,2);
    b_recon = zeros(2,1);
    rc_recon = zeros(3,2);
    for k = 1:3
        A_recon(1,1) = ic2(2*k-1,cf)*L(7) - L(1);
        A_recon(1,2) = ic2(2*k-1,cf)*L(8) - L(2);
        A_recon(2,1) = ic2(2*k,cf)*L(7) - L(4);
        A_recon(2,2) = ic2(2*k,cf)*L(8) - L(5);
    
        b_recon(1,1) = L(3) - ic2(2*k-1,cf);
        b_recon(2,1) = L(6) - ic2(2*k,cf);
        rc_recon(k,:) = round(pinv(A_recon)*b_recon);
    end
    PositionREAL_x(cf,:) = transpose(rc_recon(:,1));
    PositionREAL_y(cf,:) = transpose(rc_recon(:,2));
end

% Create a table to save as CSV
real_world_data = table(PositionREAL_x(:,1), PositionREAL_y(:,1), ...
                        PositionREAL_x(:,2), PositionREAL_y(:,2), ...
                        PositionREAL_x(:,3), PositionREAL_y(:,3), ...
                        'VariableNames', {'Marker1x', 'Marker1y', 'Marker2x', 'Marker2y', 'Marker3x', 'Marker3y'});

% save to a csv file
[save_file, save_path] = uiputfile('*.csv', 'Save Real-world Coordinates As CSV');
writetable(real_world_data, strcat(save_path, save_file));

%% calculate and plot knee angle

% loading the csv file
[filename, pathname] = uigetfile('*.csv', 'Select the CSV file with motion capture data');
fullPath = fullfile(pathname, filename);
data = readtable(fullPath);

% Extract motion capture data
Hip_x = data.Marker1x;
Hip_y = data.Marker1y;
Knee_x = data.Marker2x;
Knee_y = data.Marker2y;
Ankle_x = data.Marker3x;
Ankle_y = data.Marker3y;

% Calculate vectors for raw and smoothed coordinates
thigh_vector_raw_x = Knee_x - Hip_x;
thigh_vector_raw_y = Knee_y - Hip_y;
shank_vector_raw_x = Ankle_x - Knee_x;
shank_vector_raw_y = Ankle_y - Knee_y;

%Final vector
thigh_vector_raw = [thigh_vector_raw_x,thigh_vector_raw_y];

shank_vector_raw = [shank_vector_raw_x, shank_vector_raw_y];

%unit vector of negative axis
vx = [-1,0];
num_frames = size(thigh_vector_raw, 1);
theta_thigh_raw = zeros(num_frames, 1);
theta_shank_raw = zeros(num_frames, 1);

for i = 1:num_frames
    % Raw data
    theta_thigh_raw(i) = acosd(dot(thigh_vector_raw(i,:), vx) / norm(thigh_vector_raw(i,:)));
    theta_shank_raw(i) = acosd(dot(shank_vector_raw(i,:), vx) / norm(shank_vector_raw(i,:)));
end

knee_angle_raw = theta_thigh_raw - theta_shank_raw;

% Save the data
data.knee_angle_raw = knee_angle_raw;

% save the csv file
[save_filename, save_pathname] = uiputfile('*.csv', 'Save the output data as');
save_fullPath = fullfile(save_pathname, save_filename);
writetable(data, save_fullPath);