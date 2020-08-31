function value=sirheadvalue(option,head);
%
%   value=sirheadvalue(option,head);
%
% returns a parameters value extracted from the SIR file header
% Option is set by SIR header parameters name
%
% option:     string containing name of option
% head:       array contain SIR header parameters
%
% Option list:  (these return numeric values)
%  'nsx'   'nsy'     'xdeg'    'ydeg'    'nhtype'    'ascale'  'bscale' 'a0'
%  'b0'    'ioff'    'iscale'  'iyear'   'isday'     'ismin'   'ieday' 'iemin'
%  'iopt'  'iregion' 'itype'   'nhead'   'ndes'      'ldes'     'nia'
%  'vmin'  'vmax'    'anodata' 'ispare1' 'idatatype' 'i0_sc'
%  'iscale_sc'     'ixdeg_off' 'iydeg_off'            'ideg_sc'  
%  'ia0_off'       'ib0_off'    'ifreqm' 'ipol'
%
%  (these options return string values)
%  'sensor' 'title' 'type' 'tag' 'crproc' 'crtime'
%
% see also 
%   setsirhead (sets a sir header value by name)
%   display_head (returns list of head options and values)
%

% Version 3.0   written 28 Oct 2000  by DGL
% revised 12/2/2006 by DGL + added missing variables
% revised  7/6/2009 by DGL + fixed length of type variable
%
%	header mapping (see code for scaling of <= variables)
%       this routine reads raw header, scales variables and stores
%       results in returned header array
%
%	head(1)	= nsx			! pixels in x direction
%	head(2) = nsy			! pixels in y direction
%       head(3) <= xdeg			! span of deg in x
%	head(4) <= ydeg			! span of deg in y
%	head(5) = nhtype                ! header type (old<15,20,30)
%	head(6) <= ascale               ! x scaling
%	head(7) <= bscale               ! y scaling
%	head(8) <= a0                   ! x (or lon) origin
%         note: longitudes should be in the range -180 to 180
%	head(9) <= b0                   ! y (or lat) origin
%         note: latitudes should be in the range -90 to 90
%	head(10) = ioff			! offset to be added to scaled val
%	head(11) = iscale		! scale factor ival=(val-ioff)/iscale
%	head(12) = iyear		! year for data used
%	head(13) = isday		! starting JD
%	head(14) = ismin		! time of day for first data (in min)
%	head(15) = ieday		! ending JD
%	head(16) = iemin		! time of day for last data (in min)
%	head(17) = iopt			! projection type
%	head(18) = iregion		! region id code
%	head(19) = itype		! image type code
%	head(20:39) 40 chars of sensor
%       head(40) = iscale_sc            ! ascale/bscale scale factor
%       head(41) = nhead                ! number of 512 byte header blocks
%       head(42) = ndes                 ! number of 512 byte blocks description
%       head(43) = ldes                 ! number of bytes of description
%       head(44) = nia                  ! number of optional integers
%       head(45) = ipol                 ! polarization (0=n/a,1=H,2=V)
%       head(46) = ifreqhm              ! frequency in GHz (0 if n/a)
%       head(47) = ispare1              ! spare
%       head(48) = idatatype            ! data type code 0,2=i*2,1=i*1,4=f
%       head(49) <= anodata            ! value representing no data
%       head(50) <= vmin               ! minimum useful value from creator prg
%       head(51) <= vmax               ! maximum useful value from creator prg
%       head(52:53) = anodata          ! IEEE floating value of no data
%       head(54:55) = vmin             ! IEEE floating minimum useful value
%       head(56:57) = vmax             ! IEEE floating maximum useful value
%	head(58:126) 138 chars of type
%       head(127) =  ixdeg_off         ! xdeg offset
%       head(128) =  iydeg_off         ! ydeg offset
%	head(129:168) 80 chars of title
%       head(169) =  ideg_sc           ! xdeg,ydeg scale factor
%	head(170:189) 40 chars of tag
%       head(190) =  ia0_off           ! b0 offset 
%	head(191:240) 100 chars of crproc
%       head(241) =  ib0_off           ! b0 offset 
%	head(242:255) 28 chars of crtime
%       head(256) =  i0_sc             ! a0,b0 scale factor 

switch lower(option)
  case 'nsx'
    value=head(1);
  case 'nsy'
    value=head(2);
  case 'xdeg'
    value=head(3);
  case 'ydeg'
    value=head(4);
  case 'nhtype'
    value=head(5);
  case 'ascale'
    value=head(6);
  case 'bscale'
    value=head(7);
  case 'a0'
    value=head(8);
  case 'b0'
    value=head(9);
  case 'ioff'
    value=head(10);
  case 'iscale'
    value=head(11);
  case 'iyear'
    value=head(12);
  case 'isday'
    value=head(13);
  case 'ismin'
    value=head(14);
  case 'ieday'
    value=head(15);
  case 'iemin'
    value=head(16);
  case 'iopt'
    value=head(17);
  case 'iregion'
    value=head(18);
  case 'itype'
    value=head(19);
  case 'iscale_sc'
    value=head(40);
  case 'nhead'
    value=head(41);
  case 'ndes'
    value=head(42);
  case 'ldes'
    value=head(43);
  case 'nia'
    value=head(44);
  case 'ipol'
    value=head(45);
  case 'ifreqm'
    value=head(46);
  case 'ispare1'
    value=head(47);
  case 'idatatype'
    value=head(48);
  case 'anodata'
    value=head(49);
  case 'vmin'
    value=head(50);
  case 'vmax'
    value=head(51);
  case 'ixdeg_off'
    value=head(127);
  case 'iydeg_off'
    value=head(128);
  case 'ideg_sc'
    value=head(169);
  case 'ia0_off'
    value=head(190);
  case 'ib0_off'
    value=head(241);
  case 'i0_sc'
    value=head(256);

    %
    % strings
    %
    
  case 'sensor'
    value(40)=0;
    for i=1:20
      j=(i-1)*2+1;
      value(j)=(mod(head(i+19),256));
      value(j+1)=floor(head(i+19)/256);
    end;
    value=setstr(value);

  case 'title'
    value(80)=0;
    for i=1:40
      j=(i-1)*2+1;
      value(j)=(mod(head(i+128),256));
      value(j+1)=floor(head(i+128)/256);
    end;
    value=setstr(value);

  case 'type'
    value(138)=0;
    for i=1:69
      j=(i-1)*2+1;
      value(j)=(mod(head(i+57),256));
      value(j+1)=floor(head(i+57)/256);
    end;
    value=setstr(value);

  case 'tag'
    value(40)=0;
    for i=1:20
      j=(i-1)*2+1;
      value(j)=(mod(head(i+169),256));
      value(j+1)=floor(head(i+169)/256);
    end;
    value=setstr(value);

  case 'crproc'
    value(100)=0;
    for i=1:50
      j=(i-1)*2+1;
      value(j)=(mod(head(i+190),256));
      value(j+1)=floor(head(i+190)/256);
    end;
    value=setstr(value);
    
  case 'crtime'
    value(28)=0;
    for i=1:14
      j=(i-1)*2+1;
      value(j)=(mod(head(i+241),256));
      value(j+1)=floor(head(i+241)/256);
    end;
    value=setstr(value);
    
  otherwise
    disp('Unknown option');
end







