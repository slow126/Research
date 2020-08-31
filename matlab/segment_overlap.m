function [hit s1 e1 s2 e2]=segment_overlap(s,m,n);
%
% function [hit s1 e1 s2 e2]=segment_overlap(s,m,n);
%
% computes the start:end parameters for copying information from
% one buffer IN(1:m) into another, possibly overlapping, buffer OUT(1:n)
% given the relative start index s in the OUT coordinate system
%
% if the two buffers do not intersect, hit=0
%
% example:  if s=-1 and m<n, then OUT(1:m-2)=IN(3:m) & hit=1

% written by DGL BYU 11 Oct 2006

hit=1;
s1=1;
s2=1;
e1=min(m,n);
e2=e1;

e=s+m-1;

if s>n | e<1  % buffers do not intersect
  hit=0;
else          % all possible overlap cases
  if s>=1  
    s2=s;
    if e>n
      s2=s;
      e1=n-s+1;
      e2=n;
    else
      e1=m;
      e2=e;
    end
  else
    s1=2-s;
    if e>n
      e1=s1+n-1;
      e2=n;
    else
      e1=m;
      e2=e;
    end
  end
  
  if e2-s2 ~= e1-s1
    disp(sprintf('*** error s=%d e=%d m=%d n=%d s1=%d e1=%d s2=%d e2=%d',s,e,m,n,s1,e1,s2,e2))
  end

end

%disp(sprintf('hit=%d s=%d e=%d m=%d n=%d s1=%d e1=%d s2=%d e2=%d',hit,s,e,m,n,s1,e1,s2,e2));

return;
