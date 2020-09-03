function [srev,lon_asc_node,sascnode]=QSrevReader(rev)
%
% [srev,lon_asc_node,aascnode]=QSrevReader(rev)
% reads the QS.revs file for rev
%

file='/auto/share/ref/QS.revs';

% open file
fid=fopen(file,'r');

% skip header
for l=1:10
  fgetl(fid);
end

% read file, searching for matching rev number
found=0;
while 1
  if feof(fid), break, end;
  line=fgetl(fid);
  frev=sscanf(line(1:5),'%d');
  if frev == rev
    %disp(['Found rev ', num2str(rev),' ',num2str(frev)])
    %disp(line)
    found=1;
    break
  end
end

% close file
fclose(fid);


if found==0
  % exit on not found
  disp(['*** rev ',num2str(rev),' not found in file ',file]);
  srev='1958-000T00:00:00.00';
  lon_asc_node=-999;
  sascnode='1958-000T00:00:00.00';
  return
else
  % decode line
  srev=line(8:28);
  % disp(['[',srev,']',])
  %line(31:37)
  lon_asc_node=sscanf(line(31:37),'%f');
  sascnode=line(40:60);
  %disp(['[',sascnode,']',])
  return
end
