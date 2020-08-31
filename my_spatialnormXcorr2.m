function [ corr_img ] = my_spatialnormXcorr2( image1, image2 )

if(size(image1,1) ~= size(image2,1) && size(image1,2) ~= size(image2,2))
    error('Image dimensions do not agree');
else
    x = size(image1,2);
    y = size(image1,1);
    % Set the width and height of the moving window
    x_width = 10;
    y_height = 10;
    
    % Calculate the step from center of square to the edges
    x_step = x_width/2;
    y_step = y_height/2;
    
    % Define center pixel location
    index.center_y = {1:size(image1,1)};
    index.center_x = {1:size(image2,2)};
    
    % Define the +/- y's
    index.minus_y = find_new_vector(index.center_y,y_step,'-');
    index.plus_y = find_new_vector(index.center_y,y_step,'+');
    index.minus_x = find_new_vector(index.center_x,x_step,'-');
    index.plus_x = find_new_vector(index.center_x,x_step,'+');
    
    % small_eps = (max(max(small_eps)) - small_eps)./(max(max(small_eps)) - min(min(small_eps)));
    % small_sigma = (max(max(small_sigma)) - small_sigma)./(max(max(small_sigma)) - min(min(small_sigma)));
    
    % Create the corr_img. Begin sliding the square and calculating the
    % normalized correlation coefficient.
    corr_img = zeros(size(image1,1),size(image1,2));
    
    for i = 1:y 
        for j = 1:x 
            %         corr_img(i,j) = my_normxcorr2(small_eps(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)),...
            %              small_sigma(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)));
            
            %         if(i>1000 && j>1000)
            %             temp2 = normxcorr2(small_eps(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)),...
            %             small_sigma(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)));
            %             temp2(11,11);
            %         end
            temp = my_normxcorr2(image1(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)),...
                image2(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)));
            corr_img(i,j) = temp; %temp(double(int16(size(temp,1)/2)),double(int16(size(temp,1)/2))); %<- make this dynamic center of window
            %         corr_img(i,j) = max(max(abs(xcorr2(small_sigma(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)),...
            %             small_sigma(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j))))));
            
        end
    end
    
end

end

