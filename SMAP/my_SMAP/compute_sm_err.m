function [mean_err, rmse] = compute_sm_err(img1, img2)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%     img1(img1 == 0.00) = NaN;
%     img2(img2 == 0.00) = NaN;
    img1(img1 > 0.6) = 0.6;
    img2(img2 > 0.6) = 0.6;
    
    rmse=zeros(size(days));
    mean_err=zeros(size(days));
    totalsumsq=0;
    totalsum=0;
    totalmeas=0;
    
    figure(1)
    imagesc(img1(3274:3580, 3715:4000))
    imagesc(img1)
    colorbar
    drawnow
    axis off
    
    figure(2)
    imagesc(img2)
    imagesc(img2(3274:3580, 3715:4000))
    colorbar
    drawnow
    axis off
    
    figure(3)
    imagesc(img1 - img2)
    colorbar
    drawnow
    axis off
    
%     img1_mean = nanmean(nanmean(img1))
%     img2_mean = nanmean(nanmean(img2))
    

    error=img1-img2;
    cursum=nansum(reshape(abs(error),1,[]));
    cursumsq=nansum(reshape(abs(error).^2,1,[]));
    curmeas=length(find(~isnan(error)));
%     curmeas = nansum(nansum(~isnan(error)));
    rmse = sqrt(cursumsq/curmeas);
    mean_err = cursum/curmeas;
    
end

