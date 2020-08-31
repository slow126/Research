addpath('/Users/spencerlow/Downloads')
directory = '/Users/spencerlow/Downloads/*.h5';

char_directory = char(directory);
directory = dir(char_directory);
averagingDim = 3;

for i=1:length(directory)
    SMAP(i) = SMAPReader(directory(i).name,true);
end

for i=1:length(directory)
    data(:,:,i) = SMAP(i).soil_moisture;
end

data(data <-9000) = NaN;

test = mean(data,averagingDim,'omitnan');