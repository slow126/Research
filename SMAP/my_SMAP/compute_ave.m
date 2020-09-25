function [b_val, sy] = compute_ave(pow, count, fill_array, response_array, b_val, sy)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
my_count = zeros(size(b_val,1),size(b_val,2));
    for i = 1:length(response_array)
%         num(i) = sum(response_array(i).resp);        
        n = fill_array(i).pt;
        m = response_array(i).resp;
        b_val(n) = b_val(n) + pow(i) * m;
        my_count(n) = my_count(n) + 1;
        
    end
    b_val = b_val ./ (my_count);
    
    measurement * response / sum(response)
    
end

