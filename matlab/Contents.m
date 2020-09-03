% MATLAB utilities for the BYU-MERS "SIR" image format
%
% The BYU-MERS "sir" image format was developed by the Brigham Young
% University (BYU) Microwave Earth Remote Sensing (MERS) research group
% to store images of the earth along with the information required to
% earth-locate the image pixels.
%
% Files in this directory are useful for reading SIR files into matlab
% and locating pixels.  Use loadsir.m to load the file into memory.
%
% Main routines:  (version 2.0 SIR format)
%
% loadsir.m            loads image and header information into matlab
% gzloadsir.m          calls loadsir, gunzipping file if needed
% loadpartsir.m        loads part of/all image and header into matlab
% gzloadpartsir.m      calls loadpartsir, gunzipping file if needed
% printsirhead.m       prints out the header information from loadsir
% pix2latlon.m         given a pixel location, compute lat and lon
% latlon2pix.m         compute pixel location given lat and lon
% sirheadtext.m        modifies text fields of sir header before write
% writesir.m           writes sir format file
%
% Support routines:
%
% easegrid.m           forward EASE grid transformation
% ieasegrid.m          inverse EASE grid transformation
% ilambert1.m          inverse Lambert grid transformation
% ipolster.m           inverse polar stereographic grid transformation
% lambert1.m           forward Lambert grid transformation
% mod.m                compute modulo function
% polster.m            forward polar stereographic grid transformation
%
% scaleimage.m         utility to scale image for display
% showimage.m          simplified display of an image
% showsir.m            display a sir image
