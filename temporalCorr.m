function [ coorelation ] = temporalCorr( data1, data2 )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% data1(isnan(data1)) = nanmean(data1);
% data2(isnan(data2)) = nanmean(data2);



data1(isnan(data1)) = [];
data2(isnan(data2)) = [];



data1=data1(1:min(length(data1),length(data2)));
data2=data2(1:min(length(data1),length(data2)));

sum_data1 = nansum(data1);
sum_data2 = nansum(data2);

%if(length(data1) == length(data2))
    numerator = length(data1)*(nansum(data1 .* data2))-sum_data1*sum_data2;
    denominator = sqrt((length(data1)*nansum(data1.^2) - nansum(data1)^2) * (length(data1)*nansum(data2.^2) - nansum(data2)^2));
    coorelation = numerator / denominator;
%else 
%    coorelation = NaN;
%end


end

