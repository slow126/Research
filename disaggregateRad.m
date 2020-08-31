% Uses the SMAP algorithm to create higher resolution radiometer images. 

% TODO: Create all the readers and get all the data.
% TB_M: Medium resolution. It is the enhanced resolution of TB
% TB_C: Course resolution. It is the raw DIB resolution of TB
% B_C: The slope or E(TB|sigma) of TB = alpha + B_C * sigma
% sigma_M: The medium resolution of backscatter.
% sigma_C: The course resolution of backscatter.
% gamma: der(sigma)/der(cross_sigma)
% cross_sigma: Cross polarization of sigma




%%%%%%%%%%%%%%
% Simulation %
%%%%%%%%%%%%%%

days = 10;
temp = ones([36,36]);

sigma_F = zeros([36,36,days]);
TB_C = zeros([1,1,days]);
cross_sigma_F = sigma_F;
for i = 1:days
    sigma_F(:,:,i) = temp .* 2 * i + rand(36);  
    TB_C(:,:,i) = i;
    cross_sigma_F(:,:,i) = temp .* 3 * i + rand(36);
end

z = size(sigma_F,3);

sigma_M = zeros(9,9,size(sigma_F,3));
sigma_C = zeros(1,1,size(sigma_F,3));
cross_sigma_M = sigma_M;
cross_sigma_C = sigma_C;
TB_M = zeros([9,9,days-1]);


for i = 1:size(sigma_F,3)
    sigma_M(:,:,i) = reduce_size_byN(sigma_F(:,:,i),4);
    sigma_C(:,:,i) = reduce_size_byN(sigma_F(:,:,i),36);
    cross_sigma_M(:,:,i) = reduce_size_byN(cross_sigma_F(:,:,i),4);
    cross_sigma_C(:,:,i) = reduce_size_byN(cross_sigma_F(:,:,i),36);
end



my_Beta_vars = polyfit(reshape(TB_C,1,z),reshape(sigma_C,1,z),1);
B_C = my_Beta_vars(1,1);

gamma = diff(sigma_M,1,3) ./ diff(cross_sigma_M,1,3);

for i = 1:days-1
    TB_M(:,:,i) = TB_C(:,:,i) + B_C .* ((sigma_M(:,:,i) - sigma_C(:,:,i)) + gamma(:,:,i) .* (cross_sigma_C(:,:,i) - cross_sigma_M(:,:,i)));
end

% clear all;

%%%%%%%%%%%%%
% Real Data %
%%%%%%%%%%%%%
% startIndex = 3;
% 
% addpath(genpath('/home/low/NSID/SMAP/'));
% cd /home/low/NSID/SMAP/n5eil01u.ecs.nsidc.org/SMAP;
% sats = dir;
% cd(sats(5).name);
% days = dir;
% 
% for i = startIndex:size(days,1)
%     cd(days(i).name);
%     files = dir('*.h5');
%     for j = 1:size(files,1)
%         realTB_C(j) = SMAPReader(files(j).name,false,0);
%     end
%     cd ..
% end

z = 4;
 addpath('/Users/spencerlow/Documents/src/test_Folder/')
directory = '/Users/spencerlow/Documents/src/test_Folder/*.nc';

radiometer_freq = '37';
hemi = 'T';
satellite = 4;
image_only = 1;



if(hemi == 'S' || hemi == 'N')
    reduction_factor = 2;
    divisor = 1;
else
    reduction_factor = 4;
    divisor = 2;
end

% Load in the data sets as defined by the above header.
[ prerad_h,prerad_v,sigma_h,sigma_v ] = temporalCorr_setMaker( directory,radiometer_freq,hemi,satellite,image_only );

prerad_h(prerad_h <= 10) = NaN;
prerad_v(prerad_v <= 10) = NaN;
sigma_h(sigma_h <=-33) = NaN;
sigma_v(sigma_v <=-33) = NaN;

rad_h = zeros(size(prerad_h,1),size(prerad_h,2),size(prerad_h,3)/2);
rad_v = zeros(size(prerad_v,1),size(prerad_v,2),size(prerad_v,3)/2);
h = 0;
for i = 1:2:size(rad_h,3)
   j = i - h;
   h = h+1;
   
   rad_h(:,:,j) = nanmean(cat(3,prerad_h(:,:,i),prerad_h(:,:,i+1)),3);
   rad_v(:,:,j) = nanmean(cat(3,prerad_v(:,:,i),prerad_v(:,:,i+1)),3);
end

clear prerad_h;
clear prerad_v;

% Average each data set
% rad_h = mean(rad_h,3,'omitnan');
% rad_v = mean(rad_v,3,'omitnan');
% sigma_h = (mean(sigma_h,3,'omitnan')); %db2mag
% sigma_v = (mean(sigma_v,3,'omitnan'));
% 
%  sigma_h = db2mag(sigma_h);
%  sigma_v = db2mag(sigma_v);
for i = 1:z
    rad_hC(:,:,i) = reduce_size_byN(rad_h(:,:,i),12);
    sigma_hC(:,:,i) = reduce_size_byN(sigma_h(:,:,i),24);
    sigma_vC(:,:,i) = reduce_size_byN(sigma_v(:,:,i),24);
    sigma_hM(:,:,i) = reduce_size_byN(sigma_h(:,:,i),6);
    sigma_vM(:,:,i) = reduce_size_byN(sigma_v(:,:,i),6);
    sigma_hF(:,:,i) = reduce_size_byN(sigma_h(:,:,i),2);
    sigma_vF(:,:,i) = reduce_size_byN(sigma_v(:,:,i),2);
end

%my_Beta_vars = polyfit(reshape(rad_hC,1,z),reshape(sigma_hC,1,z),1);

for i = 1 : size(rad_hC,1)
    for j = 1 : size(rad_hC,2)
        my_Beta_vars = polyfit(reshape(rad_hC(i,j,:),1,z),reshape(sigma_hC(i,j,:),1,z),1);
        B_C(i,j) = my_Beta_vars(1,1);
    end
end

gamma = diff(sigma_hM,1,3) ./ diff(sigma_vM,1,3);

for i = 1:z-1
    for j = 1:size(B_C,1) - 1 
        for h = 1:size(B_C,2) - 1
            rad_hM(j,h,i) = rad_hC(floor(j/2)+1,floor(h/2)+1,i) + B_C(floor(j/2)+1,floor(h/2)+1,i) .* ((sigma_hM(j,h,i) - sigma_hC(floor(j/2)+1,floor(h/2)+1,i)) + gamma(j,h,i) .* (sigma_vC(floor(j/2)+1,floor(h/2)+1,i) - sigma_vM(j,h,i)));
        end
    end
end



