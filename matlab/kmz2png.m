function kmz2png(fname,fignum,pngout,fignum2)
%fname='DEMupdate1.kmz';
%fignum=1;
%pngout='j.png';
%
% function showkmz(fname <,fignum,<pngout>>)
%
% displays the contents of a simple kmz to matlab figure fignum [default 1]
% generates a full-scale png file if pngout is defined
%

% written D. Long 28 Sep 2012 + based on showkmz

if exist('fname','var')~=1
  error('No input ,kmz file name');
end
if exist('fignum','var')~=1
  fignum=1;
end
if exist('fignum2','var')~=1
  fignum2=2;
end
if exist('pngout','var')~=1
  pngout=[fname '.png'];
end

if filesep()=='/'
  tmp='/tmp';     % default temporary work directory (linux)
else
  tmp=pwd();      % default temporary work directory (non-linux)
end

% check to see if input file exists
if exist('fname','var')~=1
  error('*** input file name required as argument');
end
if exist(fname,'file')~=2
  error(sprintf('*** input file does not exist: %s',fname));
end

% parse input file name
[pathstr,name,ext,vers]=fileparts(fname);

% create blank figure
myfigure(fignum); clf;
title(escape_underbar(name));

% create temporary working directory 
[success,message,messageid]=mkdir(tmp,name);
if success==1 % make sure it is empty
  if exist([tmp filesep() name filesep() 'kmz'],'dir')==7
    delete([tmp filesep() name filesep() 'kmz/*']);
    rmdir([tmp filesep() name filesep() 'kmz']);
  end
  delete([tmp filesep() name filesep() '*']);
end

% create zip file from .kmz
copyfile(fname,[tmp filesep() name filesep() name '.zip'])

% create a directory to put the file contents in
[success,message,messageid]=mkdir([tmp filesep() name],'kmz');

% unzip the renamed .kmz file
unzip([tmp filesep() name filesep() name '.zip'],[tmp filesep() ...
		    name filesep() 'kmz' ]);

% list directory contents
list=ls('-1',[tmp filesep() name filesep() 'kmz/*.kml']);

% get list of kml files
if list(1)~=10 % add initial line feed if required
  list=sprintf('%c%s%c',10,list,10);
end
% parse list of files
ind=find(list==10);
if length(ind)<2
  disp(list)
  disp(sprintf('%d ',list));
  error('*** no kml file found ***');
end

% have to read kml files twice
% first pass is to get limits
Nmax=-999;
Smax=+999;
Emax=-999;
Wmax=+999;
for k=2:length(ind)
  kname=remove_trailing_spaces(list((ind(k-1)+1):(ind(k)-1)));
  % for each kml file
  fid=fopen(kname,'r');
  if fid>0
   lcnt=0;
   locs=0;
   img=[];
   alpha=[];
   while 1
    line1=fgetl(fid);
     if ~ischar(line1), break, end
     lcnt=lcnt+1;
     %disp(sprintf(' %d: %s',lcnt,line1));

     % parse key lines
     t=findstr(line1,'href');
     if length(t)>1
       iname=line1((t(1)+5):t(2)-3);
       [img cmap alph]=imread([tmp filesep() name filesep() 'kmz' filesep() iname]);
       disp(sprintf('Extracting %s from %s.kmz',iname,name));
     end
     if findstr(line1,'north')
       t=findstr(line1,'north');
       nor=sscanf(line1((t(1)+6):(t(2)-3)),'%f');
       locs=locs+1;
     end
     if findstr(line1,'south')
       t=findstr(line1,'south');
       sou=sscanf(line1((t(1)+6):(t(2)-3)),'%f');
       locs=locs+1;
     end
     if findstr(line1,'west')
       t=findstr(line1,'west');
       wes=sscanf(line1((t(1)+6):(t(2)-3)),'%f');
       locs=locs+1;
     end
     if findstr(line1,'east')
       t=findstr(line1,'east');
       eas=sscanf(line1((t(1)+6):(t(2)-3)),'%f');
       locs=locs+1;
     end
     if locs==4
       eastres=(eas-wes)/size(img,1);
       northres=(nor-sou)/size(img,2);
       Nmax=max(Nmax,nor);
       Smax=min(Smax,sou);
       Emax=max(Emax,eas);
       Wmax=min(Wmax,wes);
       % reset accumulators
       locs=0;
     end
   end
   fclose(fid);
  end  
