function [year doy hr mn sec mon day]=QStimecode(str)
%
% [year doy hr mn sec mon day]=QStimecode(str)
%
% decode QuikSCAT/SeaWinds 20 character time code string into
% numeric values for year, doy, month, day, hr, min, sec
%
% A typical time code: 1999-200T18:39:31.475

year=1900;
doy=0;
mon=1;
day=1;
hr=0;
mn=0;
sec=0;

if length(str)<17, return, end;

year=sscanf(str(1:4),'%d');
doy=sscanf(str(6:8),'%d');
hr=sscanf(str(10:11),'%d');
mn=sscanf(str(13:14),'%d');
sec=sscanf(str(16:end),'%f');

% now compute month and day
[mon day]=doy2date(doy,year);
