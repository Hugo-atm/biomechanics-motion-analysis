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
ic2 = data'; % Transpose to match the original code structure

% Assuming the rest of the code is the same, including loading the calibration matrix
load('D:\Tugas Akhir\Calibration\S33FRCALIBRATION\S33 FR CALIBRATION RESULTS\S33_DLT_CALIBRATION_RESULT.mat')

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
    PositionREAL_x(cf,:) = rc_recon(:,1)';
    PositionREAL_y(cf,:) = rc_recon(:,2)';
end

% Create a table to save as CSV
real_world_data = table(PositionREAL_x(:,1), PositionREAL_y(:,1), ...
                        PositionREAL_x(:,2), PositionREAL_y(:,2), ...
                        PositionREAL_x(:,3), PositionREAL_y(:,3), ...
                        'VariableNames', {'Marker1x', 'Marker1y', 'Marker2x', 'Marker2y', 'Marker3x', 'Marker3y'});

% Prompt user to save the CSV
[save_file, save_path] = uiputfile('*.csv', 'Save Real-world Coordinates As CSV');
writetable(real_world_data, strcat(save_path, save_file));

%% calculate and plot knee angle

% Prompt user for the CSV file
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

% Smooth the data using a robust local regression
t = (0:1:length(Hip_x)-1)';
smooth_Hip_x = smooth(t, Hip_x, 0.01, 'rloess');
smooth_Hip_y = smooth(t, Hip_y, 0.01, 'rloess');
smooth_Knee_x = smooth(t, Knee_x, 0.01, 'rloess');
smooth_Knee_y = smooth(t, Knee_y, 0.01, 'rloess');
smooth_Ankle_x = smooth(t, Ankle_x, 0.01, 'rloess');
smooth_Ankle_y = smooth(t, Ankle_y, 0.01, 'rloess');

% Calculate vectors for raw and smoothed coordinates
thigh_vector_raw_x = Knee_x - Hip_x;
thigh_vector_raw_y = Knee_y - Hip_y;
shank_vector_raw_x = Ankle_x - Knee_x;
shank_vector_raw_y = Ankle_y - Knee_y;

thigh_vector_smooth_x = smooth_Knee_x - smooth_Hip_x;
thigh_vector_smooth_y = smooth_Knee_y - smooth_Hip_y;
shank_vector_smooth_x = smooth_Ankle_x - smooth_Knee_x;
shank_vector_smooth_y = smooth_Ankle_y - smooth_Knee_y;

% Calculate angles with respect to horizontal axis for raw and smoothed data
theta_thigh_raw = acosd(thigh_vector_raw_x ./ sqrt(thigh_vector_raw_x.^2 + thigh_vector_raw_y.^2));
theta_shank_raw = acosd(shank_vector_raw_x ./ sqrt(shank_vector_raw_x.^2 + shank_vector_raw_y.^2));
knee_angle_raw = theta_thigh_raw - theta_shank_raw;

theta_thigh_smooth = acosd(thigh_vector_smooth_x ./ sqrt(thigh_vector_smooth_x.^2 + thigh_vector_smooth_y.^2));
theta_shank_smooth = acosd(shank_vector_smooth_x ./ sqrt(shank_vector_smooth_x.^2 + shank_vector_smooth_y.^2));
knee_angle_smooth = theta_thigh_smooth - theta_shank_smooth;

% Save the data
data.knee_angle_raw = knee_angle_raw;
data.knee_angle_smooth = knee_angle_smooth;

% Prompt user for output CSV file path
[save_filename, save_pathname] = uiputfile('*.csv', 'Save the output data as');
save_fullPath = fullfile(save_pathname, save_filename);
writetable(data, save_fullPath);