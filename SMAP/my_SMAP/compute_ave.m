function [ave] = compute_ave(pow, fill_array, response_array, a_val)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    ave = zeros(size(a_val));
    total = zeros(size(a_val));
    resp_total = zeros(size(a_val));
    for i = 1:length(response_array)
        total(fill_array(i).pt) = total(fill_array(i).pt) + pow(i) .* response_array(i).resp;
        resp_total(fill_array(i).pt) = resp_total(fill_array(i).pt) + response_array(i).resp;
%         ave(fill_array(i).pt) = nansum(pow(i) .* response_array(i).resp) ./ nansum(response_array(i).resp);
    end
    ave = total ./ resp_total;
end

