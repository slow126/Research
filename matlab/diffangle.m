function out = diffangle(in1,in2);
% diffangle calculates the difference (in1-in2) between two sets of 
% angles (in degrees). The difference angle is defined to be the
% smaller of the two possible angles, with the appropriate sign
% The result in the range (-180,180].
%
% Usage: out = diffangle(in1,in2)
%
% in1 and in2 are vectors or matrices of angles.  They must be the same shape.
% out is the difference of the angles and is the same shape as the input.
%
% When only a single vector argument is supplied,
%
% out = diffangle(in1)
%
% diffangle computes [in1(2)-in1(1) in1(3)-in1(1) ...] (see diff) of
% the angles in degrees
%
% Written by D.G. Long, 29 Nov 2017
sens=1.e-12;

if nargin > 1 % compute difference between two inputs

  if size(in1) ~= size(in2)
    error('input must be the same size');
  end

  % unsigned angle difference
  out=180-abs(180-abs(mod(in1-in2,360)));
  
  % determine the angle sign
  a=abs(mod(in1,360)-mod(mod(in2,360)+out,360));
  out(~(a<sens))=-out(~(a<sens));

else % compute diff-like sequence
  
  % unsigned angle difference
  out=180-abs(180-abs(mod(in1(2:end)-in1(1:end-1),360)));
  
  % determine the angle sign
  a=abs(mod(in1(2:end),360)-mod(mod(in1(1:end-1),360)+out,360));
  out(~(a<sens))=-out(~(a<sens));

end