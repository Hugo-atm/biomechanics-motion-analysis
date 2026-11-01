clear all
clc

%this code made to ease the user for triangulation and see the
%corresponding 3D estimated points of marker
%the following result of 3D estimated points of marker were followed by
%judgement of user wether the point is considered reliable or not

dummy = 'project1';
Cal = 'S1';
subject = 'S1';
% gcs = '10';

root_check= 'D:\Semester 8\TA\Gabungan\Checkerboard';
% root_check= 'D:\S2\OneDrive - Institut Teknologi Bandung\thesisproj\asset\Checkerboard';

fullsideR = strcat(Cal,'_BR_FR.mat');
fullsideL = strcat(Cal,'_FL_BL.mat');

stereoR = load(fullfile(root_check, Cal, fullsideR));
stereoL = load(fullfile(root_check, Cal, fullsideL));


root_dat = fullfile('D:\Semester 8\TA\Gabungan\Data\Cleaned');
% root_dat = fullfile('D:\S2\OneDrive - Institut Teknologi Bandung\thesisproj\asset\Gait',dummy,'Data\Processed_sal\Cleaned');

datPtsBR = readtable(fullfile(root_dat,strcat(subject,'_BR_inverted_Filtered.csv')));
datPtsFR = readtable(fullfile(root_dat,strcat(subject,'_FR_inverted_Filtered.csv')));
datPtsFL = readtable(fullfile(root_dat,strcat(subject,'_FL_inverted_Filtered.csv')));
datPtsBL = readtable(fullfile(root_dat,strcat(subject,'_BL_inverted_Filtered.csv')));

disp('data reading done')
% RightSide
sterR = strcat(Cal,'_BR_FR');

for i=1:7
    markx = strcat('Marker',num2str(i),'x');
    marky = strcat('Marker',num2str(i),'y');
    markz = strcat('Marker',num2str(i),'z');
    cam1 = [datPtsFR.(markx),datPtsFR.(marky)];
    cam2 = [datPtsBR.(markx),datPtsBR.(marky)];
    pos = triangulate(cam2,cam1,stereoR.(sterR));

    if i == 1
        Marker1x = pos(:,1);
        Marker1y = pos(:,2);
        Marker1z = pos(:,3);
        tabR = table(Marker1x,Marker1y,Marker1z);
    else
        pmarkx = pos(:,1);
        pmarky = pos(:,2);
        pmarkz = pos(:,3);
        tabR.(markx) = pmarkx;
        tabR.(marky) = pmarky;
        tabR.(markz) = pmarkz;
    end
end
targpathR = fullfile('D:\Semester 8\TA\Gabungan\Data\Triangulated');
targpathR = fullfile(targpathR,strcat(subject,'_R.csv'));
writetable(tabR,targpathR)
disp('side R done')

% LeftSide
sterL = strcat(Cal,'_FL_BL');
for i=1:7
    markx = strcat('Marker',num2str(i),'x');
    marky = strcat('Marker',num2str(i),'y');
    markz = strcat('Marker',num2str(i),'z');
    cam3 = [datPtsBL.(markx),datPtsBL.(marky)];
    cam4 = [datPtsFL.(markx),datPtsFL.(marky)];
    pos = triangulate(cam4,cam3,stereoL.(sterL));

    if i == 1
        Marker1x = pos(:,1);
        Marker1y = pos(:,2);
        Marker1z = pos(:,3);
        tabL = table(Marker1x,Marker1y,Marker1z);
    else
        pmarkx = pos(:,1);
        pmarky = pos(:,2);
        pmarkz = pos(:,3);
        tabL.(markx) = pmarkx;
        tabL.(marky) = pmarky;
        tabL.(markz) = pmarkz;
    end
end
targpathL = fullfile('D:\Semester 8\TA\Gabungan\Data\Triangulated');
targpathL = fullfile(targpathL,strcat(subject,'_L.csv'));
writetable(tabL,targpathL)
disp('side L done')
%% Refference triangulation
clear all
clc
   
