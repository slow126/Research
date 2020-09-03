function viewsir1(action,filein)
%
% viewsir(input_file_name)
%
% matlab utility for viewing sir images with interactive color table,
% and pointing capability
%

%
% viewsir1(action,file_name_in)
%
% matlab utility for viewing sir images
%
% use 'initialize' to start routine
%

play= 1;
stop=-1;

if nargin<1,
    action='initialize';
end;

if strcmp(action,'initialize'),
    oldFigNumber=watchon;

    if nargin > 1
      filename=filein;
    else
      filename='/mers0/long/sir/data/greeni.sir';
    end;
    
    figNumber=figure( ...
        'Name',filename, ...
        'Color', [.8 .8 .8], ...
        'NumberTitle','off', ...
        'Color', 'white',...
        'Visible','off');
    axes( ...
        'Units','normalized', ...
        'Color', [.8 .8 .8], ...
        'Position',[0.02 0.05 0.75 0.85], ...
	'Visible','off');
    axis([0 1 0 1]);

    %===================================
    % Information for all buttons
    labelColor=[0.8 0.8 0.8];
    top=0.95;
    bottom=0.05;
   
    yInitLabelPos=0.90;
    left=0.825;
    labelWid=0.15;
    labelHt=0.05;
    btnWid=0.15;
    btnHt=0.05;
    % Spacing between the label and the button for the same command
    btnOffset=0.003;
    % Spacing between the button and the next command's label
    spacing=0.05;
    
    %====================================
    % The CONSOLE frame
    frmBorder=0.02;
    yPos=0.05-frmBorder;
    frmPos=[left-frmBorder yPos btnWid+2*frmBorder 0.9+2*frmBorder];
    h=uicontrol( ...
        'Style','frame', ...
        'Units','normalized', ...
        'Position',frmPos, ...
        'BackgroundColor',[0.50 0.50 0.50]);

    %=============================================
 % The view popup button
    btnNumber=1;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
    labelStr='Colormap';
    popupStr=str2mat('default', 'hsv', 'hot', 'pink', 'cool', 'bone', 'prism', 'flag', 'gray', 'rand','Poster');
    
    % Generic button information
    ClbkStr = 'viewsir1(''color'')';
    labelPos=[left yLabelPos-labelHt labelWid labelHt];
    VpopupHndl=uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',labelPos, ...
        'BackgroundColor',labelColor, ...
        'HorizontalAlignment','left', ...
        'String',labelStr);
    btnPos=[left yLabelPos-labelHt-btnHt-btnOffset btnWid btnHt];
    VpopupHndl=uicontrol( ...
        'Style','popup', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',popupStr, ...
        'Call', ClbkStr);   
    
   %====================================
    % The reshow button
    btnNumber=2;  
    labelStr='Rescale';
    callbackStr='viewsir1(''scale'')';
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
    btnPos=[left yLabelPos-labelHt-btnHt-btnOffset btnWid btnHt];
    infoHndl=uicontrol( ...
        'Style','push', ...
        'Units','normalized', ...
        'position',btnPos, ...
        'string',labelStr, ...
	'call',callbackStr);
    
   %====================================
    % The point button
    btnNumber=3;  
    labelStr='Point';
    callbackStr='viewsir1(''sir_locate1'')';
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
    btnPos=[left yLabelPos-labelHt-btnHt-btnOffset btnWid btnHt];
    infoHndl=uicontrol( ...
        'Style','push', ...
        'Units','normalized', ...
        'position',btnPos, ...
        'string',labelStr, ...
	'call',callbackStr);
    
   %====================================
    % The zoom button
    btnNumber=3.75;  
    labelStr='Zoom';
    callbackStr='zoom';
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
    btnPos=[left yLabelPos-labelHt-btnHt-btnOffset btnWid btnHt];
    infoHndl=uicontrol( ...
        'Style','push', ...
        'Units','normalized', ...
        'position',btnPos, ...
        'string',labelStr, ...
        'call',callbackStr);

    %====================================
    % The unzoom button
    btnNumber=4.25;  
    labelStr='UnZoom';
    callbackStr='zoom out';
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
    btnPos=[left yLabelPos-labelHt-btnHt-btnOffset btnWid btnHt];
    infoHndl=uicontrol( ...
        'Style','push', ...
        'Units','normalized', ...
        'position',btnPos, ...
        'string',labelStr, ...
        'call',callbackStr);

    %====================================
    % The INFO button
    labelStr='Info';
    callbackStr='viewsir1(''info'')';
    infoHndl=uicontrol( ...
        'Style','push', ...
        'Units','normalized', ...
        'position',[left bottom+2*btnHt+spacing btnWid 2*btnHt], ...
        'string',labelStr, ...
        'call',callbackStr);

    %====================================
    % The CLOSE button
    labelStr='Close';
    callbackStr='close(gcf)';
    closeHndl=uicontrol( ...
        'Style','push', ...
        'Units','normalized', ...
        'position',[left bottom btnWid 2*btnHt], ...
        'string',labelStr, ...
        'call',callbackStr);
    
    % Uncover the figure
    hndlList=[infoHndl closeHndl VpopupHndl];
    passPrmt.handle=hndlList;
    passPrmt.clmap=[];
    set(figNumber,'Visible','on', ...
        'UserData',passPrmt);
    watchoff(oldFigNumber);
    figure(figNumber);
    shwimg1(filename);
    colormap('gray');
  
  elseif strcmp(action,'color'),
    colorlabels ={'default', 'hsv','hot','pink','cool','bone',...
         'prism','flag','gray','rand','Poster'};
    figNumber=gcf;
    passPrmt=get(figNumber, 'UserData');
    hndlList=passPrmt.handle;
    VpopupHndl=hndlList(3);
    colr=get(VpopupHndl, 'Value');
    if colr==10
     colormap(rand(64,3)); 
    elseif colr==11
     my_cmap;
    else
     colormap(char(colorlabels(colr)));
    end;

