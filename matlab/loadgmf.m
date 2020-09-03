function loadgmf(fname)
% function loadgmf(parameter)
%  load tabular model function into global memory
% 
%  parameter can be the name of the gmf file or a numerical code can
%  be used:
%
%    1 = nscat1
%    2 = cmodfdp
%    3 = cmod4
%    4 = sass1
%    5 = wentz

% written by DGL 21 April 1997

if (isstr(fname)==1)
  fid=fopen(fname,'r');
else
  if (fname == 1) 
    file='/brix/archive/geomodel/nscat1.dat';
  elseif (fname == 2)
    file='/brix/archive/geomodel/cmodfdp.dat';
  elseif (fname == 3)
    file='/brix/archive/geomodel/cmod4.dat';
  elseif (fname == 4)
    file='/brix/archive/geomodel/tabsass1.dat';
  else
    file='/brix/archive/geomodel/tabwentz.dat';
  end;
  disp(file)
  fid=fopen(file,'r');
end;

[temp,count]=fread(fid,inf,'float');
fclose(fid);
temp=temp(2:count-1);
global gmf_model_tab;
gmf_model_tab=reshape(temp,[33-8+1,2*50*37]);
global gmf_model_tab;