root_check= 'D:\Semester 8\TA\Gabungan\Checkerboard';
Cal = 'S1';
gcs = 'S1';
    
fullsideR = strcat(Cal,'_BR_FR.mat');
fullsideL = strcat(Cal,'_FL_BL.mat');

stereoR = load(fullfile(root_check, Cal, fullsideR));
stereoL = load(fullfile(root_check, Cal, fullsideL));
sterR = strcat(Cal,'_BR_FR');
sterL = strcat(Cal,'_FL_BL');

root_gcs = 'D:\Semester 8\TA\Gabungan\GCS';

gcs_dat = readtable(fullfile(root_gcs, gcs,'pxl_pos_inverted.csv'));

cam1 = [gcs_dat.p1x,gcs_dat.p1y]; %Cam 1 = FR
cam2 = [gcs_dat.p2x,gcs_dat.p2y]; %Cam 2 = BR
cam3 = [gcs_dat.p3x,gcs_dat.p3y]; %Cam 3 = BL
cam4 = [gcs_dat.p4x,gcs_dat.p4y]; %Cam 4 = FL

posrefR = triangulate(cam2,cam1,stereoR.(sterR));
posrefL = triangulate(cam4,cam3,stereoL.(sterL)); 


pLx = posrefL(:,1);
pLy = posrefL(:,3);
pLz = posrefL(:,2);
pRx = posrefR(:,1);
pRy = posrefR(:,3);
pRz = posrefR(:,2);

tabref = table(pRx,pRy,pRz,pLx,pLy,pLz);

targpath = fullfile(root_gcs,gcs,"pxl_pos_t.csv");
writetable(tabref, targpath)
disp('tabref done')

figure(1)
scatter3(pRx,pRy,pRz)
hold on
set(gcf, 'Toolbar', 'figure')
plot3([pRx(1),pRx(2)],[pRy(1),pRy(2)],[pRz(1),pRz(2)])
plot3([pRx(1),pRx(3)],[pRy(1),pRy(3)],[pRz(1),pRz(3)])
plot3([pRx(1),pRx(4)],[pRy(1),pRy(4)],[pRz(1),pRz(4)])
xlabel( 'x' )
ylabel( 'y' )
zlabel( 'z' )
grid on
hold off
title(strcat(gcs,' Right Side'))
figure(2)
set(gcf, 'Toolbar', 'figure')
scatter3(pLx,pLy,pLz)
hold on
plot3([pLx(1),pLx(2)],[pLy(1),pLy(2)],[pLz(1),pLz(2)])
plot3([pLx(1),pLx(3)],[pLy(1),pLy(3)],[pLz(1),pLz(3)])
plot3([pLx(1),pLx(4)],[pLy(1),pLy(4)],[pLz(1),pLz(4)])
xlabel( 'x' )
ylabel( 'y' )
zlabel( 'z' )
grid on
hold off
title(strcat(gcs,' Left Side'))
%%  Transformation to GCS
clear all
clc
   
root_check= 'D:\Semester 8\TA\Gabungan\Checkerboard';
root_gcs = 'D:\Semester 8\TA\Gabungan\GCS';
root_dat = 'D:\Semester 8\TA\Gabungan';

Cal = 'S1';
gcs = 'S1';
subject = 'S1';

Xr = [400,0,0;0,400,0;0,0,400];

% root_gcs = 'D:\S2\OneDrive - Institut Teknologi Bandung\thesisproj\asset\GCS';

gcs_dat = readtable(fullfile(root_gcs, gcs,'pxl_pos_t.csv'));

gcs_R_cc = transpose([gcs_dat.pRx,gcs_dat.pRy,gcs_dat.pRz]);
Xc_R = [gcs_R_cc(:,2:4)];
T_R = [gcs_R_cc(:,1)];
R_R = Xr*inv(Xc_R-T_R);

