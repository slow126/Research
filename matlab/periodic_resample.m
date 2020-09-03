function X=periodic_resample(z,N)
%
% function X = periodic_resample(z,N)
% increases sample rate of 2d surface z by N where
% where z is periodic in rows.
%  note: last few cols of X are outside of interpolated range
%        and should be discarded

%

[m n]=size(z);

% periodic interpolation of columss first
g=interpft(z,N*m);

% now do interpolate rows by N
X=zeros([N*m,N*n]);
for k=1:N*m
%  X(k,:)=interp(g(k,:),N); % non-periodic bandlimited interpolation
%  X(k,:)=interp1(g(k,:),([1:N*n]-1)/N+1,'nearest'); % simple,fast
  X(k,:)=interp1(g(k,:),([1:N*n]-1)/N+1,'spline'); % probably best
%  X(k,:)=interp1(g(k,:),([1:N*n]-1)/N+1,'cubic'); % also good
end
