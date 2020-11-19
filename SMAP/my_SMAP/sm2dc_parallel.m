function [ dcArray ] = sm2dc_parallel( smArray, clayfrac )
%dc2sm Converts soil moisture content to soil dielectric constant
%   Uses a dielectric mixing model (selected by the method option)
%   to convert sm to dc. Output array will be the same size as the
%   input array. Clay should be the same size as both of these.

[rows, cols]=size(smArray);
cols = length(clayfrac);
dcArray=nan(size(smArray));
        

        
        eps_inf=4.9;
        f=1.41*10^9;
        eps0=1;  % Is this correct?
        nd=1.634-.539.*clayfrac+.2748*(clayfrac.^2);
        kd=.03952-.04038.*clayfrac;
        mvt=.02863+.30673.*clayfrac;
        e0b=79.8-85.4.*clayfrac+32.7*(clayfrac.^2);
        taub=1.062*10^(-11)+3.45*10^(-12).*clayfrac;
        sigmab=.3112+.467.*clayfrac;
        sigmau=.3631+1.217.*clayfrac;
        e0u=100;
        tauu=8.5*10^(-12);
        eps1b=eps_inf+(e0b-eps_inf)./(1+(2*pi*f.*taub).^2);
        eps2b=(e0b-eps_inf)./(1+(2*pi*f.*taub).^2)*2*pi*f.*taub+sigmab./(2*pi.*eps0*f);
        eps1u=eps_inf+(e0u-eps_inf)./(1+(2*pi*f*tauu)^2);
        eps2u=(e0u-eps_inf)./(1+(2*pi*f*tauu)^2)*2*pi*f*tauu+sigmau./(2*pi.*eps0*f);
        nb=(sqrt(sqrt(eps1b.^2+eps2b.^2)+eps1b))./sqrt(2);
        nu=(sqrt(sqrt(eps1u.^2+eps2u.^2)+eps1u))./sqrt(2);
        kb=(sqrt(sqrt(eps1b.^2+eps2b.^2)-eps1b))./sqrt(2);
        ku=(sqrt(sqrt(eps1u.^2+eps2u.^2)-eps1u))./sqrt(2);
        

%         nm = zeros(size(smArray,1),size(smArray,2));
%         km = zeros(size(smArray,1),size(smArray,2));
%         real_part = zeros(size(smArray,1),size(smArray,2));
%         im_part = zeros(size(smArray,1),size(smArray,2));
        

            

            parfor i = 1:length(mvt)
                nm = zeros(size(smArray,1),size(smArray,2));
                km = zeros(size(smArray,1),size(smArray,2));
                real_part = zeros(size(smArray,1),size(smArray,2));
                im_part = zeros(size(smArray,1),size(smArray,2));
                
                less_ind = (smArray <= mvt(i));
                nm(less_ind) = nd(i)+(nb(i)-1).*smArray(less_ind);
                km(less_ind) = kd(i)+kb(i).*smArray(less_ind);
                real_part(less_ind) = nm(less_ind).^2-km(less_ind).^2;
                im_part(less_ind) = 2.*nm(less_ind).*km(less_ind);

                great_ind = (smArray > mvt(i));
                nm(great_ind) = nd(i)+(nb(i)-1).*mvt(i) + (nu(i)-1).*(smArray(great_ind)-mvt(i));
                km(great_ind) = kd(i)+kb(i)*mvt(i) + ku(i)*(smArray(great_ind)-mvt(i));
                real_part(great_ind) = nm(great_ind).^2-km(great_ind).^2;
                im_part(great_ind) = 2.*nm(great_ind).*km(great_ind);
                dcArray(i,:)=real_part+1i*im_part;
            end
            




end

