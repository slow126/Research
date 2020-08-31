% Script that divides cooresponding backscatter and brightness temperature
% images into a grid. Then compares each grid to find areas that have
% coorelation.

% Load images

% directory = '/home/low/NSID/comp_img/Temp/*.nc';
directory = '/Users/spencerlow/Documents/src/Tb_v_sigma';

% directory = '/Users/spencerlow/Documents/src/Tb_v_sigma';
[rad_h, rad_v, scat] = multi_pol(directory,1);

for i = 1:length(scat)
    % scat(i).sig = reduce_size_byN(scat(i).sig,2);
    scat(i).sig(scat(i).sig < -32) = NaN;
end

rad_h = cat(3,rad_h(:).TB);
rad_v = cat(3,rad_v(:).TB);
scat = cat(3,scat(:).sig);

radh_avg = sum(rad_h,3,'omitnan')./sum((rad_h > 0),3,'omitnan');
radv_avg = sum(rad_v,3,'omitnan')./sum((rad_v > 0),3,'omitnan');
%fix scat_avg. 
scat_avg = sum(scat,3,'omitnan')./sum((scat > -33),3,'omitnan');

radh_avg = reduce_size_byN(radh_avg,2);
radv_avg = reduce_size_byN(radv_avg,2);
scat_avg = reduce_size_byN(scat_avg,2);

rad_avg = (radh_avg - radv_avg) ./ (radh_avg + radv_avg);

%clear rad;
%clear scat;

% Begin Image Processing
%%%%%%%%%%%%%%%%%%%%%%%%%

number_x = 160;
number_y = 160;

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
        corr_img(i,j) = abs(corr2(rad_avg(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)),...
            scat_avg(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j))));
    end
end


% raytheon.com/campus 

figure(1)
imagesc(corr_img')
colorbar
saveas(figure(1),'high_res_corr.png')

save('corr_img.mat','corr_img');

save('rad_avg.mat','rad_avg');
save('scat_avg.mat','scat_avg');










