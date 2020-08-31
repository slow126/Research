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



%%%%%%%%%%%%%
% Real Data %
%%%%%%%%%%%%%

 addpath('/Users/spencerlow/Documents/src/test_Folder/')
directory = '/Users/spencerlow/Documents/src/test_Folder/*.nc';
radiometer_freq = '37';
hemi = 'T';
satellite = 4;
image_only = 1;

load('spatialT_test.mat');

if(hemi == 'S' || hemi == 'N')
    reduction_factor = 4;%2;
    divisor = 1;
else
    reduction_factor = 4;
    divisor = 2;
end

% Load in the data sets as defined by the above header.
[ rad_h,rad_v,sigma_h,sigma_v ] = temporalCorr_setMaker( directory,radiometer_freq,hemi,satellite,image_only );

% Fill empty value with NaN's 
rad_h(rad_h <= 10) = NaN;
rad_v(rad_v <= 10) = NaN;
sigma_h(sigma_h <=-33) = NaN;
sigma_v(sigma_v <=-33) = NaN;

% Average each data set
rad_h = mean(rad_h,3,'omitnan');
rad_v = mean(rad_v,3,'omitnan');
sigma_h = (mean(sigma_h,3,'omitnan')); %db2mag
sigma_v = (mean(sigma_v,3,'omitnan'));

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
%         realTB_C(j).data = SMAPReader(files(j).name,false,0);
%     end
%     cd ..
% end







