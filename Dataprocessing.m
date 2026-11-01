%% Kalibrasi DLT

clear all
close all
clc

[filename_cal,pathname_cal] = uigetfile({'*.png;*.jpeg;*.jpg;*.bmp','Frame Files(*.png, *.jpeg, *.bmp)'},'OPEN CALIBRATION','multiselect','off');
% CalibrationFrame1 = cell(1,size(filename_cal,2));

CalibrationFrame1 = strcat(pathname_cal,filename_cal);

CalibrationFrame2=imread(CalibrationFrame1);
imshow(CalibrationFrame2);
ic = ginput(4);
rc = [0 0;
    1400 0;
    400 1000;
    650 950]; %dalam mm

n=size(rc,1); % n = jumlah titik kontrol
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
close all;

save('dokumen kalibrasi.mat')

%% Konversi openpose ke real

load('D:/kalibrasi.mat')

frame_start=input('Frame start:');
frame_stop =input('Frame stop :');

[file,path] =  uigetfile('*.xlsx','Excel(*.xlsx)');
ic2 = transpose(readmatrix(strcat(path,file),'Sheet','Sheet1','Range','A2:F300'));

for cf = frame_start :frame_stop
    A_recon = zeros(2,2);
    b_recon = zeros(2,1);
    rc_recon=zeros(3,2);
    for k = 1:3
        A_recon(1,1)=ic2(2*k-1,cf+2)*L(7)-L(1);  A_recon(1,2)=ic2(2*k-1,cf+2)*L(8)-L(2);
        A_recon(2,1)=ic2(2*k,cf+2)*L(7)-L(4);  A_recon(2,2)=ic2(2*k,cf+2)*L(8)-L(5);
    
        b_recon(1,1)=L(3)-ic2(2*k-1,cf+2);
        b_recon(2,1)=L(6)-ic2(2*k,cf+2);
        rc_recon(k,:)=round(pinv(A_recon)*b_recon);
    end
    PositionREAL_x(cf-frame_start+1,:) = transpose(rc_recon(:,1));
    PositionREAL_y(cf-frame_start+1,:) = transpose(rc_recon(:,2));
end
close all;

%% Konversi marker ke real

szm = 10;
hszm = 0.5*szm;

% Open video & seperates the frames

[filename,pathname] = uigetfile({'*.mp4'},'OPEN VIDEO','multiselect','off');
videoName=strcat(pathname,filename);
a=VideoReader(videoName);

if rem(frame_stop-frame_start,2)==1
    for cf = frame_start+1:2:frame_stop
    %for cf = 76:2:frame_stop
        b=read(a,cf);
        imshow(b);
        marker = ginput(3);
        
        A_recon = zeros(2,2);
        b_recon = zeros(2,1);
        rc_recon=zeros(3,2);
        for k = 1:3
            A_recon(1,1)=marker(k,1)*L(7)-L(1);  A_recon(1,2)=marker(k,1)*L(8)-L(2);
            A_recon(2,1)=marker(k,2)*L(7)-L(4);  A_recon(2,2)=marker(k,2)*L(8)-L(5);
    
            b_recon(1,1)=L(3)-marker(k,1);
            b_recon(2,1)=L(6)-marker(k,2);
            rc_recon(k,:)=round(pinv(A_recon)*b_recon);
        end
        MarkerPositionREAL_x(cf-frame_start+1,:) = transpose(rc_recon(:,1));
        MarkerPositionREAL_y(cf-frame_start+1,:) = transpose(rc_recon(:,2));
    end
    for cf = frame_start+1:2:frame_stop-1
        MarkerPositionREAL_x(cf-frame_start+1,:) = (MarkerPositionREAL_x(cf-frame_start,:)+MarkerPositionREAL_x(cf-frame_start+2,:))/2;
        MarkerPositionREAL_y(cf-frame_start+1,:) = (MarkerPositionREAL_y(cf-frame_start,:)+MarkerPositionREAL_y(cf-frame_start+2,:))/2;
    end
else
    for cf = frame_start:2:frame_stop
        b=read(a,cf);
        imshow(b);
        marker = ginput(3);
        
        A_recon = zeros(2,2);
        b_recon = zeros(2,1);
        rc_recon=zeros(3,2);
        for k = 1:3
            A_recon(1,1)=marker(k,1)*L(7)-L(1);  A_recon(1,2)=marker(k,1)*L(8)-L(2);
            A_recon(2,1)=marker(k,2)*L(7)-L(4);  A_recon(2,2)=marker(k,2)*L(8)-L(5);
    
            b_recon(1,1)=L(3)-marker(k,1);
            b_recon(2,1)=L(6)-marker(k,2);
            rc_recon(k,:)=round(pinv(A_recon)*b_recon);
        end
        MarkerPositionREAL_x(cf-frame_start+1,:) = transpose(rc_recon(:,1));
        MarkerPositionREAL_y(cf-frame_start+1,:) = transpose(rc_recon(:,2));
    end
