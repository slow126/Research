% 
% matlab script to create a postage stamp image and extract measurements
% from SMAP data
%
% written by DGL at BYU 13 Apr 2020
%
clear

PRINT=0; % do not print
PRINT=1; % print figures


if 0 % do once
  % compile mex functions
  mex read_setup.c
  %mex sir_process.c
  mex single_pixel.c
  mex single_measurement.c
end

% location center
%% Hawaii (big island)
%tlat=19.6;
%tlon=-155.65;
%name='Hawaii';
% Aleutian island
%tlat=53.67;
%tlon=-166.83;
%name='AL';
% South Georgia Island (currently the only case supported by map routine)
tlat=-54.4;
tlon=-36.8;
name='SG';
sc1=[70 230]; % full region TB display scale
sc=[70 180]; % island TB display scale
Xoff=1;   % location offset in pixels
Yoff=-1;  % location offset in pixels


% gridding size (2*NGRD+1)*8.9
NGRD=2;

% define search box
dellat=8;
%dellon=5;
dellon=8;
clat=[floor(tlat-dellat),ceil(tlat+dellat)];
clon=[floor(tlon-dellon),ceil(tlon+dellon)];

ascflag=0;  % 0=all,1=asc,2=dsc,3=morn,4=eve
beam=1;     % 1=H,2=V

if 0 % create (large) setup file
  %% do these steps first in bash
  %%cp -r /auto/data/smap/sample_data/2* /auto/temp/long/SMAP/
  %%gunzip /auto/temp/long/SMAP/*.gz
  %%ls -1 sd/2*/*.h5 > files.lis
  
  % create .meta file for custom postage stamp area
  l1blistname='files.lis';
  srcdir='/home/long/src/linux/mymeasures/SMAP/src/prod';
  % lat/lon projection (24 pix/deg=4.6 km/lat pixel)
  cmd=sprintf('%s/meas_meta_makeSMAP %s.meta SMAP NONE 151 153 2015 NONE 1 -777 N %d. %d. %d. %d. N 0 %d %d 0 %s',srcdir,name,clat(1),clon(1),clat(2),clon(2),ascflag,beam,l1blistname);
  % lambert projection (8.9 km/pixel)
  cmd=sprintf('%s/meas_meta_makeSMAP %s.meta SMAP NONE 151 153 2015 NONE 1 -777 N %d. %d. %d. %d. N 2 %d %d 0 %s',srcdir,name,clat(1),clon(1),clat(2),clon(2),ascflag,beam,l1blistname);
  disp(cmd);
  system(cmd);

  % now create .setup file
  cmd=sprintf('%s/meas_meta_setupSMAP %s.meta ./',srcdir,name);
  disp(cmd);
  system(cmd);
  
  setup_file='SMhb-Cus15-151-153.setup';
  
  % clean up
  cmd='rm *.loc'
  system(cmd);
  
  % create rSIR dump.nc file of test region
  cmd=sprintf('%s/meas_meta_sir2b %s ./',srcdir,setup_file);
  system(cmd);
  
  sirdump='SMhb-Cus15-151-153.lis_dump.nc';
  % undump rSIR dump.nc
  cmd=sprintf('%s/meas_undump %s ./',srcdir,sirdump);
  system(cmd);
  sirfile='SMhb-a-Cus15-151-153.sir';

  % clean up
  cmd='rm SM*.lis SM*.grd'
  system(cmd);
  
  cmd='sirtool SMhb-a-Cus15-151-153.sir';
  system(cmd);
  
else
  setup_file='SMhb-Cus15-151-153.setup';
  sirfile='SMhb-a-Cus15-151-153.sir';
end

% read sir file header
sirhead=loadsirhead(sirfile);

% target center point in sir image pixels
[x01, y01] = latlon2pix1(tlon,tlat,sirhead);

if 1
  % read sirfile image and display
  [img sirhead]=loadsir(sirfile);
  myfigure(20);clf
  imagesc(img,sc1); colorbar;
  colormap(gray);
  % add overlay plot of island
  hold on;
  %plot(x01-Xoff,y01-Yoff,'r*');
  plot_local_map(tlon,tlat,sirhead,1,'b',1,Xoff,Yoff,1);
  hold off;
  title('South Georgia Island');
  axis image
  drawnow;
end

% select a narrower box around the target center point
dellat1=1; % for lat/lon projection at 1/24 deg resolution
dellon1=2;
dellat1=2.5; % for lambert 8.9 km projection
dellon1=3;
blat=[tlat-dellat1,tlat-dellat1,tlat+dellat1,tlat+dellat1];
blon=[tlon-dellon1,tlon+dellon1,tlon+dellon1,tlon-dellon1];
llpixbox=[blon(1) blon(3) blat(1) blat(3)]; % lon,lat extent
[ix,iy]=latlon2pix(blon,blat,sirhead);
ix=floor(ix);
iy=floor(iy);
pixbox=[ix(1) ix(3) iy(3) iy(1)]; % x,y extent

% origin and extent of reconstruction area based on previously defined pixbox
x0=pixbox(1);
y0=pixbox(3);
NX=pixbox(2)-pixbox(1); % horizontal size
NY=pixbox(4)-pixbox(3); % vertical size
pixbox1=[ix(1)-x0 ix(3)-x0 iy(3)-y0 iy(1)-y0]; % x,y reduced axes

