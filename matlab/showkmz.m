function showkmz(fname,fignum)
%
% function showkmz(fname <,fignum>)
%
% displays the contents of a simple kmz to matlab figure fignum [default 1]
%

% written D. Long 21 Dec 2011
% revised D. Long 22 Dec 2011 + delete pre-existing directory

if exist('fignum','var')~=1
  fignum=1;
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
% parst list of files
ind=find(list==10);
if length(ind)<2
  disp(list)
  disp(sprintf('%d ',list));
  error('*** no kml file found ***');
end
for k=2:length(ind)
  kname=remove_trailing_spaces(list((ind(k-1)+1):(ind(k)-1)));
  % for each kml file
  fid=fopen(kname,'r');
  if fid>0
   lcnt=0;
   locs=0;
   img=[];
   Nmax=-999;
   Smax=+999;
   Emax=-999;
   Wmax=+999;
   while 1
    line1=fgetl(fid);
     if ~ischar(line1), break, end
     lcnt=lcnt+1;
     %disp(sprintf(' %d: %s',lcnt,line1));

     % parse key lines
     t=findstr(line1,'href');
     if length(t)>1
       iname=line1((t(1)+5):t(2)-3);
       [img cmap]=imread([tmp filesep() name filesep() 'kmz' filesep() iname]);
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
       Nmax=max(Nmax,nor);
       Smax=min(Smax,sou);
       Emax=max(Emax,eas);
       Wmax=min(Wmax,wes);
       axis([Wmax Emax Smax Nmax]);

       % reset accumulators
       locs=0;
       img=[];
     end
   end
   fclose(fid);
  end  
end

% clean up temporary directory
if 1
  delete([tmp filesep() name filesep() 'kmz' filesep() '*']);
  rmdir ([tmp filesep() name filesep() 'kmz']);
  delete([tmp filesep() name filesep() '*']);
  rmdir ([tmp filesep() name]);
end