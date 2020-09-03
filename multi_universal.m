function [rad, scat] = multi_universal(directory,image_only)
% A script to read in multiple .nc files from multiple directories that are
% passed in as a vector of directories. It will return a struct of
% radiometers and scatterometer .nc files.
% funtion [rad, scat] = multi_universal(directory,image_only)
    char_directory = char(directory);
    directory = dir(char_directory);
    
    j = 1; 
    k = 1;
    
    for i = 1 : size(directory,1)
        if strfind(directory(i).name,'NSIDC')
            rad(j) = universal_nsid(directory(i).name,'rad',image_only);
            rad(j).TB = double(rad(j).TB);
            j = j + 1;
        elseif strfind(directory(i).name,'sir')
            scat(k) = universal_nsid(directory(i).name,'scat',image_only);
            scat(k).sig = double(scat(k).sig);
            k = k + 1;
        end
    end
    
    if ~exist('rad','var')
        rad = [];
    end
    if ~exist('scat','var')
        scat = [];
    end

end