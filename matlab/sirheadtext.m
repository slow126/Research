function head=sirheadtext(head,sensor,title,type,tag,cproc,cdate)
%
%   head=sirheadtext(head,sensor,title,type,tag,cproc,cdate)
%
% modifies contents of text components of sir head array
%
% head:       scaled header information block
% sensor:     40 char string
% title:      80 char string
% type:      138 char string
% tag:        50 char string
% cproc:     100 char string
% cdate:      28 char string

% version 2.0 header   written 19 March 1997 by DGL
%
%	header mapping (see code for scaling of <= variables)
%
%	head(1)	= nsx			! pixels in x direction
%	head(2) = nsy			! pixels in y direction
%       head(3) <= xdeg			! span of deg in x
%	head(4) <= ydeg			! span of deg in y
%	head(5) = nhtype                ! header type (old<15)
%	head(6) <= ascale               ! x scaling
%	head(7) <= bscale               ! y scaling
%	head(8) <= a0                   ! x (lon) origin
%         note: longitudes should be in the range -180 to 180
%	head(9) <= b0                   ! y (lat) origin
%	head(10) = ioff			! offset to be added to scaled val
%	head(11) = iscale		! scale factor ival=(val-ioff)/iscale
%	head(12) = iyear		! year for data used
%	head(13) = isday		! starting JD
%	head(14) = ismin		! time of day for first data (in min)
%	head(15) = ieday		! ending JD
%	head(16) = iemin		! time of day for last data (in min)
%	head(17) = iopt			! projection type
%					!  -1 = no projection, image only
%					!   0 = rectalinear lat/lon
%					!   1 = lambert equal area
%					!   2 = lambert equal area (local rad)
%					!   5 = polar stereographic
%					!  11 = EASE north equal area grid
%					!  12 = EASE south equal area grid
%					!  13 = EASE cylindrical grid
%	head(18) = iregion		! region id code
%	head(19) = itype		! image type code
%                                       ! standard values: 0=unknown or n/a
%                                       ! 1 = scatterometer A (dB)
%                                       ! 2 = scatterometer B (dB/deg)
%                                       ! 3 = radiometer Tb (K)
%                                       ! 9 = topography (m)
%	head(20:39) 40 chars of sensor
%       head(40) = 0 
%       head(41) = nhead                ! number of 512 byte header blocks
%       head(42) = ndes                 ! number of 512 byte blocks description
%       head(43) = ldes                 ! number of bytes of description
%       head(44) = nia                  ! number of optional integers
%       temp(45) = ipol                 ! polarization (0=n/a,1=H,2=V)
%       temp(46) = ifreqhm              ! frequency in GHz (0 if n/a)
%       temp(47) = ispare1              ! spare
%       head(48) = idatatype            ! data type code 0,2=i*2,1=i*1,4=f
%       the value of idata type determines how data is stored
%
%       if idatatype = 1 data is stored as bytes and minv=128
%       if idatatype = 2 data is stored as 2 byte integers and minv=32766
%       if idatatype = 4 data is stored as IEEE floating point
%
%       if idatatype = 1,2 anodata,vmin,vmax are stored as 2 byte integers
%         in head(49)..head(51)  minv, ioff and iscal used to convert
%         integers or bytes into floating point values
%         nodata, vmin, and vmax must be representable with ioff and iscale
%            head(*) = (value-ioff)*iscale-minv
%            value = float(head(*)+minv)/float(iscale)+ioff
%       idatatype=2 is considered the SIR standard format
%
%       if idatatype = f anodata,vmin,vmax are stored as floating points
%         in head(52)..head(57) and minv, ioff and iscale are ignored here
%         and when reading the file.
%         floating point numbers are NOT standard across platforms and
%         is not recommended
%
%       For matlab implementation, head(49:51) hold floating point
%       values.  head(52:57) not used
%
%       head(49) <= anodata            ! value representing no data
%       head(50) <= vmin               ! minimum useful value from creator prg
%       head(51) <= vmax               ! maximum useful value from creator prg
%       head(52:53) = anodata          ! IEEE floating value of no data
%       head(54:55) = vmin             ! IEEE floating minimum useful value
%       head(56:57) = vmax             ! IEEE floating maximum useful value
%
%	head(58:126) 138 chars of type
%       head(127) = 0 
%       head(128) = 0 
%	head(129:168) 80 chars of title
%       head(169) = 0 
%	head(170:189) 40 chars of tag
%       head(190) = 0 
%	head(191:240) 100 chars of crproc
%       head(241) = 0 
%	head(242:255) 28 chars of crtime
%       head(256) = 0 
%
%     optional header blocks:
%
%	ndes header blocks of 512 bytes: chars of description
%	nhead-ndes-1 header blocks of 512 bytes: values of iaopt
%       by convention, first value iaopt is a code telling how to interpret
%       the rest of the array if nia>0
%
%       remainder of file is image data in a multiple of 512 byte blocks
%       two byte integer and byte scaling is
%          intval = (fvalue-ioff)*iscale-minv
%          fvalue = float(intval+minv)/float(iscale)+ioff
%

if (exist('sensor') == 1)
  s=real(sensor);
  s(41)=0;
  s=s(1:40);
  for i=1:20
    j=(i-1)*2+1;
    head(i+19)=s(j)+s(j+1)*256;
  end;
else
  return;
end;

if (exist('title') == 1)
  s=real(title);
  s(81)=0;
  s=s(1:80);
  for i=1:40
    j=(i-1)*2+1;
    head(i+128)=s(j)+s(j+1)*256;
  end;
else
  return;
end;

if (exist('type') == 1)
  s=real(type);
  s(139)=0;
  s=s(1:138);
  for i=1:69
    j=(i-1)*2+1;
    head(i+57)=s(j)+s(j+1)*256;
  end;
else
  return;
end;

if (exist('tag') == 1)
  s=real(tag);
  s(41)=0;
  s=s(1:40);
  for i=1:20
    j=(i-1)*2+1;
    head(i+169)=s(j)+s(j+1)*256;
  end;
else
  return;
end;

if (exist('cproc') == 1)
  s=real(cproc);
  s(101)=0;
  s=s(1:100);
  for i=1:50
    j=(i-1)*2+1;
    head(i+190)=s(j)+s(j+1)*256;
  end;
else
  return;
end;

if (exist('cdate') == 1)
  s=real(cdate);
  s(29)=0;
  s=s(1:28);
  for i=1:14
    j=(i-1)*2+1;
    head(i+241)=s(j)+s(j+1)*256;
  end;
else
  return;
end;





