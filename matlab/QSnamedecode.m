function [level rev]=QSnamedecode(name);
%
% [level rev]=QSnamedecode(name)
%
% given a standard QuikSCAT or SeaWinds file name, extracts
% level and rev number from file name
%
level='00';
rev=0;
if length(name) < 11, return, end;

% strip path from file name
k=findstr(name,'/');
if ~isempty(k)
  n=k(end);
  name=name(n+1:end);
end

level=name(5:6);
%disp(['[',name(7:11),']'])
rev=sscanf(name(7:11),'%d');

return
