% A cloud removal algorithm that combines data from both scatterometer and
% radiometer time series to more accurately identify and remove clouds. 

path = '/Users/spencerlow/Documents/src/time_series/*.nc';
directory = char(path);
directory = dir(directory);
sat = 'F14_SSMI';
reg = 'E2T';
freq = '37'; 

j = 1;
k = 1;
for i = 1:length(directory) 
    if strfind(directory(i).name,'NSIDC') & strfind(directory(i).name,sat) & strfind(directory(i).name,freq)
        radiometer(j) = universal_nsid(directory(i).name,'rad',1); 
        %radiometer(j).TB = (radiometer(j).TB - min(min(radiometer(j).TB))) / (max(max(radiometer(j).TB)) - min(min(radiometer(j).TB)));
        radiometer(j).TB(radiometer(j).TB == 0) = NaN;
        j = j + 1;
        

    end
end

rad = double(cat(3,radiometer(:).TB));
clear radiometer;
rad(rad == 0) = NaN;
rad = rad * .01;
std_rad = std(rad,0,3,'omitnan');
%std_rad = (std_rad - min(min(std_rad))) / (max(max(std_rad)) - min(min(std_rad)));
rad_avg = mean(rad,3,'omitnan');


for i = 1 : length(directory) - 14
    if strfind(directory(i).name,'sir') & strfind(directory(i).name,reg)
        scatterometer(k) = universal_nsid(directory(i).name,'scat',1);
        %scatterometer(k).sig = (scatterometer(k).sig - min(min(scatterometer(k).sig)))/(max(max(scatterometer(k).sig)) - min(min(scatterometer(k).sig)));
        scatterometer(k).sig = reduce_size_byN(scatterometer(k).sig,2);
        k = k + 1;
    end
end

scat = double(cat(3,scatterometer(:).sig));
clear scatterometer;

scat(scat < -30) = NaN;
std_scat = std(scat,0,3,'omitnan');
%std_scat = (std_scat - min(min(std_scat))) / (max(max(std_scat)) - min(min(std_scat)));
scat_avg = mean(scat,3,'omitnan');
clear scat;

%std_scat = reduce_size_byN(std_scat,2);

figure(1)
imagesc(std_rad);
colorbar
impixelinfo

figure(2)
imagesc(std_scat);
colorbar
impixelinfo

cloud = (std_scat > 1.25) .* (std_rad > 1.25);
figure(3)
imagesc(cloud);
colorbar
impixelinfo




half = repmat(rad_avg,[1,1,size(rad,3)]);

lower = (rad < half);

ocean = rad_avg .* ~cloud + mean(lower,3,'omitnan') .* cloud;

figure(4)
imagesc(ocean)
colorbar
impixelinfo
caxis([0,300])

figure(5)
imagesc(rad_avg)
colorbar
impixelinfo
caxis([0,300])


%{
rad_avg = sum(cat(3,radiometer(:).TB),3,'omitnan') ./ (sum((cat(3,radiometer(:).TB) > 0),3,'omitnan'));
cat_rad = double(cat(3,radiometer(:).TB));
clear radiometer;
clear scatterometer;

figure(1)
imagesc(std(cat_rad,[],3,'omitnan')')
colorbar
impixelinfo
%}