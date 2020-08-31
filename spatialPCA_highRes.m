%addpath('/home/low/NSID/PCA')
%directory='/home/low/NSID/PCA/*.nc';
% This is a basic header. Creates the directory, and specifies what file
% type to look for
addpath('/Users/spencerlow/Documents/src/test_Folder/')
directory = '/Users/spencerlow/Documents/src/test_Folder/*.nc';
radiometer_freq = '37';
hemi = 'T';
satellite = 4;  
image_only = 1;

if(hemi == 'S' || hemi == 'N')
    reduction_factor = 8;%2;
    divisor = 1;
else
    reduction_factor = 8;
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

 sigma_h = db2mag(sigma_h);
 sigma_v = db2mag(sigma_v);


 
% "Normalize" the data
epsilon = (rad_h - rad_v) ./ (rad_h + rad_v);
sigma = (sigma_h - sigma_v)./(sigma_h + sigma_v);
rad_h_mean = nanmean(nanmean(rad_h));
rad_v_mean = nanmean(nanmean(rad_v));
sigma_h_mean = nanmean(nanmean(sigma_h));
sigma_v_mean = nanmean(nanmean(sigma_v));

rad_h_std = nanstd(nanstd(rad_h));
rad_v_std = nanstd(nanstd(rad_v));
sigma_h_std = nanstd(nanstd(sigma_h));
sigma_v_std = nanstd(nanstd(sigma_v));

rad_h = (rad_h-rad_h_mean)/rad_h_std;
rad_v = (rad_v-rad_v_mean)/rad_v_std;
sigma_h = (sigma_h-sigma_h_mean)/sigma_h_std;
sigma_v = (sigma_v-sigma_v_mean)/sigma_v_std;

%  rad_h = (rad_h - min(min(rad_h))) / (max(max(rad_h))-min(min(rad_h)));
%  rad_v = (rad_v - min(min(rad_v))) / (max(max(rad_h))-min(min(rad_h)));
%  sigma_h = (sigma_h - min(min(sigma_h))) / (max(max(sigma_h))-min(min(sigma_h)));
%  sigma_v = (sigma_v - min(min(sigma_v))) / (max(max(sigma_v))-min(min(sigma_v)));


x = size(rad_h,2);
y = size(rad_h,1);
z1 = size(rad_h,3);
z2 = size(sigma_h,3);


% Reduce the resolution of the image considerably to minimize processing
% time. Sig: 4 times reduction. Eps: 2 times reduction

sigma_h = reduce_size_byN(sigma_h,reduction_factor);
sigma_v = reduce_size_byN(sigma_v,reduction_factor);

rad_h = reduce_size_byN(rad_h,reduction_factor/divisor);
rad_v = reduce_size_byN(rad_v,reduction_factor/divisor);


%%%%%%%%%%%%%%%%%%%%
% IMAGE PROCESSING %
%%%%%%%%%%%%%%%%%%%%

% Set the width and height of the moving window 
x_width = 10;
y_height = 10;

x_step = x_width/2;
y_step = y_height/2;

% Define center pixel location
index.center_y = {1:size(rad_h,1)};
index.center_x = {1:size(rad_h,2)};

% Define the +/- y's
index.minus_y = find_new_vector(index.center_y,y_step,'-');
index.plus_y = find_new_vector(index.center_y,y_step,'+');
index.minus_x = find_new_vector(index.center_x,x_step,'-');
index.plus_x = find_new_vector(index.center_x,x_step,'+');


% Create the corr_img. Begin sliding the square and calculating the
% normalized correlation coefficient. 

center_of_windowX = x_width/2;
center_of_windowY = y_height/2;

highRes_PCA_img = zeros(size(rad_h,1),size(rad_h,2));
for i = 1:y /(reduction_factor/divisor)
    for j = 1:x /(reduction_factor/divisor)
        
        temp1 = make_oneDim(rad_h(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)));
        temp2 = make_oneDim(rad_v(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)));
        temp3 = make_oneDim(sigma_h(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)));
        temp4 = make_oneDim(sigma_v(index.minus_y(i):index.plus_y(i),index.minus_x(j):index.plus_x(j)));
        
        independent_variables = [temp1,temp2,temp3,temp4];
        [COEFF,SCORE,LATENT] = pca(independent_variables);
        
       
        if(isempty(COEFF))
            highRes_PCA_img(i,j) = NaN;
        else
            Z_star = independent_variables * COEFF;
            pca1 = reshape(Z_star(:,1),index.plus_y(i)-index.minus_y(i)+1,index.plus_x(j)-index.minus_x(j)+1);
            highRes_PCA_img(i,j) = pca1(round((index.plus_y(i)-index.minus_y(i)+1)/2),round((index.plus_x(j)-index.minus_x(j)+1)/2));   
        end
    end
end
