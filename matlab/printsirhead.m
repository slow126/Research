function printsirhead(head,descrip,iaopt)
%
%   printsirhead(head,descrip,iaopt)
%
% prints information from the SIR file header info arrays from loadsir
%
% head:       scaled header information block
% descrip:    second header description string (optional)
% iaopt:      second header integer array (optional)
%

% version 3.0 header   written 28 Oct. 2000 by DGL
%

nhtype=head(5);
nhead=head(41);
if nhtype == 1
  nhead = 1;
end;
ndes=head(42);
ldes=head(43);
nia=head(44);
idatatype=head(48);
iopt = head(17);		% transformation option
iscale=head(11);
ioff=head(10);
nsx = head(1);
nsy = head(2);
xdeg = head(3);
ydeg = head(4);
ascale = head(6);
bscale = head(7);
a0 = head(8);
b0 = head(9);

iscale_sc = head( 40);
ixdeg_off = head(127);
iydeg_off = head(128);
ideg_sc   = head(169);
ia0_off   = head(190);
ib0_off   = head(241);
i0_sc     = head(256);

if iopt == -1				% image only
  disp(['Image only form ' num2str(nhtype)]);
  disp(['  x,y scale:   ' num2str(ascale) ', ' num2str(ascale) '  ',num2str(iscale_sc)]);
  disp(['  x,y offsets: ' num2str(a0) ', ' num2str(b0) ... 
	'   ' num2str(ia0_off) ' ' num2str(ib0_off) ' ' num2str(i0_sc)]);
  disp(['  x,y span:    ' num2str(xdeg) ', ' num2str(ydeg) ...
	'   ' num2str(ixdeg_off) ' ' num2str(iydeg_off) ' ' num2str(ideg_sc)]);
elseif iopt == 0			% rectalinear
  disp(['Lat/Long Rectangular form ' num2str(nhtype)]);
  disp(['  x,y scale: (pix/deg) ' num2str(ascale) ', ' num2str(ascale) '  ',num2str(iscale_sc)]);
  disp(['  x,y offsets: (deg)   ' num2str(a0) ', ' num2str(b0) ...
	'   ' num2str(ia0_off) ' ' num2str(ib0_off) ' ' num2str(i0_sc)]);
  disp(['  x,y span: (deg)      ' num2str(xdeg) ', ' num2str(ydeg) ...
	'   ' num2str(ixdeg_off) ' ' num2str(iydeg_off) ' ' num2str(ideg_sc)]);
elseif (iopt == 1) | (iopt == 2) 	% lambert
  if (iopt == 1)
    disp(['Lambert form (global radius) ' num2str(nhtype)]);
  else
    disp(['Lambert form (local radius) ' num2str(nhtype)]);
  end;
  disp(['  x,y scale: (km/pix) ' num2str(1./ascale) ', ' num2str(1./ascale) '  ',num2str(iscale_sc)]);
  disp(['  x,y corner: (km)    ' num2str(a0) ', ' num2str(b0) ...
	'   ' num2str(ia0_off) ' ' num2str(ib0_off) ' ' num2str(i0_sc)]);
  disp(['  x,y span: (deg)     ' num2str(xdeg) ', ' num2str(ydeg) ...
	'   ' num2str(ixdeg_off) ' ' num2str(iydeg_off) ' ' num2str(ideg_sc)]);
elseif iopt ==5			% polar stereographic
  disp(['Polar Stereographic form ' num2str(nhtype)]);
  disp(['  x,y scale: (km/pix) ' num2str(ascale) ', ' num2str(ascale) '  ',num2str(iscale_sc)]);
  disp(['  x,y offsets: (km)   ' num2str(a0) ', ' num2str(b0) ...
	'   ' num2str(ia0_off) ' ' num2str(ib0_off) ' ' num2str(i0_sc)]);
  disp(['  Center: (lon,lat)   ' num2str(xdeg) ', ' num2str(ydeg) ...
	'   ' num2str(ixdeg_off) ' ' num2str(iydeg_off) ' ' num2str(ideg_sc)]);
