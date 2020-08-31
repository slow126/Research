function [ unity ] = make_UnityCetb( data1 )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
  
if(size(data1,3) > 1)
    for i = size(data1,3):-2:1
        
        unity(:,:,i/2) = mean(data1(:,:,(i-1):i),3,'omitnan');
    end
else
    unity = [];
end

end

