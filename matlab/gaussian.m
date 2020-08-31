function y=gaussian(x,std,mea)
%
% function y=gaussian(x,std,mea)
%
% given standard deviation and mean, computes the gaussian distribution
% value at x
%
y=(1/sqrt(2*pi*std*std))*exp(-(x-mea).^2/(2*std.^2)); 
return;