if ismac
    PATH = '/Users/low/CLionProjects/SMAP/sir/setup_files/SMvb*.setup';
elseif isunix
    addpath(genpath('/home/spencer/Documents/MATLAB'));
    addpath(genpath('/media/spencer/Scratch_Disk/SMAP/sir/setup_files'));
    PATH = '/media/spencer/Scratch_Disk/SMAP/sir/setup_files/SMvb*.setup';
end
directory = dir(PATH);

if ismac
    prefix = '/Users/low/CLionProjects/SMAP/sir/setup_files/';
elseif isunix
    prefix = '/media/spencer/Scratch_Disk/SMAP/sir/setup_files/';
end


for i=1:1%length(directory)
    file = strcat(prefix, directory(3).name);
    data(i).out = SMAP_sir(file, './', 0, 2016, str2double(directory(3).name(12:14)));
end

save('data_range.mat', 'data');