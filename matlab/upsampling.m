function out=upsampling(in,N)
%
% out=upsampling(in,N)
%
% increase the sampling rate of a real signal in by a factor N
%

% written by DGL 23 Nov. 2006

[m n]=size(in);
if m > n
  SZ=[N*m n];
else
  SZ=[m N*n];
end
n=length(in(:));
n2=floor(n/2);
if n2==n/2
  n0=1;
else
  n0=0;
end
n2=n2-1; % add a bit of ideal LPF
fin=fft(in(:));
fin2=zeros(SZ);
nn=length(fin2(:));
fin2(1:n2)=fin(1:n2);
fin2(nn-n2+n0:nn)=fin(n-n2+n0:n);
if n2==n/2  % to handle even number of samples
  fin2(n2+1)=0.5*real(fin(n2+1));
  fn2(nn-n2)=0.5*real(fin(n2+1));
end
out=ifft(N*fin2,'symmetric');
