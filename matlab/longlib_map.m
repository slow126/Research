function longlib_map
%
% function longlib_map
%
% plots a low-resolution coastline map using the longlib coastline map
%

% load longlib coastline data
load /auto/share/ref/LL93/earth.dat;

[m n]=size(earth);
x=[];
y=[];
for n=1:m
  for i=1:2:10
    if earth(n,i) == 0 & earth(n,i+1) == 0
    else
      if earth(n,i+1) > 800
	if ~isempty(x)
	  plot(x,y)
	end
	x=[];
	y=[];
      else
	if abs(earth(n,i)) > 180.5 | abs(earth(n,i+1))> 91.0
	  if ~isempty(x)
	    plot(x,y)
	  end
	  x=[];
	  y=[];
	else 
	  x=[x earth(n,i)];
	  y=[y earth(n,i+1)];
	end
      end
    end
  end
end
