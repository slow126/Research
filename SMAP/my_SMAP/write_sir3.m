function [sir] = write_sir3(b_name, b_val, nhead, nhtype, idatatype,...
    nsx, nsy, xdeg, ydeg, ascale, bscale, a0, b0, ixdeg_off,...
    iydeg_off, ideg_sc, iscale_sc, ia0_off, ib0_off, i0_sc,...
    ioff_A, iscale_A, iyear, isday, ismin, ieday, iemin,...
    iregion, itype_A, iopt, ipol, ifreqhm, ispare1, anodata_A,...
    v_min_A, v_max_A, sensor, title1, type_A, tag, crproc,...
    crtime, descrip, ldes, iaopt, nia)
%WRITE_SIR3 Summary of this function goes here
%   Detailed explanation goes here
sir.b_name = b_name;
sir.b_val = b_val;
sir.nhead = nhead;
sir.nhtype = nhtype;
sir.idatatype = idatatype;
sir.nsx = nsx;
sir.nsy = nsy;
sir.xdeg = xdeg;
sir.ydeg = ydeg;
sir.ascale = ascale;
sir.bscale = bscale;
sir.a0 = a0;
sir.b0 = b0;
sir.ixdeg_off = ixdeg_off;
sir.iydeg_off = iydeg_off;
sir.ideg_sc = ideg_sc;
sir.iscale_sc = iscale_sc;
sir.ia0_off = ia0_off;
sir.ib0_off = ib0_off;
sir.i0_sc = i0_sc;
sir.ioff_A = ioff_A;
sir.iscale_A = iscale_A;
sir.iyear = iyear;
sir.isday = isday;
sir.ismin = ismin;
sir.ieday = ieday;
sir.iemin = iemin;
sir.iregion = iregion;
sir.itype_A = itype_A;
sir.iopt = iopt;
sir.ipol = ipol;
sir.ifreqhm = ifreqhm;
sir.ispare1 = ispare1;
sir.anodata_A = anodata_A;
sir.v_min_A = v_min_A;
sir.v_max_A = v_max_A;
sir.sensor = sensor;
sir.title1 = title1;
sir.type_A = type_A;
sir.tag = tag;
sir.crproc = crproc;
sir.crtime = crtime; 
sir.descrip = descrip;
sir.ldes = ldes;
sir.iaopt = iaopt;
sir.nia = nia;



end

