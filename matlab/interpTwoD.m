function [Sout varargout]=interpTwoD(Sin,ri1,ci1,varargin)
%
% function Sout=interpTwoD(Sin,ri,ci);
% function [Sout,rout,cout]=interpTwoD(Sin,ri,ci,rin,cin);
%
% complex fft2-based interpolation of 2d periodic function Sin
% of size N1 x N2 to size N1*ri x N2*ci
% optionally, the function can also return interpolated 
% row and column axes variables
% if ri and ci are negative, absolute value used for interpolation
% after first removing of linear trend from signal, which restored
% after interpolation

% written by DGL at BYU 21 Jul 2016
% revised by DGL at BYU 28 Jul 2016 + separately handle linear trend/mean
%
ri=abs(ri1);
ci=abs(ci1);
[r,c]=size(Sin);

% general even or odd case
ur1=floor(r*(ri-1)/2);ur=floor(r*(ri-1)/2+0.5001);
uc1=floor(c*(ci-1)/2);uc=floor(c*(ci-1)/2+0.5001);
%[ur ur1 uc uc1 ri ci r r*ri c c*ci]

if ri1<0 | ci1<0  % use separate linear trend processing and mean
  mS=mean(Sin(:));  % input signal mean
  mC=(c-1)/2;       % mC=mean(0:c-1);
  mR=(r-1)/2;       % mR=mean(0:r-1);
  [C,R]=meshgrid((0:c-1)-mC,(0:r-1)-mR);
  P=polyfit2d(C(:),R(:),Sin(:)-mS,1,1);
  lineartrend=polyval2d(P,C,R);
  [C,R]=meshgrid((0:ci*c-1)/ci-mC,(0:ri*r-1)/ri-mR);
  newlineartrend=polyval2d(P,C,R);
  clear C R
else    % do not include separate linear trend processing
  lineartrend=0;
  newlineartrend=0;
end

Smean=mean(Sin(:)-lineartrend(:));
Smean=0;

if 0 % use ifft first
  % compute 2d iFFT
  % note: ifft is functionally equivalent to fft and is used here 
  % because we are often working with LFMCW SAR data for which
  % this is a natural choice.  Also, scaling is not required.
  fm=fftshift(ifft2(Sin-lineartrend-Smean));

  % zero pad in time domain
  fm2=[zeros([ur c*ci]); ...
       zeros([r uc]) fm zeros([r uc1]); ...
       zeros([ur1 c*ci])];  
  
  if c/2==floor(c/2) % handle even cols case
    tmpc=fm2(:,uc+1)*0.5;
    fm2(:,uc+1  )=tmpc;
    fm2(:,uc+c+1)=tmpc.';
  end
  if r/2==floor(r/2) % handle even rows case
    tmpr=fm2(ur+1,:)*0.5;
    fm2(ur+1,  :)=tmpr;
    fm2(ur+r+1,:)=tmpr.';
  end  
  if c/2==floor(c/2) & r/2==floor(r/2) % handle both even cols and rows 
    fm2(ur+1,  uc+1  )=fm(1,1)*0.25;
    fm2(ur+r+1,uc+1  )=fm(1,1)*0.25;
    fm2(ur+r+1,uc+c+1)=fm(1,1)*0.25;
    fm2(ur+1,  uc+c+1)=fm(1,1)*0.25;
  end
 
  % compute inverse 2d FFT
  Sout=fft2(ifftshift(fm2))+newlineartrend+Smean;

else % use fft first
  % compute 2d FFT
  fm=fftshift(fft2(Sin-lineartrend-Smean));

  % zero pad in frequency domain
  fm2=[zeros([ur c*ci]); ...
       zeros([r uc]) fm zeros([r uc1]); ...
       zeros([ur1 c*ci])];  
    
  if c/2==floor(c/2) % handle even cols case
    tmpc=fm2(:,uc+1)*0.5;
    fm2(:,uc+1  )=tmpc;
    fm2(:,uc+c+1)=tmpc.';
  end
  if r/2==floor(r/2) % handle even rows case
    tmpr=fm2(ur+1,:)*0.5;
    fm2(ur+1,  :)=tmpr;
    fm2(ur+r+1,:)=tmpr.';
  end  
  if c/2==floor(c/2) & r/2==floor(r/2) % handle both rows and cols even case
    fm2(ur+1,  uc+1  )=fm(1,1)*0.25;
    fm2(ur+r+1,uc+1  )=fm(1,1)*0.25;
    fm2(ur+r+1,uc+c+1)=fm(1,1)*0.25;
    fm2(ur+1,  uc+c+1)=fm(1,1)*0.25;
  end
 
  % compute inverse 2d FFT and scale
  Sout=ifft2(ifftshift(fm2))*ri*ci+newlineartrend+Smean;  
end  

if isreal(Sin) % if input is real, make output strictly real
 %if norm(imag(Sout(:)))>.01
  %  norm(imag(Sout(:)))
  %  keyboard
  %end
  Sout=real(Sout);
end

% handle optional axes arguments, which are assumed to be linear and
% equally spaced
if nargin>3 & nargout>1  
  v=varargin{1};
  nv=length(v);
  mv=mean(v);
  mC=(nv-1)/2;        % mean(0:nv-1);
  vC=nv*(nv^2-1)/12;  % vC=sum(((0:nv-1)-mC).^2)
  dv=((0:nv-1)-mC)*(v(:)-mv)/vC;
  vout=dv*((0:abs(ri)*nv-1)/abs(ri)-mC)+mv;
  
  varargout{1}=vout;
  v=varargin{2};
  nv=length(v);
  mv=mean(v);
  mC=(nv-1)/2;        % mean(0:nv-1);
  vC=nv*(nv^2-1)/12;  % vC=sum(((0:nv-1)-mC).^2)
  dv=((0:nv-1)-mC)*(v(:)-mv)/vC;
  vout=dv*((0:abs(ci)*nv-1)/abs(ci)-mC)+mv;  
  varargout{2}=vout;
end