% hdf5load.m
%
% datastruct = hdf5load_recursive(datastruct,GroupHierarchy)
%
% Recursive procedure used to walk the Group Hierarchy of a given hinfo
% HDF info struct and load the data in the return struct datastruct.

% Author: Gael Varoquaux <gael.varoquaux@normalesup.org>
% Copyright: Gael Varoquaux
% License: BSD-like
%
% Generalized by DGL at BYU 29 Nov 2016 now preserves data type
% and handles missing attributes and Datasets.  Does not handle
% HDF5 Links or Datatypes

function datastruct = hdf5load_recursion(datastruct,GroupHierarchy)

if isfield(GroupHierarchy,'Attributes')
 % Load the attributes
 for i=[1:size(GroupHierarchy.Attributes,2)]
    data=hdf5read(GroupHierarchy.Attributes(i));
    name=GroupHierarchy.Attributes(i).Name;
    %fprintf('Attributes(%d) %s=%d\n',i,name,class(data));
    if 0 % do not do
     switch class(data)
      	case 'hdf5.h5string'
	  try
		if size(data,2)>1
		    buffer=data ;
		    data = {} ;
		    for j=1:size(buffer,2)
			data{j}=buffer(j).Data;
		    end
		else
		    data=data.Data;
		end
	    catch
	    end
	case 'hdf5.h5array'
	    try
		if size(data,2)>1
		    buffer=data ;
		    data = {} ;
		    for j=1:size(buffer,2)
			data{j}=buffer(j).Data;
		    end
		else
		    data=data.Data;
		end
	    catch
	    end
	otherwise
	    disp(['unknown case: ',class(data)])
	    data='NONE';
	end
    end
    name=GroupHierarchy.Attributes(i).Name;
    name=strrep(name,'/','.');
    name=strrep(name,' ','_'); % for matlab
    name=strrep(name,'-',''); % for matlab
    eval(['datastruct.Attributes' name '= data ;'])
  end
end

if isfield(GroupHierarchy,'Datasets') 
 % Load the datasets (the leafs of the tree):
 for i=[1:size(GroupHierarchy.Datasets,2)]
    data=hdf5read(GroupHierarchy.Datasets(i));
    if 0  % print dataset info
      name=GroupHierarchy.Datasets(i).Name;    
      s=size(data);
      if length(s)>2
	fprintf('  Datasets(%d of %d) %s=%s(%d,%d,%d)\n',i,size(GroupHierarchy.Datasets,2),name,class(data),s);
      elseif length(s)>1
	fprintf('  Datasets(%d of %d) %s=%s(%d,%d)\n',i,size(GroupHierarchy.Datasets,2),name,class(data),s);
      else
	fprintf('  Datasets(%d of %d) %s=%s(%d)\n',i,size(GroupHierarchy.Datasets,2),name,class(data),s);
      end
    end
    if 0 % do no do
     switch class(data)
	case 'hdf5.h5string'
	    try
		if size(data,2)>1
		    buffer=data ;
		    data = {} ;
		    for j=1:size(buffer,2)
			data{j}=buffer(j).Data;
		    end
		else
		    data=data.Data;
		end
	    catch
	    end
	case 'hdf5.h5array'
	    try
		if size(data,2)>1
		    buffer=data ;
		    data = {} ;
		    for j=1:size(buffer,2)
			data{j}=buffer(j).Data;
		    end
		else
		    data=data.Data;
		end
	    catch
	    end
	case 'uint16'
	    try
		if size(data,2)>1
		    buffer=data ;
		    data = {} ;
		    for j=1:size(buffer,2)
			data{j}=buffer(j).Data;
		    end
		else
		    data=data.Data;
		end
	    catch
	    end
	case 'single'
	    try
		if size(data,2)>1
		    buffer=data ;
		    data = {} ;
		    for j=1:size(buffer,2)
			data{j}=buffer(j).Data;
		    end
		else
		    data=data.Data;
		end
	    catch
	    end
	case 'double'
	    try
		if size(data,2)>1
		    buffer=data ;
		    data = {} ;
		    for j=1:size(buffer,2)
			data{j}=buffer(j).Data;
		    end
		else
		    data=data.Data;
		end
	    catch
	    end
	otherwise
	  disp('unknown data class')	    
     end
    end
    name=GroupHierarchy.Datasets(i).Name;
    name=strrep(name,'/','.');
    eval(['datastruct' name '= data ;'])
  end
end

% Then load the branches:
% Create structures for the group and pass them on recursively:
for i=[1:size(GroupHierarchy.Groups,2)]
  name=GroupHierarchy.Groups(i).Name;
  name=strrep(name,'/','.');
  eval(['datastruct' name '= struct ;']);
  datastruct = hdf5load_recursion(datastruct,GroupHierarchy.Groups(i));
end
