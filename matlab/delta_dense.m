function [rout,cout]=delta_dense(h)
%
% function [rout,cout]=delta_dense(h)
%
% compute array of delta dense values for each element of matrix h
% that has elements 0 or non-zero to indicate a sample location
% outputs are the vertical and horizontal deltas for each sample 
% location and zero otherwise
%

% written 15 Mar 2016 by DGL at BYU 
%
% matlab notes
%  add(r,c)=(c-1)*Nc+r for [Nr,Nc]=size(array) [r,c]=ind2sub([Nr,Nc],s)
% to illustrate: 
%>>q=[11 12; 21 22; 31 32]
%q =
%    11    12
%    21    22
%    31    32
%>> q(:)
%ans =
%    11
%    21
%    31
%    12
%    22
%    32
%>> [r,c]=ind2sub([Nr,Nc],1:length(q(:)))
%r =
%     1     2     3     1     2     3
%c =
%     1     1     1     2     2     2

if 0 % generate a test input data set
  h=zeros([15,15]);
  N=floor(prod(size(h))/10);
  sloc=floor(rand([N 1])*length(h(:))+1);
  h(sloc)=1;
end

[Nr,Nc]=size(h);
s=find(h>0);
N=length(s);
[r,c]=ind2sub([Nr,Nc],s);

if 0 % show input, check locations
  myfigure(1)
  imagesc(h)
  
  hold on;
  out=zeros([Nr,Nc]);
  for k=1:N  
    plot(c(k),r(k),'k+');
  end
  hold off
end

maxd=min(Nr,Nc)/2;

rout=zeros([Nr,Nc]);
cout=zeros([Nr,Nc]);
for k=1:N  
  flg=0;
  for d=1:maxd
    cr=[max(c(k)-d,1):min(c(k)+d,Nc)];
    if r(k)-d>0
      if length(find(h(r(k)-d,cr)>0))>0
	flg=d;
	break;
      end
    end
    if r(k)+d<=Nr
      if length(find(h(r(k)+d,cr)>0))>0
	flg=d;
	break;
      end
    end
  end
  cout(s(k))=flg;
  flg=0;
  for d=1:maxd    
    rc=[max(r(k)-d,1):min(r(k)+d,Nr)];
    if c(k)-d>0
      if length(find(h(rc,c(k)-d)>0))>0
	flg=d;
	break;
      end
    end
    if c(k)+d<=Nc
      if length(find(h(rc,c(k)+d)>0))>0
	flg=d;
	break;
      end
    end  
  end
  rout(s(k))=flg;
end

if 0 % display output
  myfigure(2)
  imagesc(rout);colorbar
  myfigure(3)
  imagesc(cout);colorbar
  tmp=max(rout,cout);
  myfigure(4)
  imagesc(tmp);colorbar
end