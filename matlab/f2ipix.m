function [ix,iy]=f2ipix(x,y,head);
% quantizes the floating point pixel location to the actual pixel value
%      returns a zero if location is outside of image limits
%      a small amount (0.002 pixels) of rounding is permitted

nsx=head(1);
nsy=head(2);

ix=floor(x+0.0002);
ix(ix<1)=1;
ix(ix>nsx)=nsx;

iy=floor(y+0.0002);
iy(iy<1)=1;
iy(iy>nsy)=nsy;