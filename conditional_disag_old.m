% Build a backscatter array
% Do this by first reading in one set of scatterometer data to get the
% mean, and std deviation of the data. 

% Do this again for radiometer data.

for i = 1 : 100
    x(i,:) = [i:100+i-1];
end
y = 2 * x;

corr = spatialCorr_basic(x,y);

addpath('/home/spencer/Documents/MATLAB/test_folder')
directory='/home/spencer/Documents/MATLAB/test_folder/*.nc';

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

tb = (nanmean(cat(3,prerad_h,prerad_v),3));
sigma = (nanmean(cat(3,sigma_h,sigma_v),3));

clear prerad_h;
clear prerad_v;


[ndvi, head, desrip, iaopt] = loadsir('/home/spencer/Documents/MATLAB/NDVI/AVHRR-Land_v004_AVH13C1_NOAA-14_19990227_c20140212105427.nc.E2T.sir');


figure(1)
imagesc(tb')

figure(2)
imagesc(ndvi)

figure(3)
imagesc(sigma')

% tb_small = reduce_size_byN(tb, 4);
ndvi = ndvi';
% sigma_small = reduce_size_byN(sigma,8);
ndvi_small = reduce_size_byN(ndvi,2);

% Average each data set
% rad_h = mean(rad_h,3,'omitnan');
% rad_v = mean(rad_v,3,'omitnan');
% sigma_h = (mean(sigma_h,3,'omitnan')); %db2mag
% sigma_v = (mean(sigma_v,3,'omitnan'));
% 
%  sigma_h = db2mag(sigma_h);
%  sigma_v = db2mag(sigma_v);
% for i = 1:size(tb,3)
%     rad_hC(:,:,i) = reduce_size_byN(tb,12);
%     sigma_hC(:,:,i) = reduce_size_byN(sigma_h(:,:,i),24);
%     sigma_vC(:,:,i) = reduce_size_byN(sigma_v(:,:,i),24);
%     sigma_hM(:,:,i) = reduce_size_byN(sigma_h(:,:,i),12);
%     sigma_vM(:,:,i) = reduce_size_byN(sigma_v(:,:,i),12);
%     sigma_hF(:,:,i) = reduce_size_byN(sigma_h(:,:,i),2);
%     sigma_vF(:,:,i) = reduce_size_byN(sigma_v(:,:,i),2);
%     rad_hM_Truth(:,:,i) = reduce_size_byN(tb,6);
%     
% end

%sigma = medfilt2(sigma,[6,6]);

rad_C = reduce_size_byN(tb,12);
sigma_C = reduce_size_byN(sigma,24);
sigma_M = reduce_size_byN(sigma,12);
sigma_F = reduce_size_byN(sigma,2);
rad_M_truth = reduce_size_byN(tb,6);

clear sigma_h;
clear sigma_v;

%my_Beta_vars = polyfit(reshape(rad_hC,1,z),reshape(sigma_hC,1,z),1);


B_C = spatial_condExp(rad_C,sigma_C,reduce_size_byN(ndvi_small,2));
sigma2tb = B_C .* sigma_C;


% B_C(isinf(B_C)) = 0;
% gamma = diff(sigma_hM,1,3) ./ diff(sigma_vM,1,3);
% gamma = zeros(size(sigma_M,1),size(sigma_M,2));


sigma_add = (increase_size_byN(B_C,2) .* sigma_M - increase_size_byN(B_C .* sigma_C,2));

% filt_sigma_add = medianFilter(sigma_add,6,6);

rad_M = increase_size_byN(rad_C,2)  +  (sigma_add);
% rad_M_prefilt = increase_size_byN(rad_C,2)  + filt_sigma_add;

figure(4)
imagesc(rad_M')
caxis([160,300])
title('rad_M')

figure(5)
imagesc(rad_C')
title('rad_C')

figure(6)
imagesc(rad_M_truth')
title('rad_M Truth')

figure(7)
imagesc(B_C')
caxis([-50,0])
title('B_C')

filt = medfilt2(rad_M,[6,6]);

make_image(filt',8);
title('Filtered rad_M')

for i = 1:8
	saveas(figure(i),strcat('/home/spencer/Documents/images/fig',num2str(i),'.png'));
end


% make_image(rad_M_prefilt',9);
% 
% make_image(filt_sigma_add',10);
% 
% make_image(sigma_add',11);