end

%% Plot

t=[0:1:(frame_stop-frame_start)];

smoothx1=smooth(t,PositionREAL_x(:,1),0.1,'rloess'); %hip
smoothy1=smooth(t,PositionREAL_y(:,1),0.1,'rloess');
smoothx1m=smooth(t,MarkerPositionREAL_x(:,1),0.1,'rloess');
smoothy1m=smooth(t,MarkerPositionREAL_y(:,1),0.1,'rloess');

smoothx2=smooth(t,PositionREAL_x(:,2),0.1,'rloess'); %knee
smoothy2=smooth(t,PositionREAL_y(:,2),0.1,'rloess');
smoothx2m=smooth(t,MarkerPositionREAL_x(:,2),0.1,'rloess');
smoothy2m=smooth(t,MarkerPositionREAL_y(:,2),0.1,'rloess');

smoothx3=smooth(t,PositionREAL_x(:,3),0.1,'rloess'); %ankle
smoothy3=smooth(t,PositionREAL_y(:,3),0.1,'rloess');
smoothx3m=smooth(t,MarkerPositionREAL_x(:,3),0.1,'rloess');
smoothy3m=smooth(t,MarkerPositionREAL_y(:,3),0.1,'rloess');

smoothx=[smoothx1,smoothx2,smoothx3,smoothx1m,smoothx2m,smoothx3m];
smoothy=[smoothy1,smoothy2,smoothy3,smoothy1m,smoothy2m,smoothy3m];
%smoothxm=[smoothx1m,smoothx2m,smoothx3m];
%smoothym=[smoothy1m,smoothy2m,smoothy3m];

%:,1-3 openpose :,4-6 marker

vecs1x=[smoothx(:,1)-smoothx(:,2),smoothx(:,4)-smoothx(:,5)]; %thigh
vecs1y=[smoothy(:,1)-smoothy(:,2),smoothy(:,4)-smoothy(:,5)];
vecs1=[vecs1x,vecs1y];

vecs2x=[smoothx(:,2)-smoothx(:,3),smoothx(:,5)-smoothx(:,6)]; %leg
vecs2y=[smoothy(:,2)-smoothy(:,3),smoothy(:,5)-smoothy(:,6)];
vecs2=[vecs2x,vecs2y];

theta_thigh=[acosd(complex(-vecs1(:,1),vecs1(:,3))),acosd(complex(-vecs1(:,2),vecs1(:,4)))]; %x negatif karena arah gerak ke kiri
theta_leg=[acosd(complex(-vecs2(:,1),vecs2(:,3))),acosd(complex(-vecs2(:,2),vecs2(:,4)))];
theta_knee=theta_thigh-theta_leg;

figure
chart = tiledlayout(3,1);
position = tiledlayout(chart,2,3); position.Layout.TileSpan = [2 1];
angle = tiledlayout(chart,1,3); angle.Layout.Tile = 3;
joint = {'hip','knee','ankle'};
for i=1:3
    nexttile(position,i); plot(t,smoothx(:,i),'r',t,smoothx(:,i+3),'b'), title(['X_{' joint{i} '}'])
    nexttile(position,i+3); plot(t,smoothy(:,i),'r',t,smoothy(:,i+3),'b'), title(['Y_{' joint{i} '}'])
end
ylabel(position, 'Posisi (mm)')
lgd = legend('OpenPose','Penanda'); lgd.Location = 'eastoutside';
nexttile(angle), plot(t,theta_thigh(:,1),'r',t,theta_thigh(:,2),'b'), title(strcat('\theta','_{thigh}'))
nexttile(angle), plot(t,theta_leg(:,1),'r',t,theta_leg(:,2),'b'), title(strcat('\theta','_{leg}')) %lgd.Layout.Tile = 3;
nexttile(angle), plot(t,theta_knee(:,1),'r',t,theta_knee(:,2),'b'), title(strcat('\theta','_{knee}'))
xlabel(chart, 'Nomor petikan')
ylabel(angle, ['Sudut (' char(176) ')'])

for i = 1:3
    subplot (3,3,i)
    plot(t,smoothx(:,i),'r',t,smoothx(:,i+3),'b')
    title(strcat('X',num2str(i)))
    subplot (3,3,i+3)
    plot(t,smoothy(:,i),'r',t,smoothy(:,i+3),'b')
    title(strcat('Y',num2str(i)))
