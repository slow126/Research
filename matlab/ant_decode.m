function [ant,pol,ipol,name] = ant_decode(cur_ant_beam)

% function [ant,pol,ipol,name] = ant_decode(cur_ant_beam)
%
% This function decodes the current_antenna_beam value
%   in L15 records into the antenna_number and polarization.

antenna_num  = [ 1   6   2   5   2   5   3   4];
polarization = ['V' 'V' 'V' 'V' 'H' 'H' 'V' 'V'];

ant = antenna_num(cur_ant_beam);
pol = polarization(cur_ant_beam);
ipol = 1;
if pol == 'H'
 ipol=2;
end
name=[sprintf('%1.0f',ant) pol];

end
