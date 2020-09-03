function setup_mat = my_setup_reader(file_in)
%
% function modify_setup(file_in, file_out, icase)
%
% reads simplified setup file from file_in, modifies MRF based on
% value of icase, and writes modified setup file to file_out
%

% (c) copyright 2014 David G. Long, Brigham Young University
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% open files
iid=fopen(file_in,'r');
%disp(sprintf('Writing %s',file_out));

% copy header
M=fread(iid,1,'int32');
N=fread(iid,1,'int32');
sampspacing=fread(iid,1,'float32');
grd_size=fread(iid,1,'float32');
true1=fread(iid,[M N],'float32');

setup_mat.size = [M, N];
setup_mat.pixel_resolution = sampspacing;
setup_mat.grd_size = grd_size;
setup_mat.truth = true1;

% fwrite(fid,[M, N],'int32');         % write image size
% fwrite(fid,sampspacing,'float32');  % write pixel resolution
% fwrite(fid,grd_size,'float32');     % write GRD pixel size
% fwrite(fid,true1,'float32');        % write "truth" image

setup_mat.iadd(1,:) = [0, 0];
setup_mat.z_s(1,:) = [0, 0];

cnt=0;
for i=1:1e10
  % read measurement and associated response function from input .setup file
  iadd=fread(iid,1,'int32'); % address of the center of the measurement
  if length(iadd)<1, break; end;
  n=fread(iid,1,'int32');
  z=fread(iid,1,'float32'); % z or z1 are the measurments. z1 is noisefree probably
  z1=fread(iid,1,'float32');
  pointer=fread(iid,n,'int32');
  aresp1=fread(iid,n,'float32');
  
  % sum up weights multiplied with aresp1 and divide by sum of weights to
  % get the measurement.
    
  % normalize sum to 1
  aresp1=aresp1/sum(aresp1);
  
  % drop zero gain terms
  pointer=pointer(aresp1>0);
  aresp1=aresp1(aresp1>0);

  %disp(sprintf('%f',aresp1))
  
  % save measurement and associated response function to .setup file
  
  setup_mat.iadd(i,:) = [iadd length(pointer)];
  setup_mat.z_s(i,:) = [z z1];
  setup_mat.pointer1{i} = pointer;
  setup_mat.aresp1{i} = aresp1;
  
%   fwrite(fid,[iadd length(pointer)],'int32');
%   fwrite(fid,[z z1],'float32');
%   fwrite(fid,pointer,'int32');
%   fwrite(fid,aresp1,'float32');
  cnt=cnt+1;
end

% close files
% fclose(fid);
fclose(iid);