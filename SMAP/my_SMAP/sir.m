NOISY = 1;
file_in = '/Users/low/Documents/MATLAB/SMAP/SMAP/src/res/matsim/Ch1_P2_Ns3/sir.setup';
% open files
iid=fopen(file_in,'r');
%disp(sprintf('Writing %s',file_out));
nfile = 1;

% copy header
M=fread(iid,1,'int32'); %nsx
N=fread(iid,1,'int32'); %nsy
sampspacing=fread(iid,1,'float32'); %ascale
grd_size=fread(iid,1,'float32'); %gsize

a0=0.0;
b0=0.0;
xdeg=nsx*ascale;
bscale=ascale;
ydeg=nsy*bscale;
iopt=-1;
isday=0;
ieday=0;
ismin=0;
iemin=0;
iyear=2003;
ipol=0;
iregion=97;
regname = "Simulated Test";
non_size_x=round(gsize/ascale);
non_size_y=non_size_x;
nsx2=nsx/non_size_x;
nsy2=nsy/non_size_y;
a02=0.0;
b02=0.0;
ascale2=ascale*non_size_x;
bscale2=bscale*non_size_y;
xdeg2=xdeg;
ydeg2=ydeg;

if (NOISY) 
        a_name = "simA2.sir";
        grd_aname = "simA2.grd";
        grd_vname = "simV2.grd";
        non_aname = "simA2.non";
        a_name_ave = "simA2.ave";
        v_name = "simV2.sir";
else 
        a_name = "simA.sir";
        grd_aname = "simA.grd";
        grd_vname = "simV.grd";
        non_aname = "simA.non";
        a_name_ave = "simA.ave";
        v_name = "simV.sir";
end
b_name = "true.sir";
median_flag=0;

strcat("File size: ", str(nls(nfiles))," ", str(head_len(nfiles)))

nls(nfiles) = nls(nfiles) - head_len(nfiles);
nfiles = nfiles + 1;

nspace = 0
for i = 1 : length(nfiles)
    nspace = nspace + nls(i)
end

nhtype=31;		%/* set header type */
idatatype=2;	%	/* output image is in standard i*2 form */
ifreqhm=31;
nia=0;          %     /* no extra integers */
ldes=0;         %      /* no extra text */
ndes=0;
ispare1=0;
tag = "(c) 2003 BYU MERS Laboratory";
sensor = "Simulation";
regname ='\0';

% if (median_flag == 1) 
% sprintf(title,"SIRF image of %s",regname);
% else
% sprintf(title,"SIR image of %s",regname);
% 
% (void) time(&tod);
% (void) strftime(crtime,28,"%X %x",localtime(&tod));
% printf("Current time: '%s'\n",crtime);

% switch (iopt){
%   case -1: /* image only */
%     ideg_sc=10;
%     iscale_sc=1000;
%     i0_sc=100;
%     ixdeg_off=0;
%     iydeg_off=0;
%     ia0_off=0;
%     ib0_off=0;
%     break;
%   case 0: /* rectalinear lat/lon */
%     ideg_sc=100;
%     iscale_sc=1000;
%     i0_sc=100;
%     ixdeg_off=-100;
%     iydeg_off=0;
%     ia0_off=0;
%     ib0_off=0;
%     break;
%   case 1: /* lambert */
%   case 2:
%     ideg_sc=100;
%     iscale_sc=100;
%     i0_sc=1;
%     ixdeg_off=0;
%     iydeg_off=0;
%     ia0_off=0;
%     ib0_off=0;
%     break;
%   case 5: /* polar stereographic */
%     ideg_sc=100;
%     iscale_sc=100;
%     i0_sc=1;
%     ixdeg_off=-100;
%     iydeg_off=0;
%     ia0_off=0;
%     ib0_off=0;
%     break;
%   case 11: /* EASE grid */
%   case 12:
%   case 13:
%     ideg_sc=10;
%     iscale_sc=1000;
%     i0_sc=10;
%     ixdeg_off=0;
%     iydeg_off=0;
%     ia0_off=0;
%     ib0_off=0;
%     break;
%   default: /* unknown */
%     ideg_sc=100;
%     iscale_sc=1000;
%     i0_sc=100;
%     ixdeg_off=0;
%     iydeg_off=0;
%     ia0_off=0;
%     ib0_off=0;
%   }