mark_dat_R = readtable(fullfile(root_dat, 'Data', 'Triangulated',strcat(subject,'_R.csv')));

for i=1:7
    markx = strcat('Marker',num2str(i),'x');
    marky = strcat('Marker',num2str(i),'y');
    markz = strcat('Marker',num2str(i),'z');
    marker_R_cc = transpose([mark_dat_R.(markx),mark_dat_R.(marky),mark_dat_R.(markz)]);
    marker_R_rc = transpose(R_R*(marker_R_cc-T_R));

    if i == 1
        Marker1x = marker_R_rc(:,1);
        Marker1y = marker_R_rc(:,3);
        Marker1z = marker_R_rc(:,2);
        tabR = table(Marker1x,Marker1y,Marker1z);
    else
        pmarkx = marker_R_rc(:,1);
        pmarky = marker_R_rc(:,3);
        pmarkz = marker_R_rc(:,2);
        tabR.(markx) = pmarkx;
        tabR.(marky) = pmarky;
        tabR.(markz) = pmarkz;
    end
end
targpathR = fullfile('D:\Semester 8\TA\Gabungan\Data\T_Transform',strcat(subject,'_R_transform.csv'));
writetable(tabR,targpathR)
disp('R done')

gcs_L_cc = transpose([gcs_dat.pLx,gcs_dat.pLy,gcs_dat.pLz]);
Xc_L = [gcs_L_cc(:,2:4)];
T_L = [gcs_L_cc(:,1)];
R_L = Xr*inv(Xc_L-T_L);

mark_dat_L = readtable(fullfile(root_dat, 'Data', 'Triangulated',strcat(subject,'_L.csv')));

for i=1:7
    markx = strcat('Marker',num2str(i),'x');
    marky = strcat('Marker',num2str(i),'y');
    markz = strcat('Marker',num2str(i),'z');
    marker_L_cc = transpose([mark_dat_L.(markx),mark_dat_L.(marky),mark_dat_L.(markz)]);
    marker_L_rc = transpose(R_L*(marker_L_cc-T_L));

    if i == 1
        Marker1x = marker_L_rc(:,1);
        Marker1y = marker_L_rc(:,3);
        Marker1z = marker_L_rc(:,2);
        tabL = table(Marker1x,Marker1y,Marker1z);
    else
        pmarkx = marker_L_rc(:,1);
        pmarky = marker_L_rc(:,3);
        pmarkz = marker_L_rc(:,2);
        tabL.(markx) = pmarkx;
        tabL.(marky) = pmarky;
        tabL.(markz) = pmarkz;
    end
end
targpathL = fullfile('D:\Semester 8\TA\Gabungan\Data\T_Transform',strcat(subject,'_L_transform.csv'));
writetable(tabL,targpathL)
disp('L done')

%% joint center estimation
clear all
clc

% root_dat = 'C:\Users\daffa\Graduate School\OneDrive - Institut Teknologi Bandung\thesisproj\asset\Gait';
root_dat = 'D:\Semester 8\TA\Gabungan';
subject = 'S1';
mark_dat_R = readtable(fullfile(root_dat, 'Data', 'T_Transform',strcat(subject,'_R_transform.csv')));
mark_dat_L = readtable(fullfile(root_dat, 'Data', 'T_Transform',strcat(subject,'_L_transform.csv')));

p1 = [mark_dat_R.Marker1x, mark_dat_R.Marker1y, mark_dat_R.Marker1z];
p2 = [mark_dat_R.Marker2x, mark_dat_R.Marker2y, mark_dat_R.Marker2z]; 
p3 = [mark_dat_R.Marker3x, mark_dat_R.Marker3y, mark_dat_R.Marker3z];
p4 = [mark_dat_R.Marker4x, mark_dat_R.Marker4y, mark_dat_R.Marker4z];
p5 = [mark_dat_R.Marker5x, mark_dat_R.Marker5y, mark_dat_R.Marker5z];
p6 = [mark_dat_R.Marker6x, mark_dat_R.Marker6y, mark_dat_R.Marker6z];
p7 = [mark_dat_R.Marker7x, mark_dat_R.Marker7y, mark_dat_R.Marker7z];

