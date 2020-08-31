function [doy] = date2doy(year, month, day)
%
% [doy] = doy2date(year, month, day)
%
% given year, month, and day of month, returns day of year
%
% uses julday and caldat
%
doy=julday(month,day,year)-julday(1,1,year)+1;
return
