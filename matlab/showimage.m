function showimage(array_in,min1,max1)
%
% function showimage(array_in,min,max)   (min,max optional)
%
% display scaled image of array_in
%

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

clf;
image((array_in-small)*scale);
hold on;
axis image;
h=gca;
axis('off');
hand=sircolorbar('horiz',small,large);
%hand=colorbar('horiz');
%axes(hand);
%axis off;
%axes(h);
colormap('gray');
hold off;
