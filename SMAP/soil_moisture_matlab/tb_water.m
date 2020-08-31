function tbwater = tb_water(surftemp, S, inc)
%Calculate the brightness temperature contributed from a body of water
% Based off Klein-Swift Model

    Tc=surftemp-273.15;
    delta=25-Tc;
    omega=2*pi*1.41*10^9; % SMAP frequency 1.41 GHz
    dc_inf = 4.9;
    dc_0 = 8.854*10^-12;
    alpha = 0;
    

    sigma_init = S*(0.182521 - 0.00146192*S + 0.0000209324*S^2 - 0.000000128205*S^3);
    beta = 0.02033 + 0.0001266*delta + 0.000002464*delta^2 - ...
        S*(0.00001849-0.0000002551*delta+0.00000002551*delta^2);
    sigma = sigma_init*exp(-delta*beta);

    dc_s_init = 87.134 - 0.1949*Tc - .01276*Tc^2 + 0.0002491*Tc^3;
    a_s = 1 + 0.00001613*S*Tc - 0.003656*S + 0.0000321*S^2 - 0.0000004232*S^3;
    dc_s = dc_s_init*a_s;

    tau_init = 1.768*10^-11 - 6.086*10^-13*Tc + 1.104*10^-14*Tc^2 - 8.111*10^-17*Tc^3;
    b_tau = 1 + .00002282*S*Tc - .0007638*S - .00000776*S^2 + .00000001105*S^3;
    tau = tau_init*b_tau;

    waterdc=dc_inf + (dc_s - dc_inf)/(1+(1i*omega*tau)^(1-alpha))-1i*sigma/(omega*dc_0);
%     wateremis=1-abs((1-sqrt(waterdc))/(1+sqrt(waterdc)))^2; %Is this correct? Switch to fresnel which accounts for incidence angle?
    wateremis=1-abs((waterdc*cos(inc) - sqrt(waterdc - sin(inc)^2))./(waterdc*cos(inc) + sqrt(waterdc - sin(inc)^2))).^2;
    tbwater=surftemp*wateremis;

end

