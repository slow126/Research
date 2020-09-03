function viewsir(filein)
%
% viewsir(sir_input_filename)
%
% view sir image with interactive location, color tables, etc.
%
if nargin>0,
  viewsir1('initialize',filein)
else
  warning('No file name specified.  Default image being used.');
  viewsir1('initialize')
end
