clear all;
a_init = 230.0;
meas_offset = 0;
nits = 50;
AVE_INIT = 1;
NOISY = false;

nhead = 0;

ang = 0.0; %Temporary. Simulated SIR doesn't seem to have this info.
REL_EOF = 2;
MAXFILES = 2;
nspace = 0;
nfiles = 0;
cur_file = 0;

file_in = 'sir.setup';
file_id = fopen(file_in, 'r');

fseek(file_id, 0, 'eof');
nls(nfiles + 1)=ftell(file_id);
frewind(file_id);

nsx = fread(file_id, 1, 'int32');
nsy = fread(file_id, 1, 'int32');
ascale = fread(file_id, 1, 'float');
gsize = fread(file_id, 1, 'float');
head_len(nfiles + 1) = 20 + nsx * nsy * 4 + 8;



a0 = 0.0;
b0 = 0.0;
xdeg = nsx * ascale;
bscale = ascale;
ydeg = nsy * bscale;
iopt = -1;
isday = 0;
ieday = 0;
ismin = 0;
iemin = 0;
iyear = 2003;
ipol = 0;
iregion = 97;
regname = 'Simulated Test';
non_size_x = round(gsize/ascale);
non_size_y = non_size_x;
nsx2 = nsx / non_size_x;
nsy2 = nsy / non_size_y;
a02 = 0.0;
b02 = 0.0;
ascale2 = ascale * non_size_x;
bscale2 = bscale * non_size_y;
xdeg2 = xdeg;
ydeg2 = ydeg;

if NOISY
    a_name = 'simA2.sir';
    grd_aname = 'simA2.grd';
    grd_vname = 'simV2.grd';
    non_aname = 'simA2.non';
    a_name_ave = 'simA2.ave';
    v_name = 'simV2.sir';
else
    a_name = 'simA.sir';
    grd_aname = 'simA.grd';
    grd_vname = 'simV.grd';
    non_aname = 'simA.non';
    a_name_ave = 'simA.ave';
    v_name = 'simV.sir';
end

b_name = "true.sir";

median_flag=0;

"File Size: "
nls(nfiles + 1)
head_len(nfiles + 1)

nspace = 0;
for i = 1:nfiles
    nspace = nspace + nls(i);
end
nspace = nspace * 1.01;


a_val = zeros(nsx * nsy, 1);
b_val = zeros(nsx * nsy, 1);
a_temp = zeros(nsx * nsy, 1);
sxy = zeros(nsx * nsy, 1);
sx = zeros(nsx * nsy, 1);
sx2 = zeros(nsx * nsy, 1);
sy = zeros(nsx * nsy, 1);
tot = zeros(nsx * nsy, 1);

nsize = nsx * nsy;

b_val = fread(file_id, nsx * nsy, 'float');

temp = reshape(b_val, [nsx, nsy]);
figure(1)
% imagesc(exp(temp./300) + 5)
imagesc(temp)
% title("True Image")
axis off
colorbar

nrec = 0;
ncnt = 0;
nbyte = 0;
store = zeros(nsx * nsy, 1);
idx = 1;
while true
    %     store = fread(file_id, 16, 'char');
    iadd_temp = fread(file_id, 1, 'int32');
    if length(iadd_temp)<1, break; end;
    iadd(idx) = iadd_temp;
    count(idx) = fread(file_id, 1, 'int32');
    pow(idx) = fread(file_id, 1, 'float32');
    azang(idx) = fread(file_id, 1, 'float32');
    
    pointer(idx).pt = fread(file_id, count(idx), 'int32');
    aresp1(idx).resp = fread(file_id, count(idx), 'float32');
    
    aresp1(idx).resp = aresp1(idx).resp/sum(aresp1(idx).resp);
    
    % drop zero gain terms
    pointer(idx).pt=pointer(idx).pt(aresp1(idx).resp>0);
    aresp1(idx).resp=aresp1(idx).resp(aresp1(idx).resp>0);
    
    idx = idx + 1;
    ncnt = ncnt + 1;
end

fclose(file_id);

nhtype = 31;
idatatype = 2;
ifreqhm = 31;
nia = 0;
ldes = 0;
ndes = 0;
ispare1 = 0;
tag = "(c) 2003 BYU MERS Laboratory";
sensor = "Simulation";

if median_flag == 1
    my_title = strcat("SIRF image of ", regname);
else
    my_title = strcat("SIR image of ", regname);
end

switch iopt
    case -1
        ideg_sc=10;
        iscale_sc=1000;
        i0_sc=100;
        ixdeg_off=0;
        iydeg_off=0;
        ia0_off=0;
        ib0_off=0;
    case 0
        ideg_sc=100;
        iscale_sc=1000;
        i0_sc=100;
        ixdeg_off=-100;
        iydeg_off=0;
        ia0_off=0;
        ib0_off=0;
    case 1
        ideg_sc=100;
        iscale_sc=100;
        i0_sc=1;
        ixdeg_off=0;
        iydeg_off=0;
        ia0_off=0;
        ib0_off=0;
    case 2
        ideg_sc=100;
        iscale_sc=100;
        i0_sc=1;
        ixdeg_off=0;
        iydeg_off=0;
        ia0_off=0;
        ib0_off=0;
    case 5
        ideg_sc=100;
        iscale_sc=100;
        i0_sc=1;
        ixdeg_off=-100;
        iydeg_off=0;
        ia0_off=0;
        ib0_off=0;
    case 11
        ideg_sc=10;
        iscale_sc=1000;
        i0_sc=10;
        ixdeg_off=0;
        iydeg_off=0;
        ia0_off=0;
        ib0_off=0;
    case 12
        ideg_sc=10;
        iscale_sc=1000;
        i0_sc=10;
        ixdeg_off=0;
        iydeg_off=0;
        ia0_off=0;
        ib0_off=0;
    case 13
        ideg_sc=10;
        iscale_sc=1000;
        i0_sc=10;
        ixdeg_off=0;
        iydeg_off=0;
        ia0_off=0;
        ib0_off=0;
    otherwise
        ideg_sc=100;
        iscale_sc=1000;
        i0_sc=100;
        ixdeg_off=0;
        iydeg_off=0;
        ia0_off=0;
        ib0_off=0;
