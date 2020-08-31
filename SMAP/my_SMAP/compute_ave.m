function [b_val, sy] = compute_ave(pow, count, fill_array, response_array, b_val, sy)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    for i = 1:count
        n = fill_array(i);
        m = response_array(i);
        b_val(n - 1) = b_val(n - 1) + m * pow;
        sy(n - 1) = sy(n - 1) + m;
    end
    
end

