function [image, head, descrip, iaopt]=loadsir(filename)
%
%   [image head descrip iaopt]=loadsir('filename')
%
% load a sirf image into matlab.  Also sets global variables
% containing the image transformation information from file header
%
% image:      image array
% head:       scaled header information block
% descrip:    second header description string
% iaopt:      second header integer array
% filename:   name of sir input file
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
%
%     scaling for prorjection parameters are generally:
%
%        head(3) = round((xdeg + ixdeg_off) * ideg_sc)
%        head(4) = round((ydeg + iydeg_off) * ideg_sc)
%        head(6) = round(ascale * iscale_sc)
%        head(7) = round(bscale * iscale_sc)
%        head(8) = round((a0 + ia0_off) * i0_sc)
%        head(9) = round((b0 + ib0_off) * i0_sc)
%
%     with the following projection specific exceptions:
%
%	if iopt==1 | iopt == 2		% lambert
%           head(6) = round(iscale_sc/ascale)
%           head(7) = round(iscale_sc/bscale)
%	if iopt==11 | iopt==12 | iopt == 13  % EASE1 grid
%           head(6) = round(float(iscale_sc)*round(10.*ascale* ...
%                              25.067525/6371.228)*0.05)
%           head(7) = round(float(iscale_sc)*roun(10.*bscale/ ...
%                              25.067525)*0.05)
%
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
%					!   8 = EASE2 north equal area grid
%					!   9 = EASE2 south equal area grid
%					!  10 = EASE2 cylindrical grid
%					!  11 = EASE1 north equal area grid
%					!  12 = EASE1 south equal area grid
%					!  13 = EASE1 cylindrical grid
%	head(18) = iregion		! region id code
%	head(19) = itype		! image type code
%                                       ! standard values: 0=unknown or n/a
%                                       ! 1 = scatterometer A (dB)
%                                       ! 2 = scatterometer B (dB/deg)
%                                       ! 3 = radiometer Tb (K)
%                                       ! 9 = topography (m)
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
%
%     optional header blocks:
%
%	ndes header blocks of 512 bytes: chars of description
%	nhead-ndes-1 header blocks of 512 bytes: values of iaopt
%       by convention, first value iaopt is a code telling how to interpret
%       the rest of the array if nia>0.  Usage of additional blocks is
%       user dependent and non-standard.
%
%       remainder of file is image data in a multiple of 512 byte blocks
%       two byte integer and byte (idatatype = 1,2) scaling is
%          intval = (fvalue-ioff)*iscale-minv
%          fvalue = float(intval+minv)/float(iscale)+ioff
%       no scaling of float values for (idatatype=4)
%

fid=fopen(filename,'r','ieee-be');
head=fread(fid,[256],'short');  % read header

nhtype=head(5);
if nhtype < 20
  nhtype=1;
  head(5)=1;
end;

nhead=head(41);
if nhtype == 1
  nhead=1;
  head(41)=1;
  head(42)=0;
  head(43)=0;
  head(44)=0;
end;

ndes=head(42);
ldes=head(43);
nia=head(44);
idatatype=head(48);
iopt = head(17);		% transformation option

if nhtype < 30  % old header format
  %     set version 3.0 parameters to header version 2.0 defaults     
  switch iopt
    case -1  % image only
      ideg_sc=10;
      iscale_sc=1000;
      i0_sc=100;
      ixdeg_off=0;
      iydeg_off=0;
      ia0_off=0;
      ib0_off=0;
    case 0 % rectalinear lat/lon
      ideg_sc=100;
      iscale_sc=1000;
      i0_sc=100;
      ixdeg_off=-100;
      iydeg_off=0;
      ia0_off=0;
      ib0_off=0;
    case {1,2} % lambert
      ideg_sc=100;
      iscale_sc=1000;
      i0_sc=1;
      ixdeg_off=0;
      iydeg_off=0;
      ia0_off=0;
      ib0_off=0;
    case 5 % polar stereographic
      ideg_sc=100;
      iscale_sc=100;
      i0_sc=1;
      ixdeg_off=-100;
      iydeg_off=0;
      ia0_off=0;
      ib0_off=0;
    case {8, 9 10} % EASE2 grid
      ideg_sc=10;
      iscale_sc=100;
      i0_sc=10;
      ixdeg_off=0;
      iydeg_off=0;
      ia0_off=0;
      ib0_off=0;
    case {11, 12 13} % EASE1 grid
      ideg_sc=10;
      iscale_sc=1000;
      i0_sc=10;
      ixdeg_off=0;
      iydeg_off=0;
      ia0_off=0;
      ib0_off=0;
    otherwise %  unknown default scaling
      ideg_sc=100;
      iscale_sc=1000;
      i0_sc=100;
      ixdeg_off=0;
      iydeg_off=0;
      ia0_off=0;
      ib0_off=0;
  end

  head( 40) = iscale_sc;
  head(127) = ixdeg_off;
  head(128) = iydeg_off;
  head(169) = ideg_sc;
  head(190) = ia0_off;
  head(241) = ib0_off;
  head(256) = i0_sc;
  
