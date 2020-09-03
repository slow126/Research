% demonstrates the relationship between meshgrid and sub2ind

m=4;
n=6;
t=zeros([m n]);
[Y X]=meshgrid(1:m,1:n);
ind=find(X > 0 & X <= n & Y > 0 & Y <= m);
ind2=sub2ind([m n],Y,X);
ind3=reshape(ind2',length(ind),1);

[max(max(ind-ind3)) min(min(ind-ind3))]
[ind ind3]'
[max(max(ind-ind3)) min(min(ind-ind3))]


% fancy case with indexing

X=reshape(X',m*n,1);
Y=reshape(Y',m*n,1);

ind=find(X > 0 & X <= n & Y > 0 & Y <= m);

X=X(ind);
Y=Y(ind);

[length(ind) m*n]

ind2=sub2ind([m n],Y,X);
ind3=reshape(ind2,length(ind),1);

[max(max(ind-ind3)) min(min(ind-ind3))]
[ind ind3]'
[max(max(ind-ind3)) min(min(ind-ind3))]
