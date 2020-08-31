function [a b theta varargout]=Est_Lin_Xform_Para(x,y,xp,yp,case_in,a_in,b_in,theta_in)
%
% [a b theta M Minv]=Est_Lin_Xform_Para(x,y,xp,yp,case_in,a_in,b_in,theta_in]
%
% estimate linear transform parameters of the form
%
% [xp; yp] = [a cos theta, -b sin theta; a sin theta, b cos theta]*[x; y]
%
% where case_in is the case number, and a_in, b_in, theta_in are
% parameter inputs.
%
% case_in
%  1 : rotation-only (a=b=1)       a_in,b_in,theta_in ignored
%  2 : scaling and rotation (a=b)  a_in,b_in,theta_in ignored
%  3 : scaling (theta known)       a_in,b_in ignored
%  4 : scaling and rotation (b known) a_in,theta_in ignored
%  5 : scaling and rotation (a known) b_in,theta_in ignored
%
% optionally return matrix transformation M and its inverse Minv
%   [xp; yp] = M * [x; y]
%   [x; y] = Minv * [xp; yp]
% M = [a cos theta, -b sin theta; a sin theta, b cos theta]
% Minv = [b cos theta, b sin theta; -a sin theta, a cos theta]/(a b)

% written by DGL at BYU 10 Dec 2016

switch case_in
case 1  % rotation-only (a=b=1)
  a=1;
  b=1;
  theta=atan2(x*yp-xp*y,x*xp+y*yp);

case 2  % scaling and rotation (a=b)
  a=sqrt((xp^2+yp^2)/(x^2+y^2));
  b=a;
  theta=atan2(x*yp-xp*y,x*xp+y*yp);
  
case 3  % scaling (theta known)
  xy=x*y;
  if xy==0
    error('Cannot solve case 3 if x*y=0');
  end
  s=sin(theta_in);
  c=cos(theta_in);
  a=(c*y*xp+s*y*yp)/(x*y);
  b=(c*x*yp-s*x*xp)/(x*y);
  theta=theta_in;

case 4  % scaling and rotation (b known)
  if b_in==0
    error('Cannot solve case 4 if b_in=0');
  end
  b=b_in;
  t1=b*yp*y;
  t2=b^2*yp^2*y^2-(xp^2+yp^2)*(b^2*y^2-xp^2);
  cest1=(t1+sqrt(t2))/(xp^2+yp^2);
  cest2=(t1-sqrt(t2))/(xp^2+yp^2);
  sest1=real(sqrt(1-cest1^2));
  sest2=real(sqrt(1-cest2^2));
  err1a=abs(cest1*yp-b*y-sest1*xp);
  err1b=abs(cest1*yp-b*y+sest1*xp);
  err2a=abs(cest2*yp-b*y-sest2*xp);
  err2b=abs(cest2*yp-b*y+sest2*xp);
  err=[err1a err1b err2a err2b];
  eind=find(err<1.e-12);
  for ie=1:length(eind)
    switch eind(ie)
      case 1
	sest=sest1;
	cest=cest1;
      case 2
	sest=-sest1;
	cest=cest1;
      case 3
	sest=sest2;
	cest=cest2;
      case 4
	sest=-sest2;
	cest=cest2;
    end
    theta_est=atan2(sest,cest);
    if abs(sin(theta_est))>0.15
      beta_est=(yp-cos(theta_est)*b*y)/(b*x*sin(theta_est));
    else
      beta_est=(xp+sin(theta_est)*b*y)/(b*x*cos(theta_est));
    end
    if beta_est>0
      break;
    end
  end

  a=b*beta_est;
  theta=theta_est;

case 5  % scaling and rotation (a known)
  if a_in==0
    error('Cannot solve case 4 if a_in=0');
  end
  a=a_in;
  t1=a*x*yp;
  t2=a^2*x^2*yp^2-(xp^2+yp^2)*(a^2*x^2-xp^2);
  sest1=(t1+sqrt(t2))/(xp^2+yp^2);
  sest2=(t1-sqrt(t2))/(xp^2+yp^2);
  cest1=real(sqrt(1-sest1^2));
  cest2=real(sqrt(1-sest2^2));
  err1a=abs(a*x-sest1*yp-cest1*xp);
  err1b=abs(a*x-sest1*yp+cest1*xp);
  err2a=abs(a*x-sest2*yp-cest2*xp);
  err2b=abs(a*x-sest2*yp+cest2*xp);
  err=[err1a err1b err2a err2b];
  eind=find(err<1.e-12);
  for ie=1:length(eind)
    switch eind(ie)
      case 1
	sest=sest1;
	cest=cest1;
      case 2
	sest=sest1;
	cest=-cest1;
      case 3
	sest=sest2;
	cest=cest2;
      case 4
	sest=sest2;
	cest=-cest2;
    end
    theta_est=atan2(sest,cest);
    if abs(cos(theta_est))>0.15
      alpha_est=(yp-sin(theta_est)*a*x)/(a*y*cos(theta_est));
    else
      alpha_est=-(xp-cos(theta_est)*a*x)/(a*y*sin(theta_est));
    end
    if alpha_est>0
      break;
    end
  end
  b=a*alpha_est;
  theta=theta_est;
end

if nargout>0
  varargout{1} = [a*cos(theta), -b*sin(theta); a*sin(theta), b*cos(theta)];
  if nargout>1
    varargout{2} = [b*cos(theta), b*sin(theta); -a*sin(theta), a*cos(theta)]/(a*b);
  end
end
