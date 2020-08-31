%nscatbin2vec.m, to write out setup files to a vector format to use in matlab
%that will run more quickly

filename='/mers3/users/willism/nscatdata/matth-145-150-v.setup';
%filename='/mers1/users/willism/nscat/nscatdata/matt-amaz-97-001-024-v.setup';
%filename='/mers1/users/willism/nscat/nscatdata/mattnj-97-094-104-v.setup';

fid=fopen(filename,'r','ieee-be');
if fid ==0
  disp('Error opening file');
  return;
end;

%outputfile=input('Enter the name of the .mat file to output to (include .mat)','s');
filenamesim=input('Enter the name of the output binary header file:','s');
fid_out=fopen(filenamesim,'w','ieee-be');
if fid_out==0
	disp('Error opening output file');
	return;
end

%start to read in the measurements

dumb1=fread(fid,[1],'int32');      % read dummy value
[dims eof]=fread(fid,[2],'int32');  % read header
nsx=dims(1);
nsy=dims(2);
dims=[];
[dims eof]=fread(fid,[6],'float32');  % read header
ascale=dims(1);
bscale=dims(2);
a0=dims(3);
b0=dims(4);
xdeg=dims(5);
ydeg=dims(6);
dumb2=fread(fid,[1],'int32');      % read dummy value

dumb3=fread(fid,[1],'int32');      % read dummy value
[dims eof]=fread(fid,[8],'int32');  %read header
dstart=dims(1);
dend=dims(2);
mstart=dims(3);
mend=dims(4);
year=dims(5);
regnum=dims(6);
projt=dims(7);
npol=dims(8);
[dims eof]=fread(fid,[4],'float32');
latl=dims(1);
lonl=dims(2);
lath=dims(3);
lonh=dims(4);
[regname eof]=fread(fid,[10],'char');
dumb4=fread(fid,[1],'int32');      % read dummy value

%write out a copy of the file

%write out a fortran record for the header
fwrite(fid_out,32,'int32');	%fortran record header
dims=[];
dims(1)=nsx;
dims(2)=nsy;
fwrite(fid_out,dims,'int32');
dims=[];
dims(1)=ascale;
dims(2)=bscale;
dims(3)=a0;
dims(4)=b0;
dims(5)=xdeg;
dims(6)=ydeg;
fwrite(fid_out,dims,'float32');
fwrite(fid_out,32,'int32');	%fortran record header

fwrite(fid_out,58,'int32');	%fortran header
dims=[];
dims(1)=dstart;
dims(2)=dend;
dims(3)=mstart;
dims(4)=mend;
dims(5)=year;
dims(6)=regnum;
dims(7)=projt;
dims(8)=npol;
fwrite(fid_out,dims,'int32');
dims=[];
dims(1)=latl;
dims(2)=lonl;
dims(3)=lath;
dims(4)=lonh;
fwrite(fid_out,dims,'float32');
fwrite(fid_out,regname,'char');
fwrite(fid_out,58,'int32');	%fortran header
fclose(fid_out);


%initialize the vectors that I will use
powv=[];
angv=[];
countv=[];
fill_arrayv=[];

l=0;
eof=1;
while eof==1
%while l<30	%to cut down on the number of measurments, get rid of
	[dumb eof]=fread(fid,1,'int32');	%read dummy value
	if eof==1
		[dims]=fread(fid,[3],'float32');
		pow=dims(1);	%power reading that I will replace
		powv=cat(1,powv,pow);
		ang=dims(2);	%angle 
		kp=dims(3);
		angv=cat(1,angv,ang);	%make the angle vector
		
		[dims]=fread(fid,[2],'int16');
		orbnum=dims(1);
		ibeam=dims(2);
		[dims]=fread(fid,[2],'int32');
		count=dims(1);
		countv=cat(1,countv,count);
		ktime=dims(2);
		%the ktime you can't see, but it is there
		dumb6=fread(fid,1,'int32');	%read dummy value

		dumb7=fread(fid,1,'int32');	%read dummy value
		[fill_array]=fread(fid,[count],'int32');%pixels hit
		fill_arrayv=cat(1,fill_arrayv,fill_array);
		dumb8=fread(fid,1,'int32');	%read dummy value

%check the data quality, only continue for good data
%if ang>20 & ang<58 & pow<0 & pow>-40,

l=l+1

%Finding A and parts of B while reading in each measurement

%the first job is to make the expanded footprints to go on the 360x360 block

%start putting these things together

	end
end
%save mattriv-166-180-v.mat  countv powv fill_arrayv angv;








