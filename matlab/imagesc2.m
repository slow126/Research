% imagesc2.m     v1.0    - Michael Duersch
% 
%    imagesc2() takes the same arguments as imagesc(), but 
%    provides additional functionality by right-clicking on the image.
%

function hh = imagesc2(varargin)

  %%  Initialize user data
  userdata.winType = 'chebwin';
  userdata.winVal  = 85;

  %%  Get the figure, check for uicontextmenu
  f = gcf;
  c = findobj(f, 'Type', 'uicontextmenu', 'Tag', 'imagesc2');

  %%  Create the context menu if nonexistant
  if  isempty(c)
    c = uicontextmenu('UserData', userdata, 'Tag', 'imagesc2');
    
    s = uimenu(c, 'Label', 'Window');
    uimenu(s, 'Label', 'X', 'Checked', 'off', 'Callback', @checkitem_cb);
    uimenu(s, 'Label', 'Y', 'Checked', 'off', 'Callback', @checkitem_cb);
    uimenu(s, 'Label', 'Set', 'Separator', 'on', 'Callback', @setwindow_cb);
    
    s = uimenu(c, 'Label', 'FFT' );
    uimenu(s, 'Label', 'X', 'Checked', 'off', 'Callback', @checkitem_cb);
    uimenu(s, 'Label', 'Y', 'Checked', 'off', 'Callback', @checkitem_cb);

    s = uimenu(c, 'Label', 'FFTShift' );
    uimenu(s, 'Label', 'X', 'Checked', 'off', 'Callback', @checkitem_cb);
    uimenu(s, 'Label', 'Y', 'Checked', 'off', 'Callback', @checkitem_cb);

    s = uimenu(c, 'Label', 'Value' );
    uimenu(s, 'Label', 'abs',   'Checked', 'off', 'Callback', @checkitem_cb);
    uimenu(s, 'Label', 'angle', 'Checked', 'off', 'Callback', @checkitem_cb);
    uimenu(s, 'Label', 'real',  'Checked', 'off', 'Callback', @checkitem_cb);
    uimenu(s, 'Label', 'imag',  'Checked', 'off', 'Callback', @checkitem_cb);

    s = uimenu(c, 'Label', 'dB' );
    uimenu(s, 'Label', 'Power',   'Checked', 'off', 'Callback', @checkitem_cb);
    uimenu(s, 'Label', 'Voltage', 'Checked', 'off', 'Callback', @checkitem_cb);

    s = uimenu(c, 'Label', 'Axis', 'Separator', 'on' );
    uimenu(s, 'Label', 'IJ', 'Checked', 'off', 'Callback', @checkitem_cb);
    uimenu(s, 'Label', 'XY', 'Checked', 'off', 'Callback', @checkitem_cb);

    uimenu(c, 'Label','Duplicate', 'Separator','on', 'Callback',@duplicate_cb);
    uimenu(c, 'Label', 'Export', 'Callback', @export_cb);
    uimenu(c, 'Label', 'Plot X', 'Callback', @plot_cb);
    uimenu(c, 'Label', 'Plot Y', 'Callback', @plot_cb);
    uimenu(c, 'Label', 'Subset', 'Callback', @subset_cb);
    uimenu(c, 'Label', 'Frame',  'Callback', @frame_cb);
    uimenu(c, 'Label', 'RDM', 'Callback', @rdm_cb);
    
    if  isunix()
      uimenu(c, 'Label','Keyboard', 'Separator','on', 'Callback',@keyboard_cb);
    end
  end

  [userdata.orgParms, userdata.vIdx] = parseArgs(c, nargin, varargin{:});
  set(c, 'UserData', userdata);

  if 0
    vIdx = 1;
    userdata.orgData = varargin(vIdx:end);
    
    if isstr(varargin{vIdx})
      parseArgs(varargin{:});
      return;
    end
    
    if isreal(varargin{vIdx})
      h = imagesc(varargin{vIdx:end});
    else
      h = imagesc(abs(varargin{vIdx}), varargin{vIdx+1:end});
    end

    if (nargout > 0)
      varargout{:} = [h];
    end
  end

  h = drawImage(f, c, userdata, 0);
  a = ancestor(h, 'axes');

  if nargout > 0
    hh = h;
  end
    
  clear userdata h
  
  %%  See if a context menu is already present
  if 0
    f = ancestor(a, 'figure');
    c = findobj(f, 'type', 'uicontextmenu');
    if ~isempty(c)
      set(h, 'UIContextMenu', c(1));
      set(c(1), 'UserData', userdata);
      if isreal(varargin{vIdx})
        drawImage(c, a, varargin{vIdx});
      else
        drawImage(c, a, abs(varargin{vIdx}));
      end
      return;
    end
  end

  %%  set the callbacks
  %set(a, 'ButtonDownFcn', @buttonDown_cb);  %%% ***** kill this line?
  %set(h, 'UIContextMenu', c);
  
  %%  ----------------------  nested functions  ------------------------
  function keyboard_cb(t1, t2)
    keyboard
  end
  
  function buttonDown_cb(t1, t2)
    set(f, 'WindowButtonMotionFcn', '');
    set(f, 'WindowButtonDownFcn',   '');
    set(getRect(c), 'Visible', 'off');
  end

  function checkitem_cb(t1, t2)
    %  radio button type 
    if strcmp(get(ancestor(t1,'uimenu','toplevel'),'Label'), 'Value') || ...
       strcmp(get(ancestor(t1,'uimenu','toplevel'),'Label'), 'dB') || ...
       strcmp(get(ancestor(t1,'uimenu','toplevel'),'Label'), 'Axis')
      handles = allchild(ancestor(t1,'uimenu','toplevel'));
      handles = handles(find(handles ~= t1));
      set(handles, 'Checked', 'off')
    end
    
    if strcmp(get(t1,'Checked'), 'on')
      set(t1, 'Checked', 'off')
    else
      set(t1, 'Checked', 'on')
    end
    
    %  check if don't have to redraw image
    if strcmp(get(ancestor(t1,'uimenu','toplevel'),'Label'), 'Axis')
      if strcmp(get(t1, 'Label'), 'IJ')
        axis ij
      else
        axis xy
      end
    else
      drawImage(f, c, get(c, 'UserData'), 1);
    end
  end
  
  function setwindow_cb(t1, t2)
    ud = get(c, 'UserData');
    [ud.winType ud.winVal] = windowDlg(ud.winType, ud.winVal);
    set(c, 'UserData', ud);
    sH = findobj(c, 'Label', 'Window');
    if strcmp(get(findobj(sH, 'Label', 'X'), 'Checked'), 'on') || ...
       strcmp(get(findobj(sH, 'Label', 'Y'), 'Checked'), 'on')
       drawImage(f, c, ud, 1);
    end
  end
  
  function duplicate_cb(t1, t2)
    figure;
    ud = get(c, 'UserData');
    imagesc2(ud.orgParms{:});
  end
  
  function export_cb(H, ENV)
    ud = get(c, 'UserData');
    im       = getCData(a, ud.orgParms{ud.vIdx});
    labels   = {'Image Data:'};
    varnames = {'data'};
    items2ex = {im};
    export2wsdlg(labels, varnames, items2ex)
  end
  
  function plot_cb(t1, t2)
    [x,y] = ginput(1);
    im = getCData(a);
    if strcmp(get(t1, 'Label'), 'Plot X')
      newPlot(c, round(y), im(round(y), :));
    else
      newPlot(c, round(x), im(:, round(x)));
    end
  end

  function subset_cb(t1, t2)
    [x,y] = ginput(2);
    x  = round(sort(x)); 
    y  = round(sort(y));
    ud = get(c, 'UserData');
    im = getCData(a, ud.orgParms{ud.vIdx});
    figure;
    imagesc2(im(y(1):y(2), x(1):x(2)));
  end
  
  function frame_cb(t1, t2)
    set(f, 'WindowButtonMotionFcn', @frameMotion_cb);
    set(f, 'WindowButtonDownFcn',   @buttonDown_cb);
    set(getRect(c), 'Visible', 'on');
    waitfor(f, 'WindowButtonDownFcn')
    pt = get(a, 'CurrentPoint');
    x = pt(1,1);
    y = pt(1,2);
    ud = get(c, 'UserData');
    im = getCData(a, ud.orgParms{ud.vIdx});
    xMin = max([round(x)-63 1]);
    xMax = min([round(x)+64 size(im,2)]);
    figure;
    imagesc2(im(:, xMin:xMax));
  end
  
  function frameMotion_cb(t1, t2)
    pt = get(a, 'CurrentPoint');
    x1 = max([pt(1,1)-63 min(get(a, 'XLim'))]);
    x2 = min([pt(1,1)+64 max(get(a, 'XLim'))]);
    y1 = min(get(a, 'YLim'));
    y2 = max(get(a, 'YLim'));
    oldA = gca;
    axes(a);
    set(getRect(c), 'Position', [x1 y1 max(x2-x1,1) y2-y1]);
    %set(data.myTxt,'String',sprintf('(%f,%f)',pt(1,1),pt(1,2)),'Visible','on');
    axes(oldA);
  end
  
  function rdm_cb(t1, t2)
    if strcmp(get(t1,'Checked'), 'off')
      sH = findobj(c, 'Label', 'Window');
      set(findobj(sH, 'Label', 'X'), 'Checked', 'on');
      sH = findobj(c, 'Label', 'FFT');
      set(findobj(sH, 'Label', 'X'), 'Checked', 'on');
      sH = findobj(c, 'Label', 'dB');
      set(findobj(sH, 'Label', 'Voltage'), 'Checked', 'on');
      set(t1, 'Checked', 'on');
    else
      sH = findobj(c, 'Label', 'Window');
      set(findobj(sH, 'Label', 'X'), 'Checked', 'off');
      sH = findobj(c, 'Label', 'FFT');
      set(findobj(sH, 'Label', 'X'), 'Checked', 'off');
      sH = findobj(c, 'Label', 'dB');
      set(findobj(sH, 'Label', 'Voltage'), 'Checked', 'off');
      set(t1, 'Checked', 'off');
    end
    sH = findobj(c, 'Label', 'Axis');
    set(findobj(sH, 'Label', 'IJ'), 'Checked', 'off');
    set(findobj(sH, 'Label', 'XY'), 'Checked', 'on');
    ud = get(c, 'UserData');
    drawImage(f, c, ud, 1);
  end
  
