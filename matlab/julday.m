function julday = julday(mm,id,iyyy)
%
% function julday = julday(mm,id,iyyy)
%     returns the Julian day number that begins on noon of the calendar
%     date specifed by month mm, day id and year iyy.
%
% opposite of caldat
IGREG=15+31*(10+12*1582);
jy=iyyy;
if (jy <0) 
  jy=jy+1;
end
if (mm > 2) 
  jm=mm+1;
else
  jy=jy-1;
  jm=mm+13;
end
julday=floor(365.25*jy)+floor(30.6001*jm)+id+1720995;
if (id+31*(mm+12*iyyy) >= IGREG) 
  ja=floor(0.01*jy);
  julday=julday+2-ja+floor(0.25*ja);
end
return
