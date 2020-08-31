directory = '/Users/spencerlow/Documents/src/time_series/*.nc';

%sorted_directory = sort_ncDirectory(directory);
hemi = 'T';
radiometer_freq = '85';
image_only = 1;

[ rad_h,rad_v,sigma ] = temporal_universal(directory,hemi,radiometer_freq,image_only);