% ioff_A=140;
%   iscale_A=200;
%   itype_A=1;
%   anodata_A=150.0;
%   v_min_A=0.0;
%   v_max_A=0.1;
%   sprintf(type_A,"TB A image  (%s)",a_name);
%   
%   ioff_V=-1;
%   iscale_V=500;
%   itype_V=22;
%   anodata_V=-1.00;
%   v_min_V=0.0;
%   v_max_V=10.0;
%   sprintf(type_V,"TB STD  (%s)",a_name);
% 
%   old_amin=1.e25;
%   old_amax=-1.e25;
%   for (i=0; i < nsize; i++) {
%     old_amin=min(old_amin, *(b_val+i));
%     old_amax=max(old_amax, *(b_val+i));
%   }
%   printf("True min/max %f %f\n",old_amin,old_amax);
%   v_min_A=old_amin;
%   v_max_A=old_amax;

% Begin SIRF processing
nsize = nsx * nsy;
a_init = 230.0;
meas_offset = 0;
nits = 20;
AVE_INIT = 1;


a_val  = a_init * ones(1, nsize);
b_val  = zeros(1, nsize);
a_temp = zeros(1, nsize);
sx     = zeros(1, nsize);
sy     = zeros(1, nsize);
sxy    = zeros(1, nsize);
sx2    = zeros(1, nsize);
tot    = zeros(1, nsize);

old_amin=a_init;
old_amax=a_init;

printf("SIRF parameters: A_init=%f N=%d\n",a_init,nits);
printf("                 Offset=%f\n\n",meas_offset);

% for each iteration of SIRF %

for its = 0 : nits

    printf("\nSIRF iteration %d %d\n",its+1,ncnt);


% for each measurement, accumulate results %

  measurements = get_measurements(infile);

  if meas_offset ~= 0.0
      pow = pow + meas_offset;
  end

  % printf("get_updates\n"); %

  get_updates(pow, ang, count, store,...
      store2, irec, a_val, a_temp, tot, sx, sx2);

  % compute AVE image during first iteration */

  if (its == 0) 
        compute_ave(pow, count, (int *) store, (float *) store2);
  end

  store = store+4*count;
  store = store+4*count;

end

% done:
% after processing all measurements for this iteration and
%   updating the A image, clear arrays */

amin =  320.0;            /* for user stats */
amax =  -320.0;
tmax = -1;
total = 0.0;

for (i=0; i<nsize; i++){
  if (*(tot+i) > 0) {    /* update only hit pixels */
total = total + *(tot+i);
*(a_val+i) = *(a_temp+i);

if (its+1 != nits) {          /* clean up */
  *(a_temp+i) = 0.0;
  *(sx+i) = 0.0;
  *(sx2+i) = 0.0;
  *(tot+i) = 0.0; 
} else {                      /* last iteration */
  *(sx2+i) = *(sx2+i) - *(sx+i) * *(sx+i);
  if (*(sx2+i) > 0.0) *(sx2+i) = sqrt((double) *(sx2+i));
  *(sxy+i) = *(tot+i);
  tmax = max(tmax, *(tot+i));
}
if (its == 0) {        /* first iteration, compute AVE */
  if (*(sy+i) > 0) 
    *(b_val+i) = *(b_val+i) / *(sy+i);
  else
    *(b_val+i) = anodata_A;
  if (AVE_INIT)
    *(a_val+i)=*(b_val+i); /* copy AVE to sir iteration buffer */
}
amin = min(amin, *(a_val+i));
amax = max(amax, *(a_val+i));

  } else {
*(a_val+i) = anodata_A;
*(b_val+i) = anodata_A;
if (its+1 == nits) {
  *(sx2+i) = -1;
  *(sxy+i) = -1;
}
  }	
}

if (its == 0) printf("Average hits: %.4f\n",total/nsize);
printf(" A min   max --> %f %f %d\n",amin,amax,its+1);
printf(" A change    --> %f %f\n",amin-old_amin,amax-old_amax);

old_amin=amin;
old_amax=amax;


