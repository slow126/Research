function varargout = HDFhead(varargin)
%
% [str1,str2,...] = HDFhead('filename','global_attr1','global_attr2',...)
%
% reads the global attributes of a QuikSCAT or SeaWinds HDF file
% specifying no attributes will list the available attributes
%

% written 15 Feb 2006 by DGL at BYU
%filename='QS_S2B22262.20032711949';

filename=varargin{1};

SD_id = hdfsd('start',filename,'rdonly');
if SD_id < 1, error(['*** could not open file ',filename]), return, end;

[ndatasets,nglobal_attr,status] = hdfsd('fileinfo',SD_id);
if status ~=0, error(['*** could not get file info ',filename]), hdfsd('end',SD_id), return, end;

if nargin < 2  % list global all attributes
  disp(['Data sets: ',num2str(ndatasets),' Global Attributes: ',num2str(nglobal_attr)]);
  for attr_idx=0:nglobal_attr-1
    [name,data_type,count,status] = hdfsd('attrinfo',SD_id,attr_idx);
    if status ~=0, error(['*** could not get attribute info ',...
	  num2str(attr_idx),' ',filename]), hdfsd('end',SD_id), return, end;
    disp(['Attribute number: ',num2str(attr_idx),' Name: ',name,' type ',data_type,' count ',num2str(count)])
    [data,status] = hdfsd('readattr',SD_id,attr_idx);
    if status ~=0, error('*** could not read attribute data'), hdfsd('end',SD_id), return, end;
    %data
    %data(1:3)
    if data(1:3) == 'int',
      data=data(7:end-1);
    else 
      %data(1:5)
      if data(1:5) == 'float',
	data=data(9:end-1);
      else
	data=data(7:end-1);
      end
    end
    if double(data(1)) == 10, data=data(2:end);,end  % discard leading return if present
    disp(data)
  end
else  % return desired attributes
  
  x = 1;
  while x<nargin
    x = x+1;
    attr_idx = hdfsd('findattr',SD_id,varargin{x});
    if attr_idx < 1, error(['*** could not find attribute ',varargin{x}]), return, end;
    [name,data_type,count,status] = hdfsd('attrinfo',SD_id,attr_idx);
    if status ~=0, error('*** could not get attribute info'), hdfsd('end',SD_id), return, end;
    % disp(['Attribute number: ',num2str(attr_idx),' Name: ',name,' type ',data_type,' count ',num2str(count)])
    [data,status] = hdfsd('readattr',SD_id,attr_idx);
    if status ~=0, error('*** could not read attribute data'), hdfsd('end',SD_id), return, end;
    %data(1:3)
    if data(1:3) == 'int',
      data=data(7:end-1);
    else 
      %data(1:5)
      if data(1:5) == 'float',
	data=data(9:end-1);
      else
	data=data(7:end-1);
      end
    end
    if double(data(1)) == 10, data=data(2:end);,end  % discard leading return if present
    % disp(data)
    varargout{x-1}=data;
  end
end


status = hdfsd('end',SD_id);
if status ~=0, error('*** could not close file'), return, end;

return
