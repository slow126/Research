function [out hout]=grd2non(in,hin)
%
% function [out hout]=grd2non(in<,hin>)
%
% pixel replicates the input array in to convert a 'grd' .sir file image
% to its 'non' (10 times) larger equivalent.  Optionally converts the
% matlab .sir header array
%

% written 7 Aug 2009 by DGL at BYU

% copy image data
N=10; % pixel replication factor
out=zeros(size(in)*N);
[i j]=ind2sub(size(in),1:prod(size(in)));
for x=1:N
  for y=1:N
    ind2=sub2ind(size(out),(i-1)*N+x,(j-1)*N+y);
    out(ind2)=in;
  end
end

% if header is input, modify and return
if exist('hin')
  hout=setsirhead('nsx',hin,N*sirheadvalue('nsx',hin));
  hout=setsirhead('nsy',hout,N*sirheadvalue('nsy',hout));
end

