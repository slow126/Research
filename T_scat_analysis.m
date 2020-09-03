path = '/Users/spencerlow/Documents/src/time_series_T/*.nc';
directory = char(path);
directory = dir(directory);

reg = 'E2T';
final = length(directory) / 2;

for i = 1 : final
    scat(i) = universal_nsid(directory(i).name,'scat',1);
    scat(i).sig(scat(i).sig <= -30) = NaN;
end

figure(1)
imagesc(scat(9).sig')
impixelinfo
colorbar

scatter = cat(3,scat(:).sig);
clear scat;

std_scat = std(scatter,0,3,'omitnan');

figure(2)
imagesc(std_scat')
impixelinfo
colorbar
caxis([0,10])

figure(3)
imagesc((std_scat > 2.5)')
impixelinfo
colorbar