if exist('img')
  myfigure(21);  
  imagesc(img,sc1); colorbar;
  colormap(gray);
  % add plot of island
  hold on;
  %plot(x01-Xoff,y01-Yoff,'r*');
  plot([pixbox(1) pixbox(2) pixbox(2) pixbox(1) pixbox(1)]-Xoff,[pixbox(3) pixbox(3) pixbox(4) pixbox(4) pixbox(3)]-Yoff,'g');
  plot_local_map(tlon,tlat,sirhead,1,'b',1,Xoff,Yoff,1);
  hold off;
  title('South Georgia Island');
  axis image
  drawnow;

  % zoom of island
  myfigure(22);clf
  x=((1:size(img,2)))*8.9-pixbox(1)*8.9;
  y=((1:size(img,1)))*8.9-pixbox(3)*8.9;
  h=imagesc(x,y,img,sc); colorbar;
  %h=imagesc(img,sc); colorbar;
  %colormap(gray);
  % add plot of island
  hold on;
  %plot(x01-Xoff,y01-Yoff,'r*'); % center location
  plot_local_map(tlon,tlat,sirhead,1,'b',1,pixbox(1)+Xoff,pixbox(3)+Yoff,8.9);
  circle(40/2,300,100,'w'); % add 40 km circle representing 3dB SMAP footprint
  hold off;
  title('South Georgia Island');
  axis image
  axis([0,pixbox(2)-pixbox(1),0,pixbox(4)-pixbox(3)]*8.9)
  xlabel('km');ylabel('km');
  %axis off
  drawnow;
  if PRINT
    print -dpng SG.png
  end
end

% Extract measurements

gain_thres=0.125;
gain_thres=0.0625;
% read setup file using mex function and generate pixel count and index arrays
[setuphead store pcnt mind]=read_setup(setup_file,gain_thres);

%disp('pausing');pause;disp('continuing');

% extract list of measurements and their locations
disp('Extract list of measurements and their locations');
nmeas=setuphead(38);
maxcnt=setuphead(39);
Tbs=zeros([nmeas 1]);
adss=zeros([nmeas 1]);
ktimes=zeros([nmeas 1]);
counts=zeros([nmeas 1]);
index=zeros([nmeas 1]);
ws1=zeros([nmeas maxcnt]);
ls1=zeros([nmeas maxcnt]);
for i=1:nmeas
  [TBval,count,incang,iadd,ktime,wts,w,l]=single_measurement(setuphead,store,i-1);
  TBs(i)=TBval;
  adds(i)=iadd;
  ktimes(i)=ktime;
  counts(i)=count;
  index(i)=i;
  ws1(i,1:count)=w;
  ls1(i,1:count)=l;
  %fprintf(' %d of %d: %f %f %d %d\n',i,nmeas,TBval,incang,iadd,ktime);
end

% select only a limited time interval
ind=find(ktimes>44*60 & ktimes<(44+24)*60);
adds=adds(ind);
TBs=TBs(ind);
ktimes=ktimes(ind);
counts=counts(ind);
index=index(ind);
ws1=ws1(ind,:);
ls1=ls1(ind,:);

% make the measurements unique (remove redundant measurement locations)
disp('Unique list of measurements and their locations');
[adds,IA,IC]=unique(adds);
TBs=TBs(IA);
ktimes=ktimes(IA);
counts=counts(IA);
index=index(IA);
ws1=ws1(IA,:);
ls1=ls1(IA,:);

if 0
  % plot measurement locations in lat/long
  disp('plot measurement locations');
  [x,y]=ifsirlex(adds,sirhead);
  y=sirhead(2)-y+1;
  [lons,lats]=pix2latlon(x,y,sirhead);
  myfigure(10);clf
  plot(lons,lats,'k.');
  hold on;
  %plot(tlon,tlat,'r*');
  plot_local_map(tlon,tlat,sirhead,0,'b',1,0,0,1);   % add plot of island
  hold off;
  axis image
  axis(llpixbox)
  xlabel('Longitude (deg)');
  ylabel('Latitude (deg)');
  drawnow;
end

if 1
  % plot measurement locations in pixels
  [x,y]=ifsirlex(adds,sirhead);
  y=sirhead(2)-y+1;
  myfigure(11);clf
  plot(x-Xoff-x0,y-Yoff-y0,'k.');
  hold on;
  %plot(x01-Xoff,y01-Yoff,'r*');
  plot_local_map(tlon,tlat,sirhead,1,'b',1,x0+Xoff,y0+Yoff,1);   % add plot of island
  circle((40/2)/8.9,300/8.9,100/8.9,'r'); % add 40 km circle representing 3dB SMAP footprint
  hold off;
  axis ij;
  axis image
  axis(pixbox1)
  xlabel('pixels'); ylabel('pixels');
  drawnow;
  if PRINT
    print -dpng measlocs.png
  end
  %title(sprintf('Lambert projection %0.3f km/pixel',1/sirheadvalue('ascale',sirhead)))
end

