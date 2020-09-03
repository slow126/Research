% Create Titles for each figure. Used later to save the figures.
titles = ["TB","NDVI","Sigma","TB_M","TB_C","TB_M Truth","B_C",...
"Filtered TB_M","Mouth of Amazon TB_M","Mouth of Amazon TB_M Filtered",...
"Mouth of Amazon TB_M Truth","Mouth of Amazon TB_C","Image Difference"];

%Add path to the data sets
% addpath('/home/spencer/Documents/MATLAB/test_folder')
% directory='/home/spencer/Documents/MATLAB/test_folder/*.nc';
% addpath('/home/low/NSID/PCA');
% directory='/home/low/NSID/PCA/*.nc';

addpath('/Users/spencerlow/Documents/src/test_Folder');
directory = '/Users/spencerlow/Documents/src/test_Folder/*.nc';


% Used to grab the desired brightness temperature data
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

% Fill the empty values with NaN
prerad_h(prerad_h <= 10) = NaN;
prerad_v(prerad_v <= 10) = NaN;
sigma_h(sigma_h <=-33) = NaN;
sigma_v(sigma_v <=-33) = NaN;

% Occasionally data is unpacked incorrectly and requires this scaling
% factor

prerad_h = prerad_h;
prerad_v = prerad_v;

% Create an average for both brightness temperature and backscatter
tb = (nanmean(cat(3,prerad_h,prerad_v),3));
sigma = (nanmean(cat(3,sigma_h,sigma_v),3));

% Clear data to open up RAM
clear prerad_h;
clear prerad_v;

% Load in the NDVI
% [ndvi, head, desrip, iaopt] = loadsir('/home/spencer/Documents/MATLAB/NDVI/AVHRR-Land_v004_AVH13C1_NOAA-14_19990227_c20140212105427.nc.E2T.sir');
% [ndvi, head, desrip, iaopt] = loadsir('/home/low/NSID/NDVI/AVHRR-Land_v004_AVH13C1_NOAA-14_19990227_c20140212105427.nc.E2T.sir');
[ndvi, head, desrip, iaopt] = loadsir('/Users/spencerlow/Documents/MATLAB/NDVI/AVHRR-Land_v004_AVH13C1_NOAA-14_19990227_c20140212105427.nc.E2T.sir');

