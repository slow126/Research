%
% function out=growing_fill(in,mask,nthres,ave_med)
%
% MEX function that umplements a growing window fill function using 
% mask to indicate which pixels to consider.  The fill value
% is computed using either an average or a median filter.
%
% in = 2d (double) input array (matlab coordinates assumed)
% mask = 2d (double) input array (must be the same size as in)
%        fill values are produced were mask==0 using mask==1 values
%	out=in for mask==1 or mask==2, set the mask to 2 to not consider
% nthres = minimum number of points required to update file
%          OR ratio (0>0 & <1) of points from window size
% ave_med = optional flag set to ave_med=0 to fill with average value [default]
%           set to ave_med=1 to use median filter
% out = output array
% mout = optional output array containing the window size used for fill
%        (zero indicates no fill, negative means ratio threshold not met)

% written: DG Long   19 Nov 2011
% revised: DG Long   21 Nov 2011 + added optional output mask, ratio thres

