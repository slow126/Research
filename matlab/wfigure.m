function varargout=wfigure(varargin)
%
% wfigure(num) sets figure num to the active figure (creates new figure
%  if necessary), does not raise figure to front unless newly created
%  if figure num does not already exist, created window is made 1.75
%  times wider than a standard window.  Does not change size or status
%  (raised, focus, etc.) of existing window.
%
% wfigure (no arg) creates a new figure (same as matlab figure command)
% created window is 1.75 time wider than standard window
%
% h=wfigure(num) sets figure num to active, returns handle to figure
% creates figure num if not already existing.
% created window is 1.75 times wider than standard window.

% h=wfigure(num,wide) sets figure num to active, returns handle to figure
% creates figure num if not already existing.
% created window is wide times wider than standard window.
% h=wfigure(num,wide,high) sets figure num to active, returns handle to figure
% creates figure num if not already existing.
% created window is wide times wider and high times taller than a
% standard window created by matlab
%
%
% WFIGURE is a shortcut replacement for matlab's figure command allows rapid 
% switching between figures w/o speed slow down caused by raising window 
% to the front everytime it is active. figures can be plotted to even
% when iconified. handy when rapidly switching between figures.
%
%  - if there no input figure number num, creates a new figure which is
%     raised to front and made active. new window is 1.75 times wider
%     than standard.
%  - if num is specified and figure does not exist, creates figure which
%     is raised to front and made active. new window is 1.75 times wider
%     than standard. existing window is unmodified.
%  - if figure num already exits, this function makes it active (current)
%     but does not raise it to the front and does not change it's size
%  - if wide is specified, a new window is wide times wider than standard
%
% optionally returns figure handle of newly active figure

% written DGL at BYU 3 Dec 2018 based on myfigure.m
% 
n=0;
if nargin>0 % if num argument specified
  num=cell2mat(varargin(1));
  if ~isnumeric(num)
    error('Argument to myfigure must be numeric');
  end
  if ~ishandle(num) % if figure does not exist
    figure(num);    % create new figure
    n=num;
  else % set figure num as active      
    set(0,'CurrentFigure',num);
  end
else % create new figure if num not specified
  h=figure();
  n=get(h,'Number');
end

if n ~= 0 % resize newly created figure
  pos=get(n,'Position');
  wide=1.75;
  high=1.0;
  if nargin > 1
    wide=cell2mat(varargin(2));
    if nargin > 2
      high=cell2mat(varargin(3));
    end
  end
  w=round(wide*pos(3));
  if w > 0, pos(3)=w; end;
  h=round(high*pos(4));
  if h > 0, pos(4)=h; end;
  set(n,'Position',pos);
end

if nargout==1 % return handle to figure if output argument specified
  varargout={gcf()}; % return handle to currently active figure
end
