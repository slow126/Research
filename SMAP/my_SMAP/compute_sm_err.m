function [mean_err, rmse] = compute_sm_err(img1, img2)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    img1(img1 == 0.00) = NaN;
    img2(img2 == 0.01) = NaN;
    rmse=zeros(size(days));
    mean_err=zeros(size(days));
    totalsumsq=0;
    totalsum=0;
    totalmeas=0;
    
    figure(1)
    imagesc(img1)
    colorbar
    drawnow
    
    figure(2)
    imagesc(img2)
    colorbar
    drawnow
    
    figure(3)
    imagesc(img1 - img2)
    colorbar
    drawnow
    
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

