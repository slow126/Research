function[Tb,B,g,nsx,nsy]=nscatsirvecr(powsimv,countv,angv,fill_arrayv,setup);
%nscatsirvec.m, reads in less information to help it go faster.
%The important things it will need will be a binary header file that it will get from
%nscatbin2vec.m, and also the vectors for the power, angles, count, and fill_array that also come from nscatbin2vec.m
%of the form [Tb,B,g,nsx,nsy]=nscatsirvec(powv,countv,angv,fill_arrayv)

%filename=input('enter the binary header file:','s');
filename=setup;

n=0;
while n<10,  %iterations

fid=fopen(filename,'r','ieee-be');
if fid==0;
	disp('Error opening file');
	return;
end

%bring in the header file
dumb=fread(fid,[1],'int32');      % read dummy value
[dims eof]=fread(fid,[2],'int32');  % read header
nsx=dims(1);	%the y dimension
nsy=dims(2);
dims=[];
[dims eof]=fread(fid,[6],'float32');  % read header
ascale=dims(1);
bscale=dims(2);
a0=dims(3);
b0=dims(4);
xdeg=dims(5);
ydeg=dims(6);
dumb=fread(fid,[1],'int32');      % read dummy value

dumb=fread(fid,[1],'int32');      % read dummy value
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
dumb=fread(fid,[1],'int32');      % read dummy value
%finished bringing in the header file
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fid=fopen('headerm.txt','w');
%fprintf(fid,'%4.2f\t',nsx,nsy,ascale,bscale,a0,b0,xdeg,ydeg,...
%			dstart,dend,mstart,mend,year,regnum,projt,npol,...
%			latl,lonl,lath,lonh,regname);
%fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%initialize Tb and B
if n==0,
	Tb([1:nsx*nsy],1)=-8.4;
	B([1:nsx*nsy],1)=-0.14;
else
	Tb=Tb;
	B=B;
end
%initialize g
g=zeros(1,nsx*nsy);
%initialize mult2
mult2=zeros(nsx*nsy,1);

%initialize all of those B things
r=zeros(nsx*nsy,1);
t=zeros(nsx*nsy,1);
m=zeros(nsx*nsy,1);
a=zeros(nsx*nsy,1);
xi=zeros(nsx*nsy,1);
b_weight=30;	%b acceleration factor

%start looping through the each measurement
up=0;
for i=1:length(powsimv),	%the total number of measurements
i;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%if i == 600,
%	fid3=fopen('measm.txt','w');
%	fprintf(fid3,'%4.2f\n',powsimv(i),angv(i),...
%		fill_arrayv(1+up:countv(i)+up),countv(i));
%	fclose(fid3);
%end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	point([1:nsx*nsy])=0;
	for j=1+up:2:countv(i)+up,
		point([fill_arrayv(j):fill_arrayv(j+1)])=1;
	end
	up=up+countv(i);

	
	if angv(i)>20 & angv(i)<58 & powsimv(i)<0 & powsimv(i)>-40,
	
%the forward projection fj
	q=sum(point);	%they are all of weight 1
	Tbten=10.^(Tb./10); 	%real space
	temp=point*Tbten;
	f=10.*log10(temp/q);

	d=(powsimv(i)+B.*(40-angv(i)))/f;

%constrain d
	dltz=(d<=0);
	d=max(d,0);
	d=d+dltz;
	d=d.^(.5);

	updatea=1./(.5*inv(f)*(1-1./(d'))+1./(Tb'.*d'));
	updateb=.5*f*(1-d')+Tb'.*d';
	dgto=(d>=1);
	update=dgto'.*updatea+(1-dgto)'.*updateb;

	r=r+point'.*angv(i)^2;
	t=t+point'.*angv(i);

	zeta=update'+B.*(angv(i)-40);

	m=m+point'.*zeta.*angv(i);
	a=a+point'.*zeta;

g=g+point;
mult1=point'.*update';
mult2=mult2+mult1;
%this is the end of the  if statement for data quality

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if i == 23,
%this is to find a measurement that is actully hit
	for j=1:nsx*nsy,
		if point(j)==1
		p=j-1;
		end
	end
%for the first iteration, every value of update and zeta will be
%the same, because Tb and B are the same for every element
	fid2=fopen('avarm.txt','w');
	fprintf(fid2,'%4.5f\n',f,d(p),update(p),zeta(p),...
		mult2(p)/g(p),g(p),p);
	fclose(fid2);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%time to test the B values
%if i==23,
%	fid4=fopen('bvarm.txt','w');
%	fprintf(fid4,'%4.5f\n',t(p)/g(p),r(p)/g(p),a(p)/g(p),m(p)/g(p),...
%		g(p),p);
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	end
end

%I should have gone through all the measurements in the iteration by now
%normalize the b values, r,t,m,a
r=r./g';
t=t./g';
m=m./g';
a=a./g';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%the final test on the b values, after all of the measurements
fid5=fopen('bfinalm.txt','w');
fprintf(fid5,'%6.5f\n',r(675),t(675),m(675),a(500:600));
fclose(fid5);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tb=mult2./g';
%small=min(Tb);
Tb=max(-33,Tb);	%for NaN values where there is no g value (0)


%having created Tb (A), I now hope to create B, exploiting matrices
%question, isn't the "pi" in the paper the same as my point, the number
%of measurements covering the pixel, since the value for each is one?

c=(1./(r-t.^2)).*(m-t.*a);
x=b_weight*((r./t.^2)-1);
B=(1./(x+1)).*(x.*c+B);
small1=min(B);
B=max(-3,B);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check out the final product before the median filter
fid6=fopen('afinalm.txt','w');
fprintf(fid6,'%4.6f\n',Tb(600:700));
fclose(fid6);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Tb=vec2mat(Tb,nsy);
%B=vec2mat(B,nsy);	

%apply the filter
Tb=median2dn(Tb,3,0,-33,nsx,nsy)';	%modified median filter, originally use median2d2.m
B=median2dn(B,3,1,-3,nsx,nsy)';	%ave filter

%Tb=reshape(Tb,nsx*nsy,1);
%B=reshape(B,nsx*nsy,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%image values after the median filter
fid7=fopen('postfiltm.txt','w');
fprintf(fid7,'%4.6f\n',Tb(600:700));
fclose(fid7);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n=n+1
%if n==5,
%	save temp-matth-145-150-5.mat
%elseif n==10
%	save temp-mattriv-160-188-10.mat
%elseif n==15
%	save temp-mattriv-160-188-15.mat
%elseif n==20
%	save temp-mattriv-160-188-20.mat
%elseif n==30
%	save temp-mattriv-160-188-30.mat
%elseif n==40
%	save temp-mattriv-160-188-40.mat
%elseif n==50
%	save temp-mattriv-160-188-50.mat
%else
%end;
end
Tb=flipud(vec2mat(Tb,nsy));
B=flipud(vec2mat(B,nsy));
g=flipud(vec2mat(g,nsy));