% Make images of what we have so far
make_image(tb',1)
title(titles(1))
caxis([160,300]);

make_image(ndvi,2);
title(titles(2));

make_image(sigma',3);
title(titles(3));


% Begin changing size of data. Create a course image by reducing 2x more
% than the medium image. 

% tb_small = reduce_size_byN(tb, 4);
ndvi = ndvi';
% sigma_small = reduce_size_byN(sigma,8);
ndvi_small = reduce_size_byN(ndvi,2);

rad_C = reduce_size_byN(tb,12);
sigma_C = reduce_size_byN(sigma,24);
sigma_M = reduce_size_byN(sigma,12);
sigma_F = reduce_size_byN(sigma,2);
rad_M_truth = reduce_size_byN(tb,6);

% Clear to free up RAM
clear sigma_h;
clear sigma_v;

% rad_C = normData2(rad_C);
% sigma_C = normData2(sigma_C);
% sigma_M = normData2(sigma_M);
% sigma_F = normData2(sigma_F);
% rad_M_truth = normData2(rad_M_truth);

% Calcualte a two-dimenstional spatial conditional expectation
% B_C = spatial_condExp(rad_C,sigma_C,reduce_size_byN(ndvi_small,3));
B_C = rad_C ./ sigma_C;
% Multiply sigma by B_C to ensure that result looks similiar to a
% brightness temperature image
sigma2tb = B_C .* sigma_C;

% Begin the disaggregation formula
sig_c = B_C .* sigma_C;
sig_c = increase_size_byN(sig_c,2);
sig_m = increase_size_byN(B_C,2) .* sigma_M;

% Create a filter sigma term
sigma_add_filt =  medfilt2(sig_c,[6,6]) - medfilt2(sig_m,[6,6]);
% sigma_add_filt = imdiffusefilt(sig_m) - imdiffusefilt(sig_c);
% sigma_add_filt =  -1 .* medfilt2(sig_m,[6,6]) + medfilt2(sig_c,[6,6]);
% Create an unfiltered sigma term
sigma_add = sig_c - sig_m;

rad_M_prefilt = increase_size_byN(rad_C,2)  +  (sigma_add_filt);
% rad_M = increase_size_byN(rad_C,2) + sigma_add;
rad_M = rad_M_prefilt;

figure(4)
imagesc(rad_M')
colorbar;
caxis([160,300])
title(titles(4));
caxis([160,300]);
axis off;

figure(5)
imagesc(rad_C')
colorbar;
title(titles(5));
caxis([160,300]);
axis off;

figure(6)
imagesc(rad_M_truth')
colorbar;
title(titles(6));
caxis([160,300]);
% caxis([0,1]);
axis off;

figure(7)
imagesc(B_C')
colorbar;
caxis([-50,0])
title(titles(7))
axis off;

% Filter one more time
filt = medfilt2(rad_M,[3,3]);
% filt = imdiffusefilt(rad_M);
make_image(filt',8);
title(titles(8));
caxis([160,300]);
% caxis([0,1])


mouth = rad_M(643:691,345:393);
% mouth = (mouth - min(min(mouth)))/(max(max(mouth))-min(min(mouth)));
make_image(mouth',9);
caxis([160,300]);
title(titles(9));
% figure(11)
% imhist(mouth);
% saveas(figure(10),);
 
mouth_filt = filt(643:691,345:393);
% mouth = (mouth - min(min(mouth)))/(max(max(mouth))-min(min(mouth)));
make_image(mouth_filt',10);
caxis([160,300]);
% caxis([0,1]);
title(titles(10));

% figure(13)
% imhist(mouth);

mouth_truth = rad_M_truth(643:691,345:393);
% mouth = (mouth - min(min(mouth)))/(max(max(mouth))-min(min(mouth)));
make_image(mouth_truth',11);
caxis([160,300]);
% caxis([0,1]);
title(titles(11));
% figure(15)
% imhist(mouth);

mouth = rad_C(320:345,172:196);
make_image(mouth',12);
caxis([160,300]);
title(titles(12));

mouth_diff = (mouth_filt - mouth_truth)./mouth_truth;
make_image(mouth_diff',13);
title(titles(13));

% filt_norm = (filt - min(min(filt)))./(max(max(filt)) - min(min(filt)));
% filt_sharp = imsharpen(filt_norm);
% make_image(filt_sharp',14);
% filt_sharp_unnorm = filt_sharp .* (max(max(filt)) - min(min(filt))) + min(min(filt));
% make_image(filt_sharp_unnorm',15);
% caxis([160,300]);

% mouth_sharp = filt_sharp_unnorm(643:691,345:393);
% make_image(mouth_sharp',16);
% caxis([160,300]);

old_std = nanstd(nanstd(rad_C));
old_mean = nanmean(nanmean(rad_C));

disag_std = nanstd(nanstd(filt));
true_std = nanstd(nanstd(rad_M_truth));
disag_mean = nanmean(nanmean(filt));
true_mean = nanmean(nanmean(rad_M_truth));

corr_of_all = my_normxcorr2(rad_M_truth,filt);
corr_img = spatialCorr_basic(rad_M_truth, filt);
make_image(corr_img',17);

corr_old_all = my_normxcorr2(increase_size_byN(rad_C,2),rad_M_truth);
corr_old_img = spatialCorr_basic(rad_M_truth,increase_size_byN(rad_C,2));
make_image(corr_old_img',18);

diff1 = rad_M_truth - filt;
diff2 = rad_M_truth - increase_size_byN(rad_C,2);

std_filt = nanstd(nanstd(diff1))
std_orig = nanstd(nanstd(diff2))


% for i = 1:length(titles)
% % 	saveas(figure(i),strcat('/home/spencer/Documents/images/',titles(i),'.png'));
% %     saveas(figure(i),strcat('/home/low/NSID/NDVI/',titles(i),'.png'));
%     saveas(figure(i),strcat(titles(i),'.png'));
% end