if 0 
  % create and plot a simulated DIB image
  [x1,y1]=ifsirlex(adds,sirhead);
  y1=sirhead(2)-y1+1;
  grd=zeros([sirhead(2) sirhead(1)]);
  ngrd=zeros([sirhead(2) sirhead(1)]);
  for n=1:length(x1)
    for ix=-NGRD:NGRD
      for iy=-NGRD:NGRD
	xx=x1(n)+ix;
	yy=y1(n)+iy;
	if xx>0 & xx<=sirhead(1) & yy>0 & yy<=sirhead(2)
	  grd(yy,xx)=grd(yy,xx)+TBs(n);
	  ngrd(yy,xx)=ngrd(yy,xx)+1;
	end
      end
    end
  end
  grd(ngrd>0)=grd(ngrd>0)./ngrd(ngrd>0);

  myfigure(5)
  imagesc(grd,sc); colorbar;
  hold on;
  %plot(x01-y0ff,y01-Xoff,'r*');
  plot([pixbox(1) pixbox(2) pixbox(2) pixbox(1) pixbox(1)],[pixbox(3) pixbox(3) pixbox(4) pixbox(4) pixbox(3)],'w');
  hold off;
  xlabel('pixels'); ylabel('pixels');
  axis image
  title(sprintf('DIB at %d pix gridding, single pix posting',2*NGRD+1));
end

%disp('pausing');pause;disp('continuing');

% extract subregion
if 1
  [x,y]=ifsirlex(adds,sirhead); % fortran
  xx=x;
  yy=sirhead(2)-y+1;
  ind=find(xx>pixbox(1)&xx<pixbox(2)&yy>pixbox(3)&yy<pixbox(4));
else
  [x,y]=isirlex(adds,sirhead);  % matlab
  ind=find(x>pixbox(1)&x<pixbox(2)&y>pixbox(3)&y<pixbox(4));
end
adds=adds(ind);
TBs=TBs(ind);
ktimes=ktimes(ind);
counts=counts(ind);
index=index(ind);
ws1=ws1(ind,:);
ls1=ls1(ind,:);

if 0 
  % create and plot a new simulated DIB image
  [x1,y1]=ifsirlex(adds,sirhead);
  y1=sirhead(2)-y1+1;
  grd=zeros([sirhead(2) sirhead(1)]);
  ngrd=zeros([sirhead(2) sirhead(1)]);
  for n=1:length(x1)
    for ix=-NGRD:NGRD
      for iy=-NGRD:NGRD
	xx=x1(n)+ix;
	yy=y1(n)+iy;
	if xx>0 & xx<=sirhead(1) & yy>0 & yy<=sirhead(2)
	  grd(yy,xx)=grd(yy,xx)+TBs(n);
	  ngrd(yy,xx)=ngrd(yy,xx)+1;
	end
      end
    end
  end
  grd(ngrd>0)=grd(ngrd>0)./ngrd(ngrd>0);

  myfigure(15)
  imagesc(grd,sc); colorbar;
  hold on;
  %plot(x01,y01-Yoff,'r*');
  plot([pixbox(1) pixbox(2) pixbox(2) pixbox(1) pixbox(1)],[pixbox(3) pixbox(3) pixbox(4) pixbox(4) pixbox(3)],'w');
  hold off;
  xlabel('pixels'); ylabel('pixels');
  axis image
  title(sprintf('DIB at %d pix gridding, single pix posting',2*NGRD+1));
end

%disp('pausing');pause;disp('continuing');

%
% now reconstruct image from measurements
%

[x,y]=ifsirlex(adds,sirhead); % measurement locations at x-x0, y-y0
y=sirhead(2)-y+1;

fprintf('Region size: %d x %d = %d  Measurements: %d\n',NX,NY,NX*NY,length(x));

% choose reconstruction parameters M1,M2,E1,E2,d1,d2,N1,N2
%%[N1,N2,M1,M2,E1,E2,d1,d2,da1,da2]=select_recon(NX,NY,x-x0,y-y0);
%manually selected values:
N1=44; M1=10; E1=1; d1=2;
N2=62; M2=10; E2=10; d2=2;  % square frequency response
N2=62; M2=15; E2=0; d2=2;   % max frequencies
disp([N1-d1*(2*M1+1+E1) N2-d2*(2*M2+1+E2)]); % should both be zero
da1=N1/(2*M1+1); da2=M2/(2*M2+1);

Ns=length(x); Np=N1*N2; Ma=(2*M1+1)*(2*M2+1); Mm=(2*M1+1+E1)*(2*M2+1+E2);
fprintf('Reconstruction parameters   Ns=%d  Np=%d  Ma=%d  Mm=%d\n',Ns,Np,Ma,Mm);
fprintf('N1,N2: %d x %d  M1,M2: %d, %d  E1,E2: %d, %d  d1,d2: %d, %d\n',N1,N2,M1,M2,E1,E2,d1,d2);

% create periodic sampling and variable aperture sampling matrices

% create Dm kernal centered reconstruction area
%n1=[0:N1-1]; 
%n2=[0:N2-1]; 
%n11=n1-floor(N1/2); n22=n2-floor(N2/2);
%[nn2, nn1]=meshgrid(n11,n22);  % signal dimension (N2 x N1)

