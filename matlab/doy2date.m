function [month day] = doy2date(doy,year)
%
% [month day] = doy2date(doy,year)
%
% given day of year and year, returns month and day of month
%
% uses julday and caldat
%
jday=julday(1,1,year)+doy-1;
[month, day, iyyy]=caldat(jday);
if iyyy ~= year
  error('*** doy2date error');
end
return
