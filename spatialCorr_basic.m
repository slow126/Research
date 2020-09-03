function [ corr_img ] = spatialCorr_basic( small_eps, small_sigma)
% Calculate a moving window 2d correlation of already made eps, and sig
% images. 

x = size(small_eps,2);
y = size(small_eps,1);
z1 = size(small_eps,3);
z2 = size(small_sigma,3);

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
for i = 1:y 
    for j = 1:x 
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