% generate an ideal lowpass filter response within reconstruction area
lpf=zeros([N2,N1]); lpf(1:M2+1,1:M1+1)=1; lpf(N2-M2+1:N2,N1-M1+1:N1)=1;
lpf(1:M2+1,N1-M1+1:N1)=1; lpf(N2-M2+1:N2,1:M1+1)=1;

% create centered Dirchlet function
D=shift2d(real(ifft2(lpf)),N2/2,N1/2);
D=D/max(max(D));

if 1
  myfigure(3)
  imagesc(D);colorbar;
  hold on;
  circle((40/2)/8.9,300/8.9,100/8.9,'w'); % add 40 km circle representing 3dB SMAP footprint
  hold off
  xlabel('N_1');ylabel('N_2');
  axis image;
  xlabel('pixels'); ylabel('pixels');
  if PRINT
    print -dpng SMAPdirchelt.png
  end
  title('Centered 2D Dirchlet function');
end

% measurement locations within image area
[x,y]=ifsirlex(adds,sirhead);
y=sirhead(2)-y+1;
x=x-x0;
y=y-y0;
Dnorm=1./sum(sum(D));

% dimension: samples by pixels
D1=zeros([Ns N1*N2]);    % delta function sampling matrix
Dv1=zeros([Ns N1*N2]);   % variable aperture sampling matrix w/o bandlimit
Dv=zeros([Ns N1*N2]);    % variable aperture sampling matrix w/bandlimit
Dg=zeros([Ns N1*N2]);    % simulated dDIB sampling matrix

for n=1:Ns % for each measurement

  % ideal (delta function) sampling, put D at measurement location
  mD=shift2d(D,y(n)-N2/2-1,x(n)-N1/2-1); % dirchlet
  D1(n,:)=mD(:)*Dnorm;
  
  mD=zeros(size(mD)); mD(y(n),x(n))=1;   % delta
  for ix=-NGRD:NGRD
    for iy=-NGRD:NGRD
      xx=x(n)+ix;
      xx(xx<1)=xx(xx<1)+N1;
      xx(xx>N1)=xx(xx>N1)-N1;
      yy=y(n)+iy;
      yy(yy<1)=yy(yy<1)+N2;
      yy(yy>N2)=yy(yy>N2)-N2;
      mD(yy,xx)=1/(NGRD*2+1).^2;  % grd
    end
  end
  %mD=real(ifft2(fft2(mD).*lpf,'symmetric'));
  Dg(n,:)=mD(:);
  
  z=zeros([sirhead(2) sirhead(1)]);  %z(adds(n))=1;  % ideal sampling

  mrf=ws1(n,1:counts(n));
  minmrf=min(mrf(mrf>0));
  mrf(mrf>0)=mrf(mrf>0)-minmrf+0.001;
  mrf=mrf/sum(mrf);
  
  %% fortran/C method  %z(ls1(n,1:counts(n)))=mrf;
  %% but have to convert fortran indexing to use with matlab
  [x1,y1]=ifsirlex(ls1(n,1:counts(n)),sirhead);
  y1=sirhead(2)-y1+1;
  ind=sub2ind(size(z),y1,x1);
  z(ind)=mrf;   % aperture function
  
  if 0 % test
    myfigure(4);clf
    imagesc(z);
    hold on;
    plot(x(n)+x0,y(n)+y0,'w*');
    %plot(x1,y1,'c*');
    %plot(x1,y1,'k.');    
    %plot(x0-Xoff,y0-Yoff,'r*');
    plot([pixbox(1) pixbox(2) pixbox(2) pixbox(1) pixbox(1)],[pixbox(3) pixbox(3) pixbox(4) pixbox(4) pixbox(3)],'w');
    hold off;
    xlabel('pixels'); ylabel('pixels');
    disp('pausing');pause;disp('continuing...');
  end

  % create periodic signal in image box
  ind=find(z>0);
  [r,c]=ind2sub(size(z),ind);
  r=r-y0;
  c=c-x0;
  r(r<=0)=r(r<=0)+N2;
  c(c<=0)=c(c<=0)+N1;
  r(r>N2)=r(r>N2)-N2;
  c(c>N1)=c(c>N1)-N1;
  
  % final periodic aperture function
  Ap=zeros(size(mD));
  ind=sub2ind(size(mD),r,c);
  Ap(ind)=z(z>0);  

  if 0 % test
    myfigure(4)
    imagesc(Ap);
    hold on;
    [r,c]=ind2sub(size(z),adds(n));
    plot(c-x0-1,r-y0,'k*');
    hold off;
    xlabel('pixels'); ylabel('pixels');
    disp('pausing');pause;disp('continuing...');
  end
  
  Dv1(n,:)=Ap(:);
  
  % convolve aperture function with Dirchlet kernal
  Ap=real(ifft2(fft2(Ap).*lpf,'symmetric'));
  Dv(n,:)=Ap(:);  
  
  if 0 % test
    myfigure(4)
    imagesc(Ap);
    disp('pausing');pause;disp('continuing...');
  end
 
end

