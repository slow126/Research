%
% this code reads a SIR file and dumps the read image as a binary file
%

fname='/home/long/src/linux/mymeasures/SMAP/testing/work/SMhb-a-E2N15-153-154.ave';
%fname='/home/long/src/linux/mymeasures/SMAP/testing/work/SMhb-a-E2N15-153-154.non';
%fname='/home/long/src/linux/mymeasures/SMAP/testing/work/SMhb-a-E2N15-153-154.sir';
%fname='/home/long/src/linux/mymeasures/SMAP/testing/work/SMvb-a-E2N15-153-154.ave';
%fname='/home/long/src/linux/mymeasures/SMAP/testing/work/SMvb-a-E2N15-153-154.non';
%fname='/home/long/src/linux/mymeasures/SMAP/testing/work/SMvb-a-E2N15-153-154.sir';
%fname='/home/long/src/linux/mymeasures/SMAP/testing/work/SM4b-a-E2N15-153-154.ave';
%fname='/home/long/src/linux/mymeasures/SMAP/testing/work/SM4b-a-E2N15-153-154.non';
%fname='/home/long/src/linux/mymeasures/SMAP/testing/work/SM4b-a-E2N15-153-154.sir';

[img,head]=loadsir(fname);

fprintf('image size %d x %d\n',head(1:2))

ofile=[fname '.bin'];

fid=fopen(ofile,'wb');
fwrite(fid,img,'float');
fclose(fid);
