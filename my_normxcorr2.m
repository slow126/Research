function [ norm_xcorr_coef ] = my_normxcorr2( template, image )
%input a template and image, and returns the normalized xcorrelation
%coefficiant at the center point. 

% template = abs(template);
% image = abs(image);

% y = size(template,1);
% x = size(template,2);

      template_mean = nanmean(nanmean(template));
      image_mean = nanmean(nanmean(image));

f = template - template_mean;
t = image - image_mean;

% f = template;
% t = image;


num = nansum(nansum(f .* t));
den1 = nansum(nansum(abs(f).^2));
den2 = nansum(nansum(abs(t).^2));
den3 = sqrt(den1*den2);
% den1 = nanstd(nanstd(f));
% den2 = nanstd(nanstd(t));
% den3 = den1 * den2;

norm_xcorr_coef = num / den3;% / (x * y);


end