if (median_flag == 1)   /* apply modified median filtering */
  filter(a_val, 3, 0, nsx, nsy, a_temp, anodata_A);  /* 3x3 modified median filter */

if (its == 0) {  /* output AVE image */

  sprintf(title1, "AVE image of %s",regname);
  sprintf(crproc,"BYU MERS:sea_meta_sirf_egg v4.1 AVE image");

  if (meas_offset != 0.0) {   /* shift A image before save */
for (i=0; i<nsize; i++)
  if (*(b_val+i) > anodata_A)    /* update only hit pixels */
    *(b_val+i) = *(b_val+i) - meas_offset;
  }

  printf("	Writing A output AVE file '%s'\n", a_name_ave);
  ierr = write_sir3(addpath(outpath,a_name_ave, tstr), b_val, &nhead, nhtype, 
        idatatype, nsx, nsy, xdeg, ydeg, ascale, bscale, a0, b0, 
        ixdeg_off, iydeg_off, ideg_sc, iscale_sc, 
        ia0_off, ib0_off, i0_sc,
        ioff_A, iscale_A, iyear, isday, ismin, ieday, iemin, 
        iregion, itype_A, iopt, ipol, ifreqhm, ispare1,
        anodata_A, v_min_A, v_max_A, sensor, title1, type_A, tag,
        crproc, crtime, descrip, ldes, iaopt, nia);
  if (ierr < 0) {
fprintf(stdout,"*** ERROR writing A AVE output file ***\n");
errors++;
  }
}

/* output A files during iterations */

if ( Niter < 0 || its+1 == nits) {

  if (meas_offset != 0.0) {   /* shift A image before save */
for (i=0; i<nsize; i++)
  if (*(a_val+i) > anodata_A)    /* update only hit pixels */
    *(a_val+i) = *(a_val+i) - meas_offset;
  }

  sprintf(crproc,"BYU MERS:meas_meta_sir Ai=%6.2f It=%d",a_init,its+1);

  if (its+1 == nits) {  /* final product image */
printf("\n");      
printf("Writing A output SIR file '%s'\n", a_name);
ierr = write_sir3(addpath(outpath,a_name, tstr), a_val, &nhead, nhtype, 
          idatatype, nsx, nsy, xdeg, ydeg, ascale, bscale, a0, b0, 
          ixdeg_off, iydeg_off, ideg_sc, iscale_sc, 
          ia0_off, ib0_off, i0_sc,
          ioff_A, iscale_A, iyear, isday, ismin, ieday, iemin, 
          iregion, itype_A, iopt, ipol, ifreqhm, ispare1,
          anodata_A, v_min_A, v_max_A, sensor, title, type_A, tag,
          crproc, crtime, descrip, ldes, iaopt, nia);
if (ierr < 0) {
  fprintf(stdout,"*** ERROR writing A output file ***\n");
  errors++;
}
  }

  if (Niter < 0) {  /* iteration image */
if (NOISY)
  sprintf(a2_name,"simA2_%d.sir",its+1);
else
  sprintf(a2_name,"simA_%d.sir",its+1);

printf("\n"); 
printf("Writing iteration %d A output SIR file '%s'\n", its+1, a2_name);
ierr = write_sir3(addpath(outpath,a2_name, tstr), a_val, &nhead, nhtype, 
          idatatype, nsx, nsy, xdeg, ydeg, ascale, bscale, a0, b0, 
          ixdeg_off, iydeg_off, ideg_sc, iscale_sc, 
          ia0_off, ib0_off, i0_sc,
          ioff_A, iscale_A, iyear, isday, ismin, ieday, iemin, 
          iregion, itype_A, iopt, ipol, ifreqhm, ispare1,
          anodata_A, v_min_A, v_max_A, sensor, title, type_A, tag,
          crproc, crtime, descrip, ldes, iaopt, nia);
if (ierr < 0) {
  fprintf(stdout,"*** ERROR writing output file ***\n");
  errors++;
}
  }

  if (meas_offset != 0.0 && its+1 != nits) {   /* shift A image back */
for (i=0; i<nsize; i++)
  if (*(a_val+i) > anodata_A)    /* update only hit pixels */
    *(a_val+i) = *(a_val+i) + meas_offset;

  }
}
}
