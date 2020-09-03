%directory = '/home/low/NSID/correlation_files/test/*.nc';
directory = '/Users/spencerlow/Documents/src/comp_img/*.nc';
radiometer_freq = '37';
hemi = 'S';
satellite = 4;
image_only = 1;

if(hemi == 'S' | hemi == 'N')
    reduction_factor = 2;
else
    reduction_factor = 4;
end

 [ rad_h,rad_v,sigma ] = temporalCorr_setMaker( directory,radiometer_freq,hemi,satellite,image_only );

x = size(rad_h,2);
y = size(rad_h,1);
z1 = size(rad_h,3)/2;
z2 = size(sigma,3);

for i = size(rad_h,3):-1:1
    rad_h(rad_h <= 0) = NaN;
    rad_v(rad_v <= 0) = NaN;
    %epsilon(:,:,i) = (rad_h(:,:,i) - rad_v(:,:,i)) ./ (rad_h(:,:,i) + rad_v(:,:,i)); 
    %clear rad_h(:,:,i); temporarily commeted out
    %clear rad_v(:,:,i);
end

%  rad_h_temp = make_UnityCetb(rad_h);
%  rad_v_temp = make_UnityCetb(rad_v);


epsilon = rad_h; % (rad_h - rad_v) ./ (rad_h + rad_v); % <- equation for isolating e
 clear rad_h;
%  clear rad_h_temp;
%  clear rad_v_temp;

 
%  fill_Values = mean(epsilon,3,'omitnan');
%  for i = 1:size(epsilon,3)
%      holes = isnan(epsilon(:,:,i));
%      epsilon(holes) = fill_Values(holes);
%  end
 
% clear rad_h; 
% clear rad_v; 


sigma(sigma <= -33) = NaN;

% reduce the resolution of the image considerably to minimize processing
% time. Sig: 4 times reduction. Eps: 2 times reduction
small_sigma = zeros(size(sigma,1)/reduction_factor,size(sigma,2)/reduction_factor,z2);
small_eps = zeros(size(epsilon,1)/2,size(epsilon,2)/2,z1);
for i = 1 : size(sigma,3)
    small_sigma(:,:,i) = reduce_size_byN(sigma(:,:,i),reduction_factor);
    if(i <= size(epsilon,3))
        small_eps(:,:,i) = reduce_size_byN(epsilon(:,:,i),2);
    end   
end
clear sigma;
clear epsilon;

% fill_Sig = mean(small_sigma,3,'omitnan');
% for i = 1 : size(small_sigma,3)
%     holes = isnan(small_sigma(:,:,i));
%     small_sigma(holes) = fill_Sig(holes);
% end


% small_eps = nanmean(small_eps,3);
% small_sigma = nanmean(small_sigma,3);
% corr_img = xcorr2(small_eps(500:1000,500:1000),small_sigma(500:1000,500:1000));
corr_img = zeros(y/4,x/4);
for i = 1:y / 2
    for j = 1:x / 2
        eps = reshape(small_eps(i,j,:),[1 z1]);
        sig = reshape(small_sigma(i,j,:),[1 z2]);
        corr_img(i,j) = temporalCorr(eps(1:min(z1,z2))',sig(1:min(z1,z2))');
%         temp = corrcoef(eps',sig','rows','pairwise');
%         if exist('temp','var')
%             corr_img(i,j) = temp(2, 1);
%         else
%             corr_img(i,j) = nan;
%         end
      
    end
end



save('temporalCorr.mat','corr_img');