end


%%%   ==========================   Helper  Functions   ========================

%%  Get the image CData from the child image inside axis "h"
%     Note: CData is always real, so sometimes we grab the complex image
function im = getCData(h, varargin)
  a = findobj(h, 'Type', 'Image');
  im = get(a, 'CData');
  if  isempty(varargin)
    return;
  end
  %  now check to see if any of the Value checks are on
  h = ancestor(h,'Figure');
  s = findobj(h, 'Label', 'Value');
  c = get(s, 'Children');
  checked = 0;
  for  i = c'
    if  strcmp(get(i, 'Checked'), 'on')
      checked = 1;
    end
  end
  if  ~checked  &&  isreal(im)  &&  ~isreal(varargin{1})
    im = varargin{1};
    disp('Note: passing inititial complex data instead of real processed')
  end
end


%%  Get a drawable rectangle
function r = getRect(c)
  ud = get(c, 'Userdata');
  if ~isfield(ud, 'hRect')
    ud.hRect = rectangle;
    set(c, 'Userdata', ud);
  end
  r = ud.hRect;
end


%%  Open a plot in a new figure
function newPlot(c, i, vec)
  s = findobj(c, 'Label', 'dB');
  if     strcmp(get(findobj(s, 'Label', 'Power'), 'Checked'), 'on')
    rms = 10*log10(sqrt(mean(abs(10.^(vec./10)).^2)));
  elseif strcmp(get(findobj(s, 'Label', 'Voltage'), 'Checked'), 'on')
    rms = 20*log10(sqrt(mean(abs(10.^(vec./10)).^2)));
  else
    rms = sqrt(mean(abs(vec).^2));
  end

  if ~isreal(vec)
    b = questdlg('Data is complex. Only show magnitude?','Complex data', ...
                 'No', 'Yes', 'Yes');
    if  strcmp(b,'Yes')
      vec = abs(vec);
    end
  end
  
  figure;
  plot(vec, '.-');
  title(sprintf( 'i: %i     \\mu: %g   \\sigma^2: %g   rms: %g', ...
                 i, mean(vec), var(vec), rms ))
