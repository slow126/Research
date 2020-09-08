function [b_val, sy] = compute_ave(pow, count, fill_array, response_array, b_val, sy)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    for i = 1:length(count)
        
        n = fill_array(i).pt;
        m = response_array(i).resp;
        b_val = nanmean(n .* m);
        
        
    end
    
end

