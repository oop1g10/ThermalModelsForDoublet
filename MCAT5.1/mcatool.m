function mcatool(plotParams, varargin) % plotParams options added by Pedchenko
%
% Monte-Carlo Analysis Tool
%
% Matthew Lees & Thorsten Wagener, Imperial College, September 1999

global sliderbar slider_value slider_text;

gvs=get(0,'userdata');
COMMAND=gvs.COMMAND;
HH=gvs.HH;

set(0,'units','pixels');
ss=get(0,'screensize');sw=ss(3);sh=ss(4);

if strcmp(COMMAND,'new')
  perfs=str2mat(gvs.lhoods,gvs.vars);
  slider_value = 100; %set the default slider value.
  % set up uimenu
  %set(0,'units','pixels');
  %ss=get(0,'screensize');sw=ss(3);sh=ss(4);
  set(HH,'position',[0.1*sw 0.1*sh 0.8*sw 0.8*sh]);figure(HH)
  sliderbar = uicontrol('Style', 'slider', 'Position', [1 1 150 15],...
        'Value', slider_value, 'Min', 0, 'Max', 100,...
        'SliderStep',[0.01 0.1], 'Visible','off', 'Callback','mcatool slider_edit');
  slider_text(1) = uicontrol('Style', 'text', 'Position', [1 35 150 15],...
        'Visible','off','String', 'Objective Threshold (%)');
  slider_text(2) = uicontrol('Style', 'text', 'Position', [1 20 150 15],...
        'Visible','off','String', num2str(slider_value));
  if max(ss)>800
     set(gcf,'defaultaxesfontsize',10);
  else
     set(gcf,'defaultaxesfontsize',8);
  end
  h1=uimenu('label','MCAT Menu');
  % plotParams are added as input to mcatool by Pedchenko
  uimenu(h1,'label','Parameter Table','callback','gvs=get(0,''userdata'');gvs.COMMAND=''table'';set(0,''userdata'',gvs);mcatool(plotParams)');
  uimenu(h1,'label','Dotty Plots Objective Functions','callback','gvs=get(0,''userdata'');gvs.COMMAND=''dotty'';set(0,''userdata'',gvs);mcatool(plotParams)');
  uimenu(h1,'label','Dotty Plots Likelihoods','callback','gvs=get(0,''userdata'');gvs.COMMAND=''dotlhoods'';set(0,''userdata'',gvs);mcatool(plotParams)');
  uimenu(h1,'label','A Posteriori Parameter Distribution','callback','gvs=get(0,''userdata'');gvs.COMMAND=''postdis'';set(0,''userdata'',gvs);mcatool(plotParams)');
  uimenu(h1,'label','Identifiability Plots','callback','gvs=get(0,''userdata'');gvs.COMMAND=''idmain'';set(0,''userdata'',gvs);mcatool(plotParams)');
  if ~isempty(gvs.mct)
     uimenu(h1,'label','DYNIA','callback','gvs=get(0,''userdata'');gvs.COMMAND=''id_time'';set(0,''userdata'',gvs);mcatool(plotParams)');
  end
  uimenu(h1,'label','Regional Sensitivity Analysis','callback','gvs=get(0,''userdata'');gvs.COMMAND=''sensi'';set(0,''userdata'',gvs);mcatool(plotParams)');
  uimenu(h1,'label','Regional Sensitivity Analysis 2','callback','gvs=get(0,''userdata'');gvs.COMMAND=''sensi2'';set(0,''userdata'',gvs);mcatool(plotParams)');
  if gvs.ff(1)~=1
     uimenu(h1,'label','Parameter View','callback','gvs=get(0,''userdata'');gvs.PCOMMAND=''new'';parvis');
  end
  if ~isempty(gvs.mct)
    uimenu(h1,'label','Class Plot','callback','gvs=get(0,''userdata'');gvs.COMMAND=''class'';set(0,''userdata'',gvs);mcatool(plotParams)');
  end
  if gvs.ff(3)
    uimenu(h1,'label','GLUE Variable Uncertainty','callback','gvs=get(0,''userdata'');gvs.COMMAND=''uncert'';gvs.LS=1;gvs.VS=1;set(0,''userdata'',gvs);mcatool(plotParams)');
  end
  if ~isempty(gvs.mct)
    uimenu(h1,'label','GLUE Output Uncertainty','callback','gvs=get(0,''userdata'');gvs.COMMAND=''ouncert'';set(0,''userdata'',gvs);mcatool(plotParams)');
  end
  uimenu(h1,'label','PARETO Output Uncertainty','callback','gvs=get(0,''userdata'');gvs.COMMAND=''paretounc'';set(0,''userdata'',gvs);mcatool(plotParams)');
  uimenu(h1,'label','Multi-Objective Plots','callback','gvs=get(0,''userdata'');gvs.COMMAND=''multi-obj'';set(0,''userdata'',gvs);mcatool(plotParams)');
  uimenu(h1,'label','Parameter Correlation Matrix','callback','gvs=get(0,''userdata'');gvs.COMMAND=''cor-matrix'';set(0,''userdata'',gvs);mcatool(plotParams)');
  uimenu(h1,'label','Normalised Parameter Range Plot','callback','gvs=get(0,''userdata'');gvs.COMMAND=''prange'';set(0,''userdata'',gvs);mcatool(plotParams)');
  uimenu(h1,'label','Best Predictions Plot','callback','gvs=get(0,''userdata'');gvs.COMMAND=''bestpred'';set(0,''userdata'',gvs);mcatool(plotParams)');
  uimenu(h1,'label','Simulation Pixel Plot','callback','gvs=get(0,''userdata'');gvs.COMMAND=''pixel'';set(0,''userdata'',gvs);mcatool(plotParams)');
  uimenu(h1,'label','Time-Series Surface Plot','callback','gvs=get(0,''userdata'');gvs.COMMAND=''time-surf'';set(0,''userdata'',gvs);mcatool(plotParams)');
  uimenu(h1,'label','Threshold','callback','gvs=get(0,''userdata'');gvs.THRS=inputdlg(''Enter threshold value'',''mcatool'');gvs.THRS=str2num(gvs.THRS{1});set(0,''userdata'',gvs);mcatool(plotParams)','separ','on');
  if gvs.ff(3)|~isempty(gvs.mct) 
    uimenu(h1,'label','Set upper CI','callback','gvs=get(0,''userdata'');gvs.uci=inputdlg(''Enter upper confidence interval (0-1)'',''mcatool'');gvs.uci=str2num(gvs.uci{1});set(0,''userdata'',gvs);mcatool(plotParams)');
    uimenu(h1,'label','Set lower CI','callback','gvs=get(0,''userdata'');gvs.lci=inputdlg(''Enter lower confidence interval (0-1)'',''mcatool'');gvs.lci=str2num(gvs.lci{1});set(0,''userdata'',gvs);mcatool(plotParams)');   
  end
  uimenu(h1,'label','Zoom In','callback','zoom on','separ','on');
  uimenu(h1,'label','Exit','callback','gvs=get(0,''userdata'');gvs.COMMAND=''exit'';set(0,''userdata'',gvs);mcatool(plotParams)','separ','on');
  h2=uimenu('label','Objectives/Variables');
  for i=1:gvs.ff(2)+gvs.ff(3)
     if i==gvs.ff(2)+1
        eval(['uimenu(h2,''label'',perfs(i,:),''callback'',''gvs=get(0,''''userdata'''');gvs.PS=' num2str(i)  ';set(0,''''userdata'''',gvs);mcatool(plotParams)'',''separ'',''on'')']);
     else
        eval(['uimenu(h2,''label'',perfs(i,:),''callback'',''gvs=get(0,''''userdata'''');gvs.PS=' num2str(i)  ';set(0,''''userdata'''',gvs);mcatool(plotParams)'')']);
     end
  end
  end

