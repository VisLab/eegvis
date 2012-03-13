%%%%%%%%%%%%%%%%%%%%%%%% Set defaults %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
icadefs                 % read defaults MAXTOPOPLOTCHANS and DEFAULT_ELOC and BACKCOLOR

whitebk = 'off';  % by default, make gridplot background color = EEGLAB screen background color

%plotgrid = 'off';
%plotchans = [];
noplot  = 'off';
handle = [];
chanval = NaN;
rmax = 0.5;             % actual head radius - Don't change this!
INTERPLIMITS = 'head';  % head, electrodes
INTSQUARE = 'on';       % default, interpolate electrodes located though the whole square containing
                        % the plotting disk
%default_intrad = 1;     % indicator for (no) specified intrad
MAPLIMITS = 'absmax';   % absmax, maxmin, [values]
GRID_SCALE = 67;        % plot map on a 67X67 grid
CIRCGRID   = 201;       % number of angles to use in drawing circles
AXHEADFAC = 1.3;        % head to axes scaling factor
CONTOURNUM = 6;         % number of contour levels to plot
STYLE = 'map';         % default 'style': both,straight,fill,contour,blank
HEADCOLOR = [0 0 0];    % default head color (black)
CCOLOR = [0.2 0.2 0.2]; % default contour color
%ELECTRODES = [];        % default 'electrodes': on|off|label - set below
MAXDEFAULTSHOWLOCS = 64;% if more channels than this, don't show electrode locations by default
EMARKER = '.';          % mark electrode locations with small disks
ECOLOR = [0 0 0];       % default electrode color = black
EMARKERSIZE = [];       % default depends on number of electrodes, set in code
EMARKERLINEWIDTH = 1;   % default edge linewidth for emarkers
EMARKERSIZE1CHAN = 20;  % default selected channel location marker size
EMARKERCOLOR1CHAN = 'red'; % selected channel location marker color
EMARKER2CHANS = [];      % mark subset of electrode locations with small disks
EMARKER2 = 'o';          % mark subset of electrode locations with small disks
EMARKER2COLOR = 'r';     % mark subset of electrode locations with small disks
EMARKERSIZE2 = 10;      % default selected channel location marker size
EMARKER2LINEWIDTH = 1;
EFSIZE = get(0,'DefaultAxesFontSize'); % use current default fontsize for electrode labels
HLINEWIDTH = 1.7;         % default linewidth for head, nose, ears
BLANKINGRINGWIDTH = .035;% width of the blanking ring 
HEADRINGWIDTH    = .007;% width of the cartoon head ring
SHADING = 'flat';       % default 'shading': flat|interp
shrinkfactor = [];      % shrink mode (dprecated)
intrad       = [];      % default interpolation square is to outermost electrode (<=1.0)
plotrad      = [];      % plotting radius ([] = auto, based on outermost channel location)
headrad      = [];      % default plotting radius for cartoon head is 0.5
%squeezefac = 1.0;
MINPLOTRAD = 0.15;      % can't make a topoplot with smaller plotrad (contours fail)
VERBOSE = 'off';
MASKSURF = 'off';
CONVHULL = 'off';       % dont mask outside the electrodes convex hull
DRAWAXIS = 'off';
CHOOSECHANTYPE = 0;
ContourVals = Values;
PMASKFLAG   = 0;

%%%%%% Dipole defaults %%%%%%%%%%%%
DIPOLE  = [];           
DIPNORM   = 'on';
DIPSPHERE = 85;
DIPLEN    = 1;
DIPSCALE  = 1;
DIPORIENT  = 1;
DIPCOLOR  = [0 0 0];
NOSEDIR   = '+X';
CHANINFO  = [];

nargs = nargin;


cmap = colormap;
cmaplen = size(cmap,1);

ELECTRODES = 'numpoint';
[r,c] = size(Values);
if r>1 && c>1,
  error('input data must be a single vector');
end
Values = Values(:); % make Values a column vector
ContourVals = ContourVals(:); % values for contour
[tmpeloc labels Th Rd indices] = readlocs( loc_file );

  Th = pi/180*Th;                              % convert degrees to radians
  allchansind = 1:length(Th);

    plotchans = indices;

% remove Nans and infinite values
if length(Values) > 1
    inds          = union(find(isnan(Values)), find(isinf(Values))); % NaN and Inf values
    plotchans     = setdiff(plotchans, inds);
end;

