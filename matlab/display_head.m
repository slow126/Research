function [val_str,val_num]=display_head(head)
%
% [val_str,val_num]=display_head(head)
% 
% returns a list of head options with their given values 
% given an input header 
%
%  Option list:  (these return numeric inputs)
%   'nsx'   'nsy'     'xdeg'    'ydeg'    'nhtype'    'ascale'  'bscale' 'a0'
%   'b0'    'ioff'    'iscale'  'iyear'   'isday'     'ismin'   'ieday' 'iemin'
%   'iopt'  'iregion' 'itype'   'nhead'   'ndes'      'ldes'     'nia'
%   'vmin'  'vmax'    'anodata' 'ispare1' 'idatatype' 'i0_sc'
%   'iscale_sc'     'ixdeg_off' 'iydeg_off'            'ideg_sc'  
%   'ia0_off'       'ib0_off' 
%
%   (these options return string inputs)
%   'sensor' 'title' 'type' 'tag' 'crproc' 'crtime'
% 
% see also 
%  sirheadvalue (returns a value by name)
%  setsirhead   (sets a header value by name)

% written 28 Oct 2000  by DGL

string_head={ 'sensor' 'title' 'type' 'tag' 'crproc' 'crtime'}';  
head_options={ 'nsx' 'nsy' 'xdeg' 'ydeg' 'nhtype' 'ascale' 'bscale' ...
      'a0' 'b0' 'ioff' 'iscale' 'iyear'  'isday' 'ismin' 'ieday' ...
      'iemin' 'iopt' 'iregion' 'itype' 'nhead'  'ndes' 'ldes' 'nia' ...
      'vmin' 'vmax' 'anodata' 'ispare1' 'idatatype' 'i0_sc' 'iscale_sc' ...
      'ixdeg_off' 'iydeg_off' 'ideg_sc' 'ia0_off' 'ib0_off' }';
c=length(head_options);
c2=length(string_head);

values1={};
for p=1:c2
  values=sirheadvalue(char(string_head(p)),head);
  values1=[values1; {values}];
end
val_str=[char(string_head) char(string_head)*0 + ' ' char(values1)];

value1=[];
for t=1:c
  value=sirheadvalue(char(head_options(t)),head);
  value1=[value1; value];
end
val_num = [char(head_options) num2str(value1)];












