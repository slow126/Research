%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) copyright 2016, 2018 David G. Long, Brigham Young University
%
% simple 2D simulation driver code for simplified SIR algorithm
% implemenation for SMAP
%
% written by D. Long at BYU 19 Nov 2016 + based on SSM/I simulator
% modified by D. Long at BYU  2 Jan 2018 + add SMAP grid option
%
% This is a simple simulation of how combining multiple measurements
% with SIR can significantly improve the effective resolution of the
% estimated TB image.  The simulated geometry is based on SMAP radiometer.
%
% general program flow:
%  first, create sample locations based on simple instrument simulation
%  sedond, create simulated response function for measurements
%  third, define the final image size/resolution
%  fourth, create a synthetic "truth" image
%  fifth, generate simulated measurements from truth image and 
%           write to .setup file
%  sixth, use sim_SIR.c to process the .setup file into GRD, SIR and 
%           AVE images for noisy and noise-free cases
%  seventh, read resulting .SIR-formatted files, plot, and compute error
%  eighth, generate .SIR file images versus iteration and create plots
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
% set flags useful for debugging
% RUN_SETUP=0; % do not regenerate setup files
RUN_SETUP=1; % generate setup files
% RUN_SIR=0; % skip running external SIR programs when set to zero
RUN_SIR=1; % run external SIR programs if set to one

SMAP_grid=0; % use CETB 25 km base grid size, 25/2^Nscale
%SMAP_grid=1; % use SMAP 36 km base grid size, 36/2^Nscale
%SMAP_grid=2; % use SMAP 36 km base grid size, SMAP irregular size steps

if 1 % set default parameters that control font size when printing to improve figure readability
   set(0,'DefaultaxesFontName','Liberation Sans');
   set(0,'DefaultaxesFontSize',18);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step Zero:
% set simulation parameters
%
workdir='./';

% define the possible run cases

% number of passes over target area (uncomment one line)
Npass=1;   % single pass
Npass=2;   % two passes

% choose one frequency channel to uncomment
chan=1; % 1.4135 GHz channel

% Output image scaline (uncomment one line)
Nscale=3;           % output image scaling factor

% set simulation options for looping

% list of number of passes to actually process
Npass_list=1:2;
% list of channels to process
chan_list=[1];
% list of scaling parameters to consider
Nscale_list=2:4;

% over-ride for actual processing
Npass_list=2;
Nscale_list=0:4; % CETB
Nscale_list=3
if SMAP_grid > 1
  Nscale_list=1:6; % SMAP
  %Nscale_list=6
end

% loop over simulation run options
for Npass=Npass_list
  for chan=chan_list
    for Nscale=Nscale_list
      disp(sprintf('Working on Npass=%d Channel=%d Nscale=%d',Npass,chan,Nscale));
%
% set swath parameters
%
PRI=2.6*4*1.4e-3;       % pulse repetition interval in s
%PRI=4.1;            % pulse repetition interval in s
PRF=1/PRI;          % pulse repetition frequency in Hz
swathwidth=990;     % swath width in km
scvel=7.6;          % nominal s/c ground track velocity in km/sec
rotrate=14.6/60;    % rotation vel in rot/sec (can be 13-14.6 rpm)
srate=PRI;          % sample interval in sec
%frequency=1413.6e6; % radiometer center frequency in Hz
%incangle=40;        % nominal radiometer incidence angle in deg
%OrbitHeight=685;    % nominal orbit altitude in km
%EFOV spacing at equator is approx 11km X 31 km near swath center
%bandwidth=24e6;     % radiometer bandwidth in Hz
%inttime=4*0.3e-3;   % radiometer integration time in s
%DeltaT=290/sqrt(inttime*bandwidth); % noise STD (in K) for signal simulation
DeltaT=1.0;         % thermal noise STD (in K) for signal simulation
AntAzAngRange=180+[-89,89]; % angular range of swath
rotrad=swathwidth/sin((AntAzAngRange(2)-180)*pi/180)/2;
thres=0.001;        % set response threshold for output to .setup file (-30dB)

% set default number of iterations
if Nscale <= 3
  Nom_iter=30;      % nominal number of SIR iterations to run 
  maxiter=100;      % number of SIR iterations for this simulation
else
  Nom_iter=20;      % nominal number of SIR iterations to run 
  maxiter=50;       % number of SIR iterations for this simulation
end
  
% set channel-specific parameters
footprint=[39,47];   % effective 3dB footprint size in km

% define CETB output resolution in km/pix
%grid_multiple=36*25*2; % size that can be evenly divided by any sampspacing
grid_multiple=24*25; % size that can be evenly divided by any sampspacing       
Min_scale=4;
common_scale=1/2^Min_scale; % common km/pix
grd_size=25.0;              % default nominal grd pixel size in km
sampspacing=25.0/2^Nscale;  % default sir, ave pixel resolution in km/pix
Nfactor=2^Nscale;
%Wfactor=25*2^(Min_scale-Nscale);
Wfactor=sampspacing/common_scale;
grd_char='s';
if SMAP_grid==1  % basic SMAP grid
  grd_size=36.0;              % nominal grd pixel size in km
  sampspacing=36.0/2^Nscale;  % sir, ave pixel resolution in km/pix
  %Wfactor=24*2^(Min_scale-Nscale);
  Wfactor=sampspacing/common_scale;
  grd_char='t';  % more SMAP grids
elseif SMAP_grid==2
  grd_size=36.0;              % nominal grd pixel size in km
  grd_char='u';
  switch Nscale
    case 0
      sampspacing=36;   % sir, ave pixel resolution in km/pix
    case 1
      sampspacing=18;
    case 2
      sampspacing=12; 
    case 3
      sampspacing=9;
    case 4
      sampspacing=6;  
    case 5
      sampspacing=3;  
    case 6
      sampspacing=1.5;
    case 7
      sampspacing=1;
  end
  Wfactor=sampspacing/common_scale;
end

