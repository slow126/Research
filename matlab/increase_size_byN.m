function [out hout]= increase_size_byN(in,N,hin)
%
% function [out hout]=increase_size_byN(in,N,<,hin>)
%
% pixel replicates the input array 'in' to make a larger array.
% Optionally converts the matlab .sir header array

% written 17 Aug 2009 by DGL at BYU

% copy image data
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

