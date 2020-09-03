%
% routine to test the interpDn function
%
% create band limited complex test signal
N=128; % number of points
Nl=32; % bandlimit
%
% random complex signal
S1=rand([1,N])-0.5+j*(rand([1,N])-0.5);
% ideal low pass filter
Sf=fft(S1);
Sf(Nl+2:N-Nl)=0;
S=ifft(Sf); % ideally lowpass filtered signal
% ideal complex band pass filter
Sf=fft(S1);
Sf(1:Nl+1)=0;
Sf(N-Nl+1:N)=0;
Sb=ifft(Sf); % ideally bandpass filtered signal
%
if 0
  myfigure(1)
  plot(real(S1),'b');
  hold on; plot(real(S),'r'); hold off
  hold on; plot(imag(S1),'c'); hold off
  hold on; plot(imag(S),'g'); hold off
end
%
% generate interpolated signal
T=(0:N-1);
Tout=(0:4*N-4)/4;
% low pass
Sout=interpDn(S,Tout);
% plot results
if 1
  myfigure(2)
  plot(T,real(S),'b');
  hold on; plot(Tout,real(Sout),'r'); hold off
  myfigure(3)
  plot(T,imag(S),'c');
  hold on; plot(Tout,imag(Sout),'g'); hold off
end

% bandpass
Sout=interpDn(Sb,Tout,0.5);
% plot results
if 1
  myfigure(4)
  plot(T,real(Sb),'b');
  hold on; plot(Tout,real(Sout),'r'); hold off
  myfigure(5)
  plot(T,imag(Sb),'c');
  hold on; plot(Tout,imag(Sout),'g'); hold off
end


