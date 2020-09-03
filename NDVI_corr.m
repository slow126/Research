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

tb_avg = nanmean(cat(3,prerad_h,prerad_v),3);
sigma_avg = nanmean(cat(3,sigma_h,sigma_v),3);

AVHRR_mapconv;

NDVI = ndvi.NDVI;


