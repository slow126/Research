function Sout=interpDn2d(Sin,T1,T2,WinOpt)
%
% function Sout=interpDn2d(Sin,T1,T2<,WinOpt>)
%
% complex interpolation of a 2d periodic signal Sin that is N1xN2
% evaluated at T1,T2 (0<=T1<N1,0<=T1<N2) using a 2d Dirchelet kernal.
% T1 and T2 can contain multiple elements, but must be the same size.
% When T1=0:0.5:N1-0.5 and T1=0:0.5:N2-0.5 Sout is a 1/2 sample
% interpolated version of Sin
%
% WinOpt is an optional (def=0) parameter that determines if the 
% interpolation is with an offset Dirchelet kernal (WinOpt>0) or
% not (WinOpt <=0). If abs(WinOpt)>1, a 1/2 cosine window is included
% to improve the computational accuracy

% written by DGL at BYU 20 Jul 2016

if ~exist('WinOpt')
  WIN=0;
  sh=0;
else
  WIN=abs(WinOpt);
  sh=sign(WinOpt);
end

[N1,N2]=size(Sin);
[t1,t2]=size(T1);
Sout=zeros(size(T1));

N11=-N1/2; N12=N1/2;
N21=-N2/2; N22=N2/2;
%[N1 N11 N12 N2 N21 N22]

% could be vectorized and so be faster...
for k1=1:t1
  for k2=1:t2  
    darg1=(0:N1-1)'-T1(k1,k2);
    darg1=mod(darg1,N1);
    darg1(darg1>N12)=darg1(darg1>N12)-N1;
    darg1(darg1<N11)=darg1(darg1<N11)+N1;  
    darg2=(0:N2-1)-T2(k1,k2);
    darg2=mod(darg2,N2);
    darg2(darg2>N22)=darg2(darg2>N22)-N2;
    darg2(darg2<N21)=darg2(darg2<N21)+N2;  
    if WIN>1
      if sh>0
	Sw=(Dm(darg1/N1,N1).*cos(pi*darg1/N1).*exp(-j*pi*darg1))*(Dm(darg2/N2,N2).*cos(pi*darg2/N2).*exp(-j*pi*darg2)); 
      else
	Sw=(Dm(darg1/N1,N1).*cos(pi*darg1/N1))*(Dm(darg2/N2,N2).*cos(pi*darg2/N2)); 
      end
    else
      if sh>0
	Sw=(Dm(darg1/N1,N1).*exp(-j*pi*darg1))*(Dm(darg2/N2,N2).*exp(-j*pi*darg2)); 
      else
	Sw=Dm(darg1/N1,N1)*Dm(darg2/N2,N2); 
      end
   end
   Sout(k1,k2)=sum(sum(Sin.*Sw));
  end
end
return
end

function out=Dm(x,N)
%
% function out=Dm(x,N)
%
% compute centered Dirichlet function when N is odd
%  out=sin(2*pi*x*N/2) / (N * sin(2*pi*x/2)) % N odd
% and uncentered Dirichlet function when N is even
%  out=cos(pi*x) * sin(2*pi*x*N/2) / (N * sin(2*pi*x/2)) % N even
% 
% x (float value) is typically 0..N-1
% N (integer value) is the period
%

% written by DGL at BYU 17 Aug 2016

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