p8 = [mark_dat_L.Marker1x, mark_dat_L.Marker1y, mark_dat_L.Marker1z];
p9 = [mark_dat_L.Marker2x, mark_dat_L.Marker2y, mark_dat_L.Marker2z];
p10 = [mark_dat_L.Marker3x, mark_dat_L.Marker3y, mark_dat_L.Marker3z];
p11 = [mark_dat_L.Marker4x, mark_dat_L.Marker4y, mark_dat_L.Marker4z];
p12 = [mark_dat_L.Marker5x, mark_dat_L.Marker5y, mark_dat_L.Marker5z];
p13 = [mark_dat_L.Marker6x, mark_dat_L.Marker6y, mark_dat_L.Marker6z];
p14 = [mark_dat_L.Marker7x, mark_dat_L.Marker7y, mark_dat_L.Marker7z];

% antrop
antrop = readtable(fullfile(root_dat,'antrop.csv'));
antrop.Subject = categorical(antrop.Subject);
id =(antrop.Subject == subject);
antrop_Subject = antrop(id,:);

A3 = antrop_Subject.Asis;%265;
A4 = antrop_Subject.ThighUR;%550;
A7 = antrop_Subject.KneeDR;%100;
A10 = antrop_Subject.MalWR;%100;
A11 = antrop_Subject.MalHR;%60;
A12 = antrop_Subject.FootBR;%60;
A13 = antrop_Subject.FootLR;%250;

for i=1:length(mark_dat_R.Marker1x)
%Right Side

    % marker axis for the right calf checked
    v2(i,:)=(p2(i,:)-p4(i,:))/norm(p2(i,:)-p4(i,:));
    u2(i,:)=cross((p3(i,:)-p4(i,:)),(p2(i,:)-p4(i,:)))/norm(cross((p3(i,:)-p4(i,:)),(p2(i,:)-p4(i,:))));
    w2(i,:)=cross(u2(i,:),v2(i,:));
                    
    % marker axis for the right thigh checked
    v3(i,:)=(p4(i,:)-p6(i,:))/norm(p4(i,:)-p6(i,:));
    u3(i,:)=cross((p5(i,:)-p6(i,:)),(p4(i,:)-p6(i,:)))/norm(cross((p5(i,:)-p6(i,:)),(p4(i,:)-p6(i,:))));
    w3(i,:)=cross(u3(i,:),v3(i,:));
                    
    %prh 123 is not xyz perhaps %must ask the developer
    prh(i,:)=p6(i,:)-0.1*A4*u3(i,:)-0.3*A4*v3(i,:)+0.9*A4*w3(i,:); %percobaan 6 %percobaan 11 %Percobaan 13
    pra(i,:)=p2(i,:)+0*A10*u2(i,:)+0*A10*v2(i,:)+0.5*A10*w2(i,:); % P pergelangan kaki kanan
    prk(i,:)=p4(i,:)+0*A7*u2(i,:)+0*A7*v2(i,:)+0.5*A7*w2(i,:); % P position Right Knee
                    
    % marker axis for the right foot
    u1(i,:)=(p1(i,:)-p2(i,:))/norm(p1(i,:)-p2(i,:)); %depan
    w1(i,:)=cross((p1(i,:)-p2(i,:)),(pra(i,:)-p2(i,:)))/norm(cross((p1(i,:)-p2(i,:)),(pra(i,:)-p2(i,:)))); %atas
    v1(i,:)=cross(w1(i,:),u1(i,:)); %masuk
                    
    prt(i,:)=p2(i,:)+0.5*A13*u1(i,:)+0.5*A11*v1(i,:)+0.2*A12*w1(i,:);
    prhl(i,:)=p2(i,:)-0.1*A13*u1(i,:)+0.3*A11*v1(i,:)-0.8*A12*w1(i,:); %P tumit
                    
    %centres of grafity