[x,y]     = pol2cart(Th,Rd);  % transform electrode locations from polar to cartesian coordinates
plotchans = abs(plotchans);   % reverse indicated channel polarities
allchansind = allchansind(plotchans);
Th        = Th(plotchans);
Rd        = Rd(plotchans);
x         = x(plotchans);
y         = y(plotchans);
labels    = labels(plotchans); % remove labels for electrodes without locations
%labels    = strvcat(labels); % make a label string matrix
labels    = char(labels); % make a label string matrix
if ~isempty(Values) && length(Values) > 1
    Values      = Values(plotchans);
    ContourVals = ContourVals(plotchans);
end;


if isempty(plotrad) 
  plotrad = min(1.0,max(Rd)*1.02);            % default: just outside the outermost electrode location
  plotrad = max(plotrad,0.5);                 % default: plot out to the 0.5 head boundary
end                                           % don't plot channels with Rd > 1 (below head)

if isempty(intrad) 
  default_intrad = 1;     % indicator for (no) specified intrad
  intrad = min(1.0,max(Rd)*1.02);             % default: just outside the outermost electrode location
else
  default_intrad = 0;                         % indicator for (no) specified intrad
  if plotrad > intrad
     plotrad = intrad;
  end
end                                           % don't interpolate channels with Rd > 1 (below head)

%%%%%%%%%%%%%%%%%%%%%%% Set radius of head cartoon %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if isempty(headrad)  % never set -> defaults
  if plotrad >= rmax
     headrad = rmax;  % (anatomically correct)
  else % if plotrad < rmax
     headrad = 0;    % don't plot head
     if strcmpi(VERBOSE, 'on')
       fprintf('topoplot(): not plotting cartoon head since plotrad (%5.4g) < 0.5\n',...
                                                                    plotrad);
     end
  end
elseif strcmpi(headrad,'rim') % force plotting at rim of map
  headrad = plotrad;
end


%%%%%%%%%%%%%%%%%%%%% Find plotting channels  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 

pltchans = find(Rd <= plotrad); % plot channels inside plotting circle

if strcmpi(INTSQUARE,'on') % interpolate channels in the radius intrad square
  intchans = find(x <= intrad & y <= intrad); % interpolate and plot channels inside interpolation square
else
  intchans = find(Rd <= intrad); % interpolate channels in the radius intrad circle only
end

%
%%%%%%%%%%%%%%%%%%%%% Eliminate channels not plotted  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 

allx      = x;
ally      = y;
intchans; % interpolate using only the 'intchans' channels
pltchans; % plot using only indicated 'plotchans' channels

if length(pltchans) < length(Rd) && strcmpi(VERBOSE, 'on')
        fprintf('Interpolating %d and plotting %d of the %d scalp electrodes.\n', ...
                   length(intchans),length(pltchans),length(Rd));    
end;	


if ~isempty(Values)
	if length(Values) == length(Th)  % if as many map Values as channel locs
		intValues      = Values(intchans);
		intContourVals = ContourVals(intchans);
        Values         = Values(pltchans);
		ContourVals    = ContourVals(pltchans);
	end;	
end;   % now channel parameters and values all refer to plotting channels only

allchansind = allchansind(pltchans);
intTh = Th(intchans);           % eliminate channels outside the interpolation area
intRd = Rd(intchans);
intx  = x(intchans);
inty  = y(intchans);
Th    = Th(pltchans);              % eliminate channels outside the plotting area
Rd    = Rd(pltchans);
x     = x(pltchans);
y     = y(pltchans);

labels= labels(pltchans,:);
%
%%%%%%%%%%%%%%% Squeeze channel locations to <= rmax %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 

squeezefac = rmax/plotrad;
intRd = intRd*squeezefac; % squeeze electrode arc_lengths towards the vertex
Rd = Rd*squeezefac;       % squeeze electrode arc_lengths towards the vertex
                          % to plot all inside the head cartoon
intx = intx*squeezefac;   
inty = inty*squeezefac;  
x    = x*squeezefac;    
y    = y*squeezefac;   
allx    = allx*squeezefac;    
ally    = ally*squeezefac;   
% Note: Now outermost channel will be plotted just inside rmax

%
%%%%%%%%%%%%%%%% rotate channels based on chaninfo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if strcmpi(NOSEDIR, '+x')
     rotate = 0;
