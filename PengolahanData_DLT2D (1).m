clear all; close all; clc;

%% Camera Calibration DLT
[filename_cal,pathname_cal] = uigetfile({'*.png;*.jpeg;*.jpg;*.bmp','Frame Files(*.png, *.jpeg, *.bmp)'},'OPEN FRAME','multiselect','off');
% CalibrationFrame1 = cell(1,size(filename_cal,2));
CalibrationFrame1 = strcat(pathname_cal,filename_cal);
CalibrationFrame2=imread(CalibrationFrame1);
imshow(CalibrationFrame2);

ic = ginput(4);
rc = [0 0;
    297 0;
    0 210;
    297 210]; %dalam mm

n=size(rc,1); % n = number of control points
A = zeros(2*n,8);
b = zeros(2*n,1);

for i=1:n
    b(2*i-1,1) = ic(i,1);
    b(2*i,1) = ic(i,2);
    
    A(2*i-1,1)  = rc(i,1);
    A(2*i-1,2)  = rc(i,2);
    A(2*i-1,3)  = 1;
    A(2*i-1,7)  =-rc(i,1)*ic(i,1);
    A(2*i-1,8)  =-rc(i,2)*ic(i,1);
    A(2*i,4)    = rc(i,1);
    A(2*i,5)    = rc(i,2);
    A(2*i,6)    = 1;
    A(2*i,7)    =-rc(i,1)*ic(i,2);
    A(2*i,8)    =-rc(i,2)*ic(i,2);
end
Ap = pinv(A);
% Ap = inv(A);
L = Ap*b;

%% Manual marker detection
clc;
% [filename,pathname] = uigetfile({'*.png;*.jpeg;*.jpg;*.bmp','Frame Files(*.png, *.jpeg, *.bmp)'},'OPEN FRAME','multiselect','on');
% im1 = cell(1,size(filename,2));
% for a=1:size(filename,2)
%     im1(a) = strcat(pathname,filename(a));
% end

[filename,pathname] = uigetfile({'*.png;*.jpeg;*.jpg;*.bmp','Frame Files(*.png, *.jpeg, *.bmp)'},'OPEN FRAME','multiselect','off');
% CalibrationFrame1 = cell(1,size(filename_cal,2));

im1 = strcat(pathname,filename);

numMarker = 2;%bisa diganti sesuai kebutuhan

MarkerPosition_x = zeros(1,numMarker);
MarkerPosition_y = zeros(1,numMarker);

im2=imread(im1);
figure(1); imshow(im2);
ic2=ginput(numMarker);
A_recon = zeros(2,2);
b_recon = zeros(2,1);
rc_recon=zeros(numMarker,2);
for k = 1:numMarker
    A_recon(1,1)=ic2(k,1)*L(7)-L(1);  A_recon(1,2)=ic2(k,1)*L(8)-L(2);
    A_recon(2,1)=ic2(k,2)*L(7)-L(4);  A_recon(2,2)=ic2(k,2)*L(8)-L(5);
    
    b_recon(1,1)=L(3)-ic2(k,1);
    b_recon(2,1)=L(6)-ic2(k,2);
    rc_recon(k,:)=round(pinv(A_recon)*b_recon);
end
MarkerPosition_x(1,:) = transpose(rc_recon(:,1));
MarkerPosition_y(1,:) = transpose(rc_recon(:,2));


close all;


