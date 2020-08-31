function [ sorted_directory ] = sort_ncDirectory( directory )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

char_directory = char(directory);
directory = dir(char_directory);

k = 1;
for i = 1:length(directory)
    if(contains(directory(i).name,'NSIDC'))
        A(i,:) = directory(i).name;
        k = k + 1;
    end
end

start = size(directory(1).name,2)-23;
stop = size(directory(1).name,2)-21;



sorted_directory = natsort(cellstr(A));

end

