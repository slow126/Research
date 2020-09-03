function [rad_h,rad_v, scat] = multi_Tpol(directory,radiometer_freq,image_only)
% A script to read in multiple .nc files from multiple directories that are
% passed in as a vector of directories. It will return a struct of
% radiometers and scatterometer .nc files.
% funtion [rad, scat] = multi_universal(directory,image_only)
char_directory = char(directory);
directory = dir(char_directory);

for i = 1 : size(directory,1)
    if strfind(directory(i).name,'NSIDC')
        if strfind(directory(i).name,strcat(radiometer_freq,'H'))
            if ~exist('count_radh','var')
                radh_struct = universal_nsid(directory(i).name,'rad',image_only);
                rad_h = double(radh_struct.TB);
                count_radh = (rad_h > 0);
                
            else
                radh_struct = universal_nsid(directory(i).name,'rad',image_only);
                count_radh = count_radh + (radh_struct.TB > 0);
                rad_h = double(radh_struct.TB) + rad_h;
            end
            
            
        elseif strfind(directory(i).name,strcat(radiometer_freq,'V'))
            if ~exist('count_radV','var')
                radv_struct = ((universal_nsid(directory(i).name,'rad',image_only)));
                rad_v = double(radv_struct.TB);
                count_radV = (radv_struct.TB > 0);
                
            else
                radv_struct = (universal_nsid(directory(i).name,'rad',image_only));
                count_radV = count_radV + (radv_struct.TB > 0);
                rad_v = (double(radv_struct.TB) + rad_v);
                
            end
        end
    elseif strfind(directory(i).name,'sir')
        if ~exist('count_scat','var')
            scat = ((universal_nsid(directory(i).name,'scat',image_only)));
            count_scat = (scat.sig > -33);
            scat = double(scat.sig);
            
        else
            new = (universal_nsid(directory(i).name,'scat',image_only));
            count_scat = count_scat + (new.sig > 0);
            scat = (double(new.sig) + scat);
        end
    end
end

if ~exist('rad_h','var')
    rad_h = [];
else
    rad_h = rad_h ./ count_radh;
end
if ~exist('rad_v','var')
    rad_v = [];
else
    rad_v = rad_v ./ count_radV;
end
if ~exist('scat','var')
    scat = [];
else
    scat = scat ./ count_scat;
end

end