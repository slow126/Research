function [ smArray ] = dc2sm( dcArray, clayfrac, method )
%dc2sm Converts soil dielectric constant to soil moisture content
%   Uses a dielectric mixing model (selected by the method option)
%   to convert dc to sm. Output array will be the same size as the
%   input array. Clay should be the same size as both of these.

if(method==1) % MBSDM method explained/developed by Mironov, Kosolapova, Fomin
    [rows, cols]=size(dcArray);
    smArray=nan(size(dcArray));
    for x1=1:cols
        for y1=1:rows
            realeps=dcArray(y1,x1);
            clay=clayfrac(y1,x1);   %Range 0-1
            if(isnan(realeps) || isnan(clay))
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
            a1=(nb-1)^2-kb^2;
            b1=2*nd*(nb-1)-2*kb;
            c1=nd^2-kd^2-realeps;
            a2=(nu-1)^2-ku^2;
            b2=2*(nd*(nu-1)+(nb-1)*(nu-1)-ku*kd-kb*ku*mvt);
            c2=nd^2+2*nd*mvt*(nb-1)+(nb-1)^2*mvt^2-kd^2-2*kd*kb*mvt-kb^2*mvt^2-realeps;

            moisturelow=quadFun(a1,b1,c1,1);
            moisturehigh=quadFun(a2,b2,c2,1)+mvt;

            if(moisturehigh <= mvt && moisturelow <= mvt) % For sure low
                smArray(y1,x1)=moisturelow;
            elseif(moisturehigh > mvt && moisturelow > mvt) % For sure high
                smArray(y1,x1)=moisturehigh;
            else % Default case. Not sure what to do here.
                smArray(y1,x1)=moisturehigh;
            end

        end
    end
    
    
elseif(method==2) % Equation created by Topp, Davis, and Annan
    smArray = -.053 + .029*dcArray - .00055*dcArray.^2 + .0000043*dcArray.^3; 
    
elseif(method==3) % Equation created by Miller and Gaskin
    smArray = (dcArray.^.5 - 1.5)/8.0; % Fine tune this to organic/mineral
                                       % Current numbers just in between
else
    fprintf('Invalid Method Option in Function dc2sm\n');
    exit();
end

end

