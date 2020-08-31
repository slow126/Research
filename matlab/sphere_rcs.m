function [] = sphere_rcs()
% SPHERE_RCS calculates the exact RCS for a perfect sphere of given diameter, using
%   the Mie series solution, given by equations 4-19, 4-16, and 4-17 in section
%   4.2 of "Radar Cross Section," by Eugene F. Knott, John F. Shaeffer, and
%   Michael T. Tuley (c1985 Artech House).  Note: The 1993 edition changes the
%   sign of the imaginary term in the Hankel function from positive, to negative.
%   To accomplish this in MATLAB, set K=2 in BESSELH.
%   Inputs: Dia = diameter of sphere {inches}.
%           Freq = frequency {GHz} (a second frequency causes the RCS over the range
%                  between the two frequencies to be plotted.
%   Version 1.3b by Douglas Dougherty,  NSWC DD Code T45,  6/17/99


% input parameters:
Dia = input('Sphere diameter {inches}? [12.0]:   ');  % diameter of perfect conducting sphere
if isempty(Dia)
  Dia = 12.0 ;                       % if no entry, the default diameter is 12".
end

Freq_input = input('Frequency [, end Frequency] {GHz}? [3.0]:   ', 's');  % frequency, in GHz
if isempty(Freq_input)
  Freq1 = 3.0 ;                      % if no entry, the default frequency is 3.0 GHz.
  Freq2 = 0 ;
  freq_steps = 0 ;
else
  [F1,rem] = strtok(Freq_input, ' ,') ;  % search for tokens using space and/or comma delimiters.
  Freq1 = str2num(F1) ;
  if ~isempty(rem)
    F2 = strtok(rem,' ,') ;
    Freq2 = str2num(F2) ;
    freq_steps = 100 ;
  else
    Freq2 = 0 ;
    freq_steps = 0 ;
  end
end


c = 2.997925e008 ;                  % speed of light {m/sec}.
ipm = 39.3700787402 ;               % conversion factor from inches to meters.
iterations = 100 ;                  % approximation for infinity for the Mie series.
r = Dia / 2 / ipm ;                 % calculate sphere radius {m}.


for k = 0 : freq_steps ;
  Freq = Freq1 + ( k / (freq_steps + eps) * ( Freq2 - Freq1 ) ) ;  % frequency range, in GHz.
  Frequency( k + 1 ) = Freq ;
  lambda = c / ( Freq * 1e9 ) ;     % calculate wavelength in meters for each frequency step.
  ka = 2 * pi * r / lambda ;        % a frequently used constant {dimensionless}.
  s = sqrt( pi / 2 / ka ) ;         % to convert cartesian Bessel and Hankel functions to
                                    %   spherical Bessel and Hankel functions, increase the
                                    %   ORDER of the function by 1/2, and multiply by 's'.
  n = 1 : iterations ;              % "n" is the ORDER of the Bessel and Hankel functions.

  [B1(n),ierr(1,n)] = besselj( n + 1/2, ka ) ;
  [B2(n),ierr(2,n)] = besselh( n + 1/2, 2, ka ) ;
  [B3(n),ierr(3,n)] = besselj( n + 1/2 - 1, ka ) ;
  [B4(n),ierr(4,n)] = besselh( n + 1/2 - 1, 2, ka ) ;
  if any(any(ierr))                 % if any element in 'ierr' is non-zero...
    disp('Warning: There was an accuracy error in evaluating a Bessel or Hankel function.')
  end

  a(n) = ( s*B1 ) ./ ( s*B2 ) ;
  b(n) = ( ka * s*B3 - n .* s.*B1 ) ./ ...
         ( ka * s*B4 - n .* s.*B2 ) ;
  RCS(k+1) = (lambda^2 / pi) * ( abs( sum( (-1).^n .* ( n + 1/2 ) .* ( b(n) - a(n) ) ) ) )^2 ;
end


if ( freq_steps == 0 )              % if you specified RCS for a single frequency...
  % print the results in the command window:
  fprintf(1,'Sphere diameter {inches} \tFrequency {GHz} \t   RCS {m^2} \t RCS {dBm^2} \n ' ) ;
  fprintf(1,'\t  %2.1f \t\t         %4.3f \t       %6.5f \t      %4.2f \n\n', ...
          Dia, Freq1, RCS, 10*log10(RCS) ) ;
else

  q = input('\nRCS in dBm^2 {D} or in \m^2 {M} ?  [D]/M: ','s');
  if ~isempty(q) & ( q == 'm' | q == 'M' )
    h1 = plot( Frequency, RCS ) ;
    set(gca, 'YScale', 'linear') ;
%    set(gca, 'YTick', [min(RCS):(max(RCS)-min(RCS))/10:max(RCS)] ) ;
    title('RCS of perfect sphere versus Frequency','FontSize',15),...
      xlabel('Frequency  \{GHz\}','FontSize',10),...
      ylabel('RCS  \{m^2\}','FontSize',10) ;
  else
    h1 = plot( Frequency, 10.*log10(RCS) ) ;
    set(gca, 'YScale', 'linear') ;
%    set(gca, 'YTick', [min(RCS):(max(RCS)-min(RCS))/10:max(RCS)] ) ;
    title('RCS of perfect sphere versus Frequency','FontSize',15),...
      xlabel('Frequency  \{GHz\}','FontSize',10),...
      ylabel('RCS  \{dBm^2\}','FontSize',10) ;
  end


%  Using a frequency range of '.03, 6.3' for a 6" sphere with the following code will also
%    plot the RCS curve for spheres typically depicted by Skolnik and other references.
%  figure ;
%  h2 = plot( 2*pi*r*(Frequency*1e9)/c, RCS/pi/r^2 ) ;
%  set(gca, 'XScale', 'log', 'XLim', [0.1 20], 'YScale', 'log') ;
%  title('RCS of perfect sphere versus Frequency','FontSize',15),...
%    xlabel('Circumference / \lambda','FontSize',10),...
%    ylabel('RCS / (\pir^2)','FontSize',10) ;


  q2 = input('\nPrint this figure to the system printer {P} or clipboard {C}?   P/C/N [N]: ','s');
  if ~isempty(q2)
    if ( q2 == 'c' | q2 == 'C' )
      print -dbitmap ;
    elseif ( q2 == 'p' | q2 == 'P' )
      print -dsetup -f(gcf) ;
    end
  end

end
