%
% routine to test the interpDn2d function
%
% create band limited complex test signal
N1=64; N2=128;  % number of points
Nl1=8; Nl2=16; % bandlimit
%
% random complex signal
S1=rand([N1,N2])-0.5+j*(rand([N1,N2])-0.5);
% ideal low pass filter
Sf=fft2(S1);
%%Sf(Nl1+2:N1-Nl1,Nl2+2:N2-Nl2)=0;
Sf(Nl1+2:N1-Nl1,:)=0;
Sf(:,Nl2+2:N2-Nl2)=0;
S=ifft2(Sf)*sqrt(N1*N2/(Nl1*Nl2))/2; % ideally lowpass filtered signal
                                     % w/scale factor
% generate interpolated signal
T1=(0:N1-1);  % rows (Y)
T2=(0:N2-1);  % cols (X)
To1=(0:4*N1-1)/4;
To2=(0:3*N2-1)/3;
[Tout2 Tout1]=meshgrid(To2,To1);
% low pass
Sout=interpDn2d(S,Tout1,Tout2,-0.5);
% plot results
if 1
  myfigure(2)
  subplot(1,2,1);
  imagesc(T2,T1,real(S),[-1, 1]); axis xy;
  subplot(1,2,2);
  imagesc(To2,To1,real(Sout),[-1, 1]); axis xy;
  hold on; contour(To2,To1,real(Sout),[0.5,0.5],'k'); hold off
  hold on; contour(To2,To1,real(Sout),[0,0],'r'); hold off
  hold on; contour(To2,To1,real(Sout),[-0.5,-0.5],'w'); hold off
  myfigure(3)
  subplot(1,2,1);
  imagesc(T2,T1,imag(S),[-1, 1]); axis xy;
  subplot(1,2,2);
  imagesc(To2,To1,imag(Sout),[-1, 1]); axis xy;
end

if 0 % band pass
  % ideal complex bandpass filter
  Sb=fft2(S1);
  Sf=zeros(size(Sb));
  Sf(Nl1+2:N1-Nl1,Nl2+2:N2-Nl2)=Sb(Nl1+2:N1-Nl1,Nl2+2:N2-Nl2);
  Sb=ifft2(Sf)*sqrt(N1*N2/(Nl1*Nl2))/2; % ideally bandpass filtered signal
  % generate interpolated signal
  Sout=interpDn2d(Sb,Tout1,Tout2,0.5);
  % plot results
  myfigure(4)
  subplot(1,2,1);
  imagesc(T2,T1,real(Sb),[-1, 1]); axis xy;
  subplot(1,2,2);
  imagesc(To2,To1,real(Sout),[-1, 1]); axis xy;
  myfigure(5)
  subplot(1,2,1);
  imagesc(T2,T1,imag(Sb),[-1, 1]); axis xy;
  subplot(1,2,2);
  imagesc(To2,To1,imag(Sout),[-1, 1]); axis xy;
end
