function delta=deltad(array,conv_type)
%
% function delta = deltad(array <,conv_type>)
%
%  array : 2d sampling matrix (0 or 1, with 1 indicating sample location)
%  conv_type: optional convolution type flag
%     (0 or absent) = linear (non-periodic signal, edges not considered)
%     (1) = circular convolution (periodic signal)
%
% Computes the delta-dense parameter for the non-zero entries of array.
% returns the smallest delta (in pixels) such that a squares with
% dimension 2*delta+1 centered at the non-zero entries of array
% completely span the array.  (The computational method used in this
% routine can be a time consuming task for large arrays.)
%
% Note: when the sampling is uniform with circular convotion, the
% returned delta value may seem one smaller than intuition might 
% expect, but the returned value is correct.

% Written by DGL  3 Mar 1999
% Revised by DGL 23 Nov 2018 + support linear or circular convolution

conv_flag=0;
if nargin > 1
  if conv_type == 1
    conv_flag=1;
  end
end

[m n]=size(array);
N=min(m,n);

B=zeros(size(array));
B(find(array~=0))=1;

for j=0:N
  s=2*j+1;
  box=ones([s s]);

  if conv_flag 
    Bbox=zeros(size(B));
    Bbox(1:size(box,1),1:size(box,2))=box;
    Bbox=shift2d(Bbox,-j,-j);
    A=ifft2(fft2(Bbox).*fft2(B)); % circular convolution
  
    %myfigure(5); imagesc(Bbox); title(sprintf('Box size %d',j));
    %myfigure(6); imagesc(A,[0,1]); title(sprintf('Box size %d',j));
    %disp('pausing...');pause; disp('continuing...');
  
  else
    A=conv2(box,B);  A=A(j+1:m+s-j-1,j+1:n+s-j-1); % linear convolution
  end 
  
  %if isempty(find(A==0))
  if isempty(find(A<0.25)) % allow for some numerical error
    break;
  end
end

delta=j;

