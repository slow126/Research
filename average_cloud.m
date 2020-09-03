%function data = average(directory, sat, hemisphere, resolution, band, polar, direct)
%Works!!!
%input is a directory vector, the desired sphere, resolution, bandwidth,
%polarization, and direction. Be sure to add the file directories to your
%path.


function data = average_cloud(directory,sat,hemisphere,resolution,band,polar,pass)

    c = 0;
    
if(exist('directory','var') && exist('sat','var') && exist('hemisphere','var')...
   && exist('band','var') && exist('polar','var') && exist('pass','var'))  

for k = 1:size(directory,1)
    %load directory
    nc_file = dir(directory(k,:));
    %create new fields within the struct
    [nc_file(:).sat] = deal(char(0));
    [nc_file(:).sphere] = deal(char(0));
    [nc_file(:).ismissed] = deal(0);
    [nc_file(:).res] = deal(0);
    [nc_file(:).pass] = deal(char(0));
    [nc_file(:).pol] = deal(char(0));
    [nc_file(:).band] = deal(char(0));
            
    %begin to loop through and sort
    for i = 1:length(nc_file)
        %sort satelite name
        if (strfind(nc_file(i).name,'AQUA_AMSRE') > -1);
            nc_file(i).sat = 'AQUA_AMSRE';
        elseif (strfind(nc_file(i).name,'NIMBUS7_SSMR') > -1);
            nc_file(i).sat = 'NIMBUS7_SSMR';
        elseif (strfind(nc_file(i).name,'F08_SSMI') > -1);
            nc_file(i).sat = 'F08_SSMI';
        elseif (strfind(nc_file(i).name,'F10_SSMI') > -1);
            nc_file(i).sat = 'F10_SSMI';
        elseif (strfind(nc_file(i).name,'F11_SSMI') > -1);
            nc_file(i).sat = 'F11_SSMI';
        elseif (strfind(nc_file(i).name, 'F13_SSMI') > -1);
            nc_file(i).sat = 'F13_SSMI';
        elseif (strfind(nc_file(i).name, 'F14_SSMI') > -1);
            nc_file(i).sat = 'F14_SSMI';
        elseif (strfind(nc_file(i).name, 'F15_SSMI') > -1);
            nc_file(i).sat = 'F15_SSMI';
        elseif (strfind(nc_file(i).name, 'F16_SSMIS') > -1);
            nc_file(i).sat = 'F16_SSMIS';
        elseif (strfind(nc_file(i).name, 'F17_SSMIS') > -1);
            nc_file(i).sat = 'F17_SSMIS';
        elseif (strfind(nc_file(i).name, 'F18_SSMIS') > -1);
            nc_file(i).sat = 'F18_SSMIS';
        elseif (strfind(nc_file(i).name, 'F19_SSMIS') > -1);
            nc_file(i).sat = 'F19_SSMIS'; 
        %HARD CODE in the word new to find the new .nc files I create
        elseif (strfind(nc_file(i).name, 'new') > -1);
            nc_file(i).sat = 'new';
        end
        
        %sort sphere
        %18 is the index of the T,N,or S in the name.
        H = 18;
        if (nc_file(i).name(H) == 'T')
            nc_file(i).sphere = 'T';
        elseif (nc_file(i).name(H) == 'N')
            nc_file(i).sphere = 'N';
        elseif (nc_file(i).name(H) == 'S')
            nc_file(i).sphere = 'S';
        else
            nc_file(i).ismissed = deal(0);
        end    
        
        %sort resolution       
        km = strfind(nc_file(i).name,'km');
        nc_file(i).res = str2double(nc_file(i).name(19:km-1));
        
        %sort bandwidth, polarization, and pass
        dist1 = 16; %dist from the end to the pass
        dist2 = 18; %dist from the end to the polarization
        dist3 = 19; %dist from end to the end of band
        five = 5; %need to use numbers after fifth dash.
        if strcmp(pass,'both')
            nc_file(i).pass = 'both';
        else
            nc_file(i).pass = nc_file(i).name(length(nc_file(i).name)-dist1);
        end
        if strcmp(polar,'both')
            nc_file(i).pol = 'both';
        else
            nc_file(i).pol = nc_file(i).name(length(nc_file(i).name)-dist2);
        end
        if band == 0 % if zero, all frequencies will be loaded.
            nc_file(i).band = 0; 
        else
            dash = strfind(nc_file(i).name,'-');
            nc_file(i).band = str2double(nc_file(i).name(dash(five)+1:length(nc_file(i).name)-dist3));
        end
            %Create a frequency field to use later.
            dash = strfind(nc_file(i).name,'-');
            nc_file(i).freq = str2double(nc_file(i).name(dash(five)+1:length(nc_file(i).name)-dist3));
    end
    
    %read only the files that match desired criteria
    for i = 1:size(nc_file,1)
         if (hemisphere == nc_file(i).sphere && resolution == nc_file(i).res...
            && band == nc_file(i).band && strcmp(polar,nc_file(i).pol)...
            && strcmp(pass,nc_file(i).pass) && strcmp(sat,nc_file(i).sat))
            c = c + 1;
            comp(c) = read_NSID_cloud(nc_file(i).name,nc_file(i).freq);
        end
    end
    %don't do anything if nothing exists
    if(exist('comp','var'))
        data = comp;
        [data(:).count] = deal(0);
        [data(:).pix_sum] = deal(0);
        [data(:).pix_avg] = deal(0);
        [data(:).std_count] = deal(0);
        [data(:).std_sum] = deal(0);
        [data(:).std_avg] = deal(0);
    end
end
%calculate the average
if(exist('comp','var'))    
    for i = 1:size(comp,2)
        
        found = (data(i).TB > 0); %Replace 0's with NaN to help create better scaled images
        data(i).TB(~found) = 0;
        missing = (data(i).TB == 600); %Remove missing values
        data(i).TB(missing) = 0;
        value = double(comp(i).TB).*found;
        
        if i == 1
            data(i).count = found;
            data(i).pix_sum = value;
        else
            data(i).count = data(i-1).count + found;
            data(i).pix_sum = data(i-1).pix_sum + value;
        end
        data(i).pix_avg = data(i).pix_sum./data(i).count;
        
        %Find Average STD_DEV
        std_dev_idx = data(i).TB_std_dev > 655.33;
        data(i).TB_std_dev(std_dev_idx) = 0;
        std_dev = data(i).TB_std_dev.*(~std_dev_idx);
        if i == 1
            data(i).std_count = std_dev_idx;
            data(i).std_sum = std_dev;
        else
            data(i).std_count = data(i-1).std_count + found;
            data(i).std_sum = data(i-1).std_sum + std_dev;
        end
        data(i).std_avg = data(i).std_sum./data(i).std_count;
        
    end
else
    data = [];
    disp('No files found that match criteria.');
end
else
    disp('Missing input variables.');
end
end


    
