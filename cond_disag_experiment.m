% addpath('/home/spencer/Documents/MATLAB/test_folder')
% directory='/home/spencer/Documents/MATLAB/test_folder/*.nc';
% addpath('/home/low/NSID/PCA');
% directory='/home/low/NSID/PCA/*.nc';
addpath('/Users/spencerlow/Documents/src/test_Folder');
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

% prerad_h = prerad_h * .01;
% prerad_v = prerad_v * .01;

tb = (nanmean(cat(3,prerad_h,prerad_v),3));
sigma = (nanmean(cat(3,sigma_h,sigma_v),3));

clear prerad_h;
clear prerad_v;


% [ndvi, head, desrip, iaopt] = loadsir('/home/spencer/Documents/MATLAB/NDVI/AVHRR-Land_v004_AVH13C1_NOAA-14_19990227_c20140212105427.nc.E2T.sir');
% [ndvi, head, desrip, iaopt] = loadsir('/home/low/NSID/NDVI/AVHRR-Land_v004_AVH13C1_NOAA-14_19990227_c20140212105427.nc.E2T.sir');
[ndvi, head, desrip, iaopt] = loadsir('/Users/spencerlow/Documents/MATLAB/NDVI/AVHRR-Land_v004_AVH13C1_NOAA-14_19990227_c20140212105427.nc.E2T.sir');

figure(1)
imagesc(tb')

figure(2)
imagesc(ndvi)

figure(3)
imagesc(sigma')

% tb_small = reduce_size_byN(tb, 4);
ndvi = ndvi';
% sigma_small = reduce_size_byN(sigma,8);
ndvi_small = reduce_size_byN(ndvi,3);

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


% B_C = spatial_condExp(increase_size_byN(rad_C,2),sigma_M,ndvi_small);
% B_C = increase_size_byN(rad_C,2) ./ sigma_M;
B_C = rad_C ./ sigma_C;
% sigma2tb = B_C .* sigma_C;

% tb_experiment = increase_size_byN(B_C,2) .* sigma_M;

% clear B_C;

% B_C = spatial_condExp(rad_C,sigma_C,reduce_size_byN(ndvi_small,2));


% B_C(isinf(B_C)) = 0;
% gamma = diff(sigma_hM,1,3) ./ diff(sigma_vM,1,3);
% gamma = zeros(size(sigma_M,1),size(sigma_M,2));


% sigma_add = (increase_size_byN(B_C,2) .* sigma_M - increase_size_byN(B_C .* sigma_C,2));

sig_m = increase_size_byN(B_C,2) .* sigma_M;
sig_c = B_C .* (sigma_C);
sig_c = increase_size_byN(sig_c,2);

sigma_add_filt = medfilt2(sig_c,[3,3]) - medfilt2(sig_m,[3,3]);
sigma_add = sig_m - sig_c;

% filt_sigma_add = medianFilter(sigma_add,6,6);

rad_M_prefilt = increase_size_byN(rad_C,2)  +  (sigma_add_filt);
% rad_M = increase_size_byN(rad_C,2) + sigma_add;
rad_M = rad_M_prefilt;

% rad_M_prefilt = increase_size_byN(rad_C,2)  + filt_sigma_add;

figure(4)
imagesc(rad_M')
caxis([160,300])
title('rad_M')
caxis([160,300]);

figure(5)
imagesc(rad_C')
title('rad_C')
caxis([160,300]);

figure(6)
imagesc(rad_M_truth')
title('rad_M Truth')
caxis([160,300]);

figure(7)
imagesc(B_C')
caxis([-50,0])
title('B_C')

filt = medfilt2(rad_M,[3,3]);

make_image(filt',8);
title('Filtered rad_M')
caxis([160,300]);


mouth = rad_M(643:691,345:393);
% mouth = (mouth - min(min(mouth)))/(max(max(mouth))-min(min(mouth)));
make_image(mouth',10);
caxis([160,300]);
% figure(11)
% imhist(mouth);
% saveas(figure(10),);
 
mouth = filt(643:691,345:393);
% mouth = (mouth - min(min(mouth)))/(max(max(mouth))-min(min(mouth)));
make_image(mouth',12);
caxis([160,300]);
% figure(13)
% imhist(mouth);

mouth = rad_M_truth(643:691,345:393);
% mouth = (mouth - min(min(mouth)))/(max(max(mouth))-min(min(mouth)));
make_image(mouth',14);
caxis([160,300]);
% figure(15)
% imhist(mouth);

mouth = rad_C(320:345,172:196);
make_image(mouth',16);
caxis([160,300]);

% new_std = nanstd(nanstd(rad_M));
% true_std = nanstd(nanstd(rad_M_truth));
% true_mean = nanmean(nanmean(rad_M_truth));
% new_mean = nanmean(nanmean(filt));
% 
% corr_img = my_spatialnormXcorr2(rad_M_truth, filt);
% 
% make_image(corr_img',15);
% 
% correlation = my_normxcorr2(rad_M_truth, filt);
% 
% make_image(rad_M_truth',20);
% caxis([160,300]);
% make_image(tb_experiment',21);
% caxis([160,300]);
% make_image(rad_C',22);
% caxis([160,300]);
% for i = 1:8
% 	saveas(figure(i),strcat('/home/spencer/Documents/images/fig',num2str(i),'.png'));
% end


% make_image(rad_M_prefilt',9);
% 
% make_image(filt_sigma_add',10);
% 
% make_image(sigma_add',11);
