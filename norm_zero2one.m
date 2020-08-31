function [norm_image] = norm_zero2one(image)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    norm_image = (image - min(image(:))) / (max(image(:)) - min(image(:)));
end

