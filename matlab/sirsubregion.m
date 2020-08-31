function [imgout, headout]=sirsubregion(img, head, LLx, LLy, URx, URy, flg)
%
%   [imgout, headout]=sirsubregion(img, head, LLx, LLy, URx, URy, flg)
%
% extract a subimage from an existing image based on corner locations
%
% img:        image array
% head:       header information block
% LLx, LLy:   lower-left corner (lon, lat or xpix, ypix)
% URx, URy:   upper-right corner (lon, lat or xpix, ypix)
% flg:        (optional, def=0) corner type 0=lat,lon; 1=xpix,ypix
%
% notes: corners (converted to pixels if necessary) are clipped to image size

% written 27 Feb 2018 by DGL

if nargin<6
  error('sirsubregion requires a minimum of 6 arguments');
end

pflag=0;
if nargin > 6
  pflag=flg;
end

nsx    = head(1);
nsy    = head(2);
xdeg   = head(3);
ydeg   = head(4);
ascale = head(6);
bscale = head(7);
a0     = head(8);
b0     = head(9);
iopt   = head(17);

headout=head;
nsx2=nsx;
nsy2=nsy;
xdeg2=xdeg;
ydeg2=ydeg;
a02=a0;
b02=b0;

if pflag==0 % convert lat/lon to pixels
  %fprintf("%f %f %f %f\n",LLx,LLy, URx,URy);
  [LLx, LLy] = latlon2pix1(LLx,LLy,head);
  [URx, URy] = latlon2pix1(URx,URy,head);
  %fprintf("%f %f %f %f\n",LLx,LLy, URx,URy);
end

llx=floor(min(LLx,URx)+0.0002);
lly=floor(min(LLy,URy)+0.0002);
urx=floor(max(LLx,URx)+0.0002);
ury=floor(max(LLy,URy)+0.0002);
if llx<1
  llx=1;
end
if lly<1
  lly=1;
end
if urx>nsx
  urx=nsx;
end
if ury>nsy
  ury=nsy;
end

nsx2=urx-llx+1;
nsy2=ury-lly+1;
%fprintf("%d %d  %d %d  %d %d\n",llx,lly, urx,ury, nsx2,nsy2);

lly1=nsy-ury+1; % convert from matlab coordinates to SIR coordinates

switch (iopt)
  case -1  % image only
    a02 = (llx - 1) * xdeg / nsx + a0;
    b02 = (lly1 - 1) * ydeg / nsy + b0;
    xdeg2 = nsx2 * xdeg / nsx;
    ydeg2 = nsy2 * ydeg / nsy;
  case 0   % lat/lon
    a02 = (llx - 1) * xdeg / nsx + a0;
    b02 = (lly1 - 1) * ydeg / nsy + b0;
    xdeg2 = nsx2 * xdeg / nsx;
    ydeg2 = nsy2 * ydeg / nsy;
  case 1   % Lambert
    a02 = (llx - 1) / ascale + a0;
    b02 = (lly1 - 1) / bscale + b0;
  case 2   % Lambert
    a02 = (llx - 1) / ascale + a0;
    b02 = (lly1 - 1) / bscale + b0;
  case 5   % polar stereographic
    a02 = (llx - 1) * ascale + a0;
    b02 = (lly1 - 1) * bscale + b0;
  case 8   % EASE2 grid
    a02 = a0 + (llx - 1);
    b02 = b0 + (lly1 - 1);
  case 9   % EASE2 grid
    a02 = a0 + (llx - 1);
    b02 = b0 + (lly1 - 1);
  case 10  % EASE2 grid
    a02 = a0 + (llx - 1);
    b02 = b0 + (lly1 - 1);
  case 11  % EASE1 grid
    a02 = a0 + (llx - 1);
    b02 = b0 + (lly1 - 1);
  case 12  % EASE1 grid
    a02 = a0 + (llx - 1);
    b02 = b0 + (lly1 - 1);
  case 13  % EASE1 grid
    a02 = a0 + (llx - 1);
    b02 = b0 + (lly1 - 1);
  otherwise% unknown
    a02 = (llx - 1) * xdeg / nsx + a0;
    b02 = (lly1 - 1) * ydeg / nsy + b0;
    xdeg2 = nsx2 * xdeg / nsx;
    ydeg2 = nsy2 * ydeg / nsy;
end

headout(1)=nsx2;
headout(2)=nsy2;
headout(3)=xdeg2;
headout(4)=ydeg2;
headout(8)=a02;
headout(9)=b02;

imgout=img(lly:ury,llx:urx);