end

% define output size
%[Smax Nmax Wmax Emax]
pimg_size=[floor((Nmax-Smax)/northres)+1,floor((Emax-Wmax)/eastres)+1];
pimg=zeros(pimg_size);
alpha=zeros(pimg_size);
%size(pimg)

% re-read kml files and store image
for k=2:length(ind)
  kname=remove_trailing_spaces(list((ind(k-1)+1):(ind(k)-1)));
  % for each kml file
  fid=fopen(kname,'r');
  if fid>0
   lcnt=0;
   locs=0;
   img=[];
   alpha=[];
   while 1
    line1=fgetl(fid);
     if ~ischar(line1), break, end
     lcnt=lcnt+1;
     %disp(sprintf(' %d: %s',lcnt,line1));

     % parse key lines
     t=findstr(line1,'href');
     if length(t)>1
       iname=line1((t(1)+5):t(2)-3);
       [img cmap alph]=imread([tmp filesep() name filesep() 'kmz' filesep() iname]);
       disp(sprintf('Extracting %s from %s.kmz',iname,name));
     end
     if findstr(line1,'north')
       t=findstr(line1,'north');
       nor=sscanf(line1((t(1)+6):(t(2)-3)),'%f');
       locs=locs+1;
     end
     if findstr(line1,'south')
       t=findstr(line1,'south');
       sou=sscanf(line1((t(1)+6):(t(2)-3)),'%f');
       locs=locs+1;
     end
     if findstr(line1,'west')
       t=findstr(line1,'west');
       wes=sscanf(line1((t(1)+6):(t(2)-3)),'%f');
       locs=locs+1;
     end
     if findstr(line1,'east')
       t=findstr(line1,'east');
       eas=sscanf(line1((t(1)+6):(t(2)-3)),'%f');
       locs=locs+1;
     end
     if locs==4
       east=wes:(eas-wes)/size(img,1):eas;
       north=nor:-(nor-sou)/size(img,2):sou;
       % display image
       hold on; imagesc(east,north,img);hold off;
       if prod(size(cmap))>1
	 colormap(cmap);
       else
	 colormap('gray');
       end
       axis([Wmax Emax Smax Nmax]);

       % copy image segment to larger image
       n2=floor((nor-Smax)/northres)+1;
       n1=n2-size(img,1)+1;
       n2a=size(pimg)-n1+1;
       n1a=size(pimg)-n2+1;
       n2=n2a;n1=n1a;
       e1=floor((wes-Wmax)/eastres)+1;
       e2=e1+size(img,2)-1;

       %size(img)
       %[n1 n2 e1 e2]
       %size(pimg)
       %size(pimg(n1:n2,e1:e2))
       
       pimg(n1:n2,e1:e2)=img;
       if prod(size(alpha))>0
         alph(n1:n2,e1:e2)=alpha;
       end
              
       % reset accumulators
       locs=0;
       img=[];
     end
   end
   fclose(fid);
  end  
end

figure(2)
imagesc(pimg)

% write png file
if prod(size(cmap)) > 1
  if prod(size(alpha)) > 1
    if 1 % note: imwrite does not support alpha channel AND cmap at the
         % same time for 8-bit png, so use transparency where the first
         % value of the colormap is set to the transparent color 
	 % based on the alpha channel information with the bottom 
	 % color of the image moved to the second colormap index
        %disp('write with colormap and transparency')
	imwrite(uint8(pimg),cmap,pngout, 'png','transparency',cmap(1,:),'BitDepth',8);
    else % what we really want, but is not supported...
	imwrite(uint8(pimg),cmap,pngout,'png','Alpha', alpha,'BitDepth',8);
    end
  else
      %disp('write with colormap but no alpha channel')
    imwrite(uint8(pimg),cmap,pngout,'png');
  end
else
  if prod(size(alpha)) > 1
    %disp('write with alpha channel but no colormap')
    imwrite(uint8(pimg),pngout,'png','Alpha', alpha,'BitDepth',8);
  else
    %disp('write without colormap or alpha channel')
    imwrite(uint8(pimg),pngout,'png');
  end
end

% clean up temporary directory
if 1
  delete([tmp filesep() name filesep() 'kmz' filesep() '*']);
  rmdir ([tmp filesep() name filesep() 'kmz']);
  delete([tmp filesep() name filesep() '*']);
  rmdir ([tmp filesep() name]);
end