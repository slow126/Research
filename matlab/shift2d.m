function out = shift2d(x,m,n)
%
% out = shift2d(x,m,n)
%
% circulantly shift a matrix by m rows and n columns
%  [loosely] out=x(:+m,:+n)   
% m and n can larger than dimensions or negative, but must be integers
%
% example:
% >> A=[11 12 13; 21 22 23; 31 32 33; 41 42 43]
% A =
%    11    12    13
%    21    22    23
%    31    32    33
%    41    42    43
% shift one row right
% >> shift2d(A,1,0)
% ans =
%    13    11    12
%    23    21    22
%    33    31    32
%    43    41    42
% shift up one column
% >> shift2d(A,0,-1)
% ans =
%    21    22    23
%    31    32    33
%    41    42    43
%    11    12    13

% written by D.Long June 2001

% get input array sizes
[M,N]=size(x);

% compute axis shifts using mod to support all m,n values
lm=mod((0:M-1)+round(m),M)+1;
ln=mod((0:N-1)+round(n),N)+1;

% compute indexes of shifts
[X,Y]=meshgrid(lm,ln);
ind=sub2ind([M N],reshape(X',1,M*N),reshape(Y',1,M*N));

% preallocate output array
out=zeros(size(x));

% copy input into output array using shifted indexes
out(ind)=x;
