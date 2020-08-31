function [a,b,t]=stats2ellipse(xvar,yvar,xycor)
%
% function [a,b,t]=stats2ellipse(xvar,yvar,xycor)
%
% Computes the semi-major (a) and semi-minor (b) axes and the rotation
% angle in radians of the ellipse the describes the 2d one standard
% deviation ellipse of a gaussian from the components of the correlation 
% matrix of two correlated parameters x and y.  The ellipse parameters
% are designed to be used in ellipse.m 
%
% example usage:
% %set x,y to be column vectors of correlated Gaussian random variables, e.g.
%   N=10000; cxy=0.2; sx=5; sy=1; xm=1; ym=2;
%   x=randn([1 N])*sx+xm; 
%   y=x*cxy+randn([1 N])*sy+ym; 
% %compute first-order statistics
%   xvar=var(x);
%   yvar=var(y);
%   xycor=mean(x.*y)-mean(x)*mean(y);
% %compute ellipse parameters 
%   [a b t]=stats2ellipse(xvar,yvar,xycor);
% %plot points as a scatter plot, plot one std using ellipse.m
%   plot(x,y,'r.');
%   hold on; ellipse(a,b,t,mean(x),mean(y)); hold off;

% written by D.G. Long 21 Jan 2012

% check input args
if nargin < 3
  error('stats2ellipse requires 3 arguments');
end
if size(xvar) ~= size(yvar) | size(xvar) ~= size(xycor)
  error('arguments to stats2ellipse must be the same size');
end
ind=find(xvar<=0 | yvar<=0);
if length(ind)>0
  error('invalid arguments to stats2ellipse (negative or zero variance');
end

% default output arguments for zero correlation
a=sqrt(xvar);
b=sqrt(yvar);
t=zeros(size(xvar));

ind=find(xycor(:)~=0); % find non-zero correlations
for k=1:length(ind) % for each non-zero correlation
  R=(xvar(ind)+yvar(ind))^2-4*(xvar(ind)*yvar(ind)-xycor(ind)^2);
  if R<0 % bad covariance matrix
    XY=sqrt(xvar(ind)*yvar(ind)-(xvar(ind)+yvar(ind))^2/4);
    EV1=(xvar(ind)+yvar(ind))/2;
    EV2=EV1; % set semi-major and semi-minor values the same (circle)
  else   % good covariance matrix
    XY=xycor(ind);
    EV1=(xvar(ind)+yvar(ind)+sqrt(R))/2; % squared semi-major
    EV2=(xvar(ind)+yvar(ind)-sqrt(R))/2; % squared semi-minor
  end
  % compute rotation angle
  X=sign(XY)*sqrt((yvar(ind)-EV1)^2/(XY^2+(yvar(ind)-EV1)^2));
  Y=sqrt(XY^2/(XY^2+(yvar(ind)-EV1)^2));
  t(ind)=atan2(Y,X);
  % compute ellipse axes
  a(ind)=sqrt(EV1);
  b(ind)=sqrt(EV2);
end
