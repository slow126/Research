function [expect] = spatial_condExp(tb,sigma,NDVI)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here



x = size(tb,2);
y = size(tb,1);
z1 = size(sigma,3);
z2 = size(sigma,3);

% Set the width and height of the moving window 
x_width = 10;
y_height = 10;

% Calculate the step from center of square to the edges
x_step = x_width/2;
y_step = y_height/2;

% Define center pixel location
index.center_y = {1:size(tb,1)};
index.center_x = {1:size(tb,2)};

% Define the +/- y's
index.minus_y = find_new_vector(index.center_y,y_step,'-');
index.plus_y = find_new_vector(index.center_y,y_step,'+');
index.minus_x = find_new_vector(index.center_x,x_step,'-');
index.plus_x = find_new_vector(index.center_x,x_step,'+');

% Create the corr_img. Begin sliding the square and calculating the
% normalized correlation coefficient. 

cond_window = 200;

expect = zeros(size(tb,1),size(tb,2));
for i = 1:y 
    for j = 1:x 
        mask = NDVI(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)) > (NDVI(i,j) - cond_window) &...
            NDVI(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)) < (NDVI(i,j) + cond_window);
       
        if(i > 500 && j > 500)
            temp = 1;
        end
        
        tb_wind = tb(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)) .* mask;
        sigma_wind = sigma(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)) .* mask;
        
        expect(i,j) = (nanmean(nanmean(tb_wind))) / nanmean(nanmean(sigma_wind));
        
    end
end


end

