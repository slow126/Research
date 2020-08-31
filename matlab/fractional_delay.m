function out=fractional_delay(in,sh)
%
% function out=fractional_delay(in,sh)
%
% does a factional sample (sh) delay of input signal (in)
%
M=length(in);
if M/2==floor(M/2)  % even case
  freq=2*pi*[0:M/2-1 -M/2:-1]/M;
else               % odd case
  freq=2*pi*[0:floor(M/2) -floor(M/2):-1]/M;
end
out=real(ifft(fft(in).*exp(-j*sh*freq)));

