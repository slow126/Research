function [ rad_h,rad_v,sigma_h,sigma_v ] = temporalCorr_setMaker( directory,radiometer_freq,hemi,satellite,image_only )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% Satellite 1 = rad_h
% Satellite 2 = rad_v
% Satellite 3 = scat
% Satellite 4 = all
char_directory = char(directory);
directory = dir(char_directory);

l = 1;
m = 1;
n = 1;
p = 1;

for i = 1 : size(directory,1)
    if strfind(directory(i).name,'NSIDC')
        if(strfind(directory(i).name,strcat(hemi,'3.125')))
            if (strfind(directory(i).name,strcat(radiometer_freq,'H')) & (satellite == 1 | satellite == 4))
                
                radh_struct = universal_nsid(directory(i).name,'rad',image_only);
                rad_h(:,:,l) = double(radh_struct.TB);
                l = l + 1;
                %rad_h = double(radh_struct.TB);
                
                
            elseif (strfind(directory(i).name,strcat(radiometer_freq,'V')) & (satellite == 2 | satellite == 4))
                
                radv_struct = ((universal_nsid(directory(i).name,'rad',image_only)));
                rad_v(:,:,m) = double(radv_struct.TB);
                m = m + 1;
                %rad_v = double(radv_struct.TB);
                
            end
        end
    elseif strfind(directory(i).name,'sir')
        if strfind(directory(i).name,strcat('-a-E2',hemi))
            if (strfind(directory(i).name,'qush') & (satellite == 3 | satellite == 4))
                scat_struct = ((universal_nsid(directory(i).name,'scat',image_only)));
                sigma_h(:,:,n) = scat_struct.sig;
                n = n + 1;
                
                
            elseif (strfind(directory(i).name,'qusv') & (satellite == 3 | satellite == 4))
                scat_struct = ((universal_nsid(directory(i).name,'scat',image_only)));
                sigma_v(:,:,p) = scat_struct.sig;
                p = p + 1;
                
            end
        end
    end
    
    
    
end

if ~exist('rad_h','var')
    rad_h = [];
    
end
if ~exist('rad_v','var')
    rad_v = [];
    
end
if ~exist('sigma_h','var')
    sigma_h = [];
    
end
if ~exist('sigma_v','var')
    sigma_v = [];
    
end

end

