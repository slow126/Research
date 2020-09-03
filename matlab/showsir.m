function showsir(array_in,head,min1,max1)
%
% function showsir(array_in,head,min1,max1)
%
% function to display sir image 
%

if (exist('head') == 1)
  small=head(50);
  large=head(51);
  if (large == small)
    small=min(min(array_in));
    large=max(max(array_in));
  end;
  if (exist('min1') == 1)
    small=min1;
    if (exist('max1') == 1)
      large=max1;
    end;
  end;
  printsirhead(head);
  title1(80)=0;
  for i=1:40
    j=(i-1)*2+1;
    title1(j)=(mod(head(i+128),256));
    title1(j+1)=floor(head(i+128)/256);
  end;
  title1=deblank(setstr(title1));
else
  small=min(min(array_in));
  large=max(max(array_in));
  title1=' ';
end;

scale=large-small;
if scale == 0
  scale = 1;
end
scale=64/scale;
min_max=[small large]

image((array_in-small)*scale);
colormap('gray');
hold on;
axis image;
axis('off');
h=gca;
title(title1);
hand=sircolorbar('horiz',small,large);
%hand=colorbar('horiz');
%axes(hand);
%axis off;
%axes(h);
hold off;