else
    if strcmpi(NOSEDIR, '+y')
        rotate = 3*pi/2;
    elseif strcmpi(NOSEDIR, '-x')
        rotate = pi;
    else rotate = pi/2;
    end;
    allcoords = (inty + intx*sqrt(-1))*exp(sqrt(-1)*rotate);
    intx = imag(allcoords);
    inty = real(allcoords);
    allcoords = (ally + allx*sqrt(-1))*exp(sqrt(-1)*rotate);
    allx = imag(allcoords);
    ally = real(allcoords);
    allcoords = (y + x*sqrt(-1))*exp(sqrt(-1)*rotate);
    x = imag(allcoords);
    y = real(allcoords);
end;

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Make the plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

%   %%%%%%%%%%%%%%%% Find limits for interpolation %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    xmin = min(-rmax,min(intx)); xmax = max(rmax,max(intx));
    ymin = min(-rmax,min(inty)); ymax = max(rmax,max(inty));

  %%%%%%%%%%%%%%%%%%%%%%% Interpolate scalp map data %%%%%%%%%%%%%%%%%%%%%%%%
  %
  xi = linspace(xmin,xmax,GRID_SCALE);   % x-axis description (row vector)
  yi = linspace(ymin,ymax,GRID_SCALE);   % y-axis description (row vector)

  try
      [Xi,Yi,Zi] = griddata(inty,intx,intValues,yi',xi,'invdist'); % interpolate data
      [Xi,Yi,ZiC] = griddata(inty,intx,intContourVals,yi',xi,'invdist'); % interpolate data
  catch,
      [Xi,Yi,Zi] = griddata(inty,intx,intValues',yi,xi'); % interpolate data (Octave)
      [Xi,Yi,ZiC] = griddata(inty,intx,intContourVals',yi,xi'); % interpolate data
  end;
  %
  %%%%%%%%%%%%%%%%%%%%%%% Mask out data outside the head %%%%%%%%%%%%%%%%%%%%%
  %
  mask = (sqrt(Xi.^2 + Yi.^2) <= rmax); % mask outside the plotting circle
  ii = find(mask == 0);
  Zi(ii)  = NaN;                         % mask non-plotting voxels with NaNs  
  ZiC(ii) = NaN;                         % mask non-plotting voxels with NaNs
  grid = plotrad;                       % unless 'noplot', then 3rd output arg is plotrad
  %

  
  %%%%%%%%%%%%%%%%%%%%%%% Calculate colormap limits %%%%%%%%%%%%%%%%%%%%%%%%%%
  %

      amax = max(max(abs(Zi)));
      amin = -amax;
      delta = xi(2)-xi(1); % length of grid entry

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%% Scale the axes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  hold on
  h = gca; % uses current axes

                          % instead of default larger AXHEADFAC 
  if squeezefac<0.92 && plotrad-headrad > 0.05  % (size of head in axes)
    AXHEADFAC = 1.05;     % do not leave room for external ears if head cartoon
                          % shrunk enough by the 'skirt' option
  end

  set(gca,'Xlim',[-rmax rmax]*AXHEADFAC,'Ylim',[-rmax rmax]*AXHEADFAC);
                          % specify size of head axes in gca

  unsh = (GRID_SCALE+1)/GRID_SCALE; % un-shrink the effects of 'interp' SHADING


  %%%%%%%%%%%%%%%%%%%%%%%% Else plot map only %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

      if strcmp(SHADING,'interp') % 'interp' mode is shifted somehow... but how?
         tmph = surface(Xi*unsh,Yi*unsh,zeros(size(Zi)),Zi,'EdgeColor','none',...
                  'FaceColor',SHADING);
      else
         tmph = surface(Xi-delta/2,Yi-delta/2,zeros(size(Zi)),Zi,'EdgeColor','none',...
                 'FaceColor',SHADING);
      end
    if strcmpi(MASKSURF, 'on')
        set(tmph, 'visible', 'off');
        handle = tmph;
    end;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Set color axis  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  caxis([amin amax]); % set coloraxis

%
%%%%%%%%%%%%%%%%%%% Plot filled ring to mask jagged grid boundary %%%%%%%%%%%%%%%%%%%%%%%%%%%
%
hwidth = HEADRINGWIDTH;                   % width of head ring 
hin  = squeezefac*headrad*(1- hwidth/2);  % inner head ring radius

if strcmp(SHADING,'interp')
  rwidth = BLANKINGRINGWIDTH*1.3;             % width of blanking outer ring
else
  rwidth = BLANKINGRINGWIDTH;         % width of blanking outer ring
end
rin    =  rmax*(1-rwidth/2);              % inner ring radius
if hin>rin
  rin = hin;                              % dont blank inside the head ring
end

if strcmp(CONVHULL,'on') %%%%%%%%% mask outside the convex hull of the electrodes %%%%%%%%%
  cnv = convhull(allx,ally);
  cnvfac = round(CIRCGRID/length(cnv)); % spline interpolate the convex hull
  if cnvfac < 1, cnvfac=1; end;
  CIRCGRID = cnvfac*length(cnv);

  startangle = atan2(allx(cnv(1)),ally(cnv(1)));
  circ = linspace(0+startangle,2*pi+startangle,CIRCGRID);
  rx = sin(circ); 
  ry = cos(circ); 

  allx = allx(:)';  % make x (elec locations; + to nose) a row vector
  ally = ally(:)';  % make y (elec locations, + to r? ear) a row vector
  erad = sqrt(allx(cnv).^2+ally(cnv).^2);  % convert to polar coordinates
  eang = atan2(allx(cnv),ally(cnv));
  eang = unwrap(eang);
  eradi =spline(linspace(0,1,3*length(cnv)), [erad erad erad], ...
                                      linspace(0,1,3*length(cnv)*cnvfac));
  eangi =spline(linspace(0,1,3*length(cnv)), [eang+2*pi eang eang-2*pi], ...
                                      linspace(0,1,3*length(cnv)*cnvfac));
  xx = eradi.*sin(eangi);           % convert back to rect coordinates
  yy = eradi.*cos(eangi);
  yy = yy(CIRCGRID+1:2*CIRCGRID);
  xx = xx(CIRCGRID+1:2*CIRCGRID);
  eangi = eangi(CIRCGRID+1:2*CIRCGRID);
  eradi = eradi(CIRCGRID+1:2*CIRCGRID);
  xx = xx*1.02; yy = yy*1.02;           % extend spline outside electrode marks

  splrad = sqrt(xx.^2+yy.^2);           % arc radius of spline points (yy,xx)
  oob = find(splrad >= rin);            %  enforce an upper bound on xx,yy
  xx(oob) = rin*xx(oob)./splrad(oob);   % max radius = rin
  yy(oob) = rin*yy(oob)./splrad(oob);   % max radius = rin

  splrad = sqrt(xx.^2+yy.^2);           % arc radius of spline points (yy,xx)
  oob = find(splrad < hin);             % don't let splrad be inside the head cartoon
  xx(oob) = hin*xx(oob)./splrad(oob);   % min radius = hin
  yy(oob) = hin*yy(oob)./splrad(oob);   % min radius = hin

  ringy = [[ry(:)' ry(1) ]*(rin+rwidth) yy yy(1)];
  ringx = [[rx(:)' rx(1) ]*(rin+rwidth) xx xx(1)];

  ringh2= patch(ringy,ringx,ones(size(ringy)),BACKCOLOR,'edgecolor','none'); hold on

  % plot(ry*rmax,rx*rmax,'b') % debugging line

else %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% mask the jagged border around rmax %%%%%%%%%%%%%%%5%%%%%%

  circ = linspace(0,2*pi,CIRCGRID);
  rx = sin(circ); 
  ry = cos(circ); 
  ringx = [[rx(:)' rx(1) ]*(rin+rwidth)  [rx(:)' rx(1)]*rin];
  ringy = [[ry(:)' ry(1) ]*(rin+rwidth)  [ry(:)' ry(1)]*rin];

  if ~strcmpi(STYLE,'blank')
    ringh= patch(ringx,ringy,0.01*ones(size(ringx)),BACKCOLOR,'edgecolor','none'); hold on
  end
  
end

%
%%%%%%%%%%%%%%%%%%%%%%%%% Plot cartoon head, ears, nose %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
if headrad > 0                         % if cartoon head to be plotted
%
%%%%%%%%%%%%%%%%%%% Plot head outline %%%%%%%%%%%%%%%%%%%%%%%%%%%
%
headx = [[rx(:)' rx(1) ]*(hin+hwidth)  [rx(:)' rx(1)]*hin];
heady = [[ry(:)' ry(1) ]*(hin+hwidth)  [ry(:)' ry(1)]*hin];

if ~ischar(HEADCOLOR) || ~strcmpi(HEADCOLOR,'none')
   ringh= patch(headx,heady,ones(size(headx)),HEADCOLOR,'edgecolor',HEADCOLOR); hold on
end


%
%%%%%%%%%%%%%%%%%%% Plot ears and nose %%%%%%%%%%%%%%%%%%%%%%%%%%%
%
  base  = rmax-.0046;
  basex = 0.18*rmax;                   % nose width
  tip   = 1.15*rmax; 
  tiphw = .04*rmax;                    % nose tip half width
  tipr  = .01*rmax;                    % nose tip rounding
  q = .04; % ear lengthening
  EarX  = [.497-.005  .510  .518  .5299 .5419  .54    .547   .532   .510   .489-.005]; % rmax = 0.5
  EarY  = [q+.0555 q+.0775 q+.0783 q+.0746 q+.0555 -.0055 -.0932 -.1313 -.1384 -.1199];
  sf    = headrad/plotrad;                                          % squeeze the model ears and nose 
                                                                    % by this factor
  if ~ischar(HEADCOLOR) || ~strcmpi(HEADCOLOR,'none')
    plot3([basex;tiphw;0;-tiphw;-basex]*sf,[base;tip-tipr;tip;tip-tipr;base]*sf,...
         2*ones(size([basex;tiphw;0;-tiphw;-basex])),...
         'Color',HEADCOLOR,'LineWidth',HLINEWIDTH);                 % plot nose
    plot3(EarX*sf,EarY*sf,2*ones(size(EarX)),'color',HEADCOLOR,'LineWidth',HLINEWIDTH)    % plot left ear
    plot3(-EarX*sf,EarY*sf,2*ones(size(EarY)),'color',HEADCOLOR,'LineWidth',HLINEWIDTH)   % plot right ear
  end
end

%
% %%%%%%%%%%%%%%%%%%% Show electrode information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
 plotax = gca;
 axis square                                           % make plotax square
 axis off

 
 % axes(textax);                   
 axis square                                           % make textax square

 pos = get(gca,'position');
 set(plotax,'position',pos);

 xlm = get(gca,'xlim');
 set(plotax,'xlim',xlm);

 ylm = get(gca,'ylim');
 set(plotax,'ylim',ylm);                               % copy position and axis limits again

axis equal;
set(gca, 'xlim', [-0.525 0.525]); set(plotax, 'xlim', [-0.525 0.525]);
set(gca, 'ylim', [-0.525 0.525]); set(plotax, 'ylim', [-0.525 0.525]);
 

 if isempty(EMARKERSIZE)
   EMARKERSIZE = 10;
   if length(y)>=160
    EMARKERSIZE = 3;
   elseif length(y)>=128
    EMARKERSIZE = 3;
   elseif length(y)>=100
    EMARKERSIZE = 3;
   elseif length(y)>=80
    EMARKERSIZE = 4;
   elseif length(y)>=64
    EMARKERSIZE = 5;
   elseif length(y)>=48
    EMARKERSIZE = 6;
   elseif length(y)>=32 
    EMARKERSIZE = 8;
   end
 end
%
%%%%%%%%%%%%%%%%%%%%%%%% Mark electrode locations only %%%%%%%%%%%%%%%%%%%%%%%%%%
%
ELECTRODE_HEIGHT = 2.1;  % z value for plotting electrode information (above the surf)

if strcmp(ELECTRODES,'on')   % plot electrodes as spots
  if isempty(EMARKER2CHANS)
    hp2 = plot3(y,x,ones(size(x))*ELECTRODE_HEIGHT,...
        EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE,'linewidth',EMARKERLINEWIDTH);
  else % plot markers for normal chans and EMARKER2CHANS separately
    hp2 = plot3(y(mark1chans),x(mark1chans),ones(size((mark1chans)))*ELECTRODE_HEIGHT,...
        EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE,'linewidth',EMARKERLINEWIDTH);
    hp2b = plot3(y(mark2chans),x(mark2chans),ones(size((mark2chans)))*ELECTRODE_HEIGHT,...
        EMARKER2,'Color',EMARKER2COLOR,'markerfacecolor',EMARKER2COLOR,'linewidth',EMARKER2LINEWIDTH,'markersize',EMARKERSIZE2);
  end
%
%%%%%%%%%%%%%%%%%%%%%%%% Print electrode labels only %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
elseif strcmp(ELECTRODES,'labels')  % print electrode names (labels)
    for i = 1:size(labels,1)
    text(double(y(i)),double(x(i)),...
        ELECTRODE_HEIGHT,labels(i,:),'HorizontalAlignment','center',...
	'VerticalAlignment','middle','Color',ECOLOR,...
	'FontSize',EFSIZE)
    end
%
%%%%%%%%%%%%%%%%%%%%%%%% Mark electrode locations plus labels %%%%%%%%%%%%%%%%%%%
%
elseif strcmp(ELECTRODES,'labelpoint') 
  if isempty(EMARKER2CHANS)
    hp2 = plot3(y,x,ones(size(x))*ELECTRODE_HEIGHT,...
        EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE,'linewidth',EMARKERLINEWIDTH);
  else
    hp2 = plot3(y(mark1chans),x(mark1chans),ones(size((mark1chans)))*ELECTRODE_HEIGHT,...
        EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE,'linewidth',EMARKERLINEWIDTH);
    hp2b = plot3(y(mark2chans),x(mark2chans),ones(size((mark2chans)))*ELECTRODE_HEIGHT,...
        EMARKER2,'Color',EMARKER2COLOR,'markerfacecolor',EMARKER2COLOR,'linewidth',EMARKER2LINEWIDTH,'markersize',EMARKERSIZE2);
  end
  for i = 1:size(labels,1)
    hh(i) = text(double(y(i)+0.01),double(x(i)),...
        ELECTRODE_HEIGHT,labels(i,:),'HorizontalAlignment','left',...
	'VerticalAlignment','middle','Color', ECOLOR,'userdata', num2str(allchansind(i)), ...
	'FontSize',EFSIZE, 'buttondownfcn', ...
	    ['tmpstr = get(gco, ''userdata'');'...
	     'set(gco, ''userdata'', get(gco, ''string''));' ...
	     'set(gco, ''string'', tmpstr); clear tmpstr;'] );
  end
%
%%%%%%%%%%%%%%%%%%%%%%% Mark electrode locations plus numbers %%%%%%%%%%%%%%%%%%%
%
elseif strcmp(ELECTRODES,'numpoint') 
  if isempty(EMARKER2CHANS)
    hp2 = plot3(y,x,ones(size(x))*ELECTRODE_HEIGHT,...
        EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE,'linewidth',EMARKERLINEWIDTH);
  else
    hp2 = plot3(y(mark1chans),x(mark1chans),ones(size((mark1chans)))*ELECTRODE_HEIGHT,...
        EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE,'linewidth',EMARKERLINEWIDTH);
    hp2b = plot3(y(mark2chans),x(mark2chans),ones(size((mark2chans)))*ELECTRODE_HEIGHT,...
        EMARKER2,'Color',EMARKER2COLOR,'markerfacecolor',EMARKER2COLOR,'linewidth',EMARKER2LINEWIDTH,'markersize',EMARKERSIZE2);
  end
  for i = 1:size(labels,1)
    hh(i) = text(double(y(i)+0.01),double(x(i)),...
        ELECTRODE_HEIGHT,num2str(allchansind(i)),'HorizontalAlignment','left',...
	'VerticalAlignment','middle','Color', ECOLOR,'userdata', labels(i,:) , ...
	'FontSize',EFSIZE, 'buttondownfcn', ...
	    ['tmpstr = get(gco, ''userdata'');'...
	     'set(gco, ''userdata'', get(gco, ''string''));' ...
	     'set(gco, ''string'', tmpstr); clear tmpstr;'] );
  end
% %
% %%%%%%%%%%%%%%%%%%%%%% Print electrode numbers only %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% elseif strcmp(ELECTRODES,'numbers')
%   for i = 1:size(labels,1)
%     text(double(y(i)),double(x(i)),...
%         ELECTRODE_HEIGHT,int2str(allchansind(i)),'HorizontalAlignment','center',...
% 	'VerticalAlignment','middle','Color',ECOLOR,...
% 	'FontSize',EFSIZE)
%   end
% %
% %%%%%%%%%%%%%%%%%%%%%% Mark emarker2 electrodes only  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% elseif strcmp(ELECTRODES,'off') && ~isempty(EMARKER2CHANS)
%     hp2b = plot3(y(mark2chans),x(mark2chans),ones(size((mark2chans)))*ELECTRODE_HEIGHT,...
%         EMARKER2,'Color',EMARKER2COLOR,'markerfacecolor',EMARKER2COLOR,'linewidth',EMARKER2LINEWIDTH,'markersize',EMARKERSIZE2);
% end

%
%%%%%%%%%%%%% Set EEGLAB background color to match head border %%%%%%%%%%%%%%%%%%%%%%%%
%
try 
  icadefs; 
  set(gcf, 'color', BACKCOLOR); 
catch me 
end; 

hold off
axis off
return