end
subplot (3,3,7)
plot(t,theta_thigh(:,1),'r',t,theta_thigh(:,2),'b')
title('theta thigh')
subplot (3,3,8)
plot(t,theta_leg(:,1),'r',t,theta_leg(:,2),'b')
title('theta leg')
subplot (3,3,9)
plot(t,theta_knee(:,1),'r',t,theta_knee(:,2),'b')
title('theta knee')

xlabel('Nomor petikan')
ylabel('Posisi(mm)')
legend('OpenPose','Penanda')

%[file,path] = uigetfile('*.xlsx','Excel(*.xlsx)');
%xlswritefig(gcf, strcat(path,file), 'Sheet1', 'H2');

save(strcat('D:/openpose/Graph/',erase(file,'.xlsx')))

%% Plot openpose vs marker

D = 'D:/openpose/Graph_/';
S = dir(fullfile(D,'*.mat'));
for k = 1:numel(S)
    F = fullfile(D,S(k).name);
    T = load(F);
    smoothx{k} = T.smoothx;
    smoothy{k} = T.smoothy;
    theta_thigh{k} = T.theta_thigh;
    theta_leg{k} = T.theta_leg;
    theta_knee{k} = T.theta_knee;
    t{k} = T.t;
    subplot (1,2,1)
    plot(t{k}/t{k}(length(t{k})),theta_knee{k}(:,1))
    hold on
    subplot (1,2,2)
    plot(t{k}/t{k}(length(t{k})),theta_knee{k}(:,2))
    hold on
end
hold off

%% Hitung Correlation Coef. (R)

D = 'D:/openpose/Graph2/';
S = dir(fullfile(D,'*.mat'));
for k = 1:numel(S)
    F = fullfile(D,S(k).name);
    T = load(F);
    %R_now = zeros(length(T.theta_knee(:,1)));
    R_matrix = corrcoef(T.theta_knee);
    R(k) = R_matrix(2,1);
end

for i=1:3:length(R)
    R1((i+2)/3) = R(i);
    R2((i+2)/3) = R(i+1);
    R3((i+2)/3) = R(i+2);
end

save('D:/openpose/R.mat')

%% Hitung Error

D = 'D:/openpose/Graph2/';
S = dir(fullfile(D,'*.mat'));
for k = 1:numel(S)
    F = fullfile(D,S(k).name);
    T = load(F);
    Errornew = zeros(9,length(T.smoothx(:,1)));
    for i = 1:3
        Errornew(i,:)=(T.smoothx(:,i)-T.smoothx(:,i+3));
        Errornew(i+3,:)=(T.smoothy(:,i)-T.smoothy(:,i+3));
    end
    Errornew(7,:)=(T.theta_thigh(:,1)-T.theta_thigh(:,2));
    Errornew(8,:)=(T.theta_leg(:,1)-T.theta_leg(:,2));
    Errornew(9,:)=(T.theta_knee(:,1)-T.theta_knee(:,2));
    Error{k} = Errornew;
    timenew = zeros(length(T.t),1);
    timenew(:,1) = T.t;
    time{k} = timenew;
end

for i = 1:9
    figure(i)
    tiledlayout(1,3)
    for k = 1:3:length(Error)    
        ax1 = subplot (1,3,1);
        plot(time{k}/time{k}(length(time{k})),Error{k}(i,:))
        title('Lambat','FontSize',15)
        hold on
        ax2 = subplot (1,3,2);
        plot(time{k+1}/time{k+1}(length(time{k+1})),Error{k+1}(i,:))
        title('Menengah','FontSize',15)
        hold on
        ax3 = subplot (1,3,3);
        plot(time{k+2}/time{k+2}(length(time{k+2})),Error{k+2}(i,:))
        title('Cepat','FontSize',15)
        hold on
    end
    linkaxes([ax1,ax2,ax3],'y')
end
hold off

% for i = 1:9
%     for k = 1:length(Error)
%         subplot (3,3,i)
%         plot(time{k}/time{k}(length(time{k})),Error{k}(i,:)) % plot 9
%         hold on
%     end
%     hold off
% end

save('D:/openpose/Error2.mat')



%% Correction

D = 'D:/openpose/Graph/';
S = dir(fullfile(D,'*.mat'));
for k = 1:numel(S)
    F = fullfile(D,S(k).name);
    T = load(F);
    t = T.t;
    smoothx = zeros(length(T.smoothx));
    smoothy = zeros(length(T.smoothy));
    for i = 1:3
        smoothx(:,i) = T.smoothx(:,i);
        smoothy(:,i) = T.smoothy(:,i);
        smoothx(:,i+3) = T.smoothx(:,i+3) - mean(T.smoothx(:,i+3)-T.smoothx(:,i));
        smoothy(:,i+3) = T.smoothy(:,i+3) - mean(T.smoothy(:,i+3)-T.smoothy(:,i));
    end
