function [head]=loadsirhead(filename)
%
%   [head]=loadsirhead('filename')
%
% load a sirf file header into matlab.  
%
% head:       scaled header information block
% filename:   name of sir input file
%
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
    case {11, 12 13} % EASE grid
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
  case {11, 12 13} % EASE grid
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