if ~isempty(gvs.THRS)
  [jj,i]=sort(gvs.dat(:,gvs.ff(1)+gvs.PS));
  gvs.dat=gvs.dat(i,:);
  if sum(gvs.COMMAND(1:4)=='dotl')~=4
     cut=max(find(gvs.dat(:,gvs.ff(1)+gvs.PS)<gvs.THRS));
  else
     cut=max(find(gvs.dat(:,gvs.ff(1)+gvs.PS)<1-gvs.THRS));
  end
  gvs.dat(cut:length(gvs.dat),:)=[];
  if ~isempty(gvs.mct)
     gvs.mct=gvs.mct';
     gvs.mct=gvs.mct(i,:);
     gvs.mct(cut:length(gvs.mct),:)=[];
     gvs.mct=gvs.mct';
  end
  gvs.THRS=[];
  set(0,'userdata',gvs);
end

if strcmp(COMMAND,'new') % default plot
  figure(HH)
  set(HH,'numbertitle','off')
  set(HH,'name','MC ANALYSIS TOOL')
  gvs.COMMAND='dotty';
  set(0,'userdata',gvs);
  mcatool(plotParams); % (plotParams) added as input to mcatool  by Pedchenko
elseif strcmp(COMMAND,'table') % Plot table with 10 best parameter sets
   table;      