%     prtcg(i,:)=prh(i,:)+0.39*(prk(i,:)-prh(i,:));
%     prccg(i,:)=prk(i,:)+0.42*(pra(i,:)-prk(i,:));
%     prfcg(i,:)=prhl(i,:)+0.44*(prt(i,:)-prhl(i,:));
    
    %Left Side
    
    % marker axis for the Left calf
    v5(i,:)=(p9(i,:)-p11(i,:))/norm(p9(i,:)-p11(i,:));
    u5(i,:)=cross((p10(i,:)-p11(i,:)),(p9(i,:)-p11(i,:)))/norm(cross((p10(i,:)-p11(i,:)),(p9(i,:)-p11(i,:))));
    w5(i,:)=cross(u5(i,:),v5(i,:));
    
    
    % marker axis for the left thigh
    v6(i,:)=(p11(i,:)-p13(i,:))/norm(p11(i,:)-p13(i,:));
    u6(i,:)=cross((p12(i,:)-p13(i,:)),(p11(i,:)-p13(i,:)))/norm(cross((p12(i,:)-p13(i,:)),(p11(i,:)-p13(i,:))));
    w6(i,:)=cross(u6(i,:),v6(i,:));
    
    plh(i,:)=p13(i,:)-0.1*A4*u6(i,:)-0.3*A4*v6(i,:)+0.9*A4*w6(i,:); %percobaan 6 %percobaan 11 %percobaan 13 
    pla(i,:)=p9(i,:)+0*A10*u5(i,:)+0*A10*v5(i,:)+0.5*A10*w5(i,:); 
    plk(i,:)=p11(i,:)+0*A7*u5(i,:)+0*A7*v5(i,:)+0.5*A7*w5(i,:); 
       
    % marker axis for the Left foot   
    u4(i,:)=(p8(i,:)-p9(i,:))/norm(p8(i,:)-p9(i,:)); %depan
    w4(i,:)=cross((pla(i,:)-p9(i,:)),(p8(i,:)-p9(i,:)))/norm(cross((pla(i,:)-p9(i,:)),(p8(i,:)-p9(i,:)))); %atas
    v4(i,:)=cross(u4(i,:),w4(i,:));%masuk
    
    u7(i,:)=(p14(i,:)-p7(i,:))/norm(p14(i,:)-p7(i,:));
    v7(i,:)=cross((p14(i,:)-p7(i,:)),(prh(i,:)-p7(i,:)))/norm(cross((p14(i,:)-p7(i,:)),(prh(i,:)-p7(i,:))));
    w7(i,:)=cross(u7(i,:),v7(i,:));
    
    plt(i,:)=p9(i,:)+0.5*A13*u4(i,:)+0.5*A11*v4(i,:)+0.2*A12*w4(i,:);
    plhl(i,:)=p9(i,:)-0.1*A13*u4(i,:)+0.3*A11*v4(i,:)-0.8*A12*w4(i,:);
    pl(i,:)=p7(i,:)+0.45*A3*u7(i,:)+0.3*A3*v7(i,:)-0.3*A3*w7(i,:);
%   right thigh
    i1(i,:)=(prh(i,:)-prk(i,:))/norm(prh(i,:)-prk(i,:));
    j1(i,:)=cross((p5(i,:)-prh(i,:)),(prk(i,:)- prh(i,:)))/norm(cross((p5(i,:)-prh(i,:)),(prk(i,:)- prh(i,:))));
    k1(i,:)=cross(i1(i,:),j1(i,:));
    
%   left thigh
    i2(i,:)=(plh(i,:)-plk(i,:))/norm(plh(i,:)-plk(i,:));
    j2(i,:)=cross((plk(i,:)- plh(i,:)),(p12(i,:)-plh(i,:)))/norm(cross((plk(i,:)- plh(i,:)),(p12(i,:)-plh(i,:))));
    k2(i,:)=cross(i2(i,:),j2(i,:));
    
