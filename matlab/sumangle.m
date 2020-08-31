function out = sumangle(in1,in2);
% sumangle calculates the sum (in1+in2) of two sets of angles
% (in degrees), modulo 360.  Result in the range [0,360].
%
% Usage: out = sumangle(in1,in2)
%
% in1 and in2 are vectors or matrices of angles.  They must be the same shape.
% out is the sum of the angles and is the same shape as the input.
%
% Written by D.G. Long, 29 Nov 2017

if size(in1) ~= size(in2)
  error('input must be the same size');
end

out=mod(in1+in2,360);
