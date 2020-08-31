function dow = dayofweek(year,mon,day);
%
% computes the day of the week (sun=1,mon=2, etc.) given the date year,mon,day
%

% written by D.Long 4/30/2009
% this algorithm is by Tomohiko Sakamoto (http://c-faq.com/misc/zeller.html

t=[0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4];
y=year;
if mon<3
  y=y-1;
end
dow=mod((y+floor(y/4)-floor(y/100)+floor(y/400)+t(mon)+day),7)+1;

