function [ave] = compute_ave(pow, fill_array, response_array, a_val)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    ave = zeros(size(a_val));
    for i = 1:length(response_array)
        ave(fill_array(i).pt) = nansum(pow(i) .* response_array(i).resp) ./ nansum(response_array(i).pt);
    end
    
    
end

