function out=myfilter2(A,B)
%
% Returns A*B where size(A)<size(B) such that the
% boundary region is resonable
%

% written DGL 9/5/2011

asize=size(A);
if mod(asize(1),2)==1
  asize(1)=asize(1)+1;
end
if mod(asize(2),2)==1
  asize(2)=asize(2)+1;
end
bsize=size(B);
Ap=zeros([asize(1)+bsize(1) asize(1)+bsize(2)]);
a1=asize(1)/2;
a2=asize(2)/2;
Ap(a1+1:a1+bsize(1),a2+1:a2+bsize(2))=B;
Ap(1:a1,:)=Ap(a1+(a1:-1:1),:);
Ap(:,1:a2)=Ap(:,a2+(a2:-1:1),:);
Ap(a1+bsize(1)+1:asize(1)+bsize(1),:)=Ap(a1+bsize(1):-1:bsize(1)+1,:);
Ap(:,a2+bsize(2)+1:asize(2)+bsize(2))=Ap(:,a2+bsize(2):-1:bsize(2)+1);

out=filter2(A,Ap,'same');
out=out(a1+1:a1+bsize(1),a2+1:a2+bsize(2));