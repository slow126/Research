function out=scaleimage(array_in,min1,max1)
%
% scaleimage(array_in,min,max)   (min, max optional)
%
% scale array_in for display using image:
%  use: image(scaleimage(array_in,min,max));
%       colormap('gray'); colorbar; axis('off');

if (exist('min1') == 1)
  small=min1;
  if (exist('max1') == 1)
    large=max1;
  else
    large=max(max(array_in));
  end;
else
  small=min(min(array_in));
  large=max(max(array_in));
end;

scale=large-small;
if scale == 0
  scale = 1;
end
scale=64/scale;
%[small large scale]

out=(array_in-small)*scale;