% generate working directory name
workdir=sprintf('Ch%d_P%d_N%c%d',chan,Npass,grd_char,Nscale);
cpwd=pwd();
if exist(workdir,'dir') ~=7
  mkdir(cpwd,workdir);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step One:
% compute approximate sample locations for a simulated SSM/I-like single
% channel radiometer

% generate simulated sampling locations
swathlen=swathwidth;  % swath length for simulation
sec=(swathlen*2+swathwidth)/scvel; % seconds of data
time=[0:srate:sec];     % time axis in sec
ang=time*rotrate*360.0; % antenna angle in deg

if 0 % select only sample points within swath antenna azimuth range
   ind=find(mod(ang,360.0)>min(AntAzAngRange) & mod(ang,360.)<=max(AntAzAngRange));
   time=time(ind);
   ang=ang(ind);
end

% compute measurement locations relative to nadir track
x0=0; y0=-swathwidth/2; % swath orgin
along1=y0+cos(ang*pi/180)*rotrad+time*scvel;
cross1=x0+sin(ang*pi/180)*rotrad;

along_loc=along1;
cross_loc=cross1;
ant_ang=ang;

% now simulate multiple passes
% note: the multiple pass geometry varies with latitude. for this
% simulation a single particular location is treated.  for simplicity
% the relative scan angles previously computed are used
along0=swathlen/2;
cross0=0;
for pass=2:Npass
  rot=(pass-1)*20;
  rot0=rot*pi/180;
  cshift=(pass-1)*300;
  
  a=along0+cos(rot0)*(along1-along0)+sin(rot0)*(cross1-cross0);
  c=cshift-sin(rot0)*(along1-along0)+cos(rot0)*(cross1-cross0);

  along_loc=[along_loc a];
  cross_loc=[cross_loc c];  
  ant_ang=[ant_ang ang+rot];
end
along1=along_loc;
cross1=cross_loc;
ang=ant_ang;

% save space
clear a c along_loc cross_loc ant_ang time
  
if 1 % For convenence, select only part of swath width to analyze
   ind=find(along1 >= -25 & along1 <= swathlen+25 & ...
            cross1 >= -25 & cross1 <= swathwidth/2+25);
   ind=find(along1 >= -25 & along1 <= swathlen+25 & ...
            cross1 >= -swathwidth/2-25 & cross1 <= swathwidth/2+25);
 
   along=along1(ind);
   cross=cross1(ind);
   ang=ang(ind);
else
   along=along1;
   cross=cross1;
end

if 1   % show measurement locations
  myfigure(3)
  plot(cross,along,'.')  % antenna boresite positions
  title('Boresite locations along-scan')
  xlabel('Cross-track distance (km)')
  ylabel('Along-track distance (km)')
  %axis([0 swathwidth/2 0 swathlen])
  axis([0 500 0 500])
  print('-dpng',[workdir,'/boresite.png']);
  %disp('pausing...'); pause; disp('continuing...');
end

% show measurements locations and swath density
myfigure(1)
h=subplot(2,1,2);
plot(cross,along,'.')  % center positions
%title('Measurement locations')
xlabel('Cross-track dis (km)')
ylabel('Along-track dis (km)')
%axis([0 swathwidth/2 0 swathlen])
axis([0 500 0 100])
grid on;
set(h,'Ytick',[0 25 50 75 100]);
subplot(2,1,1)
xhist=0:25:500;
nh=histc(cross,xhist);
plot(xhist,25*nh/swathlen)
title('Measurement density in 25 km X 25 km area')
xlabel('Cross-track distance (km)')
ylabel('Count')
axis([0 500 0 25])
print('-dpng',[workdir,'/MeaslocDensity.png'])

