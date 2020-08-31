function viewsir_map(sir_filein,cia_filein)
%
% viewsir_map(sir_input_filename,cia_map_file)
%
% view sir image with land map
%
if nargin>0,
  if nargin>1,
    viewsir_map1('initialize',sir_filein,cia_filein)
  else
    viewsir_map1('initialize',sir_filein)
  end
else
  warning('No file name specified.  Default image being used.');
  viewsir_map1('initialize','/auto/cers0/long/sir/data/greeni.sir')
end