%   right calf
    i3(i,:)=(prk(i,:)-pra(i,:))/norm(prk(i,:)-pra(i,:));
    j3(i,:)=cross((p4(i,:)-prk(i,:)),(pra(i,:)- prk(i,:)))/norm(cross((p4(i,:)-prk(i,:)),(pra(i,:)- prk(i,:))));
    k3(i,:)=cross(i3(i,:),j3(i,:));
    
%   left calf
    i4(i,:)=(plk(i,:)-pla(i,:))/norm(plk(i,:)-pla(i,:));
    j4(i,:)=cross((pla(i,:)- plk(i,:)),(p11(i,:)-plk(i,:)))/norm(cross((pla(i,:)- plk(i,:)),(p11(i,:)-plk(i,:))));
    k4(i,:)=cross(i4(i,:),j4(i,:));
    
    %   right foot
    i5(i,:)=(prhl(i,:)-prt(i,:))/norm(prhl(i,:)-prt(i,:));
    k5(i,:)=cross((pra(i,:)-prhl(i,:)),(prt(i,:)- prhl(i,:)))/norm(cross((pra(i,:)-prhl(i,:)),(prt(i,:)- prhl(i,:))));
    j5(i,:)=cross(k5(i,:),i5(i,:));
    
    %   left foot
    i6(i,:)=(plhl(i,:)-plt(i,:))/norm(plhl(i,:)-plt(i,:));
    k6(i,:)=cross((pla(i,:)-plhl(i,:)),(plt(i,:)- plhl(i,:)))/norm(cross((pla(i,:)-plhl(i,:)),(plt(i,:)- plhl(i,:))));
    j6(i,:)=cross(k6(i,:),i6(i,:));
    
    %   pelvic
    k7(i,:)=(plh(i,:)-prh(i,:))/norm(plh(i,:)-prh(i,:));
    j7(i,:)=cross((prh(i,:)- pl(i,:)),(plh(i,:)-prh(i,:)))/norm(cross((prh(i,:)- pl(i,:)),(plh(i,:)-prh(i,:))));
    i7(i,:)=cross(j7(i,:),k7(i,:));
   
    %body
    i8(i,:)=[0,0,1];
    j8(i,:)=[1,0,0];
    k8(i,:)=[0,1,0];
    
    Irh(i,:)=cross(k7(i,:),i1(i,:))/norm(cross(k7(i,:),i1(i,:)));
    Irk(i,:)=cross(k1(i,:),i3(i,:))/norm(cross(k1(i,:),i3(i,:)));
    Ira(i,:)=cross(k3(i,:),i5(i,:))/norm(cross(k3(i,:),i5(i,:)));
    Ilh(i,:)=cross(k7(i,:),i2(i,:))/norm(cross(k7(i,:),i2(i,:)));
    Ilk(i,:)=cross(k2(i,:),i4(i,:))/norm(cross(k2(i,:),i4(i,:)));
    Ila(i,:)=cross(k4(i,:),i6(i,:))/norm(cross(k4(i,:),i6(i,:)));
    
    Ip(i,:)=cross(j7(i,:),i8(i,:))/norm(cross(j7(i,:),i8(i,:)));
    
