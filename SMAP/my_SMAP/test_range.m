PATH = '/Users/low/CLionProjects/SMAP/sir/setup_files/SMhb*.setup';
directory = dir(PATH);

prefix = '/Users/low/CLionProjects/SMAP/sir/setup_files/';

for i=1:length(directory)
    file = strcat(prefix, directory(i).name);
    data(i).out = SMAP_sir(file, './', 0);
end

save('data_range.mat', 'data');