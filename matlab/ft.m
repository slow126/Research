function [a,c,s,c2,s2]=ft(junk,ll,ul);
%
% compute the fourier series fit to extracted data
%

ind=find(junk(:,2) > ll & junk(:,2) < ul);
l=length(ind);
a=sum(junk(ind,1))/l;
csum=sum(cos(junk(ind,3)))/l;
ssum=sum(sin(junk(ind,3)))/l;
csum2=sum(cos(2*junk(ind,3)))/l;
ssum2=sum(sin(2*junk(ind,3)))/l;
csum22=sum(cos(junk(ind,3)).*cos(2*junk(ind,3)))/l;
ssum22=sum(sin(junk(ind,3)).*sin(2*junk(ind,3)))/l;
c=sum(junk(ind,1).*cos(junk(ind,3)))/l;
s=sum(junk(ind,1).*sin(junk(ind,3)))/l;
c2=sum(junk(ind,1).*cos(2*junk(ind,3)))/l;
s2=sum(junk(ind,1).*sin(2*junk(ind,3)))/l;

c=c-a*csum;
s=s-a*ssum;
c2=c2-a*csum2-c*csum22;
s2=s2-a*ssum2-s*ssum22;
