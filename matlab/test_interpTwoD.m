% test upsampling of 2d complex signal using interpTwoD.m

% create band limited complex test signal
N1=50; N2=60;  % number of points
N1=49; N2=59;  % number of points
L1=8; L2=12;   % bandlimit
%
% create random complex signal
S1=rand([N1,N2])-0.5+j*(rand([N1,N2])-0.5);
% ideal low pass filter
Sf=fft2(S1);
Sf(L1+2:N1-L1,:)=0;
Sf(:,L2+2:N2-L2)=0;
S=ifft2(Sf)*sqrt(N1*N2/(L1*L2))/2; % ideally lowpass filtered signal
% amplitude scale factor added for convenience

r=0:size(S,1)-1; % axes
c=0:size(S,2)-1;

% plot real part of original signal
myfigure(2);
imagesc(c,r,real(S),[-1 1]); colorbar;
axis xy
hold on; contour(c,r,real(S),[0.5 0.5],'k'); hold off
hold on; contour(c,r,real(S),[0 0],'r'); hold off
hold on; contour(c,r,real(S),[-0.5 -0.5],'w'); hold off

% dimension upscaling factors
Ur=2; Uc=3;

% upscale interpolation
%Sout=interpTwoD(m,ur,uc);
[Sout,ri,ci]=interpTwoD(S,Ur,Uc,r,c);

% plot real part of upsampled signal
myfigure(22);
imagesc(ci,ri,real(Sout),[-1 1]); colorbar;
axis xy
hold on; contour(ci,ri,real(Sout),[0.5 0.5],'k'); hold off
hold on; contour(ci,ri,real(Sout),[0 0],'r'); hold off
hold on; contour(ci,ri,real(Sout),[-0.5 -0.5],'w'); hold off
