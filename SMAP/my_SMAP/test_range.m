if ismac
    PATH = '/Users/low/CLionProjects/SMAP/sir/setup_files/SMhb*.setup';
elseif isunix
    PATH = '/media/spencer/Scratch_Disk/SMAP/sir/setup_files/SMhb*.setup';
end
directory = dir(PATH);

if ismac
    prefix = '/Users/low/CLionProjects/SMAP/sir/setup_files/';
elseif isunix
    prefix = '/media/spencer/Scratch_Disk/SMAP/sir/setup_files/';
end

for i=1:length(directory)
    file = strcat(prefix, directory(i).name);
    data(i).out = SMAP_sir(file, './', 0);
end

save('data_range.mat', 'data');