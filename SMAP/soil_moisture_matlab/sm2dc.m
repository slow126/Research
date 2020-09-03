function [ dcArray ] = sm2dc( smArray, clayfrac )
%dc2sm Converts soil moisture content to soil dielectric constant
%   Uses a dielectric mixing model (selected by the method option)
%   to convert sm to dc. Output array will be the same size as the
%   input array. Clay should be the same size as both of these.

[rows, cols]=size(smArray);
dcArray=nan(size(smArray));
for x1=1:cols
    for y1=1:rows
        cur_mois=smArray(y1,x1);
        clay=clayfrac(y1,x1);   %Range 0-1
        if(isnan(cur_mois) || isnan(clay))
            continue;
        end

        eps_inf=4.9;
        f=1.41*10^9;
        eps0=1;  % Is this correct?
        nd=1.634-.539*clay+.2748*(clay^2);
        kd=.03952-.04038*clay;
        mvt=.02863+.30673*clay;
        e0b=79.8-85.4*clay+32.7*(clay^2);
        taub=1.062*10^(-11)+3.45*10^(-12)*clay;
        sigmab=.3112+.467*clay;
        sigmau=.3631+1.217*clay;
        e0u=100;
        tauu=8.5*10^(-12);
        eps1b=eps_inf+(e0b-eps_inf)/(1+(2*pi*f*taub)^2);
        eps2b=(e0b-eps_inf)/(1+(2*pi*f*taub)^2)*2*pi*f*taub+sigmab/(2*pi*eps0*f);
        eps1u=eps_inf+(e0u-eps_inf)/(1+(2*pi*f*tauu)^2);
        eps2u=(e0u-eps_inf)/(1+(2*pi*f*tauu)^2)*2*pi*f*tauu+sigmau/(2*pi*eps0*f);
        nb=(sqrt(sqrt(eps1b^2+eps2b^2)+eps1b))/sqrt(2);
        nu=(sqrt(sqrt(eps1u^2+eps2u^2)+eps1u))/sqrt(2);
        kb=(sqrt(sqrt(eps1b^2+eps2b^2)-eps1b))/sqrt(2);
        ku=(sqrt(sqrt(eps1u^2+eps2u^2)-eps1u))/sqrt(2);
        

        if(cur_mois <= mvt)
            nm = nd+(nb-1)*cur_mois;
            km = kd+kb*cur_mois;
            real_part = nm^2-km^2;
            im_part = 2*nm*km;
            dcArray(y1,x1)=real_part+1i*im_part;
        elseif(cur_mois > mvt)
            nm = nd+(nb-1)*mvt + (nu-1)*(cur_mois-mvt);
            km = kd+kb*mvt + ku*(cur_mois-mvt);
            real_part = nm^2-km^2;
            im_part = 2*nm*km;
            dcArray(y1,x1)=real_part+1i*im_part;
        end

    end
end

end