end


%%  Draw the image "im" in axes "a"
function h = drawImage(f, c, ud, keep)

  %  get the image
  im = ud.orgParms{ud.vIdx};
  
  %  window
  s = findobj(c, 'Label', 'Window');
  if strcmp(get(findobj(s, 'Label', 'X'), 'Checked'), 'on')
    im = myWindow(im, 2, ud);
  end
  if strcmp(get(findobj(s, 'Label', 'Y'), 'Checked'), 'on')
    im = myWindow(im, 1, ud);
  end

  %  fft
  s = findobj(c, 'Label', 'FFT');
  if strcmp(get(findobj(s, 'Label', 'X'), 'Checked'), 'on')
     im = fft(im, [], 2);
  end
  if strcmp(get(findobj(s, 'Label', 'Y'), 'Checked'), 'on')
     im = fft(im, [], 1);
  end

  %  fft shift
  s = findobj(c, 'Label', 'FFTShift');
  if strcmp(get(findobj(s, 'Label', 'X'), 'Checked'), 'on')
     im = fftshift(im, 2);
  end
  if strcmp(get(findobj(s, 'Label', 'Y'), 'Checked'), 'on')
     im = fftshift(im, 1);
  end

  %  value
  s = findobj(c, 'Label', 'Value');
  if     strcmp(get(findobj(s, 'Label', 'abs'),   'Checked'), 'on')
    im = abs(im);
  elseif strcmp(get(findobj(s, 'Label', 'angle'), 'Checked'), 'on')
    im = angle(im);
  elseif strcmp(get(findobj(s, 'Label', 'real'),  'Checked'), 'on')
    im = real(im);
  elseif strcmp(get(findobj(s, 'Label', 'imag'),  'Checked'), 'on')
    im = imag(im);
  end
  
  %  scale
  s = findobj(c, 'Label', 'dB');
  if strcmp(get(findobj(s, 'Label', 'Power'), 'Checked'), 'on')
    warning off; im = 10*log10(im); warning on;
  end
  if strcmp(get(findobj(s, 'Label', 'Voltage'), 'Checked'), 'on')
    warning off; im = 20*log10(im); warning on;
  end

  %  imagesc can't handle a complex image
  if ~isreal(im)
    im = abs(im);
  end

  %  get the proper clim
  %if isfield(ud, 'clim')
  %  clim = ud.clim;
  %else
  %  clim = [min(im(:)) max(im(:))];
  %end
  
  %  get the axis if it doesn't exist
  %if ~isfield(ud, 'axes')
  %  ud.axes = gca;
  %  set(
  %end
  
  %%  ***** see if this is what I really wint (maybe just keep)
  %  check axes  
  a = get(f, 'CurrentAxes');
  if keep && ~isempty(a)
    % if ~isempty(findobj(a, 'Type', 'image'))
      hold on                               %  keep all the axes properties
      set(a, 'CLimMode', 'auto');
    % end
  else
    a = gca;
    %if isappdata(a, 'matlab_graphics_resetplotview')
    %  rmappdata(a,'matlab_graphics_resetplotview');
    %end
  end

  %  draw the image
  ud.orgParms{ud.vIdx} = im;
  %h = imagesc(ud.orgParms{:}, clim);    %  side effect: doesn't replace image
  h = imagesc(ud.orgParms{:});          %  side effect: doesn't replace image
  hold off

  % fix matlab bug with axes zoom limits not resetting even with hold off
  if ~keep
    resetplotview(a, 'SaveCurrentView');  
  end
  
  %  kill (replace) the old image
  o = findobj(a, 'Type', 'Image', 'Tag', '');
  delete(o(2:end));
  
  %  send the image to the back
  child = get(a, 'Children');
  if length(child) > 1
    set(a, 'Children', [child(2:end) ; child(1)]);
  end

  %  axis
  s = findobj(c, 'Label', 'Axis');
  if strcmp(get(findobj(s, 'Label', 'XY'), 'Checked'), 'on')
    axis xy
  end

  %  reset context menu
  set (h, 'UIContextMenu', c);
end


%%  Window the data
function im = myWindow(im, dim, userdata)

  n   = size(im,dim);
  opt = userdata.winVal;
  switch userdata.winType
   case {'chebwin'}
    W = window( userdata.winType, n, opt );              % opt in decibels(100)
   case {'gausswin'}
    W = window( userdata.winType, n, opt );              % opt is alpha (2.5)
   case {'kaiser'}
    W = window( userdata.winType, n, opt );              % opt is beta (0.5)
   case {'tukeywin'}
    if (opt <= 0  | opt >= 1)
      opt = 0.5;
    end
    W = window( userdata.winType, n, opt );              % opt is R  (0<R<1)
   case {'blackman', 'flattopwin', 'hamming', 'hann'}
    if sum(strcmp(opt, {'symmetric','periodic'}))==0
      opt = 'symmetric';
    end
    W = window( userdata.winType, n, opt );              % opt is R  (0<R<1)
   otherwise
    W = window( userdata.winType, n );
  end
  
  if (dim == 1)
    im = im .* repmat(W', [size(im,2) 1]).';
  else
    im = im .* repmat(W', [size(im,1) 1]);
  end
  
end


%%  Show a dialog to select window types
function [type val] = windowDlg(type, val)
  WIN_TYPES = {'chebwin' , 'gausswin' , 'kaiser' , 'tukeywin', ...
              'blackman' , 'flattopwin' , 'hamming' , 'hann' , ...
              'User Defined'};
  SMP_TYPES = {'symmetric', 'periodic'};

  h = dialog('Name', 'Window Parameters', 'Visible', 'off');
  pos = get(h, 'Position');
  pos(3:4) = [250, 145];
  set(h, 'Position', pos);
  
  tT = uicontrol(h, 'Style', 'text', 'String', 'Type:',      ...
                 'HorizontalAlignment', 'left', 'Position', [10 115 100 20]);
  tF = uicontrol(h, 'Style', 'text', 'String', 'Function:',  ...
                 'HorizontalAlignment', 'left', 'Position', [10  90 100 20]);
  tV = uicontrol(h, 'Style', 'text', 'String', 'Parameter:', ...
                 'HorizontalAlignment', 'left', 'Position', [10  65 100 20]);
  tS = uicontrol(h, 'Style', 'text', 'String', 'Sampling:',  ...
                 'HorizontalAlignment', 'left', 'Position', [10  40 100 20]);
  cT = uicontrol(h, 'Style', 'popupmenu', 'String', WIN_TYPES, ...
                 'Callback', @type_cb, 'Position', [120 115 120 20]);
  cF = uicontrol(h, 'Style', 'edit', 'Max', 1, 'HorizontalAlignment','left',...
                 'Position', [120  90 120 20]);
  cV = uicontrol(h, 'Style', 'edit', 'Max', 1,'HorizontalAlignment','right',...
                 'Position', [120  65 120 20]);
  cS = uicontrol(h, 'Style', 'popupmenu', 'String', SMP_TYPES, ...
                 'Position', [120  40 120 20]);
  cD = uicontrol(h, 'Style', 'pushbutton', 'String', 'Set', ...
                 'Callback', @set_cb, 'Position', [90 10 70 20]);

  %  Set the default window type
  idx = find(strcmp(WIN_TYPES, type) == 1);
  if isempty(idx)
    idx = find(strcmp(WIN_TYPES, 'User Defined') == 1);
    set(cF, 'String', type);
  end
  set(cT, 'Value', idx);
  %  Set the default parameter value
  if isstr(val)
    idx = find(strcmp(SMP_TYPES, val) == 1);
    if isempty(idx)
      idx = 1;
    end
    set(cS, 'Value', idx);
  else
    set(cV, 'String', num2str(val));
  end
  
  %  call the callback to initialize
  type_cb(cT);
  
  %  show and block
  set(h, 'Visible', 'on');
  uiwait(h);
  
  function type_cb(t1, t2)
    set(cF, 'Enable', 'off');
    set(tF, 'Enable', 'off');
    set(cV, 'Enable', 'on');
    set(tV, 'Enable', 'on');
    set(cS, 'Enable', 'off');
    set(tS, 'Enable', 'off');
    switch(WIN_TYPES{get(t1, 'Value')})
     case {'chebwin'}
      set(tV, 'String', 'Sidelobe Atten:');   % decibels (100)
     case {'gausswin'}
      set(tV, 'String', 'Alpha:');   % 2.5
     case {'kaiser'}
      set(tV, 'String', 'Beta:');    % 0.5
     case {'tukeywin'}
      set(tV, 'String', 'R:');       % 0 < R < 1
     case {'blackman', 'flattopwin', 'hamming', 'hann'}
      set(cV, 'Enable', 'off');
      set(tV, 'String', 'Parameter', 'Enable', 'off');
      set(cS, 'Enable', 'on');
      set(tS, 'Enable', 'on');
     otherwise
      set(cF, 'Enable', 'on');
      set(tF, 'Enable', 'on');
    end
  end
  
  function set_cb(t1, t2)
    type = WIN_TYPES{get(cT, 'Value')};
    switch(type)
     case {'chebwin'}
      val = str2num(get(cV, 'String'));   % decibels (100)
     case {'gausswin'}
      val = str2num(get(cV, 'String'));   % 2.5
     case {'kaiser'}
      val = str2num(get(cV, 'String'));   % 0.5
     case {'tukeywin'}
      val = str2num(get(cV, 'String'));   % 0 < R < 1
     case {'blackman', 'flattopwin', 'hamming', 'hann'}
      val = SMP_TYPES{get(cS, 'Value')};
     otherwise
      val  = get(cV, 'String');
      type = get(cF, 'String');
    end
    close
  end
  
end


%%  Parse input arguments
function [args, idx] = parseArgs(c, nargin, varargin)
  if 0
    %%  *** this code is a hack until better parsing is done ***
    f  = ancestor(gca, 'Figure');
    c  = findobj(f, 'Type', 'uicontextmenu');
    %% ***** why is there more than one context menu? *****  
    h1 = findobj(c(end), 'Label', varargin{1});
    h2 = findobj(h1(end), 'Label', varargin{2});
    if ~isempty(h2)
      for i = get(h1(end), 'Children')
        set(i, 'Checked', 'off');
      end
      set(h2, 'Checked', 'on');
      drawImage(c(end), gca, getCData(f));
    end
  end

  if     nargin == 0
    h    = image;
    args = {get(h, 'CData')};
    idx  = 1;
  elseif nargin == 1
    args = varargin;
    idx  = 1;
  elseif nargin > 1
    i    = 1;
    idx  = [];
    args = {};
    while i <= nargin
      if isstr(varargin{i})
        % argument is a string
        if isempty(idx)
          idx = i-1;
        end
        
        h1 = findobj(c, 'Label', varargin{i});
        if isempty(h1)
          % image's string
          args = {args{:} varargin{i:i+1}};
        else
          % our string
          h2 = findobj(h1, 'Label', varargin{i+1});
          if ~isempty(h2)
            for h3 = get(h1, 'Children')
              set(h3, 'Checked', 'off');
            end
            set(h2, 'Checked', 'on');
          else
            error(sprintf('Bad parameter %s to %s\n', ...
                          varargin{i+1}, varargin{i}))
          end
        end
        i = i + 2;
      else
        args = {args{:} varargin{i}};
        i = i + 1;
      end
    end
    
    if isempty(idx)
      % need to choose which arg is the image
      if (nargin > 3) || (nargin == 2)
        % clim present
        idx = nargin-1;
      else
        idx = nargin;
      end
    end
  end
    
end
