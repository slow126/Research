function [ Data ] = TRMMReader( filename )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

Info = h5info( filename );

for i=1:length(Info.Groups.Groups(1).Datasets)
    Data.G1.(Info.Groups.Groups(1).Datasets(i).Name) = ...
        h5read(filename,strcat('/Grids/G1/',Info.Groups.Groups(1).Datasets(i).Name));
    
    
end

for j = 1:length(Info.Groups.Groups(2).Datasets)
        Data.G2.(Info.Groups.Groups(1).Datasets(2).Name) = ...
        h5read(filename,strcat('/Grids/G2/',Info.Groups.Groups(2).Datasets(i).Name));
end


end
