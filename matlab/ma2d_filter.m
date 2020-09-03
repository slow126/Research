%
% mex function out=ma2d_filter(in,weights,thres)
%
% applies 2d moving average filter to a 2d input array 
% Input values less than thres are not considered. 
% weights should be odd sized.
%
% note array is assumed stored in matlab order NOT sir file order

% written 21 Aug 2010 by D.G. Long