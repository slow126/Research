function [] = antenna(N)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
close all;
lambda=1;
d=N*lambda/2;
N=2;

thetas=0:.001:pi;



%rho=((sin((N.*pi.*d./lambda).*cos(thetas))).^2)./((N.^2)*(sin((pi.*d./lambda).*cos(thetas))).^2);
rho=(sin(N*pi*d*cos(thetas)./lambda)).^2./(N^2*(sin(pi*d*cos(thetas)./lambda)).^2);

%polarplot(thetas, sin(2*thetas).*cos(2*thetas), '--r');
polarplot(thetas,rho);
%figure;
%plot(thetas*180/pi, rho)
[peaks,locs]=findpeaks(rho)
round(thetas(locs).*180/pi)
end
