function out=clip_blanks(in);
%
% function out=clip_blanks(in)
%
% removes any characters after (and including) first space from 'in'

ind=find(in==' ');
if length(ind)>0
  out=in(1:ind(1)-1);
else
  out=in;
end

return