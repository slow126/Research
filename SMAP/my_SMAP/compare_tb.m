    
 if ismac
    addpath(genpath('/Users/low/Documents/MATLAB'));
    addpath(genpath('/Users/low/CLionProjects/SMAP/sir/setup_files/'));
    PATH = '/Users/low/CLionProjects/SMAP/sir/setup_files/SMvb*.setup';
elseif isunix
    addpath(genpath('/home/spencer/Documents/MATLAB'));
    addpath(genpath('/mnt/nvme1n1p1/SMAP/sir/setup_files'));
    PATH = '/mnt/nvme1n1p1/SMAP/sir/setup_files/SMvb*.setup';
end
directory = dir(PATH);

if ismac
    prefix = '/Users/low/CLionProjects/SMAP/sir/setup_files/';
elseif isunix
    prefix = '/mnt/nvme1n1p1/SMAP/sir/setup_files/';
end
res = 1;
year = 2016;



[tbav2, albav, incav, qualav, clayf, vopav, rghav, smav, vwcav, tempav, wfracav]=data_loadSIR(year,277,0,res);
[nsy, nsx] = size(tbav2);



    for i =1:length(directory)
        read_start_day = str2double(directory(i).name(12:14));
        read_end_day = read_start_day + 4;
        a_val = ncread(strcat('/home/spencer/Documents/MATLAB/Research/SMAP/images/SMvb-E2T16-', int2str(read_start_day),'-',int2str(read_end_day),'.lis_dump.nc'),'a_image');
        a_val(a_val == 100) = NaN;
        
        
        temp = reshape(a_val, [nsx, nsy]);
        temp = flipud(temp');
        
%         temp2 = tbav2;
        mask = ~isnan(temp) .* ~isnan(tbav2);
        temp2 = tbav2 .* mask;
        temp = temp .* mask;
        temp(temp < 150) = NaN;
        temp2(temp2 < 150) = NaN;
        tbav2_mean = nanmean(reshape(temp2,1,[]))
        
%         temp = temp(2200:2550,3300:4200);
%         temp2 = temp2(2200:2550, 3300:4200);
        a_val_mean = nanmean(reshape(temp,1,[]))
        tbav2_mean = nanmean(reshape(temp2,1,[]))

        

        
        
        figure(1)
        imagesc(temp2)
        colorbar
        drawnow
        caxis([100,330])

        
        figure(2)
        imagesc(temp)
        colorbar
        drawnow
        caxis([100,330])
        
        figure(3)
        imagesc(temp2 - temp)
        colorbar
        drawnow
        
        [mm_err(i), rms_err(i)] = compute_sm_err(temp2, temp)
        pause
    end