elseif strcmp(COMMAND,'dotty') % dotty plots
  for i=1:(max(gvs.ff(1),gvs.ff(2)))^2, delete(gca), end
  if nargin == 1 % initially was ==0, modified to 1 by Pedchenko
    set(HH,'name',['MC ANALYSIS TOOL: Dotty plots (objective functions) for ' gvs.id])
    set(sliderbar,'Visible','on');
    set(slider_text,'Visible','on');
    slider_value = get(sliderbar,'Value'); % get the slider value
    dotty(plotParams); % plotParams options added by Pedchenko
  else % if the user has moved the slider, execute callback
    slider_value = get(sliderbar,'Value'); % get the text box value
    set(slider_text(2),'String',num2str(slider_value)); % set slider to this
    dotty(plotParams); % plotParams options added by Pedchenko
  end
elseif strcmp(COMMAND,'dotlhoods') % dotty plots
  for i=1:(max(gvs.ff(1),gvs.ff(2)))^2, delete(gca), end
  if nargin == 1 % initially was ==0, modified to 1 by Pedchenko
    set(HH,'name',['MC ANALYSIS TOOL: Dotty plots (likelihoods) for ' gvs.id])
    set(sliderbar,'Visible','on');
    set(slider_text,'Visible','on');
    slider_value = get(sliderbar,'Value'); % get the slider value
     dotlhoods;
  else % if the user has moved the slider, execute callback
    slider_value = get(sliderbar,'Value'); % get the text box value
    set(slider_text(2),'String',num2str(slider_value)); % set slider to this
    dotlhoods;
  end
elseif strcmp(COMMAND,'postdis') % a posteriori parameter distribution
  for i=1:(max(gvs.ff(1),gvs.ff(2)))^2, delete(gca), end
  if nargin == 1 % initially was ==0, modified to 1 by Pedchenko
    set(HH,'name',['MC ANALYSIS TOOL: A posteriori parameter distribution (likelihoods) for ' gvs.id])
    set(sliderbar,'Visible','on');
    set(slider_text,'Visible','on');
    slider_value = get(sliderbar,'Value'); % get the slider value
    postdis;
  else % if the user has moved the slider, execute callback
    slider_value = get(sliderbar,'Value'); % get the text box value
    set(slider_text(2),'String',num2str(slider_value)); % set slider to this
    postdis;
  end
elseif strcmp(COMMAND,'idmain') % identifiability plots
  for i=1:(max(gvs.ff(1),gvs.ff(2)))^2, delete(gca), end
  if nargin == 1 % initially was ==0, modified to 1 by Pedchenko
    set(HH,'name',['MC ANALYSIS TOOL: Identifiability plots for ' gvs.id])
    set(sliderbar,'Visible','on');
    set(slider_text,'Visible','on');
    slider_value = get(sliderbar,'Value'); % get the slider value
    idmain;
  else % if the user has moved the slider, execute callback
    slider_value = get(sliderbar,'Value'); % get the text box value
    set(slider_text(2),'String',num2str(slider_value)); % set slider to this
    idmain;
  end
elseif strcmp(COMMAND,'id_time') % dynamic identifiability analysis plots
   for i=1:(max(gvs.ff(1),gvs.ff(2)))^2, delete(gca), end
   set(HH,'name',['MC ANALYSIS TOOL: Identifiability analysis per dt plot for ' gvs.id])
   id_time;
elseif strcmp(COMMAND,'multi-obj') % multi-objective plots
  for i=1:(max(gvs.ff(1),gvs.ff(2)))^2, delete(gca), end
  if nargin == 1 % initially was ==0, modified to 1 by Pedchenko
    set(HH,'name',['MC ANALYSIS TOOL: Multi objective plots for ' gvs.id])
    set(sliderbar,'Visible','on');
    set(slider_text,'Visible','on');
    slider_value = get(sliderbar,'Value'); % get the slider value
    multiobj;
  else % if the user has moved the slider, execute callback
    slider_value = get(sliderbar,'Value'); % get the text box value
    set(slider_text(2),'String',num2str(slider_value)); % set slider to this
    multiobj;
  end
  %set(HH,'name',['MC ANALYSIS TOOL: Multi objective plots for ' gvs.id])
  %multiobj;
