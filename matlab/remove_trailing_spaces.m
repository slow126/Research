function out=remove_trailing_spaces(in)
%
% out=remove_trailing_spaces(in)
%
% removes trailing spaces (if any) from the input string in
%
k=find(in<30);
if length(k)>0
  out=in(1:(k(1)-1));
else
  out=in;
end