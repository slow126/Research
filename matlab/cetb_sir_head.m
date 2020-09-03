function head=cetb_sir_head(cetb,filename,opt)
%
% head=cetb_sir_head(cetb,filename,opt)
%
%      cetb: structure read using readcetb.m
%      filename: filename to store in header
%      opt: array option 'TB','TB_inc','TB_std','TB_num','TB_time'
%
% generate BYU .SIR header from cetb structure
%
head=zeros([256,1]);  % template header array
head(1)=cetb.xdim;
head(2)=cetb.ydim;
head=setsirhead('nsx',head,cetb.xdim);
head=setsirhead('nsy',head,cetb.ydim);
head=setsirhead('nhead',head,1);
head=setsirhead('nhtype',head,31);
head=setsirhead('nia',head,0);
head=setsirhead('ndes',head,0);
head=setsirhead('ldes',head,0);
head=setsirhead('ideg_sc',head,10);
head=setsirhead('iscale_sc',head,100);
head=setsirhead('i0_sc',head,1);
head=setsirhead('ixdeg_off',head,0);
head=setsirhead('iydeg_off',head,0);
head=setsirhead('ia0_off',head,0);
head=setsirhead('ib0_off',head,0);
head=setsirhead('ioff',head,100);
head=setsirhead('iscale',head,200);

if cetb.lat_org > 80.0
  head=setsirhead('iopt',head,8); % EASE2N
elseif cetb.lat_org < -80.0
  head=setsirhead('iopt',head,9); % EASE2S
else
  head=setsirhead('iopt',head,10);% EASE2T
end
head=setsirhead('xdeg',head,cetb.xdim/2.0);
head=setsirhead('ydeg',head,cetb.ydim/2.0);

xres=sscanf(cetb.xres,'%f');
if xres > 1000.0
  xres=xres/1000.0;
end
i=round(25.0/xres+0.01);
if i==1 
  head=setsirhead('ascale',head,0.0); %nease  (0=25, 1=12.5, 2=6.25, 3=3.125, 4=1.56)	
elseif i==2    
  head=setsirhead('ascale',head,2.0); %nease  (0=25, 1=12.5, 2=6.25, 3=3.125, 4=1.56)	
elseif (i==3)    
  head=setsirhead('ascale',head,3.0); %nease  (0=25, 1=12.5, 2=6.25, 3=3.125, 4=1.56)	
elseif (i==4)    
  head=setsirhead('ascale',head,4.0); %nease  (0=25, 1=12.5, 2=6.25, 3=3.125, 4=1.56)	
else
  head=setsirhead('ascale',head,3.0); %nease  (0=25, 1=12.5, 2=6.25, 3=3.125, 4=1.56)	
end
head=setsirhead('bscale',head,0.0);  %ind=0
head=setsirhead('a0',head,0.0);
head=setsirhead('b0',head,0.0);
head=setsirhead('ipol',head,0.0);
if cetb.fpol(3:3)=='V' 
  head=setsirhead('ipol',head,1.0);
end
if length(cetb.fpol)> 5
  if cetb.fpol(5:5) == 'V'
    head=setsirhead('ipol',head,1.0);
  end
end

if cetb.fpol(3)=='.'
  xres=sscanf(cetb.fpol,'%4.1f');
else
  xres=sscanf(cetb.fpol,'%2d');
end
head=setsirhead('ifreqhm',head,round(xres(1)*10));

% decode start/stop days
head=setsirhead('ismin',head,0.0);
head=setsirhead('iemin',head,1440.0);
iyear=sscanf(cetb.tstart,'%4d');
imon=sscanf(cetb.tstart(6:end),'%2d');
iday=sscanf(cetb.tstart(9:end),'%2d');
head=setsirhead('iyear',head,iyear(1));
doy=julday(imon(1),iday(1),iyear(1))-julday(1,1,iyear(1))+1;
head=setsirhead('isday',head,doy);
imon=sscanf(cetb.tstop(6:end),'%2d');
iday=sscanf(cetb.tstop(9:end),'%2d');
doy=julday(imon(1),iday(1),iyear(1))-julday(1,1,iyear(1))+1;
head=setsirhead('ieday',head,doy);

% store strings
k=strfind(filename,'/');
if length(k)>0 
  k=k(end);
else
  k=1;
end
head=setsirhead('title',head,filename(k:end));
head=setsirhead('type',head,['CETB TB ',cetb.platform]);
head=setsirhead('sensor',head,['CETB ',cetb.instrument]);
head=setsirhead('tag',head,'(c) 2017 BYU MERS');
head=setsirhead('crproc',head,'cetb_sir_head.m');
str=char(datetime());
head=setsirhead('crtime',head,str);


switch opt
  case {'sig', 'Sig'}  % backscatter 
    head=setsirhead('type',head,['Sigma0 ',cetb.platform]);
    head=setsirhead('ioff',head,-33);
    head=setsirhead('iscale',head,1000);
    head=setsirhead('itype',head,1);
    head=setsirhead('anodata',head,-33);
    head=setsirhead('vmin',head,-30);
    head=setsirhead('vmax',head,0);
	
  case 'TB'  % brightness temperture
    head=setsirhead('type',head,['CETB TB ',cetb.platform]);
    head=setsirhead('ioff',head,100);
    head=setsirhead('iscale',head,200);
    head=setsirhead('itype',head,3);
    head=setsirhead('anodata',head,100);
    head=setsirhead('vmin',head,180);
    head=setsirhead('vmax',head,295);
	
  case 'TB_num'
    head=setsirhead('type',head,['CETB TB_num ',cetb.platform]);
    head=setsirhead('ioff',head,-1);
    head=setsirhead('iscale',head,8);
    head=setsirhead('itype',head,3);
    head=setsirhead('anodata',head,-1);
    head=setsirhead('vmin',head,-1);
    head=setsirhead('vmax',head,50);
  
  case 'TB_inc'
    head=setsirhead('type',head,['CETB TB_inc ',cetb.platform]);
    head=setsirhead('ioff',head,0);
    head=setsirhead('iscale',head,100);
    head=setsirhead('itype',head,9);
    head=setsirhead('anodata',head,-1);
    head=setsirhead('vmin',head,40);
    head=setsirhead('vmax',head,60);
  
  case 'TB_std'
    head=setsirhead('type',head,['CETB TB_std ',cetb.platform]);
    head=setsirhead('ioff',head,-1);
    head=setsirhead('iscale',head,100);
    head=setsirhead('itype',head,23);
    head=setsirhead('anodata',head,-1);
    head=setsirhead('vmin',head,0);
    head=setsirhead('vmax',head,15);
  
  case 'TB_time'
    head=setsirhead('type',head,['CETB TB_time ',cetb.platform]);
    head=setsirhead('ioff',head,-1);
    head=setsirhead('iscale',head,1);
    head=setsirhead('itype',head,11);
    head=setsirhead('anodata',head,-1);
    head=setsirhead('vmin',head,0);
    head=setsirhead('vmax',head,2880);
    
  otherwise
    disp('*** invalid cetb_sir_head option');
end