elseif strcmp(COMMAND,'cor-matrix') % parameter correlation matrix
  for i=1:(max(gvs.ff(1),gvs.ff(2)))^2, delete(gca), end
  if nargin == 1 % initially was ==0, modified to 1 by Pedchenko
    set(HH,'name',['MC ANALYSIS TOOL: Parameter Correlation Matrix for ' gvs.id])
    set(sliderbar,'Visible','on');
    set(slider_text,'Visible','on');
    slider_value = get(sliderbar,'Value'); % get the slider value
    correlmatrix; 
  else % if the user has moved the slider, execute callback
    slider_value = get(sliderbar,'Value'); % get the text box value
    set(slider_text(2),'String',num2str(slider_value)); % set slider to this
    correlmatrix;
  end
elseif strcmp(COMMAND,'prange') % normalised parameter range plot
  for i=1:(max(gvs.ff(1),gvs.ff(2)))^2, delete(gca), end
  set(HH,'name',['MC ANALYSIS TOOL: Normalised parameter range plot for ' gvs.id])
  prange;
elseif strcmp(COMMAND,'bestpred') % plot all 'best' predictions with respect to the different objective functions
  for i=1:(max(gvs.ff(1),gvs.ff(2)))^2, delete(gca), end
  set(HH,'name',['MC ANALYSIS TOOL: Best predictions of different OFs for ' gvs.id])
  bestpred;
elseif strcmp(COMMAND,'sensi') % sensitivity plots   
  for i=1:(max(gvs.ff(1),gvs.ff(2)))^2, delete(gca), end
  set(HH,'name',['MC ANALYSIS TOOL: Regional sensitivity plots for ' gvs.id])
  sensi(plotParams); % plotParams options added by Pedchenko
elseif strcmp(COMMAND,'sensi2') % sensitivity plots   
  for i=1:(max(gvs.ff(1),gvs.ff(2)))^2, delete(gca), end
  set(HH,'name',['MC ANALYSIS TOOL: Regional sensitivity plots type 2 for ' gvs.id])
  sensi2(gvs.ff);  
elseif strcmp(COMMAND,'paretounc') % PARETO uncertainty plot
   for i=1:(max(gvs.ff(1),gvs.ff(2)))^2, delete(gca), end
   set(HH,'name',['MC ANALYSIS TOOL: Pareto uncertainty plot for ' gvs.id])
   paretounc;
elseif strcmp(COMMAND,'uncert') % variable uncertainty plots
  if gvs.PS<gvs.ff(2)|gvs.PS==gvs.ff(2) % likelihood changed
    gvs.LS=gvs.PS;
    set(0,'userdata',gvs);
  else
    gvs.VS=gvs.PS-gvs.ff(2); % variable changed
    set(0,'userdata',gvs);
 end
  delete(gca)
  lstr=unpad(gvs.lhoods(gvs.LS,:),' ','e');lstr=unpad(lstr,' ','b');
  set(HH,'name',['MC ANALYSIS TOOL: GLUE variable uncertainty for ' gvs.id ' (' lstr ')'])
  uncert;
elseif strcmp(COMMAND,'ouncert') % output uncertainty plot
  if gvs.PS<gvs.ff(2)+1,gvs.LS=gvs.PS;set(0,'userdata',gvs);end
  for i=1:(max(gvs.ff(1),gvs.ff(2)))^2, delete(gca), end
  lstr=unpad(gvs.lhoods(gvs.LS,:),' ','e');lstr=unpad(lstr,' ','b');
  set(HH,'name',['MC ANALYSIS TOOL: GLUE output uncertainty for ' gvs.id ' (' lstr ')'])
  gloue;
elseif strcmp(COMMAND,'class') % class plot
  for i=1:(max(gvs.ff(1),gvs.ff(2)))^2, delete(gca), end
  set(HH,'name',['MC ANALYSIS TOOL: Class plot for ' gvs.id])
  classp;
elseif strcmp(COMMAND,'parvis') % contour plot
  COMMAND='new';
  parvis(COMMAND,ff,id,pars,lhoods,vars,dat,PS);
elseif strcmp(COMMAND,'pixel') % simulation pixel plot
  for i=1:(max(gvs.ff(1),gvs.ff(2)))^2, delete(gca), end
  set(sliderbar,'Visible','off');
  set(slider_text,'Visible','off');
  set(HH,'name',['MC ANALYSIS TOOL: Simulation Pixel Plot for ' gvs.id])
  pixel;
elseif strcmp(COMMAND,'time-surf') % time-series surface plot
  for i=1:(max(gvs.ff(1),gvs.ff(2)))^2, delete(gca), end
  set(HH,'name',['MC ANALYSIS TOOL: Time-Series Surface Plot for ' gvs.id])
  time_surface;
elseif strcmp(COMMAND,'exit') % exit program
  close(gvs.HH)
  if gvs.FH, close(gvs.FH), end
end