elseif (iopt == 8) | (iopt == 9) | (iopt == 10) % EASE2 grid
  disp(['EASE2 form ' num2str(iopt) ' ' num2str(nhtype)]);
  disp(['  Scale: (c,r)  ' num2str(ascale) ', ' num2str(ascale) '  ',num2str(iscale_sc)]);
  disp(['  Origin: (c,r) ' num2str(a0) ', ' num2str(b0) ...
	'   ' num2str(ia0_off) ' ' num2str(ib0_off) ' ' num2str(i0_sc)]);
  disp(['  Center: (c,r) ' num2str(xdeg) ', ' num2str(ydeg) ...
	'   ' num2str(ixdeg_off) ' ' num2str(iydeg_off) ' ' num2str(ideg_sc)]);
elseif (iopt == 11) | (iopt == 12) | (iopt == 13) % EASE1 grid
  disp(['EASE1 form '  num2str(iopt) ' ' num2str(nhtype)]);
  disp(['  Scale: (c,r)  ' num2str(ascale) ', ' num2str(ascale) '  ',num2str(iscale_sc)]);
  disp(['  Origin: (c,r) ' num2str(a0) ', ' num2str(b0) ...
	'   ' num2str(ia0_off) ' ' num2str(ib0_off) ' ' num2str(i0_sc)]);
  disp(['  Center: (c,r) ' num2str(xdeg) ', ' num2str(ydeg) ...
	'   ' num2str(ixdeg_off) ' ' num2str(iydeg_off) ' ' num2str(ideg_sc)]);
else
  disp('*** Unrecognized SIR option in loadsir ***');
end;

disp(['  Pixels:  ' num2str(nsx) ' by ' num2str(nsy)]);
disp(['  Year: ' num2str(head(12)) '  Start Day: ' num2str(head(13)) ...
      '  Min: '  num2str(head(14))]);
disp(['  End Day: ' num2str(head(15)) '   Min: ' num2str(head(16))]);
disp(['  Region: ' num2str(head(18))  '  Type: ' num2str(head(19)) ...
      '  Htype: ' num2str(head(5))  '  Nhead: ' num2str(nhead)]);
disp(['  Frequency: ',num2str(head(46)),'  Pol: ',num2str(head(45))]);
disp(['  Nodata value: ' num2str(head(49))  '  Vmin: ' ...
      num2str(head(50)) '  Vmax: ' num2str(head(51))]);

if idatatype == 4
  disp(['  Datatype: float']);
elseif idatatype == 1
  disp(['  Datatype: byte']);
else
  disp(['  Datatype: short']);
end;

sensor(40)=0;
for i=1:20
  j=(i-1)*2+1;
  sensor(j)=(mod(head(i+19),256));
  sensor(j+1)=floor(head(i+19)/256);
end;
disp(['  Sensor: ',deblank(setstr(sensor))]);
title(80)=0;
for i=1:40
  j=(i-1)*2+1;
  title(j)=(mod(head(i+128),256));
  title(j+1)=floor(head(i+128)/256);
end;
disp(['  Title: "',deblank(setstr(title)),'"']);
if (nhtype > 1)
  type(138)=0;
  for i=1:69
    j=(i-1)*2+1;
    type(j)=(mod(head(i+57),256));
    type(j+1)=floor(head(i+57)/256);
  end;
  disp(['  Type:  "',deblank(setstr(type)),'"']);
  tag(40)=0;
  for i=1:20
    j=(i-1)*2+1;
    tag(j)=(mod(head(i+169),256));
    tag(j+1)=floor(head(i+169)/256);
  end;
  disp(['  Tag:   "',deblank(setstr(tag)),'"']);
  crp1(100)=0;
  for i=1:50
    j=(i-1)*2+1;
    crp1(j)=(mod(head(i+190),256));
    crp1(j+1)=floor(head(i+190)/256);
  end;
  disp(['  Creator: "',deblank(setstr(crp1)),'"']);
  crt1(28)=0;
  for i=1:14
    j=(i-1)*2+1;
    crt1(j)=(mod(head(i+241),256));
    crt1(j+1)=floor(head(i+241)/256);
  end;
  disp(['  Created: ',deblank(setstr(crt1))]);
end;

if nhead > 1
  if ndes > 0
    if (exist('descrip') == 1)
      disp(['  Extra Description: ' setstr(descrip)])
    else
      disp(['  Extra desription characters: ' num2str(ldes)]);
    end;
  end;
  if nia > 0
    disp(['  Extra integers: ' num2str(nia) ]);
%    iaopt'
  end;
end;




