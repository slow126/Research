function out = indshift2d(dim,ind,m,n)
%
% out = indshift2d(dim,ind,m,n)
%
% circulantly shifts the matlab indices ind (that correspond to)
% a matrix of size dim) by the values m,n. (r=r+m, c=c+n)
%
M=dim(1);
N=dim(2);

[X Y]=ind2sub(dim,ind);
X=X+m;
Y=Y+n;

in=find(X<1);
if ~isempty(in)
  X(in)=X(in)+M;
  in=find(X<1);
  if ~isempty(in)
    X(in)=X(in)+M;
  end
end
in=find(X>M);
if ~isempty(in)
  X(in)=X(in)-M;
  in=find(X>M);
  if ~isempty(in)
    X(in)=X(in)-M;
  end
end

in=find(Y<1);
if ~isempty(in)
  Y(in)=Y(in)+N;
  in=find(Y<1);
  if ~isempty(in)
    Y(in)=Y(in)+N;
  end
end
in=find(Y>N);
if ~isempty(in)
  Y(in)=Y(in)-N;
  in=find(Y>N);
  if ~isempty(in)
    Y(in)=Y(in)-N;
  end
end

out=sub2ind(dim,X,Y);
