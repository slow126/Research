function head=setsirhead(option,head,value);
%
%   head=setsirhead(option,head,value)
%
% sets parameter option in the SIR header array head to value
% Option is set by SIR header parameters name
%
% option:     string containing name of option to change
% head:       array contain SIR header parameters
% value:      value to set header parameter to
%
% Option list:  (this require numeric inputs for value)
%  'nsx'   'nsy'     'xdeg'    'ydeg'    'nhtype'    'ascale'  'bscale' 'a0'
%  'b0'    'ioff'    'iscale'  'iyear'   'isday'     'ismin'   'ieday' 'iemin'
%  'iopt'  'iregion' 'itype'   'nhead'   'ndes'      'ldes'     'nia'
%  'vmin'  'vmax'    'anodata' 'ispare1' 'idatatype' 'i0_sc'
%  'iscale_sc'     'ixdeg_off' 'iydeg_off'            'ideg_sc'  
%  'ia0_off'       'ib0_off'    
%
%  (these options require string inputs)
%  'sensor' 'title' 'type' 'tag' 'crproc' 'crtime'
%
% CAUTION: this routine does NOT protect against invalid value and can
%          result in an unusable/unreadable SIR file header
%
% see also sirheadvalue (returns a value by hame)
%

% Version 3.0   written 28 Oct 2000  by DGL
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

nhtype=head(5);

switch lower(option)
  case 'nsx'
    head(1)=value;
  case 'nsy'
    head(2)=value;
  case 'xdeg'
    head(3)=value;
  case 'ydeg'
    head(4)=value;
  case 'nhtype'
    head(5)=value;
  case 'ascale'
    head(6)=value;
  case 'bscale'
    head(7)=value;
  case 'a0'
    head(8)=value;
  case 'b0'
    head(9)=value;
  case 'ioff'
    head(10)=value;
  case 'iscale'
    head(11)=value;
  case 'iyear'
    head(12)=value;
  case 'isday'
    head(13)=value;
  case 'ismin'
    head(14)=value;
  case 'ieday'
    head(15)=value;
  case 'iemin'
    head(16)=value;
  case 'iopt'
    head(17)=value;
  case 'iregion'
    head(18)=value;
  case 'itype'
    head(19)=value;
  case 'iscale_sc'
    head(40)=value;
  case 'nhead'
    head(41)=value;
  case 'ndes'
    head(42)=value;
  case 'ldes'
    head(43)=value;
  case 'nia'
    head(44)=value;
  case 'ipol'
    head(45)=value;
  case 'ifreqhm'
    head(46)=value;
  case 'ispare1'
    head(47)=value;
  case 'idatatype'
    head(48)=value;
  case 'anodata'
    head(49)=value;
  case 'vmin'
    head(50)=value;
  case 'vmax'
    head(51)=value;
  case 'ixdeg_off'
    head(127)=value;
  case 'iydeg_off'
    head(128)=value;
  case 'ideg_sc'
    head(169)=value;
  case 'ia0_off'
    head(190)=value;
  case 'ib0_off'
    head(241)=value;
  case 'i0_sc'
    head(256)=value;

    %
    % strings
    %
    
  case 'sensor'
    s=real(value);
    s(41)=0;
    s=s(1:40);
    for i=1:20
      j=(i-1)*2+1;
      head(i+19)=s(j)+s(j+1)*256;
    end;
    
  case 'title'
    s=real(value);
    s(81)=0;
    s=s(1:80);
    for i=1:40
      j=(i-1)*2+1;
      head(i+128)=s(j)+s(j+1)*256;
    end;
    
  case 'type'
    s=real(value);
    s(139)=0;
    s=s(1:138);
    for i=1:69
      j=(i-1)*2+1;
      head(i+57)=s(j)+s(j+1)*256;
    end;

  case 'tag'
    s=real(value);
    s(41)=0;
    s=s(1:40);
    for i=1:20
      j=(i-1)*2+1;
      head(i+169)=s(j)+s(j+1)*256;
    end;

  case 'crproc'
    s=real(value);
    s(101)=0;
    s=s(1:100);
    for i=1:50
      j=(i-1)*2+1;
      head(i+190)=s(j)+s(j+1)*256;
    end;

  case 'crtime'
    s=real(value);
    s(29)=0;
    s=s(1:28);
    for i=1:14
      j=(i-1)*2+1;
      head(i+241)=s(j)+s(j+1)*256;
  end;
    
  otherwise
    disp('Unknown option');
end







