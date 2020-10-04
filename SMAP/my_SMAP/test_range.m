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


for i=1:1%length(directory)
    file = strcat(prefix, directory(i).name);
    test = sir_test(file, './', 0, 2016, str2double(directory(i).name(12:14)));
    data(i).out = SMAP_sir(file, './', 0, 2016, str2double(directory(i).name(12:14)));
end

save('data_range.mat', 'data', '-v7.3');

for i = 1:length(data)
    imgs(:,:,i) = reshape(data(i).out, [11568, 4872]);
end

avg_img = nanmean(imgs,3);

