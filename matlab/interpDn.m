function Sout=interpDn(Sin,Tout,WinOpt)
%
% function Sout=interpDn(Sin,Tout<,WinOpt>)
%
% complex interpolation of a periodic signal Sin that is N points long
% evaluated at Tout (0<=Tout<N) using a Dirchelet kernal.  If Sin is
% a matrix, the interpolation is done within a row, with an output for
% each column.  Tout can contain multiple elements.  For example, 
% Tout=0:0.5:N-0.5, Sout is a 1/2 sample interpolated version of Sin
%
% WinOpt is an optional (def=0) parameter that determines if the 
% interpolation is with an offset Dirchelet kernal (WinOpt>1) or
% not (WinOpt <=0). If abs(WinOpt)>1, a 1/2 cosine window is included
% to improve the computational accuracy

% written by DGL at BYU 27 Feb 2008
% revised by DGL at BYU 10 Aug 2016 + handle even number of points

if ~exist('WinOpt')
  WIN=0;
  sh=0;
else
  WIN=abs(WinOpt);
  sh=sign(WinOpt);
end

[N,M]=size(Sin);
if N==1 & M>0
  N=M;
  M=1;
end
n=length(Tout);

N2=N/2;
for k=1:n
  darg=(0:N-1)-Tout(k);
  darg(darg>N2)=darg(darg>N2)-N;
  darg(darg<-N2)=darg(darg<-N2)+N;  
  if WIN>1
    Wwin=cos(pi*darg/N);
    if sh>0
      Sw=Dm(darg/N,N).*exp(-j*pi*darg).*Wwin; 
    else
      Sw=Dm(darg/N,N).*Wwin; 
    end
  else
    if sh>0
      Sw=Dm(darg/N,N).*exp(-j*pi*darg); 
    else
      Sw=Dm(darg/N,N); 
    end
  end
  if M>1
    for m=1:M
      Sout(k,m)=Sin(:,m)*Sw';
    end
  else
    Sout(k)=Sin(:).'*Sw';
  end
end
return
end


function out=Dm(x,N)
%
% compute centered Dirichlet function when N is odd
%  out=sin(2*pi*x*N/2) / (N * sin(2*pi*x/2)) % N odd
% and uncentered Dirichlet function when N is even
%  out=cos(pi*x) * sin(2*pi*x*N/2) / (N * sin(2*pi*x/2)) % N even
% 
% x (float value) is typically 0..N-1
% N (integer value) is the period
%

if 0 % this way is faster, but generates a divide by zero error message
  if N/2==floor(N/2) % N even
    out=sin(N*x*pi)./(N*sin(x*pi));
  else               % N odd
    out=cos(x*pi).*sin(N*x*pi)./(N*sin(x*pi));
  end
  ind=find(sin(x*pi)==0);
  out(ind)=1;
else % alternately, use this method to avoid divide by zero
  out=zeros(size(x));
  num=sin(N*pi*x);
  if N/2==floor(N/2) % N even
    num=cos(pi*x).*sin(N*pi*x);
  else               % N odd
    num=sin(N*pi*x);
  end
  denom=N*sin(pi*x);
  ind=find(denom~=0);
  out(ind)=num(ind)./denom(ind);
  ind=find(denom==0);
  out(ind)=1;
end

end