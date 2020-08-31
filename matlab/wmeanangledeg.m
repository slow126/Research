function out = wmeanangledeg(in,dim,sens,weight);
%
% WMEANANGLE calculates the mean of a set of angles (in degrees)
%
% Usage: out = wmeanangle(in,dim)
%
% in is a vector or matrix of angles (in degrees)
% out is the mean of these angles along the dimension dim (in degrees)
%
% If dim is not specified, the first non-singleton dimension is used.
%
% A sensitivity factor is used to determine oppositeness, which is how close
% the mean of the complex representations of the angles is to zero
% before being called zero.  The default is (1e-12), which is
% satisfactory in most cases but it can be readjusted via a third
% parameter if desired:
%
% out = wmeanangle(in,dim,sensitivity)
%
% a weighted mean average can be specifieas where w is the same size as in
%
% out = wmeanangle(in,dim,sensitivity,w)
%

% Written by J.A. Dunne, 10-20-05
% Modified by D.G. Long, 11-27-17 

if nargin<4
  weight=ones(size(in));
end

if nargin<3
    sens = 1e-12;
end

if nargin<2
    ind = min(find(size(in)>1));
    if isempty(ind)
        % scalar case
        out = in;
        return
    end
    dim = ind;
end

in = exp(i*in*pi/180).*weight;
mid = mean(in,dim)./mean(weight,dim);
out = atan2(imag(mid),real(mid))*180/pi;
out(abs(mid)<sens) = nan;