elseif strcmp(action,'scale');
    reshow(1);
  
elseif strcmp(action,'sir_locate1');
    sir_locate1(1);

elseif strcmp(action,'info');
    helpwin(mfilename);

end;    % if strcmp(action, ...

%%%%  sub functions
    
function sir_locate1(dummy)
%
% interactive position location
%
    global sir_head_viewsir;
    global sir_im_viewsir;
    
    nsx=sir_head_viewsir(1)+1;
    nsy=sir_head_viewsir(2)+1;
    disp('Left button to locate points, right button to quit');
    button=1;
    while button == 1
      [x y button]=ginput(1);
      [lon lat]=pix2latlon(x,y,sir_head_viewsir);
      y1=floor(x);
      x1=floor(nsy-y);
      if (x1 > 0) & (x1 < nsy) & (y1 > 0) & (y1 < nsx)
	val=sir_im_viewsir(x1,y1);
      else
	val=0;
      end;
      disp(['Lon ',num2str(lon),'   Lat ',num2str(lat),'  Value ',num2str(val),'  x ',num2str(y1),'  y ',num2str(x1)]);
    end;
    
function shwimg1(filename)
%
% load sir file and display
%
    global sir_head_viewsir;
    global sir_im_viewsir;
    
    disp(['viewsir: Reading file: "',filename,'"']);
    [sir_im_viewsir head1]=loadsir(filename);
    showsir1(sir_im_viewsir,head1);
    axis off;
    sir_head_viewsir=head1;
    
function reshow(dummy)
    global sir_im_viewsir;
    
    small=min(min(sir_im_viewsir));
    large=max(max(sir_im_viewsir));
    disp(['Data min=',num2str(small),'  max=',num2str(large)])
    min_max=input('Enter new min, max: "[min max]" ');
    if isempty(min_max),
      min_max=[small large];
    end
    ss=size(min_max);
    if ss(2)<2,
      min_max=[small large];
    end
    large=min_max(2);
    small=min_max(1);
    scale=large-small;
    if scale == 0
      scale = 1;
    end
    scale=64/scale;
    hold on;
    image((sir_im_viewsir-small)*scale);
    hold off;
    sircolorbar('horiz',small,large);
    
function showsir1(array_in,head,min1,max1)
%
% function showsir1(array_in,head,min1,max1)
%
% function to display sir image 
%

if (exist('head') == 1)
  small=head(50);
  large=head(51);
  if (large == small)
    small=min(min(array_in));
    large=max(max(array_in));
  end;
  if (exist('min1') == 1)
    small=min1;
    if (exist('max1') == 1)
      large=max1;
    end;
  end;
  printsirhead(head);
  title1(80)=0;
  for i=1:40
    j=(i-1)*2+1;
    title1(j)=(mod(head(i+128),256));
    title1(j+1)=floor(head(i+128)/256);
  end;
  title1=deblank(setstr(title1));
else
  small=min(min(array_in));
  large=max(max(array_in));
  title1=' ';
end;

scale=large-small;
if scale == 0
  scale = 1;
end
scale=64/scale;
min_max=[small large]

image((array_in-small)*scale);
axis image;
title(title1);
sircolorbar('horiz',small,large);


function handle=sircolorbar(loc,cmin,cmax)
% handle = sircolorbar(loc,min,max)
%   Display color bar
%
%   loc='vert' appends a vertical color scale to the current
%   axis. loc='horiz' appends a horizontal color scale.
%
%   loc=H places the colorbar in the axes H. The colorbar will
%   be horizontal if the axes H width > height (in pixels).
%
%   COLORBAR without arguments either adds a new vertical color scale
%   or updates an existing colorbar.
%
%   optional cmin,cmax give the labels for the minimum and maximum on scale
%
%   handle = handle to the colorbar axis.

%   Clay M. Thompson 10-9-92
%   Copyright (c) 1984-96 by The MathWorks, Inc.
%   $Revision: 5.18 $  $Date: 1996/10/22 15:10:46 $

%   If called with COLORBAR(H) or for an existing colorbar, don't change
%   the NextPlot property.
changeNextPlot = 1;

if nargin<1, loc = 'vert'; end
ax = [];
t=[1   64];
if nargin >= 1,
    if ishandle(loc)
        ax = loc;
        if ~strcmp(get(ax,'type'),'axes'),
            error('Requires axes handle.');
        end
        units = get(ax,'units'); set(ax,'units','pixels');
        rect = get(ax,'position'); set(ax,'units',units)
        if rect(3) > rect(4), loc = 'horiz'; else loc = 'vert'; end
        changeNextPlot = 0;
    end
    if nargin > 1
      t=[cmin cmax];
    end;
end

h = gca;

%if nargin==0,
    % Search for existing colorbar
    ch = get(gcf,'children'); ax = [];
    for i=1:length(ch),
        d = get(ch(i),'userdata');
        if prod(size(d))==1 & isequal(d,h), 
            ax = ch(i); 
            pos = get(ch(i),'Position');
            if pos(3)<pos(4), loc = 'vert'; else loc = 'horiz'; end
            changeNextPlot = 0;
            break; 
        end
    end
%end

origNextPlot = get(gcf,'NextPlot');
if strcmp(origNextPlot,'replacechildren') | strcmp(origNextPlot,'replace'),
    set(gcf,'NextPlot','add')
end

if loc(1)=='v', % Append vertical scale to right of current plot
    
    if isempty(ax),
        units = get(h,'units'); set(h,'units','normalized')
        pos = get(h,'Position'); 
        [az,el] = view;
        stripe = 0.075; edge = 0.02; 
        if all([az,el]==[0 90]), space = 0.05; else space = .1; end
        set(h,'Position',[pos(1) pos(2) pos(3)*(1-stripe-edge-space) pos(4)])
        rect = [pos(1)+(1-stripe-edge)*pos(3) pos(2) stripe*pos(3) pos(4)];
        
        % Create axes for stripe
        ax = axes('Position', rect);
        set(h,'units',units)
    else
        axes(ax);
    end
    
    % Create color stripe
    n = size(colormap,1);
    image([0 1],t,(1:n)','Tag','TMW_COLORBAR'); set(ax,'Ydir','normal')
    set(ax,'YAxisLocation','right')
    set(ax,'xtick',[])
    
else, % Append horizontal scale to top of current plot
    
    if isempty(ax),
        units = get(h,'units'); set(h,'units','normalized')
        pos = get(h,'Position');
%        stripe = 0.075; space = 0.1;   % original values
	stripe = 0.05; space = 0.05;
        set(h,'Position',...
            [pos(1) pos(2)+(stripe+space)*pos(4) pos(3) (1-stripe-space)*pos(4)])
        rect = [pos(1) pos(2) pos(3) stripe*pos(4)];
        
        % Create axes for stripe
        ax = axes('Position', rect);
        set(h,'units',units)
    else
        axes(ax);
    end
    
    % Create color stripe
    n = size(colormap,1);
    image(t,[0 1],(1:n),'Tag','TMW_COLORBAR'); set(ax,'Ydir','normal')
    set(ax,'ytick',[])
    
end
set(ax,'userdata',h)
set(gcf,'CurrentAxes',h)
if changeNextPlot
    set(gcf,'Nextplot','ReplaceChildren')
end

if nargout>0, handle = ax; end