end

ioff_A=140;
iscale_A=200;
itype_A=1;
anodata_A=150.0;
v_min_A=0.0;
v_max_A=0.1;
type_A = strcat("TB A image ", a_name);

ioff_V=-1;
iscale_V=500;
itype_V=22;
anodata_V=-1.00;
v_min_V=0.0;
v_max_V=10.0;
type_V = strcat("TB STD ", a_name);

old_amin=min(b_val);
old_amax=max(b_val);

"True min/max:"
old_amin
old_amax

v_min_A = old_amin;
v_max_A = old_amax;

strcat("Writing True A file ", b_name)

title1 = "";
crproc = "";
crtime = "";
descrip = "";
iaopt = [];

sir = write_sir3(b_name, b_val, nhead, nhtype, idatatype,...
    nsx, nsy, xdeg, ydeg, ascale, bscale, a0, b0, ixdeg_off,...
    iydeg_off, ideg_sc, iscale_sc, ia0_off, ib0_off, i0_sc,...
    ioff_A, iscale_A, iyear, isday, ismin, ieday, iemin,...
    iregion, itype_A, iopt, ipol, ifreqhm, ispare1, anodata_A,...
    v_min_A, v_max_A, sensor, title1, type_A, tag, crproc,...
    crtime, descrip, ldes, iaopt, nia);


"Begin SIR/SIRF processing. First Initialize Working Arrays."
a_val = ones(nsize, 1) .* a_init;
b_val = zeros(nsize, 1);
% a_temp = zeros(nsize, 1);
sx = zeros(nsize, 1);
sy = zeros(nsize, 1);
sxy = zeros(nsize, 1);
sx2 = zeros(nsize, 1);
% tot = zeros(nsize, 1);

old_amin = a_init;
old_amax = a_init;
a_temp = zeros(nsize,1);
tot = zeros(nsize,1);

sm = exp(pow ./ 300) + 5;
pow = sm;

for i=1:length(aresp1)
    
    data(i).sm_resp = (exp((aresp1(i).resp .* pow(i) ./ nanmean(aresp1(i).resp))./300) + 5) ./ sm(i);
%     data(i).sm_resp = 1./data(i).sm_resp;
%     data(i).sm_resp = data(i).sm_resp - nanmean(data(i).sm_resp);
    data(i).pt = pointer(i).pt;
end

for its = 0:nits - 1
    a_temp = zeros(nsize,1);
    tot = zeros(nsize,1);
    strcat("SIRF iteration: ", string(its + 1))
    if NOISY == 1
        pow = azang;
    end
    
    if its > 0
        a_val = log(a_val - 5) .* 300;
    end

    
    [a_val, a_temp, tot, sx, sx2, total] = get_simUpdates(pow', ang, count, pointer, aresp1, a_val, sx, sx2, a_temp, tot);
    a_val(a_temp > 0) = a_temp(a_temp>0);
    
    
    a_val = exp(a_val ./ 300) + 5;
    

    
    %     for i = 1:length(a_temp)
    %         hit = (a_temp(i).a_temp > 0);
    % %     total = total + tot .* hit;
    %         a_val(hit) = a_temp(i).a_temp(hit);
    %     end
    %     a_temp = zeros(nsize, 1);
    %     tot = zeros(nsize, 1);
%     temp2 = reshape(a_val, [nsx, nsy]);
%     figure(2)
%     imagesc(temp2)
%     colormap(gray)
%     title('MATLAB Code SIRF OUTPUT')
    
end




temp2 = reshape(a_val, [nsx, nsy]);
figure(2)
imagesc(temp2)
% title('Transformed Measurement Update SIRF')
axis off
colorbar


[image, head, descrip, iaopt]=loadsir('simA.sir');

figure(4)
imagesc(exp(flip(image',2) ./ 300) + 5)
% title('Sequential SIRF to Transformation')
axis off
colorbar

diff = temp2 - (exp(flip(image',2) ./ 300) + 5);
figure(5)
imagesc(diff)
colorbar
axis off
title('Difference Between Both Methods')

% [com_mean_err, com_rmse] = compute_sm_err(temp2, exp(temp./300) + 5)
% [seq_mean_err, seq_rmse] = compute_sm_err((exp(flip(image',2) ./ 300) + 5), exp(temp./300) + 5)

figure(4)
imagesc(abs((temp2 - (exp(temp./300) + 5)) ./ (exp(temp./300) + 5)) * 100)

% for i = 1:nsy
%     ancil(1:nsx, i) = i:nsx + i - 1;
% end
% 
% figure(6)
% imagesc(temp2 + ancil)
% colormap(gray)

imagesc(abs(((exp(flip(image',2) ./ 300) + 5) - (exp(temp./300) + 5)) ./ (exp(temp./300) + 5)) * 100)
axis off
colorbar