% compute inverse of sampling matrix
Dvinv=pinv(Dv);  % variable aperture
fv=Dvinv*TBs';
myfigure(9)
fv=reshape(fv,N2,N1);
%imagesc(fv,sc);colorbar;
imagesc(fv);colorbar;
% add plot of island outline
hold on
[xmap,ymap]=plot_local_map(tlon,tlat,sirhead,1,'k',1,x0+Xoff,y0+Yoff,1);
hold off
xlabel('pixels'); ylabel('pixels');
axis image
title(sprintf('condition number %6.2g',cond(Dv)));
%title('Variable aperture inverse');
drawnow
if PRINT
  print -dpng Dvinv.png
end

% regularized variable aperture inversion w/bandlimit
%alpha=0.01;
for alpha=[0 0.0001 0.001 0.01 0.1]
  arg=Dv'*Dv+alpha*eye([size(Dv,2) size(Dv,2)]);
  DvinvR=inv(arg)*Dv';
  r=cond(arg);
  fv1=DvinvR*TBs';
  myfigure(12)
  fv1=reshape(fv1,N2,N1);
  imagesc(fv1,sc);colorbar;
  if 1 % add plot of island outline
    hold on
    plot_local_map(tlon,tlat,sirhead,1,'k',1,x0+Xoff,y0+Yoff,1);
    hold off
  end
  axis image
  xlabel('pixels'); ylabel('pixels');
  drawnow
  if alpha ~= 0
    title(sprintf('condition number %f',r));
  end
  if PRINT
    name=sprintf('Regularized_%5.5d.png',alpha*10000);
    print('-dpng',name)
  end
  %title(sprintf('Regularized Dv inverse alpha=%f',alpha));
end


