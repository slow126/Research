%
%  mexfunction out=region_grower(IN,r,c)
%
% Matlab mex function to implement binary region growing.
% Given a 2D image IN containing only values of 1 or 2,
% and a seed pixel location r,c, the code does region 
% growing within IN=1 starting at the seed location out to 
% the boundary defined by IN=2. 
% 
% Returns a copy of the input image, with region-filled pixel
% values set to 2.  Pixels with value 1 that do not "touch" 
% the filled seed region are left unmodified.  Touch means 
% adjacent to, i.e. in the following, only the 1 values "touch" 
% the 2 value.  The zero values are considered not touching.
%
%    0 1 0
%    1 2 1
%    0 1 0

% written 29 Jun 2009 by DG Long at BYU
% revised 23 Nov 2010 by DG Long at BYU