else   % get projection parameters offset and scale factors

  iscale_sc = head( 40);
  ixdeg_off = head(127);
  iydeg_off = head(128);
  ideg_sc   = head(169);
  ia0_off   = head(190);
  ib0_off   = head(241);
  i0_sc     = head(256);

end


%	decode projection transformation 

xdeg   = head(3)/ideg_sc - ixdeg_off;
ydeg   = head(4)/ideg_sc - iydeg_off;
ascale = head(6)/iscale_sc;
bscale = head(7)/iscale_sc;
a0     = head(8)/i0_sc - ia0_off;
b0     = head(9)/i0_sc - ib0_off;

%	get special cases which depend on transformation option
switch iopt
  case -1  % image only
  case 0 % rectalinear lat/lon
  case {1,2} % lambert
    ascale=iscale_sc/head(6);
    bscale=iscale_sc/head(7);
  case 5 % polar stereographic
  case { 8,  9 10} % EASE2 grid
  case {11, 12 13} % EASE1 grid
    ascale = 2.0*(head(6)/iscale_sc)*6371.228/25.067525;
    bscale = 2.0*(head(7)/iscale_sc)*25.067525d0
  otherwise %  unknown default scaling
    disp('*** Unrecognized SIR option in loadsir ***');
end;

head(3)=xdeg;
head(4)=ydeg;
head(6)=ascale;
head(7)=bscale;
head(8)=a0;
head(9)=b0;

if head(11) == 0  % iscale
  head(11)=1;
end;
s=1./head(11);
soff=32767.0/head(11);
if idatatype == 1
  soff=128.0/head(11);
end;
ioff=head(10);

anodata = head(49)*s+ioff+soff;
vmin = head(50)*s+ioff+soff;
vmax = head(51)*s+ioff+soff;

if idatatype == 4
  frewind(fid);
  fread(fid,[51],'short');
  fl=fread(fid,[3],'float');
  frewind(fid);
  fread(fid,[256],'short');
  anodata=fl(1);
  vmin=fl(2);
  vmax=fl(3);
end;

head(46)=head(46)*0.1;
head(49)=anodata;
head(50)=vmin;
head(51)=vmax;

descrip=[];
iaopt=[];

if nhead > 1
  if ndes > 0
    descrip=fread(fid,[ndes*512],'char');
    descrip=descrip(1:ldes)';
    [m n]=size(descrip);
    for j=1:n/2
      k=(j-1)*2+1;
      t=descrip(k);
      descrip(k)=descrip(k+1);
      descrip(k+1)=t;
    end;
  end;
  if nia > 0
    nia1=256*ceil(nia/256);
    iaopt=fread(fid,[nia1],'short');
    iaopt=iaopt(1:nia)';
  end;
end;

% read image data
  
if idatatype == 1 
%   disp(['Read byte data: ' num2str(head(1)) ' x ' num2str(head(2))]);
    im_in=fread(fid,[head(1),head(2)],'schar');  % read byte image data
    image=rot90(s*im_in+soff+ioff);   % scale data to floating point and
                                      % change origin location 
elseif idatatype == 4
%   disp(['Read float data: ' num2str(head(1)) ' x ' num2str(head(2))]);
    image=rot90(fread(fid,[head(1),head(2)],'float'));  % read floating piont data
else
%    disp(['Read integer data: ' num2str(head(1)) ' x ' num2str(head(2))]);
    im_in=fread(fid,[head(1),head(2)],'short');  % read integer image data
    image=rot90(s*im_in+soff+ioff);   % scale data to floating point and
                                      % change origin location for display
end;

if (nhtype == 1)                      % if old-style header, set default values
  vmin=min(min(image));
  vmax=max(max(image));
  anodata=vmin;
  head(49)=anodata;
  head(50)=vmin;
  head(51)=vmax;
  if vmin == -32
    head(19)=1;
  elseif vmin==-3.2
    head(19)=2;
  end;
  head(45)=2;
  head(46)=53;
end;

fclose(fid);






