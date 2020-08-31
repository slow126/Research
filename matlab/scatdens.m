function [varargout] = scatdens( x , y , bins , threshold , map)
% scatdens  Scatter/Density Plot 
%
%  [NDENS, BX, BY] = scatdens(X, Y, THRESHOLD, MAP)
%
%      scatdens(X,Y) displays a scatter plot of the data in equal
%      length vectors X and Y, superimposed on a contour/density
%      plot where the points are densely packed, to avoid large
%      'black' regions where there are so many points that individual 
%      points sccannot be distinguished. 
%
%      scatdens(X,Y,BINS) is similar but with the density plot created
%      using BINS regions along the x and y axes.  The default is 
%      BINS = 100.
%
%      scatdens(X,Y,BINS,THRESHOLD) sets the threshold for the number
%      of points per bin, below which points in a given bin
%      are plotted individually as dots, and above which the 
%      plot reverts from markers for individual points to the 
%      contour/density plot.
%
%      scatdens(X,Y,BINS,THRESHOLD,MAP) sets the colormap to gray
%      (MAP=0) or color (MAP=1).  If this argument is not passed, the
%      current colormap is used.
%
%      Optional output arguments:  NDENS is a 2D matrix of the number
%      of points in each bin, and BX and BY are the centers of the
%      bins along the x and y axes.
%  
%      EXAMPLE:     
%        scatdens(randn(100000,1),randn(100000,1));
%
%      EXAMPLE:     
%        x = randn([100000,1]); 
%        y = randn([100000,1]); 
%        bins = 100;
%        threshold = 30;
%        map = 1;
%        [ Ndens, N , BX , BY ] = scatdens(x, y, bins, threshold, map);
%
%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                %
%%    Mark Tuttle (Research Assistant)            %
%%    Prof. Karl F. Warnick                       %
%%    ECE Department                              %
%%    Brigham Young University                    %
%%    459 Clyde Building                          %
%%    Provo, UT  84602                            %
%%    Copyright 2004                              %
%%    Date:  5/24/04                              %
%%                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%         ARGUMENTS FOR FUNCTION CALL         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (nargin<2),
  error('This function requires at least two arguments.');
end;

if ischar(x) | ischar(y) ,
  error('Input arguments must be numeric.');
end;

if ( (size(x)~=length(y)) | isempty(y) ),
  error('The vectors ''X'' and ''Y'' must be vectors of the same length.');
end;

TOTALPNTS = length(x);

% check for arguments 3-5
if (nargin<3),
  map = 1;
  bins = 100;
end;

if (nargin<4)
  threshold = 15*100^2/bins^2;
end

if (nargin<5)
  map=1;
else
  if map==1,
    colormap('jet')
  end
end

% check for empty arguments
if isempty(bins),
  bins = 100;
end

if isempty(threshold),
  threshold = 15*100^2/bins^2;
end

% check for usable arguments
if (threshold<0),
  error('The variable ''THRESHOLD'' must be positive.');
end;

if ( (size(bins)>1) | (bins<3) ),
  error('The variable ''BINS'' must be a positive integer greater than 3.');
end;

if (map<0),
  error('The variable ''MAP'' must be positive.');
end;

LOG_PLT=1;  % uses log of counts when set to 1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                    SETUP                    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


minX = (min(x) - eps); 
maxX = (max(x) + eps);
minY = (min(y) - eps);
maxY = (max(y) + eps);

% Grid with Endpoints min-max: length equal to # of Bins+1
BX = linspace( minX , maxX , (bins+1) );
BY = linspace( minY , maxY , (bins+1) );

% Evaluating the Grid Spacing: Necessary if x or y 
% have minimum values < 0
dX =  diff( [BX(2) BX(3) ] ); 
dY =  diff( [ BY(2) BY(3) ] ); 

% Grid Centers: Length equal to # of Bins
BXc = linspace( (BX(1)+(dX/2)) , (BX(end)-(dX/2)) , round(((BX(end)-(dX/2))-(BX(1)+(dX/2)))/dX)+1 );  
BYc = linspace( (BY(1)+(dY/2)) , (BY(end)-(dY/2)) , round(((BY(end)-(dY/2))-(BY(1)+(dY/2)))/dY)+1 );  

% Assigns a value to the index of the appropriate bin.  
Y_cell_indx = fix((y-minY)/dY - 0.5) + 1; 
X_cell_indx = fix((x-minX)/dX - 0.5) + 1; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%          2-D HISTOGRAM CALCULATION          %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Ndens = zeros( bins , bins ); 
for cnt = 1:TOTALPNTS,
  m = Y_cell_indx(cnt);
  n = X_cell_indx(cnt);
  Ndens(m,n) = Ndens(m,n) + 1;
end;


% This determines which points will be plotted individually
idxs = [];
mask = Ndens<threshold;
for cnt = 1:TOTALPNTS,
  if mask(Y_cell_indx(cnt),X_cell_indx(cnt)) 
    idxs = [idxs,cnt]; 
  end
end

% This determines which bins will be plotted as a density.
DENS = Ndens.*(1-mask);

maxdens = max(max(Ndens));

% skip using margins for max height
[m n]=size(Ndens);
maxdens = max(max(Ndens(2:m,2:n)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                   PLOTS                     %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%BXc2 = BXc;
%BYc2 = BYc;

BXc2 = BXc+dX/2; % This is used because 'imagesc' assumes centers are
                 % the edges of the bins. 
BYc2 = BYc+dY/2;

clf

PLOT_DENS = sum(sum(DENS))~=0;

if PLOT_DENS,
  % density plot
  clow = (63*threshold-maxdens)/(63-1);
  chigh = maxdens;

  if LOG_PLT
    clow=log(clow);
    chigh=log(chigh);
    imagesc( BXc2 , BYc2 , log(DENS), [clow chigh]);
  else
    imagesc( BXc2 , BYc2 , DENS, [clow chigh]);
  end

  if map==0,
    colormap(1-gray);
  else
    map = colormap;
    map(1,:) = [1 1 1];
    colormap(map);
  end

  % contour plot
  hold on
  ncnts=15;
  contour(BXc2, BYc2, DENS,[maxdens/ncnts:maxdens/ncnts:maxdens],'k');
  %[ dc , dh ] = contour(BXc2, BYc2, DENS,'k');
  %contour(BXc2,BYc2,DENS,[threshold threshold],'k');
  %clabel(dc,dh,'fontsize',12,'rotation',0,'FontWeight','demi');
  hold off
end

% set the font size
set(gca,'ydir','normal','FontSize',14 ); 

% Enable the lines below if colorbar desired
%Hbar3 = colorbar;                          
%set(Hbar3,'FontSize',14,'Position',[ 0.90  0.10  0.025  0.825 ] );    
%set(gca,'Position',[ 0.08  0.100  0.80  0.8250 ]);


% scatter plot
hold on
Hdotplot = plot(x(idxs), y(idxs), 'k.'); 
set(Hdotplot,'MarkerSize',3);
hold off

hold off;

%grid on;


% display parameters used
if 1==0
txt3a = [ 'BINS/AXIS = ' num2str(bins) ];
disp( txt3a );

txt3b = [ 'THRESHOLD = ' num2str(threshold) ' pts/bin' ];
disp( txt3b );

txt3c = [ 'TOTAL POINTS = ' num2str(TOTALPNTS) ];
disp( txt3c );
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%              OUTPUT ARGUMENTS               %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargout>0
  varargout(1) = {Ndens};
end
if nargout>1
  varargout(2) = {BX};
end
if nargout>2
  varargout(3) = {BY};
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                    END                      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