%     for i = 1:6
%         smoothx(:,i) = T.smoothx(:,i);
%         smoothy(:,i) = T.smoothy(:,i);
%     end
%     i = 1;
%     smoothx(:,i+3) = T.smoothx(:,i+3) - mean(T.smoothx(:,i+3)-T.smoothx(:,i));
%     smoothy(:,i+3) = T.smoothy(:,i+3) - mean(T.smoothy(:,i+3)-T.smoothy(:,i));
    
    vecs1x=[smoothx(:,1)-smoothx(:,2),smoothx(:,4)-smoothx(:,5)]; %thigh
    vecs1y=[smoothy(:,1)-smoothy(:,2),smoothy(:,4)-smoothy(:,5)];
    vecs1=[vecs1x,vecs1y];

    vecs2x=[smoothx(:,2)-smoothx(:,3),smoothx(:,5)-smoothx(:,6)]; %leg
    vecs2y=[smoothy(:,2)-smoothy(:,3),smoothy(:,5)-smoothy(:,6)];
    vecs2=[vecs2x,vecs2y];

    theta_thigh=[acosd(complex(-vecs1(:,1),vecs1(:,3))),acosd(complex(-vecs1(:,2),vecs1(:,4)))]; %x negatif karena arah gerak ke kiri
    theta_leg=[acosd(complex(-vecs2(:,1),vecs2(:,3))),acosd(complex(-vecs2(:,2),vecs2(:,4)))];
    theta_knee=theta_thigh-theta_leg;
    
    save(strcat('D:/openpose/Graph_/',(S(k).name)))
end

%% Mean Error, Variance

for k=1:length(Error)
    V(k,:) = var(Error{k}');
    M(k,:) = mean(Error{k}');
    RMSE(k,:) = rms(real(Error{k}'));
end

for i=1:3:length(Error)
    m1((i+2)/3,:) = RMSE(i,:);
    m2((i+2)/3,:) = RMSE(i+1,:);
    m3((i+2)/3,:) = RMSE(i+2,:);
end

save('D:/openpose/Error2.mat')

%% Trial 2

D = 'D:/openpose/Graph/';
S = dir(fullfile(D,'*.mat'));
for kk = 1:length(S)
    F = fullfile(D,S(kk).name);
    load(F);
    theta_thigh=[atan2d(vecs1(:,3),-vecs1(:,1)),atan2d(vecs1(:,4),-vecs1(:,2))]; %x negatif karena arah gerak ke kiri
    theta_leg=[atan2d(vecs2(:,3),-vecs2(:,1)),atan2d(vecs2(:,4),-vecs2(:,2))];
    theta_knee=theta_thigh-theta_leg;
    save(strcat('D:/openpose/Graph2/',(S(kk).name)))
    clearvars -except D S kk
end    

D = 'D:/openpose/Graph2/';
S = dir(fullfile(D,'*.mat'));
for k = 1:numel(S)
    F = fullfile(D,S(k).name);
    T = load(F);
    timenew = zeros(length(T.t),1);
    timenew(:,1) = T.t;
    time{k} = timenew;
    theta_knee_new = zeros(length(T.theta_knee(:,1)),2);
    theta_knee_new = T.theta_knee;
    theta_knee{k} = theta_knee_new;
end

for i = 1:3
    figure(i)
    tiledlayout(5,2)
%     lgd = legend('OpenPose','Penanda'); lgd.Location = 'southoutside';
    for k = 1:3:length(theta_knee)
        t = time{k+i-1}/time{k+i-1}(length(time{k+i-1}));
        nexttile
        plot(t,theta_knee{k+i-1}(:,1),'r',t,theta_knee{k+i-1}(:,2),'b')
    end
    nexttile(10)
    lgd = legend('OpenPose','Penanda'); lgd.Layout.Tile = 'south';
end
hold off

%indeks 1:lari lambat 2:lari sedang 3:lari cepat
for i=1:3:length(R)
    R1((i+2)/3) = R(i);
    R2((i+2)/3) = R(i+1);
    R3((i+2)/3) = R(i+2);
    RMSE1((i+2)/3) = mean(RMSE(i));
    RMSE2((i+2)/3) = mean(RMSE(i+1));
    RMSE3((i+2)/3) = mean(RMSE(i+2));
end
