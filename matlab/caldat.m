function [mm id iyyy] = caldat(julian)
%
% [mm id iyyy] = caldat(julian)
%
% given julian day, returns output month, day, year
%
% opposite of julday
IGREG=2299161;
if (julian >= IGREG)
  jalpha=floor(((julian-1867216)-0.25)/36524.25);
  ja=julian+1+jalpha-floor(0.25*jalpha);
else
  ja=julian;
end
jb=ja+1524;
jc=floor(6680.+((jb-2439870)-122.1)/365.25);
jd=365*jc+floor(0.25*jc);
je=floor((jb-jd)/30.6001);
id=jb-jd-floor(30.6001*je);
mm=je-1;
if (mm > 12)
  mm=mm-12;
end
iyyy=jc-4715;
if (mm > 2) 
  iyyy=iyyy-1;
end
if (iyyy <= 0) 
  iyyy=iyyy-1;
end
return
