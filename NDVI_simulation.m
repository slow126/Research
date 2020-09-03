% Build a backscatter array
% Do this by first reading in one set of scatterometer data to get the
% mean, and std deviation of the data. 

% Do this again for radiometer data.

x = [1:10;2:11;3:12;4:13;5:14;6:15;7:16;8:17;9:18;10:19];
y = 2 * x;

corr = spatialCorr_basic(x,y);

% addpath('/home/spencer/Documents/MATLAB/test_folder')
% directory='/home/spencer/Documents/MATLAB/test_folder/*.nc';

addpath('/Users/spencerlow/Documents/src/test_Folder/');
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

tb = nanmean(cat(3,prerad_h,prerad_v),3);
sigma = nanmean(cat(3,sigma_h,sigma_v),3);


%[ndvi, head, desrip, iaopt] = loadsir('/home/spencer/Documents/MATLAB/NDVI/AVHRR-Land_v004_AVH13C1_NOAA-14_19990227_c20140212105427.nc.E2T.sir');
[ndvi, head, desrip, iaopt] = loadsir('AVHRR-Land_v004_AVH13C1_NOAA-14_19990227_c20140212105427.nc.E2T.sir');



figure(1)
imagesc(tb')

figure(2)
imagesc(ndvi)

figure(3)
imagesc(sigma')

tb_small = reduce_size_byN(tb, 4);
ndvi = ndvi';
sigma_small = reduce_size_byN(sigma,8);
ndvi_small = reduce_size_byN(ndvi,2);
%ndvi_small = ndvi;

tb_norm = (tb - min(tb(:))) / (max(tb(:)) - min(tb(:)));
sigma_norm = (sigma - min(sigma(:))) / (max(sigma(:)) - min(sigma(:)));

corr = spatialCorr_basic(tb_small,ndvi_small);
corr2 = spatialCorr_basic(tb_small,sigma_small);
corr3 = spatialCorr_basic(sigma_small,ndvi_small);

make_image(corr,4);
make_image(corr2,5);
make_image(corr3,6);

ndvi_small_norm = norm_zero2one(ndvi_small);
tb_small_norm = norm_zero2one(tb_small);
sigma_small_norm = norm_zero2one(sigma_small);

make_image(ndvi_small_norm,7);
make_image(tb_small_norm,8);
make_image(sigma_small_norm,9);

corr4 = spatialCorr_basic(tb_small_norm, ndvi_small_norm);
corr5 = spatialCorr_basic(tb_small_norm,sigma_small_norm);
corr6 = spatialCorr_basic(sigma_small_norm,ndvi_small_norm);

make_image(corr4,10);
make_image(corr5,11);
make_image(corr6,12);

tb_small(tb_small < 200) = NaN;
sigma_small(sigma_small < -17) = NaN;

tb_amazon = tb_small(700:1200,400:800);
sigma_amazon = sigma_small(700:1200,400:800);
ndvi_amazon = ndvi_small(700:1200,400:800);

make_image(tb_amazon',13);
make_image(sigma_amazon',14);
make_image(ndvi_amazon',15);

cond_corr = spatial_cond_corr2(tb_amazon,sigma_amazon,ndvi_amazon, 0);
make_image(cond_corr',1);
