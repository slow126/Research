function [corr] = spatial_cond_corr2(tb,sigma,ndvi,cond_ndvi_value)
%spatial_cond_corr2 calculates the spatial correlation by sliding a window
%over the tb and sigma images and using a mask of the ndvi as a conditional
%NDVI value. 

mask = ndvi > cond_ndvi_value;
sigma = sigma .* mask;

make_image(mask',2);
corr = spatialCorr_basic(tb,sigma);


end

