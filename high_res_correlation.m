% Script that divides cooresponding backscatter and brightness temperature
% images into a grid. Then compares each grid to find areas that have
% coorelation.

% Load images

% directory = '/home/low/NSID/comp_img/Temp/*.nc';
directory = '/Users/spencerlow/Documents/src/Tb_v_sigma/*.nc';

% directory = '/Users/spencerlow/Documents/src/Tb_v_sigma';
[rad, scat] = multi_universal(directory,1);

for i = 1:length(scat)
    % scat(i).sig = reduce_size_byN(scat(i).sig,2);
    scat(i).sig(scat(i).sig < -32) = NaN;
end

rad = cat(3,rad(:).TB);
scat = cat(3,scat(:).sig);

rad_avg = sum(rad,3,'omitnan')./sum((rad > 0),3,'omitnan');
%fix scat_avg. 
scat_avg = sum(scat,3,'omitnan')./sum((scat > -33),3,'omitnan');

rad_avg = reduce_size_byN(rad_avg,2);
scat_avg = reduce_size_byN(scat_avg,2);

%clear rad;
%clear scat;

% Begin Image Processing
%%%%%%%%%%%%%%%%%%%%%%%%%

number_x = 320;
number_y = 320;

x_width = size(rad_avg,2) / number_x;
y_height = size(rad_avg,1) / number_y;

x_step = x_width / 2;
y_step = y_height / 2;

corr_img = zeros(size(rad_avg,1),size(rad_avg,2));

% Define center pixel location
index.center_y = {1:size(rad_avg,1)};
index.center_x = {1:size(rad_avg,2)};

% Define the +/- y's
index.minus_y = find_new_vector(index.center_y,y_step,'-');
index.plus_y = find_new_vector(index.center_y,y_step,'+');
index.minus_x = find_new_vector(index.center_x,x_step,'-');
index.plus_x = find_new_vector(index.center_x,x_step,'+');



for i = 1 : size(rad_avg,1)
    for j = 1 : size(rad_avg,2)
        corr_img(i,j) = corr2(rad_avg(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)),...
            scat_avg(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)));
    end
end


% raytheon.com/campus 

figure(1)
imagesc(corr_img')
colorbar
saveas(figure(1),'high_res_corr.png')














