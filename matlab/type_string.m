function bname=type_string(b);
% function ptype=type_string(b);
%
% returns a unique color & line type for b=1:8 and 9:16
%
 bname='r-';
 if b==2 
  bname='r:';
 end
 if b==3
  bname='b-';
 end 
 if b==4
  bname='b:';
 end
 if b==5
  bname='g-';
 end
 if b==6
  bname='g:';
 end
 if b==7
  bname='y-';
 end
 if b==8
  bname='y:';
 end
 if b==9
  bname='r--';
 end
 if b==10 
  bname='r-.';
 end
 if b==11
  bname='b--';
 end 
 if b==12
  bname='b-.';
 end
 if b==13
  bname='g--';
 end
 if b==14
  bname='g-.';
 end
 if b==15
  bname='y--';
 end
 if b==16
  bname='y-.';
 end
