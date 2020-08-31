function [ rad_h,rad_v,scat ] = temporal_universal(directory,hemi,radiometer_freq,image_only)
% [ epsilon,sigma ] =
% temporal_universal(directory,radiometer_freq,image_only)
% arguments:
% directory - directory of the .nc files, in the form 'directory/*.nc'
% radiometer_freq - a string that is the radiometer frequency ex. '85'
% image_only - flag that reads only the image array. 1: image only 0: full
%   read
% Function reads in Horizontal and Vertical polarized radiometer images and
% calculates epsilon (Tb_h - Tb_v) / (Tb_h + Tb_v) and returns it in 3d
% array where the Z-axis is the day. Also reads in the sigma value and
% returns it in a similiar manner to the epsilon value.
day_h = 1;
day_v = 1;
day_scat = 1;
prev_day = 0;
k = 1;
char_directory = char(directory);
directory = dir(char_directory);
for i = length(directory):-1:1
   if contains(directory(i).name,'NSIDC')
       if contains(directory(i).name,strcat(radiometer_freq,'H'))
           rad_h_temp = universal_nsid(directory(i).name,'rad',image_only);
           rad_h(:,:,day_h) = rad_h_temp.TB;
           day_h = day_h + 1;
       elseif contains(directory(i).name,strcat(radiometer_freq,'V'))
           rad_v_temp = universal_nsid(directory(i).name,'rad',image_only);
           rad_v(:,:,day_v) = rad_v_temp.TB;
           day_v = day_v + 1;
       end
%        if day_h == day_v && day_h > 0 && day_h > prev_day
%            epsilon(k) = (rad_h - rad_v) / (rad_h + rad_v);
%            prev_day = day_h;
%        end
   elseif contains(directory(i).name,'sir')
       scat_temp = universal_nsid(directory(i).name,'scat',image_only);
       scat(:,:,day_scat) = reduce_size_byN(scat_temp.sig,2);
       day_scat = day_scat + 1;
   end
end

if ~exist('rad_h','var')
    rad_h = [];
end
if ~exist('rad_v','var')
    rad_v = [];
end
if ~exist('scat','var')
    scat = [];
end

end

