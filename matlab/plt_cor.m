%load ftn04
%load ftn40

ftn40=f40;

figure(2)
hold off

if (1==1)
angs=[];
angs(36*36,12)=0;
for pulse=1:36*36
  for islice=1:12
    ind =4+(islice-1)*(8*6+7)+7+(2+6*([2:3]-1))+1;
    ang=(180/pi)*atan2(ftn40(pulse,ind(2))-ftn40(pulse,ind(1)), ... 
	               ftn40(pulse,ind(2)+1)-ftn40(pulse,ind(1)+1));

    orbit=floor((pulse-1)/36);
    az=pulse-1-orbit*36;
    if az == orbit
      ang1=ang;
      if ang>0 
	ang=ang-180;
      else
	if ang < 0
	  ang=ang+180;
	end
      end
      if ang >= 360
	ang=ang-360;
      end
      if ang <= -360
	ang=ang+360;
      end
      if ang >= 360
	ang=ang-360;
      end
      if ang <= -360
	ang=ang+360;
      end
      [pulse az orbit ang ang1]
    end
    angs(pulse,islice)=ang;
    
  end
end
a=reshape(angs(:,7),36,36);
contour(a)
disp('Computed angles');
pause;
end

if (1==1)
%tab=[];
%tab(36*36,3*12)=0;
for pulse=1:36*36
%  for islice=1:12
    for islice=3:10
    ind0=4+(islice-1)*(8*6+7)+7+(2+6*([1:8]-1))+1;
%    x0=sum(ftn40(pulse,ind0))/8;
%    y0=sum(ftn40(pulse,ind0+1))/8;
    cent=4+(islice-1)*(8*6+7)+1+1;
    x0=ftn40(pulse,cent);
    y0=ftn40(pulse,cent+1);
    ang=(180/pi)*atan2(ftn40(pulse,ind0(3))-ftn40(pulse,ind0(2)), ...
                       ftn40(pulse,ind0(3)+1)-ftn40(pulse,ind0(2)+1));
    ang=angs(pulse,islice);
    cx=cos(-ang*pi/180);
    sx=sin(-ang*pi/180);
    mx=[ cx sx];
    my=[-sx cx];
    x=mx * [ftn40(pulse,ind0)-x0; ftn40(pulse,ind0+1)-y0];
    y=my * [ftn40(pulse,ind0)-x0; ftn40(pulse,ind0+1)-y0];
%    x=mx * [ftn40(pulse,ind0); ftn40(pulse,ind0+1)];
%    y=my * [ftn40(pulse,ind0); ftn40(pulse,ind0+1)];
 %   plot(x,y,'c')
 %   hold on
    ftn40(pulse,ind0)=x;
    ftn40(pulse,ind0+1)=y;
%    j=(islice-1)*3+1;
%    tab(pulse,j)=ang;
%    tab(pulse,j+1)=ftn40(pulse,cent);
%    tab(pulse,j+2)=ftn40(pulse,cent+1);
  end
end
hold off
%disp('pausing...');
%pause
end

if (1==0)
c=reshape(tab(:,(7-1)*3+2),36,36);
a=reshape(angs(:,7),36,36);
for i=1:36
  j=(i-1)*36+i;
%  angs(j,:)=angs(j,:)+180;
  ind=find(angs(j,:)>0);
  ind1=find(angs(j,:)<0);
  angs(j,ind)=angs(j,ind)-180;
  angs(j,ind1)=angs(j,ind1)+180;
  ind=find(angs(j,:)>=360);
  angs(j,ind)=angs(j,ind)-360;
  ind=find(angs(j,:)<=-360);
  angs(j,ind)=angs(j,ind)+360;
end
b=reshape(angs(:,7),36,36);

disp('Computed table');
%pause;

end

figure(2)

if (1==0)

for pulse=1:6:36*36
  ang=angs(pulse,7)
  for islice=3:10
    ind=4+(islice-1)*(8*6+7)+7+(2+6*([1:8 1]-1))+1;
    plot(ftn40(pulse,ind),ftn40(pulse,ind+1),'g')
    hold on
    cent=4+(islice-1)*(8*6+7)+1+1;
    %    plot(ftn40(pulse,cent),ftn40(pulse,cent+1),'r+')
%  plot(ftn40(pulse,ind(1)),ftn40(pulse,ind(1)+1),'r+')
%  plot(ftn40(pulse,ind(2)),ftn40(pulse,ind(2)+1),'gx')
%  [ind' ftn40(pulse,ind)' ftn40(pulse,ind+1)']
  end
end

end

xval=0;
yval=0;
for pulse=1:36*36
  for islice=3:10
    ind =4+(islice-1)*(8*6+7)+7+(2+6*([1:8 1]-1))+1;
    j=(islice-1)*3+1;
    ang=angs(pulse,islice);
    
    cx=cos(ang*pi/180);
    sx=sin(ang*pi/180);
    mx=[ cx sx];
    my=[-sx cx];
    x=mx * [ftn40(pulse,ind); ftn40(pulse,ind+1)];
    y=my * [ftn40(pulse,ind); ftn40(pulse,ind+1)];
    cent=4+(islice-1)*(8*6+7)+1+1;
    x0=ftn40(pulse,cent);
    y0=ftn40(pulse,cent+1);
    plot(x+x0,y+y0,'b')
    hold on
    plot(f40(pulse,ind),f40(pulse,ind+1),'r')
    xval=max(xval,max(max(abs(x+x0-f40(pulse,ind)))));
    yval=max(yval,max(max(abs(y+y0-f40(pulse,ind+1)))));
  end
  if (pulse-1)/36==round((pulse-1)/36)
    disp('pause...');
    pause;
    hold off
  end
end

[xval yval]


if (1==0)

  for pulse=1:6:36*36
%  for islice=1:12
      for islice=3:10
    ind0=4+(islice-1)*(8*6+7)+7+(2+6*([1:8]-1))+1;
    ind =4+(islice-1)*(8*6+7)+7+(2+6*([1:8 1]-1))+1;
    cent=4+(islice-1)*(8*6+7)+1+1;
    az_nom=ftn40(pulse,4);
    x0=sum(ftn40(pulse,ind0))/8;
    y0=sum(ftn40(pulse,ind0+1))/8;
    cx0=ftn40(pulse,cent);
    cy0=ftn40(pulse,cent+1);
%    plot(ftn40(pulse,ind)-x0,ftn40(pulse,ind+1)-y0)

    ang=(180/pi)*atan2(ftn40(pulse,ind(3))-ftn40(pulse,ind(2)),ftn40(pulse,ind(3)+1)-ftn40(pulse,ind(2)+1));

    ang=angs(pulse,islice);

    cx=cos(-ang*pi/180);
    sx=sin(-ang*pi/180);
    mx=[cx sx];
    my=[-sx cx];
    x=mx *[ftn40(pulse,ind)-x0; ftn40(pulse,ind+1)-y0];
    y=my *[ftn40(pulse,ind)-x0; ftn40(pulse,ind+1)-y0];
%    plot(x,y)
%    %    plot(ftn40(pulse,ind)-cx0,ftn40(pulse,ind+1)-cy0)
    hold on
%    plot(ftn40(pulse,cent),ftn40(pulse,cent+1),'r+')
%  plot(ftn40(pulse,ind(1)),ftn40(pulse,ind(1)+1),'r+')
%  plot(ftn40(pulse,ind(2)),ftn40(pulse,ind(2)+1),'gx')
%  [ind' ftn40(pulse,ind)' ftn40(pulse,ind+1)']
  end
end
end
hold off







