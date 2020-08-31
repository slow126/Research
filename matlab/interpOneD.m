function [Sout varargout]=interpOneD(Sin,ci,varargin)
%
% function Sout=interpOneD(Sin,ci);
% function [Sout,cout]=interpOneD(Sin,ci,cin);
%
% complex fft2-based interpolation of a nominally 1d 
% periodic function Sin of length N to length N*abs(ci)
% optionally, the function can return interpolated linear axes variables
% if ci<0, signal interpolation separately handles linear trend

% written by DGL at BYU 22 Jul 2016
% revised by DGL at BYU 28 Jul 2016 + separately handle linear trend/mean
%
c=length(Sin);
uc1=floor(c*(abs(ci)-1)/2);
uc =floor(c*(abs(ci)-1)/2+0.5001);
  
if ci<0 % use separate linear trend processing and mean
  mS=mean(Sin);     % input signal mean
  mC=(c-1)/2;       % mC=mean(0:c-1);
  vC=c*(c^2-1)/12;  % vC=sum(((0:c-1)-mC).^2)
  dS=((0:c-1)-mC)*(Sin(:)-mS)/vC; % input signal slope 
  lineartrend=dS*((0:c-1)-mC)+mS;
  newlineartrend=dS*((0:abs(ci)*c-1)/abs(ci)-mC)+mS;
else    % do not include separate linear trend processing
  lineartrend=0;
  newlineartrend=0;
end

Smean=mean(Sin(:)-lineartrend(:));

if 0 % use ifft first
  % compute iFFT
  % note: ifft is functionally equivalent to fft but does not require scaling
  fm=fftshift(ifft(Sin(:)-lineartrend(:)-Smean));

  % zero pad in time domain
  fm2=[zeros([uc 1]); ...
       fm; ...
       zeros([uc1 1])];  

  if c/2==floor(c/2) % even case
    tmp=fm2(uc1+1)*0.5;
    fm2(uc1+1)=tmp;
    fm2(uc1+c+1)=tmp';
  end

  % compute inverse 2d FFT
  Sout=fft(ifftshift(fm2))+newlineartrend(:)+Smean;

else % use fft first
  % compute FFT
  fm=fftshift(fft(Sin(:)-lineartrend(:)-Smean));

  % zero pad in frequency domain
  fm2=[zeros([uc 1]); ...
       fm; ...
       zeros([uc1 1])];  

  if c/2==floor(c/2) % handle even case
    tmp=fm2(uc+1)*0.5;
    fm2(uc+1)=tmp;
    fm2(uc+c+1)=tmp';
  end
 
  % compute inverse 2d FFT and scale
  Sout=ifft(ifftshift(fm2))*abs(ci)+newlineartrend(:)+Smean;
end  

% reshape output to match input
if size(Sin,2) > size(Sin,1)
  Sout=Sout.';
end

if isreal(Sin) % if input is real, make output strictly real
  %if norm(imag(Sout))>.01
  %  norm(imag(Sout))
  %  keyboard
  %end
  Sout=real(Sout);
end

if 1 % force interpolation to be absolutely exact at input points
     % not essential but improves apparent numerical accuracy
  ind=1:abs(ci):c*abs(ci);
  Sout(ind)=Sin;
end

% handle optional axes argument, which is assumed to be linear and
% equally spaced
if nargin>2 & nargout>1  
  v=varargin{1};
  nv=length(v);
  mv=mean(v);
  mC=(nv-1)/2;        % mean(0:nv-1);
  vC=nv*(nv^2-1)/12;  % vC=sum(((0:nv-1)-mC).^2)
  dv=((0:nv-1)-mC)*(v(:)-mv)/vC;
  vout=dv*((0:abs(ci)*nv-1)/abs(ci)-mC)+mv;
  varargout{1}=vout;
end