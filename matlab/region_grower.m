%
%  mexfunction out=region_grower(IN,x,y)
%
%
% Matlab mex function to implement binary region growing.
% Given an nsx by nsy image IN, region growing is done within IN=1
% out to the boundary defined by IN=2.  Filled pixels are set to 2.
% Returns region filled image.
%
% note that in matlab convention x are columns, y are rows
%

% written 29 Jun 2009 by DG Long at BYU
