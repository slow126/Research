function sigs = gmf(in)
% function sigs = gmf(in)
%  evaluates gmf at the parameters specified by the rows of in
%  where in = [relaz,speed,inc,ipol;
%              relaz,speed,inc,ipol; 
%              etc.]
%

% written by DGL 21 April 1997

global gmf_model_tab;
[m,n]=size(gmf_model_tab);
if (m == 0), error('Model function table not loaded'), end

[m,n]=size(in);
for k=1:m
  ipol=in(k,4);
  ainc=(in(k,3)-16)/2+1;
  if ainc<1 | ainc>66 
    disp('Error with incidence angle...');
    sigs(k)=0;
  else
    if ipol < 1 | ipol > 2
      disp('Error with polarization...');
      sigs(k)=0;
    else
      speed=in(k,2);
      if speed < 1
	speed=1;
      end;
      if speed > 50
	speed=50;
      end;
      relaz=in(k,1)/5+1;
      if relaz < 1 
	relaz = relaz+72;
      end;
      if relaz > 73 
	relaz = relaz-72;
      end;
      if relaz > 37
	relaz=74-relaz;
      end;
      if ipol==2
	ipol=1+50*37;
      end;
      i1=floor(ainc);
      i2=i1+1;
      if i2 > 33
	i1=i1-1;
	i2=i1+1;
      end;
      a1=1-(ainc-i1);
      a2=ainc-i1;
      t1=reshape(gmf_model_tab(i1,ipol:ipol+50*37-1),[50,37]);
      t1=[[0:50]' [1:37; t1]];
      t2=reshape(gmf_model_tab(i2,ipol:ipol+50*37-1),[50,37]);
      z1=table2(t1,speed,relaz);
      t2=[[0:50]' [1:37; t2]];
      z2=table2(t2,speed,relaz);
      sigs(k)=a1*z1+a2*z2;
    end;
  end;
end;
