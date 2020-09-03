function out=escape_underbar(in)
%
% function out=escape_underbar(in)
% 
% generates "escaped underbar" string out from input string in with
% underbars so that underbars are not interpretted as subscripts
%
% e.g. out="this\_is\_a\_test" from "this_is_a_test"
%

% written 11/17/2007 by DGL at BYU

out=sprintf('%s',in);
ind=find(out=='_');
for k=length(ind):-1:1
  if ind(k)==1
    out=sprintf('\\%s',out(ind(k):end));
  else
    out=sprintf('%s\\%s',out(1:ind(k)-1),out(ind(k):end));
  end
end