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
% rad_h = mean(rad_h,3,'omitnan');
% rad_v = mean(rad_v,3,'omitnan');
% sigma_h = (mean(sigma_h,3,'omitnan')); %db2mag
% sigma_v = (mean(sigma_v,3,'omitnan'));