function [ smapData ] = SMAPReader( filename,soilMoistureFlag )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

smapInfo = h5info( filename );
dataIndex = 2;
    if(~soilMoistureFlag)
        for i=1:length(smapInfo.Groups(dataIndex).Datasets)
            smapData.(smapInfo.Groups(dataIndex).Datasets(i).Name) = ...
                h5read(filename,strcat( smapInfo.Groups(dataIndex).Name, ...
                '/',smapInfo.Groups(dataIndex).Datasets(i).Name));


        end
    else
        smapData.soil_moisture=h5read(filename,strcat( smapInfo.Groups(dataIndex).Name,...
        '/','soil_moisture'));
    end
end