%anatomical joint angles
    %right
    al_rh(i,:)=(asin(dot(Irh(i,:),i7(i,:))))*180/pi;
    be_rh(i,:)=asin(dot(k7(i,:),i1(i,:)))*180/pi;
    ga_rh(i,:)=(-asin(dot(Irh(i,:),k1(i,:))))*180/pi;
    al_rk(i,:)=-asin(dot(Irk(i,:),i1(i,:)))*180/pi;
    be_rk(i,:)=(-asin(dot(k1(i,:),i3(i,:))))*180/pi;
    ga_rk(i,:)=(-asin(dot(Irk(i,:),k3(i,:))))*180/pi;
    al_ra(i,:)=(-asin(dot(Ira(i,:),j3(i,:))))*180/pi;
    be_ra(i,:)=asin(dot(k3(i,:),i5(i,:)))*180/pi;
    ga_ra(i,:)=(asin(dot(Ira(i,:),k5(i,:))))*180/pi;
    %left
    al_lh(i,:)=(asin(dot(Ilh(i,:),i7(i,:))))*180/pi;
    be_lh(i,:)=-asin(dot(k7(i,:),i2(i,:)))*180/pi;
    ga_lh(i,:)=(asin(dot(Ilh(i,:),k2(i,:))))*180/pi;
    al_lk(i,:)=-asin(dot(Ilk(i,:),i2(i,:)))*180/pi;
    be_lk(i,:)=(-asin(dot(k2(i,:),i4(i,:))))*180/pi;
    ga_lk(i,:)=(asin(dot(Ilk(i,:),k4(i,:))))*180/pi;
    al_la(i,:)=(-asin(dot(Ila(i,:),j4(i,:))))*180/pi;
    be_la(i,:)=-asin(dot(k4(i,:),i6(i,:)))*180/pi;
    ga_la(i,:)=(asin(dot(Ila(i,:),k6(i,:))))*180/pi;
    %pelvis
    al_p(i,:)=(asin(dot(Ip(i,:),j7(i,:))))*180/pi;
    be_p(i,:)=-asin(dot(k7(i,:),i8(i,:)))*180/pi;
    ga_p(i,:)=(asin(dot(Ip(i,:),i7(i,:))))*180/pi;


    %centres of grafity
%     pltcg(i,:)=plh(i,:)+0.39*(plk(i,:)-plh(i,:));
%     plccg(i,:)=plk(i,:)+0.42*(pla(i,:)-plk(i,:));
%     plfcg(i,:)=plhl(i,:)+0.44*(plt(i,:)-plhl(i,:));
%     ppcg(i,:)=1/3*(pl(i,:)+prh(i,:)+plh(i,:));
%     phatcg(i,:)= pl(i,:)+ 1/2*thm(i,:);
end

KneeAngles = cat(2,al_rk,al_lk);

Kneedata = array2table(KneeAngles,'VariableNames',{'a_kneeR','a_kneeL'});
writetable(Kneedata,fullfile(root_dat,'Data','Desired',strcat(subject,'_kneedata.csv')));

jointAngles = cat(2,al_rh,be_rh,ga_rh,al_rk,be_rk,ga_rk,...
al_ra,be_ra,ga_ra,al_lh,be_lh,ga_lh,al_lk,...
be_lk,ga_lk,al_la,be_la, ga_la);

angledata = array2table(jointAngles,'VariableNames',{'a_hipR','b_hipR',...
        'g_hipR','a_kneeR','b_kneeR','g_kneeR','a_ankleR','b_ankleR','g_ankleR',...
        'a_hipL','b_hipL','g_hipL','a_kneeL','b_kneeL','g_kneeL',...
        'a_ankleL','b_ankleL','g_ankleL'});
writetable(angledata,fullfile(root_dat, 'Data', '3d recon',strcat(subject,'_angledata.csv')));
%%
figure(3)
set(gcf, 'Toolbar', 'figure')
plot(1:length(al_rk),al_rk)
grid on
hold off
title(strcat(gcs,' Right Side'))

figure(4)
set(gcf, 'Toolbar', 'figure')
plot(1:length(al_lk),al_lk)
grid on
hold off
title(strcat(gcs,' Left Side'))
% %%
% clear all
% clc
% 
% dat_root = 'C:\Users\daffa\Graduate School\OneDrive - Institut Teknologi Bandung\thesisproj\asset\Gait\dummy\Data\Processed_sal\Filled';
% data = readtable(fullfile(dat_root,"S3a_BR_filled.csv"));
% 
% [imf,residual,info] = vmd(data.Marker1y);
% disp(info)