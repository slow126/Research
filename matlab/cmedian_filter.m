%
% mex function out=cmedian_filter(in,size,thres)
%
% filters the 2-d input array containing directions in radians [0..2pi]
% using a circular median filter with dimension size.  Input values less
% than thres are not considered.  The output value is the direction that
% minimizes the mean direction error between all directions in the
% window, which is one definition of the circular median.
%
% note the array is assumed stored in matlab order NOT sir file order

% written 21 Aug 2010 by D.G. Long