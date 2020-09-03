function makedirpath(dirpath)
%
% function makedirpath(dirpath)
%
% checks to see if the directory (which can be absolute or
% relative) exists.  If not, the directory is created.
%

% written by D.G. Long 16 Dec 2011

% check to see if directory specified by dirpath exists within current path
if exist(dirpath,'dir')~=7 % if not, create it
  if length(find(dirpath==pathsep()))>0 | dirpath(1)==filesep() % absolute path
    DestDir=[dirpath filesep()]; % append closing filesep
  else % make relative path into an absolute path
    DestDir=[pwd() filesep() dirpath filesep()]; % append closing filesep
  end
  ind=find(DestDir==filesep());
  for k=2:length(ind)
    ind2=(ind(k-1)+1):(ind(k)-1);
    parentdir=DestDir(1:ind(k-1));
    if length(ind2)>0
      newdir=DestDir(ind2);
      if exist([parentdir,newdir])~=7
        [success message]=mkdir(parentdir,newdir);
        if success==0
          error(sprintf('*** error creating %s%c%s %s',parentdir, ...
                        filesep(),newdir,message));
        end
      end
    end    
  end
end
