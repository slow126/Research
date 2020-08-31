function cmap=my_cmap(file_name)
% function cmap=my_cmap(file_name)
%  loads binary color map file file_name as a matlab colormap
%  e.g., my_cmap('/mers0/long/sir/Old_Glory7.ct');

if exist('file_name') == 1
  fid=fopen(file_name,'r','ieee-be');
else
  fid=fopen('/mers0/long/sir/Old_Glory7.ct','r','ieee-be');
end
data=fread(fid,[256*3],'uchar');  % read color table data
data=reshape(data,256,3)/255;
data=data([1:4:256],:);
colormap(data);
cmap=data;