%disp('Measurement locations computed.  Hit return to continue.'); pause; disp('continuing...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step Two:
% create measurement responses

% set footprint measurement response size
MajorAxis=max(footprint);
MinorAxis=min(footprint);

% generate a centered local grid
Ngrid=ceil(2*MajorAxis/sampspacing);
if mod(Ngrid,2)==0
  Ngrid=Ngrid+1;
end
x=((1:Ngrid)-floor(Ngrid/2)-1)*sampspacing;
y=((1:Ngrid)-floor(Ngrid/2)-1)*sampspacing;
[X, Y]=meshgrid(x,y);

if 1 % compute an example at a particular location and orientation
  x0=X(Ngrid/2+0.5,Ngrid/2+0.5);
  y0=Y(Ngrid/2+0.5,Ngrid/2+0.5);
  ang0=30*pi/180;

  xx= (X-x0)*cos(ang0)+(Y-y0)*sin(ang0);
  yy=-(X-x0)*sin(ang0)+(Y-y0)*cos(ang0);
  xx=xx/MajorAxis;
  yy=yy/MinorAxis;

  kang=atan2(yy,xx);
  x1=zeros(size(xx)); ind=find(cos(kang)~=0); x1(ind)=xx(ind)./cos(kang(ind));
  y1=zeros(size(yy)); ind=find(sin(kang)~=0); y1(ind)=yy(ind)./sin(kang(ind));
  V=exp(-x1.*x1).*exp(-y1.*y1);

  % truncate response
  V(V<thres)=0;

  myfigure(2);
  % show a sample measurement response
  imagesc(x,y,V); h=colorbar; set(h,'FontSize',12);
  xlabel('km');ylabel('km')
  %h=title(sprintf('Chan: %d  Resolution: %0.4f km/pix  size: %dx%d km',chan,sampspacing,footprint)); set(h,'FontSize',12); 
  h=title(sprintf('Resolution: %0.3f km/pix  size: %dx%d km',sampspacing,footprint)); set(h,'FontSize',12); 
  print('-dpng',[workdir,'/MRF.png']);
  drawnow
  
  myfigure(200)
  % show 3d sample measurement response
  surf(V)
  xlabel('km'); ylabel('km');
  print('-dpng',[workdir,'/MRF3d.png']);
  %disp('pausing');pause; disp('continuing...');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3: define output image grid

% define processing grid for the output
M=floor(swathlen/sampspacing);
if (floor(M/2)*2 ~= M)
  M=M+1;
end
N=floor((swathwidth/2)/sampspacing);
if (floor(N/2)*2 ~= N)
  N=N+1;
end

fprintf('Image size: %dx%d  Nscale=%d  spacing=%f %f %d %d\n',M,N,Nscale,sampspacing,grid_multiple,Nfactor,Wfactor);

% define the image bandlimit to fixed bandwidth
BL=0.3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4:
% create a synthetic image to generate simulated measurements
% (quite arbitrary)

% first is generated at the highest resolution considered (Mfactor=2^4) and
% sub-sample to the size of interest
%M1=M*Wfactor; % Mfactor/Nfactor;
%N1=N*Wfactor; % Mfactor/Nfactor;
M1=round(M*sampspacing/common_scale);
N1=round(N*sampspacing/common_scale);
fprintf('Image size: %dx%d  %dx%d Nscale=%d  spacing=%d  %dx%d\n',M,N,M1,N1,Nscale,Wfactor,length(1:Wfactor:M1),length(1:Wfactor:N1));

% generate an image with background
true=zeros([M1 N1])+200;  % ocean
true(M1/2:M1,1:N1)=230;   % add some land
true(M1/2:M1,1:N1/2)=220; % add some land

sf=floor(3.125/common_scale/2);
wide=-2*sf:2*sf;
% add some thin line features
true(floor(M1/3)+wide,:)=240;
true(:,max(1,floor(2*N1/3)+wide-10*sf))=240;

% add gradients
for i=1:N1
  true(floor(5*M1/6):M1,i)=200+i*(250-200)/N1;
end
for i=floor(M1/6):M1
  true(i,1:floor(N1/6))=200+i*(250-200)/(5*M1/6);
end

% add some warm spots
const=250;
true(floor(M1/2)+10*sf:floor(M1/2)+40*sf,max(1,floor(N1/2)-50*sf):floor(N1/2)-20*sf)=250;
true(floor(2*M1/3):floor(2*M1/3)+20*sf,floor(2*N1/3)+15*sf:floor(2*N1/3)+35*sf)=const;
true(floor(2*M1/3):floor(2*M1/3)+16*sf,max(1,floor(  N1/3)-16*sf):floor(  N1/3))=const;
true(floor(2*M1/3):floor(2*M1/3)+12*sf,max(1,floor(  N1/2)-12*sf):floor(  N1/2))=const;
true(floor(M1/6):floor(M1/6)+16*sf,floor(2*N1/3)+9*sf:floor(2*N1/3)+26*sf)=const;
true(floor(M1/6):floor(M1/6)+12*sf,floor(  N1/2)+9*sf:floor(  N1/2)+22*sf)=const;
true(floor(M1/6):floor(M1/6)+ 8*sf,floor(  N1/3)+9*sf:floor(  N1/3)+18*sf)=const;

% display true image
myfigure(41)
%myfigure(4+Nscale*10+100)
colormap('gray')
imagesc(flipud(true')); h=colorbar; set(h,'FontSize',12);
title('True image')
axis off
axis image

%disp('Non-Bandlimited True image created.  Hit return to continue.'); pause; disp('continuing...');
% bandlimit true image to ensure Nyquist criterion is met for
% sampling and reconstruction.  Multiple filtering passes ensures out-of-band
% signal is small and prevents negative TB values
BL1=floor(M1*BL*0.5/sf);
BL2=floor(N1*BL*0.5/sf);
true=bandlimit2d2(true,BL1,BL2,0);
true=abs(true);
true=bandlimit2d2(true,BL1,BL2,0);
true=abs(true);

% reduce image size by subsampling
w=Wfactor; % Mfactor/Nfactor;
strue=true(1:w:M1,1:w:N1);
true=strue;

% last bandlimit pass
%BL1=floor(M*BL*0.5);
%BL2=floor(N*BL*0.5);
%true=bandlimit2d2(true,BL1,BL2,0);
%true=abs(true);

% display true image
myfigure(4)
%myfigure(4+Nscale*10+100)
colormap('gray')
imagesc(flipud(true')); h=colorbar; set(h,'FontSize',12);
title('True image')
axis off
axis image
print('-dpng',[workdir,'/true.png']);

%disp('Bandlimited True image created.  Hit return to continue.'); pause; disp('continuing...');

% convert 2d image into a linear array for storage and processing
true1=reshape(true,1,M*N);

if 1 % do rest

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 5:
% for each measurement, write measurement and response to the .setup file

outfile=[workdir '/sir.setup'];
if RUN_SETUP
% first, write the setup file header and true image to .setup file
disp(sprintf('Creating output file: %s',outfile));
fid=fopen(outfile,'w');

fwrite(fid,[M, N],'int32');         % write image size
fwrite(fid,sampspacing,'float32');  % write pixel resolution
fwrite(fid,grd_size,'float32');     % write GRD pixel size
fwrite(fid,true1,'float32');        % write "truth" image

% for each measurement, compute the response function
nn=length(along);
disp(['Size: ',num2str(M),' x ',num2str(N),'  Meas: ',num2str(nn)])
cnt=0;
% for each masuremement
for i=1:nn
  ia=fix(along(i)/sampspacing);
  ic=fix(cross(i)/sampspacing);
  if ia > 0 & ia < M+1 & ic > 0 & ic < N+1  
  
    % compute nominal measurement response function
    Ang=ang(i)*pi/180;
    xx= X*cos(Ang)+Y*sin(Ang);
    yy=-X*sin(Ang)+Y*cos(Ang);
    xx=xx/MajorAxis;
    yy=yy/MinorAxis;

    kang=atan2(yy,xx);
    x1=zeros(size(xx));
    ind=find(cos(kang)~=0); 
    x1(ind)=xx(ind)./cos(kang(ind));
    y1=zeros(size(yy));
    ind=find(sin(kang)~=0); 
    y1(ind)=yy(ind)./sin(kang(ind));
  
    % response function
    aresp=exp(-x1.*x1).*exp(-y1.*y1);

    % plot response function fpr testing
    %myfigure(5)
    %imagesc(x,y,aresp);h=colorbar; set(h,'FontSize',12);
    %title(sprintf('Angle: %f',ang(i)));
    %disp('pausing...');pause; disp('continuing...');

    % center response function at measurement location
    Xloc=X+cross(i);
    Yloc=Y+along(i);
    Xloc1=fix(Xloc/sampspacing);
    Yloc1=fix(Yloc/sampspacing);

    %disp(sprintf('%d of %d: %f,%f %d,%d',i,nn,cross(i),along(i),fix(cross(i)/sampspacing),fix(along(i)/sampspacing)));
  
    % find valid pixels of measurement within image area
    ind=find(Xloc1>0 & Xloc1 <=N & Yloc1>0 & Yloc1 <=M & ...
	reshape(aresp,size(Xloc))>thres);

    if ~isempty(ind) 
      
      pointer=sub2ind([M,N],fix(Yloc1(ind)),fix(Xloc1(ind)));
      iadd=sub2ind([M,N],fix(along(i)/sampspacing),fix(cross(i)/sampspacing))-1;
    
      % response function with area
      aresp1=aresp(ind).'/sum(aresp(ind));
      
      % generate synthetic measurement
      z=sum(true1(pointer).*aresp1);  % noise-free
      z1=z+randn(size(z))*DeltaT;   % add noise
      
      % save measurement and associated response function to .setup file
      fwrite(fid,[iadd length(pointer)],'int32');
      fwrite(fid,[z z1],'float32');
      fwrite(fid,pointer,'int32');
      fwrite(fid,aresp1,'float32');
      cnt=cnt+1;
    
      if 0
	disp(sprintf('keep %d of %d: %f %f %d %d %d %d,%d',i,nn,z,z1,iadd,length(pointer),prod(size(X)),ia,ic));
	myfigure(6)
	subplot(1,2,1)
	imagesc(x,y,aresp);h=colorbar; set(h,'FontSize',12);
	h=title(sprintf('Angle: %f',mod(ang(i),360.0))); set(h,'FontSize',12);
	axis image
	subplot(1,2,2)
	bp=zeros(size(true));
	bp(pointer)=aresp1/max(aresp1);
	imagesc(bp);h=colorbar; set(h,'FontSize',12); set(h,'FontSize',12);
	h=title(sprintf('max: %f',max(aresp1)));
	disp('pausing...');pause; disp('continuing...');
      end

      if mod(i,1000)==1
	disp(sprintf('progress %d %f %f %d %d %d %d,%d',i,z,z1,iadd,length(pointer),nn,ia,ic));
      end
    end
  end
end

disp(sprintf('wrote %d measurements', cnt));
% close output file
fclose(fid);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step six:
%  run external sir program
%

if RUN_SIR
  % run SIR/AVE and default DIB GRD
  % noise-free
  cmd=sprintf('./sim_SIR %s 0 0 %d %s', outfile,Nom_iter,workdir);
  system(cmd);

  % noisy
  cmd=sprintf('./sim_SIR %s 0 1 %d %s', outfile,Nom_iter,workdir);
  system(cmd);

  % run multiple gridding options (DIB0, DIB1, IDG1)
  % noise-free
  cmd=sprintf('sim_GRDs %s 0 0 %s', outfile,workdir);
  system(cmd);

  % noisy
  cmd=sprintf('sim_GRDs %s 0 1 %s', outfile,workdir);
  system(cmd);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step seven:
%  load and display image results
%
[tr h_t]=loadsir([workdir, '/true.sir']);

% noise-free
[fAg h_fAg]=loadsir([workdir, '/simA.grd']);
[fAn h_fAn]=loadsir([workdir, '/simA.non']);
[fAa h_fAa]=loadsir([workdir, '/simA.ave']);
[fAs h_fAs]=loadsir([workdir, '/simA.sir']);
[fAn_DIB0 h]=loadsir([workdir, '/simA.non_DIB0']); % should be same as simA.non
[fAn_DIB1 h]=loadsir([workdir, '/simA.non_DIB1']);
[fAn_IDG1 h]=loadsir([workdir, '/simA.non_IDG1']);

% noisy
[nAg h_nAg]=loadsir([workdir, '/simA2.grd']);
[nAn h_nAn]=loadsir([workdir, '/simA2.non']);
[nAa h_nAa]=loadsir([workdir, '/simA2.ave']);
[nAs h_nAs]=loadsir([workdir, '/simA2.sir']);
[nAn_DIB0 h]=loadsir([workdir, '/simA2.non_DIB0']); % should be same as simA2.non
[nAn_DIB1 h]=loadsir([workdir, '/simA2.non_DIB1']);
[nAn_IDG1 h]=loadsir([workdir, '/simA2.non_IDG1']);

% compute error stats
[fAn_m,fAn_s,fAn_r]=compute_stats_grd(tr,fAn,Nfactor);
[fAa_m,fAa_s,fAa_r]=compute_stats(tr-fAa);
[fAs_m,fAs_s,fAs_r]=compute_stats(tr-fAs);
[fAn_DIB0_m,fAn_DIB0_s,fAn_DIB0_r]=compute_stats_grd(tr,fAn_DIB0,Nfactor);
[fAn_DIB1_m,fAn_DIB1_s,fAn_DIB1_r]=compute_stats_grd(tr,fAn_DIB1,Nfactor);
[fAn_IDG1_m,fAn_IDG1_s,fAn_IDG1_r]=compute_stats_grd(tr,fAn_IDG1,Nfactor);
[fAn_del_m,fAn_del_s,fAn_del_r]   =compute_stats_grd(fAn,fAn_DIB0,Nfactor);
[nAn_m,nAn_s,nAn_r]=compute_stats_grd(tr,nAn,Nfactor);
[nAa_m,nAa_s,nAa_r]=compute_stats(tr-nAa);
[nAs_m,nAs_s,nAs_r]=compute_stats(tr-nAs);
[eAs_m,eAs_s,eAs_r]=compute_stats(nAs-fAs); % stats for en=s+n - nf
[eAn_m,eAn_s,eAn_r]=compute_stats_grd(nAn,fAn,Nfactor); % stats for en=s+n - nf
[nAn_DIB0_m,nAn_DIB0_s,nAn_DIB0_r]=compute_stats_grd(tr,nAn_DIB0,Nfactor);
[nAn_DIB1_m,nAn_DIB1_s,nAn_DIB1_r]=compute_stats_grd(tr,nAn_DIB1,Nfactor);
[nAn_IDG1_m,nAn_IDG1_s,nAn_IDG1_r]=compute_stats_grd(tr,nAn_IDG1,Nfactor);

% summarize results
disp(' ');
disp(sprintf('Channel: %d GHz  Footprint size: %f x %f   Passes: %d',chan,footprint,Npass));
disp(sprintf('SIR threshold: %f dB  Noise STD: %f K',10*log10(thres),DeltaT));  
disp(sprintf('Resolution: %f km/pix  Bandlimit: %f km',sampspacing,sampspacing/BL));
disp(sprintf('Sample image size: %d x %d',M,N));
disp(' ');
disp(sprintf('Case        Mean    STD    RMS'));
disp(sprintf('N-F Non    %5.2f  %5.2f  %5.2f',fAn_m,fAn_s,fAn_r));
disp(sprintf('N-F Ave    %5.2f  %5.2f  %5.2f',fAa_m,fAa_s,fAa_r));
disp(sprintf('N-F SIR    %5.2f  %5.2f  %5.2f',fAs_m,fAs_s,fAs_r));
disp(sprintf('N-F del    %5.2f  %5.2f  %5.2f',fAn_del_m,fAn_del_s,fAn_del_r));
%disp(sprintf('N-F DIB0   %5.2f  %5.2f  %5.2f',fAn_DIB0_m,fAn_DIB0_s,fAn_DIB0_r));
%disp(sprintf('N-F DIB1   %5.2f  %5.2f  %5.2f',fAn_DIB1_m,fAn_DIB1_s,fAn_DIB1_r));
%disp(sprintf('N-F IDG1   %5.2f  %5.2f  %5.2f',fAn_IDG1_m,fAn_IDG1_s,fAn_IDG1_r));
disp(sprintf('Noisy Non  %5.2f  %5.2f  %5.2f',nAn_m,nAn_s,nAn_r));
disp(sprintf('Noisy Ave  %5.2f  %5.2f  %5.2f',nAa_m,nAa_s,nAa_r));
disp(sprintf('Noisy SIR  %5.2f  %5.2f  %5.2f',nAs_m,nAs_s,nAs_r));
%disp(sprintf('Noisy DIB0 %5.2f  %5.2f  %5.2f',nAn_DIB0_m,nAn_DIB0_s,nAn_DIB0_r));
%disp(sprintf('Noisy DIB1 %5.2f  %5.2f  %5.2f',nAn_DIB1_m,nAn_DIB1_s,nAn_DIB1_r));
%disp(sprintf('Noisy IDG1 %5.2f  %5.2f  %5.2f',nAn_IDG1_m,nAn_IDG1_s,nAn_IDG1_r));

% set color bar the same for all caes
sc=[190 260];

% plot various comparisons
myfigure(7) % noise-free
colormap('gray')
subplot(2,2,1)
imagesc(tr,sc);h=colorbar; set(h,'FontSize',12);
axis image
axis off
h=title('true'); set(h,'FontSize',12);
subplot(2,2,2)
imagesc(fAn,sc);h=colorbar; set(h,'FontSize',12);
axis image
axis off
h=title(sprintf('non N-F %0.2f %0.2f %0.2f',fAn_m,fAn_s,fAn_r)); set(h,'FontSize',12);
subplot(2,2,3)
imagesc(fAa,sc);h=colorbar; set(h,'FontSize',12);
axis image
axis off
h=title(sprintf('ave N-F %0.2f %0.2f %0.2f',fAa_m,fAa_s,fAa_r)); set(h,'FontSize',12);
subplot(2,2,4)
imagesc(fAs,sc);h=colorbar; set(h,'FontSize',12);
axis image
axis off
h=title(sprintf('sir N-F %0.2f %0.2f %0.2f',fAs_m,fAs_s,fAs_r)); set(h,'FontSize',12);
print('-dpng',[workdir,'/NoiseFree.png']);

myfigure(8) % noisy
colormap('gray')
subplot(2,2,1)
imagesc(tr,sc);h=colorbar; set(h,'FontSize',12);
axis image
axis off
h=title('true'); set(h,'FontSize',12);
subplot(2,2,2)
imagesc(nAn,sc);h=colorbar; set(h,'FontSize',12);
axis image
axis off
h=title(sprintf('non noisy %0.2f %0.2f %0.2f',nAn_m,nAn_s,nAn_r)); set(h,'FontSize',12);
subplot(2,2,3)
imagesc(nAa,sc);h=colorbar; set(h,'FontSize',12);
axis image
axis off
h=title(sprintf('ave noisy %0.2f %0.2f %0.2f',nAa_m,nAa_s,nAa_r)); set(h,'FontSize',12);
subplot(2,2,4)
imagesc(nAs,sc);h=colorbar; set(h,'FontSize',12);
axis image
axis off
h=title(sprintf('sir noisy %0.2f %0.2f %0.2f',nAs_m,nAs_s,nAs_r)); set(h,'FontSize',12);
print('-dpng',[workdir,'/Noisy.png']);

myfigure(9)
colormap('gray')
subplot(2,2,1)
imagesc(tr,sc);h=colorbar; set(h,'FontSize',12);
axis image
axis off
h=title('true'); set(h,'FontSize',12);
subplot(2,2,2)
imagesc(nAg,sc);h=colorbar; set(h,'FontSize',12);
axis image
axis off
h=title('grd noisy'); set(h,'FontSize',12);
subplot(2,2,3)
imagesc(nAa,sc);h=colorbar; set(h,'FontSize',12);
axis image
axis off
h=title('ave noisy'); set(h,'FontSize',12);
subplot(2,2,4)
imagesc(nAs,sc);h=colorbar; set(h,'FontSize',12);
axis image
axis off
h=title('sir noisy'); set(h,'FontSize',12);
print('-dpng',[workdir,'/grd_comp.png'])

if 0
  myfigure(27) % noise-free non DIB comparisons
  colormap('gray')
  subplot(2,2,1)
  imagesc(tr,sc);h=colorbar; set(h,'FontSize',12);
  axis image
  axis off
  h=title('true'); set(h,'FontSize',12);
  subplot(2,2,2)
  imagesc(fAn_DIB0,sc);h=colorbar; set(h,'FontSize',12);
  axis image
  axis off
  h=title(sprintf('N-F DIB0 %0.2f %0.2f %0.2f',fAn_DIB0_m,fAn_DIB0_s,fAn_DIB0_r)); set(h,'FontSize',12);
  subplot(2,2,3)
  imagesc(fAn_DIB1,sc);h=colorbar; set(h,'FontSize',12);
  axis image
  axis off
  h=title(sprintf('N-F DIB1 %0.2f %0.2f %0.2f',fAn_DIB1_m,fAn_DIB1_s,fAn_DIB1_r)); set(h,'FontSize',12);
  subplot(2,2,4)
  imagesc(fAn_IDG1,sc);h=colorbar; set(h,'FontSize',12);
  axis image
  axis off
  h=title(sprintf('N-F IDG1 %0.2f %0.2f %0.2f',fAn_IDG1_m,fAn_IDG1_s,fAn_IDG1_r)); set(h,'FontSize',12);
  print('-dpng',[workdir,'/NoiseFree_DIBs.png']);
  
  myfigure(28) % noisy non DIB comparisons
  colormap('gray')
  subplot(2,2,1)
  imagesc(tr,sc);h=colorbar; set(h,'FontSize',12);
  axis image
  axis off
  h=title('true'); set(h,'FontSize',12);
  subplot(2,2,2)
  imagesc(nAn_DIB0,sc);h=colorbar; set(h,'FontSize',12);
  axis image
  axis off
  h=title(sprintf('Noisy DIB0 %0.2f %0.2f %0.2f',nAn_DIB0_m,nAn_DIB0_s,nAn_DIB0_r)); set(h,'FontSize',12);
  subplot(2,2,3)
  imagesc(nAn_DIB1,sc);h=colorbar; set(h,'FontSize',12);
  axis image
  axis off
  h=title(sprintf('Noisy DIB1 %0.2f %0.2f %0.2f',nAn_DIB1_m,nAn_DIB1_s,nAn_DIB1_r)); set(h,'FontSize',12);
  subplot(2,2,4)
  imagesc(nAn_IDG1,sc);h=colorbar; set(h,'FontSize',12);
  axis image
  axis off
  h=title(sprintf('Noisy IDG1 %0.2f %0.2f %0.2f',nAn_IDG1_m,nAn_IDG1_s,nAn_IDG1_r)); set(h,'FontSize',12);
  print('-dpng',[workdir,'/Noisy_DIBs.png']);
end

if 1 % make large image plots
  myfigure(20)
  colormap('gray')
  imagesc(tr,sc);h=colorbar; set(h,'FontSize',12); axis image; axis off; 
  h=title('true'); set(h,'FontSize',12); print('-dpng',[workdir,'/true.png']);
  imagesc(fAn,sc);h=colorbar; set(h,'FontSize',12); axis image; axis off;
  h=title(sprintf('non N-F %0.2f %0.2f %0.2f',fAn_m,fAn_s,fAn_r)); set(h,'FontSize',12); print('-dpng',[workdir,'/non_nf.png']);
  imagesc(fAa,sc);h=colorbar; set(h,'FontSize',12); axis image; axis off;
  h=title(sprintf('ave N-F %0.2f %0.2f %0.2f',fAa_m,fAa_s,fAa_r)); set(h,'FontSize',12); print('-dpng',[workdir,'/ave_nf.png']);
  imagesc(fAs,sc);h=colorbar; set(h,'FontSize',12); axis image; axis off
  h=title(sprintf('sir N-F %0.2f %0.2f %0.2f',fAs_m,fAs_s,fAs_r)); set(h,'FontSize',12); print('-dpng',[workdir,'/sir_nf.png']);
  imagesc(nAn,sc);h=colorbar; set(h,'FontSize',12); axis image; axis off
  h=title(sprintf('non noisy %0.2f %0.2f %0.2f',nAn_m,nAn_s,nAn_r)); set(h,'FontSize',12); print('-dpng',[workdir,'/non_noisy.png']);
  imagesc(nAa,sc);h=colorbar; set(h,'FontSize',12); axis image; axis off
  h=title(sprintf('ave noisy %0.2f %0.2f %0.2f',nAa_m,nAa_s,nAa_r)); set(h,'FontSize',12); print('-dpng',[workdir,'/ave_noisy.png']);
  imagesc(nAs,sc);h=colorbar; set(h,'FontSize',12); axis image; axis off
  h=title(sprintf('sir noisy %0.2f %0.2f %0.2f',nAs_m,nAs_s,nAs_r)); set(h,'FontSize',12); print('-dpng',[workdir,'/sir_noisy.png']);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step eight:
%  generate SIR algorithm outputs versus iteration number
%  read resulting files, and generate summary plots
%

if RUN_SIR
  % run noise-free SIR
  cmd=sprintf('sim_SIR %s 0 0 -%d %s', outfile,maxiter,workdir);
  system(cmd);

  % run noisy SIR
  cmd=sprintf('sim_SIR %s 0 1 -%d %s', outfile,maxiter,workdir);
  system(cmd);
end

% initial stat arrays
f_m=zeros([1 maxiter]);
n_m=zeros([1 maxiter]);
d_m=zeros([1 maxiter]);
f_s=zeros([1 maxiter]);
n_s=zeros([1 maxiter]);
d_s=zeros([1 maxiter]);
f_r=zeros([1 maxiter]);
n_r=zeros([1 maxiter]);
d_r=zeros([1 maxiter]);

% for each SIR iteration number, read in file and compute error statistics
% plot selected images
myfigure(12);clf
colormap('gray')
ncnt=1;
for iter=1:maxiter
  fname=sprintf([workdir, '/simA_%d.sir'],iter);
  nname=sprintf([workdir,'/simA2_%d.sir'],iter);
  [fimg head]=loadsir(fname);
  [nimg head]=loadsir(nname);
  [f_m(iter),f_s(iter),f_r(iter)]=compute_stats(tr-fimg);
  [n_m(iter),n_s(iter),n_r(iter)]=compute_stats(tr-nimg);
  [d_m(iter),d_s(iter),d_r(iter)]=compute_stats(fimg-nimg);
  if iter==1 | iter==10 | iter==20 | iter==30
    myfigure(12);
    subplot(4,2,2*(ncnt-1)+1)
    imagesc(nimg,sc);h=colorbar; set(h,'FontSize',12);
    axis image
    axis off
    h=title(sprintf('Noisy iter=%d',iter)); set(h,'FontSize',12);
    subplot(4,2,2*ncnt)
    imagesc(fimg,sc);h=colorbar; set(h,'FontSize',12);
    axis image
    axis off
    h=title(sprintf('N-F iter=%d',iter)); set(h,'FontSize',12);
    ncnt=ncnt+1;
  end
end
print('-dpng',[workdir,'/iterimage.png']);


% inferred noise error for SIR vs iteration
s_m=n_m-f_m;
s_s=sqrt((n_s.^2-f_s.^2));
s_r=sqrt(abs(n_r.^2-f_r.^2));
% for AVE
a_s=sqrt((nAa_s.^2-fAa_s.^2));
a_r=sqrt((nAa_r.^2-fAa_r.^2));
% for grd (non)
g_s=sqrt((nAn_s.^2-fAn_s.^2));
g_r=sqrt((nAn_r.^2-fAn_r.^2));

% generate plots of error versus iteration
bgis=f_r(Nom_iter)+0.07; 
bgisn=sqrt(f_r(Nom_iter)^2+s_r(Nom_iter)^2)+0.07;
bgisn=5.45;  % bgi s+n rms % P1
bgis=4.98;   % bgi s-o rms
bgim=-0.37;  % bgi s+n mean;
bgisn=5.28;  % bgi s+n rms % P2
bgis=5.25;   % bgi s-o rms
bgim=-0.27;  % bgi s+n mean;
bgin=sqrt(bgisn^2-bgis^2);
myfigure(10)
subplot(1,2,1)
%plot([0 40],[0 0],':k');
plot(f_m,'b');
%hold on;plot(f_m,'b'); hold off
hold on; plot(nAa_m,'k*'); hold off;
%hold on; plot(nAn_m,'cs'); hold off;
hold on; plot([0 50],[nAn_m, nAn_m],'k'); hold off;
hold on; plot(n_m,'r'); hold off;
%hold on; plot([40 40],[-0.05 0.05],'--k'); hold off;
hold on; plot([Nom_iter Nom_iter],[-0.05 0.05],'--k'); hold off;
if 1 % only on desired case 
  hold on;plot([0 50],[bgim bgim],':b');hold off;
end
xlabel('Iteration');
ylabel('Mean error (K)');
%h=title('r=noisy b=noise-free k=AVE c=non'); set(h,'FontSize',12);
subplot(1,2,2)
plot(10*log10(f_r),'b');
hold on; plot(10*log10(n_r),'r'); hold off;
hold on; plot(10*log10(nAa_r),'k*'); hold off;
%hold on; plot(10*log10(nAn_r),'cs'); hold off;
hold on; plot([0 50],[10*log10(nAn_r),10*log10(nAn_r)],'k'); hold off;
%hold on; plot(10*log10(s_r)+8,'g'); hold off;
hold on; plot(10*log10(d_r)+8,'g'); hold off; 
%hold on; plot(10*log10(bgisn),'b^'); hold off;
if 1 % only on desired case 
  hold on; plot([0 50],[10*log10(bgisn) 10*log10(bgisn)],'b:'); hold off;
end
hold on; plot([Nom_iter Nom_iter],[3 8],'--k'); hold off;
ylabel('RMS error (dB K)');
%plot((f_r),'b');
%hold on; plot((n_r),'r'); hold off;
%ylabel('RMS error (K)');
xlabel('Iteration');
%h=title('r=noisy b=noise-free g=noise+4 K=AVE c=non)'); set(h,'FontSize',12);
print('-dpng',[workdir,'/iterate.png']);

% generate plots of error convergence
myfigure(11)
plot(10*log10(f_r),s_r,'.')
hold on;plot(10*log10(f_r(Nom_iter)),s_r(Nom_iter),'r*');hold off
hold on;plot(10*log10(fAa_r),a_r,'g*');hold off
%hold on;plot(10*log10(fAn_r),g_r,'ks');hold off
if 1 % only on desired case 
  hold on;plot(10*log10(bgis),bgin,'k^');hold off % add bgi for Ch1_P2_Ns3 case
end
xlabel('RMS signal error (dB K)')
ylabel('RMS noise error (K)');
%h=title(sprintf('%d fp=%dx%d DeltaT=%0.1f Np=%d (r=SIR, g=Ave, k=grd)',chan,footprint,DeltaT,Npass)); set(h,'FontSize',12);
%print('-dpng',[workdir,'/sig.png']);

% ## alternate plots of error convergence
myfigure(111)
plot(10*log10(f_r),d_r,'.')
hold on;plot(10*log10(f_r(Nom_iter)),d_r(Nom_iter),'r*');hold off  % nom
hold on;plot(10*log10(fAa_r),d_r(1),'g*');hold off % ave
hold on;plot(10*log10(fAn_r),eAn_r,'ks');hold off  % grd/non
if 1 % only on desired case 
  hold on;plot(10*log10(bgis),bgin,'k^');hold off % add bgi for Ch1_P2_Ns3 case
end
xlabel('RMS signal error (dB K)')
ylabel('RMS noise error (K)');
%h=title(sprintf('%d fp=%dx%d DeltaT=%0.1f Np=%d (r=SIR, g=Ave, k=grd)',chan,footprint,DeltaT,Npass)); set(h,'FontSize',12);
print('-dpng',[workdir,'/sig.png']);


% summarize results (again) for human operator
disp(' ');
disp(sprintf('Channel: %d GHz  Footprint size: %f x %f   Passes: %d',chan,footprint,Npass));
disp(sprintf('SIR threshold: %f dB  Noise STD: %f K',10*log10(thres),DeltaT));  
disp(sprintf('Resolution: %f km/pix  Bandlimit: %f km',sampspacing,sampspacing/BL));
disp(sprintf('Sample image size: %d x %d',M,N));
disp(sprintf(' '));
disp(sprintf('Case        Mean    STD    RMS'));
disp(sprintf('N-F Non    %5.2f  %5.2f  %5.2f',fAn_m,fAn_s,fAn_r));
disp(sprintf('N-F Ave    %5.2f  %5.2f  %5.2f',fAa_m,fAa_s,fAa_r));
disp(sprintf('N-F SIR    %5.2f  %5.2f  %5.2f',fAs_m,fAs_s,fAs_r));
%disp(sprintf('N-F del    %5.2f  %5.2f  %5.2f',fAn_del_m,fAn_del_s,fAn_del_r));
%disp(sprintf('N-F DIB0   %5.2f  %5.2f  %5.2f',fAn_DIB0_m,fAn_DIB0_s,fAn_DIB0_r));
%disp(sprintf('N-F DIB1   %5.2f  %5.2f  %5.2f',fAn_DIB1_m,fAn_DIB1_s,fAn_DIB1_r));
%disp(sprintf('N-F IDG1   %5.2f  %5.2f  %5.2f',fAn_IDG1_m,fAn_IDG1_s,fAn_IDG1_r));
disp(sprintf('Noisy Non  %5.2f  %5.2f  %5.2f',nAn_m,nAn_s,nAn_r));
disp(sprintf('Noisy Ave  %5.2f  %5.2f  %5.2f',nAa_m,nAa_s,nAa_r));
disp(sprintf('Noisy SIR  %5.2f  %5.2f  %5.2f',nAs_m,nAs_s,nAs_r));
%disp(sprintf('Noisy DIB0 %5.2f  %5.2f  %5.2f',nAn_DIB0_m,nAn_DIB0_s,nAn_DIB0_r));
%disp(sprintf('Noisy DIB1 %5.2f  %5.2f  %5.2f',nAn_DIB1_m,nAn_DIB1_s,nAn_DIB1_r));
%disp(sprintf('Noisy IDG1 %5.2f  %5.2f  %5.2f',nAn_IDG1_m,nAn_IDG1_s,nAn_IDG1_r));


% and write summary statistics to file
fid=fopen([workdir '/stats.txt'],'w');
fprintf(fid,'Channel: %d GHz  Footprint size: %f x %f   Passes: %d\n',chan,footprint,Npass);
fprintf(fid,'Footprint size: %f x %f   Passes: %d\n',footprint,Npass);
fprintf(fid,'SIR threshold: %f dB  Noise STD: %f K\n',10*log10(thres),DeltaT);  
fprintf(fid,'Resolution: %f km/pix  Bandlimit: %f km\n',sampspacing,sampspacing/BL);
fprintf(fid,'Sample image size: %d x %d\n',M,N);
fprintf(fid,' \n');
fprintf(fid,'Case        Mean    STD    RMS\n');
fprintf(fid,'N-F Non    %5.2f  %5.2f  %5.2f\n',fAn_m,fAn_s,fAn_r);
fprintf(fid,'N-F Ave    %5.2f  %5.2f  %5.2f\n',fAa_m,fAa_s,fAa_r);
fprintf(fid,'N-F SIR    %5.2f  %5.2f  %5.2f\n',fAs_m,fAs_s,fAs_r);
%fprintf(fid,'N-F del    %5.2f  %5.2f  %5.2f\n',fAn_del_m,fAn_del_s,fAn_del_r);
%fprintf(fid,'N-F DIB0   %5.2f  %5.2f  %5.2f\n',fAn_DIB0_m,fAn_DIB0_s,fAn_DIB0_r);
%fprintf(fid,'N-F DIB1   %5.2f  %5.2f  %5.2f\n',fAn_DIB1_m,fAn_DIB1_s,fAn_DIB1_r);
%fprintf(fid,'N-F IDG1   %5.2f  %5.2f  %5.2f\n',fAn_IDG1_m,fAn_IDG1_s,fAn_IDG1_r);
fprintf(fid,'Noisy Non  %5.2f  %5.2f  %5.2f\n',nAn_m,nAn_s,nAn_r);
fprintf(fid,'Noisy Ave  %5.2f  %5.2f  %5.2f\n',nAa_m,nAa_s,nAa_r);
fprintf(fid,'Noisy SIR  %5.2f  %5.2f  %5.2f\n',nAs_m,nAs_s,nAs_r);
%fprintf(fid,'Noisy DIB0 %5.2f  %5.2f  %5.2f\n',nAn_DIB0_m,nAn_DIB0_s,nAn_DIB0_r);
%fprintf(fid,'Noisy DIB1 %5.2f  %5.2f  %5.2f\n',nAn_DIB1_m,nAn_DIB1_s,nAn_DIB1_r);
%fprintf(fid,'Noisy IDG1 %5.2f  %5.2f  %5.2f\n',nAn_IDG1_m,nAn_IDG1_s,nAn_IDG1_r);
fclose(fid);

end

end
end
end