% regularized variable aperture inversion w/o bandlimit
alpha=0.01;
DvinvR=inv(Dv1'*Dv1+alpha*eye([size(Dv1,2) size(Dv1,2)]))*Dv1';
fv1=DvinvR*TBs';
myfigure(14)
fv1=reshape(fv1,N2,N1);
imagesc(fv1,sc);colorbar;
if 1 % add plot of island outline
  hold on
  plot_local_map(tlon,tlat,sirhead,1,'k',1,x0+Xoff,y0+Yoff,1);
  hold off
end
axis image
xlabel('pixels'); ylabel('pixels');
title(sprintf('Regularized Dv1 inverse alpha=%f',alpha));
drawnow


% delta function inversion w/bandlimit from no aperture sampling matrix
D1inv=pinv(D1);
f1=D1inv*TBs';
myfigure(8)
f1=reshape(f1,N2,N1);
imagesc(f1,sc);colorbar;
if 1 % add plot of island outline
  hold on
  plot_local_map(tlon,tlat,sirhead,1,'k',1,x0+Xoff,y0+Yoff,1);
  hold off
end
axis image
xlabel('pixels'); ylabel('pixels');
drawnow
if PRINT
  print -dpng NoAp.png
end
title('Bandlimited delta function inverse');

if 1 % dDIB gridding from gridded sampling matrix
  fg=reshape((TBs*Dg)./(ones(size(TBs))*Dg),N2,N1);
  myfigure(7)
  fg=reshape(fg,N2,N1);
  imagesc(fg,sc);colorbar;
  if 1 % add plot of island outline
    hold on
    plot_local_map(tlon,tlat,sirhead,1,'k',1,x0+Xoff,y0+Yoff,1);
    hold off
  end
  axis image
  xlabel('pixels'); ylabel('pixels');
  drawnow
  if PRINT
    print -dpng dDIB.png
  end
  title(sprintf('dDIB gridding  size=%d',2*NGRD+1));
end

if 1 % conventional gridding, pixel replicated, from gridded sampling matrix
  fg1=zeros(size(fg));
  for r=1:2*NGRD+1:N2
    for c=1:2*NGRD+1:N1
      for ir=1:2*NGRD+1
	for ic=1:2*NGRD+1
	  fg1(r+ir-1,c+ic-1)=fg(r,c);
	end
      end
    end
  end
  myfigure(18)
  imagesc(fg1);colorbar;
  if 1 % add plot of island outline
    hold on
    plot_local_map(tlon,tlat,sirhead,1,'k',1,x0+Xoff,y0+Yoff,1);
    circle((40/2)/8.9,300/8.9,100/8.9,'w'); % add 40 km circle representing 3dB SMAP footprint
    hold off
  end
  axis image
  xlabel('pixels'); ylabel('pixels');
  drawnow
  if PRINT
    print -dpng GRD.png
  end
  title('Gridding inverse');

  if 0% regularized gridding inversion
    alpha=0.005;
    %alpha=0.015;
    DginvR=inv(Dg'*Dg+alpha*eye([size(Dv,2) size(Dv,2)]))*Dg';
    fg1=DginvR*TBs';
    myfigure(13)
    fg1=reshape(fg1,N2,N1);
    imagesc(fg1,sc);colorbar;
    if 1 % add plot of island outline
      hold on
      plot_local_map(tlon,tlat,sirhead,1,'k',1,x0+Xoff,y0+Yoff,1);
      hold off
    end
    axis image
    xlabel('pixels'); ylabel('pixels');
    title(sprintf('Regularized Dg inverse alpha=%f',alpha));
  end
end
  
if 1 % generate and display AVE & rSIR from matrix
  ave=reshape((TBs*Dv)./(ones(size(TBs))*Dv),N2,N1);
  myfigure(1)
  imagesc(ave,sc); colorbar;
  title('AVE from matrix');
  axis image
  xlabel('pixels'); ylabel('pixels');
  
  sir=(TBs*Dv)./(ones(size(TBs))*Dv);
  niter=10;
  for i=1:niter
    fp=Dv*sir';
    err=TBs-fp';
    update=(err*Dv)./(ones(size(err))*Dv);
    sir=sir+update;
  end
  sir=reshape(sir,N2,N1);
  myfigure(2)
  imagesc(sir,sc); colorbar;
  if 1 % add plot of island outline
    hold on
    plot_local_map(tlon,tlat,sirhead,1,'k',1,x0+Xoff,y0+Yoff,1);
    hold off
  end
  axis image
  xlabel('pixels'); ylabel('pixels');
  title(sprintf('Linearized rSIR from matrix %d iter',niter));
  drawnow
end

if 0 % generate and display dDIB from measurement list
  grd=zeros([N2 N1]);
  ngrd=zeros([N2 N1]);
  for n=1:Ns  
    for ix=-NGRD:NGRD
      for iy=-NGRD:NGRD
	xx=x(n)+ix;
	xx(xx<1)=xx(xx<1)+N1;
	xx(xx>N1)=xx(xx>N1)-N1;
	yy=y(n)+iy;
	yy(yy<1)=yy(yy<1)+N2;
	yy(yy>N2)=yy(yy>N2)-N2;
	grd(yy,xx)=grd(yy,xx)+TBs(n);
	ngrd(yy,xx)=ngrd(yy,xx)+1;
      end
    end
  end
  grd(ngrd>0)=grd(ngrd>0)./ngrd(ngrd>0);

  myfigure(16)
  imagesc(grd,sc); colorbar;
  if 1 % add plot of island outline
    hold on
    plot_local_map(tlon,tlat,sirhead,1,'k',1,x0+Xoff,y0+Yoff,1);
    hold off
  end
  axis image
  xlabel('pixels'); ylabel('pixels');
  title(sprintf('DIB at %d pix gridding, single pix posting',2*NGRD+1));
end

if 0 % generate and display ave from measurement list
  ave=zeros([N2 N1]);
  nave=zeros([N2 N1]);
  for n=1:Ns  
    mrf=ws1(n,1:counts(n));
    minmrf=min(mrf(mrf>0));
    mrf(mrf>0)=mrf(mrf>0)-minmrf+0.001;
    mrf=mrf/sum(mrf);
    
    [x1,y1]=ifsirlex(ls1(n,1:counts(n)),sirhead);
    y1=sirhead(2)-y1+1;
    ind=sub2ind([sirhead(2),sirhead(1)],y1,x1);
    %z(ind)=mrf;   %aperture function
   
    for k=1:length(ind)
      xx=x1(k)-x0;
      xx(xx<1)=xx(xx<1)+N1;
      xx(xx>N1)=xx(xx>N1)-N1;
      yy=y1(k)-y0;
      yy(yy<1)=yy(yy<1)+N2;
      yy(yy>N2)=yy(yy>N2)-N2;
      ave(yy,xx)=ave(yy,xx)+mrf(k)*TBs(n);
      nave(yy,xx)=nave(yy,xx)+mrf(k);
    end
  end
  ave(nave>0)=ave(nave>0)./nave(nave>0);

  myfigure(17)
  imagesc(ave,sc); colorbar;
  if 1 % add plot of island outline
    hold on
    plot_local_map(tlon,tlat,sirhead,1,'k',1,x0+Xoff,y0+Yoff,1);
    hold off
  end
  axis image
  xlabel('pixels'); ylabel('pixels');
  title('AVE');
end


if 0 % extract info for single pixel
  ix0=floor(mean(pixbox(1:2)));
  iy0=floor(mean(pixbox(3:4)));
  % center pixel
  ipix=(iy0-1)*sirhead(1)+ix0-1; % 0-based pixel index [NOT 1-based]
  %
  [tbs,cnts,ths,adds,ts,wts,w,l]=single_pixel(setuphead,store,pcnt,mind,ipix);
  m=length(tbs);
  N=length(tbs);
  TbAve=sum(tbs.*wts)/sum(wts); % AVE value

  % plot measurement locations
  [x,y]=ifsirlex(adds,sirhead);
  [lons,lats]=pix2latlon(x,y,sirhead);
  myfigure(1);clf
  plot(x,y,'k.');
  myfigure(2);clf
  plot(lons,lats,'k.');
end

if 0 % do local sir (does not work)
  ix0=floor(mean(pixbox(1:2)));
  iy0=floor(mean(pixbox(3:4)));
  % center pixel
  ipix=(iy0-1)*sirhead(1)+ix0-1; % 0-based pixel index [NOT 1-based]
  %
  iterlist=[1 10 20 30];
  %iterlist=[1 2 3 4 5 6 7 8 10 15 20 25 30 35 40 50];
  [imgs,ave,minc,stdinc,grd,gcnt]=sir_iter_process(setuphead,store,pcnt,pixbox,iterlist,ipix,gain_thres);

  aveval=ave(ix-x0,iy-y0)
  sirval=squeeze(imgs(ix-x0,iy-y0,:));
  xv=(ix-x0)/non_size_x+1;
  yv=(iy-y0)/non_size_y+1;
  grdval=grd(xv,yv)
end


% create a synthetic image
true_ocean=75;
true_land=175;
true=zeros([N2,N1])+true_ocean;
for i=1:length(xmap)-1
  x=round(xmap(i));
  y=round(ymap(i));
  if x>0&x<=N1&y>0&y<=N2
    true(y,x)=true_land;
  end
end
if 0 % test
  myfigure(101)
  imagesc(true); colorbar;
  axis image; title('true');
end
for c=1:N1
  ind=find(true(:,c)==true_land);
  if length(ind)>1
    for r=min(ind):max(ind)
      true(r,c)=true_land;
    end
  end
end
myfigure(100)
imagesc(true,sc); colorbar;
if 1 % add plot of island outline
  hold on
  plot_local_map(tlon,tlat,sirhead,1,'k',1,x0+Xoff,y0+Yoff,1);
  hold off
end
axis image
xlabel('pixels'); ylabel('pixels');
title('true');
drawnow
if PRINT
  print -dpng true.png
end

btrue=real(ifft2(fft2(true).*lpf,'symmetric'));
myfigure(102)
imagesc(btrue,sc); colorbar;
if 1 % add plot of island outline
  hold on
  plot_local_map(tlon,tlat,sirhead,1,'k',1,x0+Xoff,y0+Yoff,1);
  hold off
end
axis image
xlabel('pixels'); ylabel('pixels');
title('bandlimited true');
drawnow
if PRINT
  print -dpng btrue.png
end

% create simulated measurements
sbTBs=Dv*btrue(:);
sTBs=Dv*true(:);  
s1bTBs=Dv1*btrue(:);
s1TBs=Dv1*true(:);
% RMS differences
disp(norm(sbTBs-sbTBs)/Ns);  % nominally 0
disp(norm(sTBs-sbTBs)/Ns);   % nominally 0
disp(norm(s1bTBs-sbTBs)/Ns); % nominally 0
disp(norm(s1TBs-sbTBs)/Ns);  % not zero since s1TBs not bandlimited

% reconstruct various cases from simulated measurements
sb=Dvinv*sbTBs;
s=Dvinv*sTBs;     
s1b=Dvinv*s1bTBs;
s1=Dvinv*s1TBs;
% RMS differences
%disp(norm(s-sb)/Np);        % s identical to sb within numerical limits
%disp(norm(s1b-sb)/Np);      % s1b identical to sb within numerical limits
%disp(norm(s1-s)/Np);        % s1 different from sb since not bandlimited
% RMS errors
fprintf('s-true rms=%f\n',rms(s-true(:)));
fprintf('s-btrue rms=%f\n',rms(s-btrue(:)));
fprintf('s1-true rms=%f\n',rms(s1-true(:)));
fprintf('s1-btrue rms=%f\n',rms(s1-btrue(:)));

% display results
myfigure(109)
sb=reshape(sb,N2,N1);
imagesc(sb,sc);colorbar;
% add plot of island outline
hold on
[xmap,ymap]=plot_local_map(tlon,tlat,sirhead,1,'k',1,x0+Xoff,y0+Yoff,1);
hold off
xlabel('pixels'); ylabel('pixels');
axis image
drawnow
if PRINT
  print -dpng sb.png
end
title('noise-free bandlimited');

if 1
  myfigure(110)
  s1=reshape(s1,N2,N1);
  imagesc(s1,sc);colorbar;
  % add plot of island outline
  hold on
  [xmap,ymap]=plot_local_map(tlon,tlat,sirhead,1,'k',1,x0+Xoff,y0+Yoff,1);
  hold off
  xlabel('pixels'); ylabel('pixels');
  axis image
  drawnow
  if PRINT
    print -dpng s1.png
  end
  title('noise-free');
end

% show regularized case
% regularized variable aperture inversion w/bandlimit
for alpha=[0 1e-10 0.000001 0.00001 0.0001 0.001 0.01 0.1]
%for alpha=[1e-14 1e-13 1e-12 1e-11 1e-10]
  %tic
  arg=Dv'*Dv+alpha*eye([size(Dv,2) size(Dv,2)]);
  DvinvR=inv(arg)*Dv';
  %toc
  r=cond(arg);

  if 0
   for alpha=[1e-10 0.000001 0.00001 0.0001 0.001 0.01 0.1 1 10]
    p=pseudoinverse(Dv,alpha,'LSQR');
    DvinvR=reshape(p.A,p.Msize);
    r=cond(DvinvR);
    sbr=DvinvR*sbTBs;
    sbr=reshape(sbr,N2,N1);
    s1r=DvinvR*s1TBs;
    s1r=reshape(s1r,N2,N1);
    fprintf(' alpha=%7.5g cd=%6.2g   s1 rms=%f s1b rms=%f  sbr rms=%f\n',alpha,r,rms(s1r-true),rms(s1r-btrue),rms(sbr-btrue));
   end
  end
   
  myfigure(112)
  sbr=DvinvR*sbTBs;
  sbr=reshape(sbr,N2,N1);
  imagesc(sbr,sc);colorbar;
  hold on
  plot_local_map(tlon,tlat,sirhead,1,'k',1,x0+Xoff,y0+Yoff,1);
  hold off
  axis image
  xlabel('pixels'); ylabel('pixels');
  drawnow
  if PRINT
    name=sprintf('sbrRegularized_%5.5d.png',alpha*10000);
    print('-dpng',name)
  end
  
  myfigure(113)
  s1r=DvinvR*s1TBs;
  s1r=reshape(s1r,N2,N1);
  imagesc(s1r,sc);colorbar;
  hold on
  plot_local_map(tlon,tlat,sirhead,1,'k',1,x0+Xoff,y0+Yoff,1);
  hold off
  axis image
  xlabel('pixels'); ylabel('pixels');
  drawnow
  if PRINT
    name=sprintf('s1rRegularized_%5.5d.png',alpha*10000);
    print('-dpng',name)
  end

  fprintf(' alpha=%7.5g cd=%6.2g  s1 rms=%f  s1b rms=%f  sbr rms=%f\n',alpha,r,rms(s1r-true),rms(s1r-btrue),rms(sbr-btrue));
end

% now add noise to the simulated measurement and do reconstruction
DeltaT=1.3; % K
noise=DeltaT*randn(size(sbTBs));
sb=Dvinv*(sbTBs+noise);
s=Dvinv*(sTBs+noise);     
s1b=Dvinv*(s1bTBs+noise);
s1=Dvinv*(s1TBs+noise);
% RMS differences
%disp(norm(s-sb)/Np);        % s identical to sb within numerical limits
disp(norm(s1b-sb)/Np);      % s1b identical to sb within numerical limits
%disp(norm(s1-s)/Np);        % s1 different from sb since not bandlimited
% RMS errors
fprintf('Noisy s-true rms=%f\n',rms(s-true(:)));
fprintf('Noisy s-btrue rms=%f\n',rms(s-btrue(:)));
fprintf('Noisy sb-true rms=%f\n',rms(sb-true(:)));
fprintf('Noisy sb-btrue rms=%f\n',rms(sb-btrue(:)));
fprintf('Noisy s1-true rms=%f\n',rms(s1-true(:)));
fprintf('Noisy s1-btrue rms=%f\n',rms(s1-btrue(:)));
fprintf('Noisy s1b-true rms=%f\n',rms(s1b-true(:)));
fprintf('Noisy s1b-btrue rms=%f\n',rms(s1b-btrue(:)));

myfigure(119)
sb=reshape(sb,N2,N1);
imagesc(sb,sc);colorbar;
% add plot of island outline
hold on
[xmap,ymap]=plot_local_map(tlon,tlat,sirhead,1,'k',1,x0+Xoff,y0+Yoff,1);
hold off
xlabel('pixels'); ylabel('pixels');
axis image
drawnow
title('noisy bandlimited');

% regularized variable aperture inversion w/bandlimit
for alpha=[0 1e-10 0.000001 0.00001 0.0001 0.001 0.01 0.1]
%for alpha=[1e-14 1e-13 1e-12 1e-11 1e-10]
  %tic
  arg=Dv'*Dv+alpha*eye([size(Dv,2) size(Dv,2)]);
  DvinvR=inv(arg)*Dv';
  %toc
  r=cond(arg);

  if 0
   for alpha=[1e-10 0.000001 0.00001 0.0001 0.001 0.01 0.1 1 10]
    p=pseudoinverse(Dv,alpha,'LSQR');
    DvinvR=reshape(p.A,p.Msize);
    r=cond(DvinvR);
    sbr=DvinvR*(sbTBs+noise);
    sbr=reshape(sbr,N2,N1);
    s1r=DvinvR*(s1TBs+noise);
    s1r=reshape(s1r,N2,N1);
    fprintf(' alpha=%7.5g cd=%6.2g s1b rms=%f  sbr rms=%f\n',alpha,r,rms(s1r-btrue),rms(sbr-btrue));
   end
  end
   
  myfigure(122)
  sbr=DvinvR*(sbTBs+noise);
  sbr=reshape(sbr,N2,N1);
  imagesc(sbr,sc);colorbar;
  hold on
  plot_local_map(tlon,tlat,sirhead,1,'k',1,x0+Xoff,y0+Yoff,1);
  hold off
  axis image
  xlabel('pixels'); ylabel('pixels');
  drawnow
  if PRINT
    name=sprintf('nsbrRegularized_%5.5d.png',alpha*10000);
    print('-dpng',name)
  end
  
  myfigure(123)
  s1r=DvinvR*(s1TBs+noise);
  s1r=reshape(s1r,N2,N1);
  imagesc(s1r,sc);colorbar;
  hold on
  plot_local_map(tlon,tlat,sirhead,1,'k',1,x0+Xoff,y0+Yoff,1);
  hold off
  axis image
  xlabel('pixels'); ylabel('pixels');
  drawnow
  if PRINT
    name=sprintf('ns1rRegularized_%5.5d.png',alpha*10000);
    print('-dpng',name)
  end

  fprintf(' alpha=%7.5g cd=%6.2g  s1 rms=%f  s1b rms=%f  sbr rms=%f\n',alpha,r,rms(s1r-true),rms(s1r-btrue),rms(sbr-btrue));
end
