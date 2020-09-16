function [mean_err, rmse] = compute_sm_err(img1, img2)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    rmse=zeros(size(days));
    mean_err=zeros(size(days));
    totalsumsq=0;
    totalsum=0;
    totalmeas=0;

    error=img1-img2;
    cursum=nansum(reshape(error,1,[]));
    cursumsq=nansum(reshape(error.^2,1,[]));
    curmeas=length(find(~isnan(error)));
    rmse = sqrt(cursumsq/curmeas);
    mean_err = cursum/curmeas;
    
end

