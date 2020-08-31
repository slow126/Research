function [ corr_img ] = spatialCorr( path, radiometer_freq, hemi, satellite, image_only )
% Calculate a moving window 2d correlation.
path = strcat(path,'.nc');

addpath(path);

if(hemi == 'S' | hemi == 'N')
    reduction_factor = 4;%2;
    divisor = 1;
else
    reduction_factor = 4;
    divisor = 2;
end

% Load in the data sets as defined by the above header.
[ rad_h,rad_v,sigma_h,sigma_v ] = temporalCorr_setMaker( directory,radiometer_freq,hemi,satellite,image_only );

% Fill empty value with NaN's 
rad_h(rad_h <= 10) = NaN;
rad_v(rad_v <= 10) = NaN;
sigma_h(sigma_h <=-33) = NaN;
sigma_v(sigma_v <=-33) = NaN;

% Average each data set 
rad_h = mean(rad_h,3,'omitnan');
rad_v = mean(rad_v,3,'omitnan');
sigma_h = (mean(sigma_h,3,'omitnan')); %db2mag
sigma_v = (mean(sigma_v,3,'omitnan'));

% "Normalize" the data
epsilon = (rad_h - rad_v) ./ (rad_h + rad_v);
sigma = (sigma_h - sigma_v)./(sigma_h + sigma_v);


% Create dimension variables to be used later
x = size(rad_h,2);
y = size(rad_h,1);
z1 = size(rad_h,3);
z2 = size(sigma,3);

%sigma = sum(sigma,3,'omitnan')./sum((sigma > -33),3,'omitnan');


% epsilon = make_UnityCetb(rad_h);
% epsilon = rad_h; % (rad_h - rad_v) ./ (rad_h + rad_v); % <- equation for isolating e
% clear rad_h;
%  clear rad_h_temp;
%  clear rad_v_temp;

% Reduce the resolution of the image considerably to minimize processing
% time. Sig: 4 times reduction. Eps: 2 times reduction
small_sigma = zeros(size(sigma,1)/reduction_factor,size(sigma,2)/reduction_factor,z2);
small_eps = zeros(size(epsilon,1)/(reduction_factor/divisor),size(epsilon,2)/(reduction_factor/divisor),z1);
for i = 1 : max(size(sigma,3),size(epsilon,3))
    if(i <= size(sigma,3))
        small_sigma(:,:,i) = reduce_size_byN(sigma(:,:,i),reduction_factor);
    end
    if((i <= size(epsilon,3)))
        small_eps(:,:,i) = reduce_size_byN(epsilon(:,:,i),reduction_factor/divisor);
    end
end
% Clear unneeded data sets to save ram
clear sigma;
clear epsilon;


% % Used for the temporal correlation. Don't need for spatial.
% fill_Values = mean(small_eps,3,'omitnan');
% for i = 1:size(small_eps,3)
%     holes = isnan(small_eps(:,:,i));
%     small_eps(holes) = fill_Values(holes);
% end
% 
% fill_Sig = mean(small_sigma,3,'omitnan');
% for i = 1 : size(small_sigma,3)
%     holes = isnan(small_sigma(:,:,i));
%     small_sigma(holes) = fill_Sig(holes);
% end


%%%%%%%%%%%%%%%%%%%%
% IMAGE PROCESSING %
%%%%%%%%%%%%%%%%%%%%

% Set the width and height of the moving window 
x_width = 10;
y_height = 10;

% Calculate the step from center of square to the edges
x_step = x_width/2;
y_step = y_height/2;

% Define center pixel location
index.center_y = {1:size(small_eps,1)};
index.center_x = {1:size(small_eps,2)};

% Define the +/- y's
index.minus_y = find_new_vector(index.center_y,y_step,'-');
index.plus_y = find_new_vector(index.center_y,y_step,'+');
index.minus_x = find_new_vector(index.center_x,x_step,'-');
index.plus_x = find_new_vector(index.center_x,x_step,'+');

% small_eps = (max(max(small_eps)) - small_eps)./(max(max(small_eps)) - min(min(small_eps)));
% small_sigma = (max(max(small_sigma)) - small_sigma)./(max(max(small_sigma)) - min(min(small_sigma)));

% Create the corr_img. Begin sliding the square and calculating the
% normalized correlation coefficient. 
corr_img = zeros(size(small_eps,1),size(small_eps,2));
for i = 1:y /(reduction_factor/divisor)
    for j = 1:x /(reduction_factor/divisor)
        %         corr_img(i,j) = my_normxcorr2(small_eps(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)),...
        %              small_sigma(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)));
        
        temp = my_normxcorr2(small_eps(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)),...
            small_sigma(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)));
        corr_img(i,j) = temp; %temp(double(int16(size(temp,1)/2)),double(int16(size(temp,1)/2))); %<- make this dynamic center of window
        %         corr_img(i,j) = max(max(abs(xcorr2(small_sigma(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)),...
        %             small_sigma(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j))))));
        
    end
end



end

