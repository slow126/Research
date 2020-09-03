function [rad_h,rad_v, scat] = multi_pol(directory,image_only)
% A script to read in multiple .nc files from multiple directories that are
% passed in as a vector of directories. It will return a struct of
% radiometers and scatterometer .nc files.
% funtion [rad, scat] = multi_universal(directory,image_only)
    char_directory = char(directory);
    directory = dir(char_directory);
    
    j = 1; 
    k = 1;
    l = 1;
    
    for i = 1 : size(directory,1)
        if strfind(directory(i).name,'NSIDC')
            if contains(directory(i).name,'85H')
                rad_h(j) = universal_nsid(directory(i).name,'rad',image_only);
                rad_h(j).TB = double(rad_h(j).TB);
                j = j + 1;
            elseif contains(directory(i).name,'85V')
                rad_v(l) = universal_nsid(directory(i).name,'rad',image_only);
                rad_v(l).TB = double(rad_v(l).TB);
                l = l + 1;
            end
        elseif strfind(directory(i).name,'sir')
            scat(k) = universal_nsid(directory(i).name,'scat',image_only);
            scat(k).sig = double(scat(k).sig);
            k = k + 1;
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