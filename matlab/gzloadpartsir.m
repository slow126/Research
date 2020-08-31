function [img, head, descrip, iaopt] = gzloadpartsir(file,xll,yll,xur,yur)
%
%   [img head descrip iaopt]=gzloadpartsir(filename)
%
% loads part of a BYU .SIR file.  The file name can contain a .gz extension
% to indicated that it is gzipped.  See loadpartsir.m

% written 12 Aug 2009 by DGL at BYU (linux specific)

tmpdir='/tmp';

% check file name to see if it has a .gz extension, 
% indicating that it is gzipped.  More generally, 
% using status = system(['gzip -l ' file '&>/dev/null']) can
% test other extensions, but takes longer.
status = strcmp('.gz',file(end-2:end));
if status ~= 0      % input file is gzipped
  %
  % gunzip file to tmpdir, read it in, and (optionally) delete it
  %
  % strip off file path
  k=findstr('/',file);
  if length(k)>0
    fname=file(k(end)+1:end-3);  % strip off path
  else
    fname=file(1:end-3);
  end

  % remove the file from the dest if it's already extant
  system(['rm -f ' tmpdir '/' fname]);
  
  % gunzip to destination
  system(['zcat ' file ' > ' tmpdir '/' fname]);

  % load the temporary file
  [img head descrip iaopt]= loadpartsir([tmpdir '/' fname],xll,yll,xur,yur);
  
  % remove gunzipped file
  system(['rm ' tmpdir '/' fname]);
  
else              % not gzipped
  
  % load the file
  [img head descrip iaopt] = loadpartsir(file,xll,yll,xur,yur); 
end
