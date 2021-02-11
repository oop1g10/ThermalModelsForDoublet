function parvis

% function parvis
%
% parameter visualisation GUI
%
% Matthew Lees & Thorsten Wagener, Imperial College London, October 1999

gvs		=get(0,'userdata');
PCOMMAND	=gvs.PCOMMAND;
ff			=gvs.ff;
id			=gvs.id;
pars		=gvs.pars;
lhoods	=gvs.lhoods;
vars		=gvs.vars;
dat		=gvs.dat;
perfs    =str2mat(lhoods,vars);

if isstr(PCOMMAND) 
  if strcmp(lower(PCOMMAND),lower('new')) 
    comm = 0;
  elseif strcmp(lower(PCOMMAND),lower('2ds')) 
    comm = 1;
  elseif strcmp(lower(PCOMMAND),lower('2dc')) 
    comm = 2;
  elseif strcmp(lower(PCOMMAND),lower('3ds')) 
    comm = 3;
  elseif strcmp(lower(PCOMMAND),lower('3dm')) 
    comm = 4;
  end 
end

if comm==0  
  % set up uimenu
  set(0,'units','pixels');
  ss=get(0,'screensize');sw=ss(3);sh=ss(4);
  FH=figure('position',[0.12*sw 0.08*sh 0.8*sw 0.8*sh]);figure(FH)
  gvs.FH=FH;set(0,'userdata',gvs);
  if max(ss)>800
     set(gcf,'defaultaxesfontsize',10);
  else
     set(gcf,'defaultaxesfontsize',8);
  end
  parvstr='set(0,''userdata'',gvs);parvis';
  g1=uimenu('label','Parameter View');
  uimenu(g1,'label','2-D Surface','callback',['gvs=get(0,''userdata'');gvs.PCOMMAND=''2ds'';' parvstr]);
  uimenu(g1,'label','2-D Contour','callback',['gvs=get(0,''userdata'');gvs.PCOMMAND=''2dc'';' parvstr]);
  uimenu(g1,'label','3-D Surface','callback',['gvs=get(0,''userdata'');gvs.PCOMMAND=''3ds'';' parvstr]);
  uimenu(g1,'label','3-D Mesh','callback',['gvs=get(0,''userdata'');gvs.PCOMMAND=''3dm'';' parvstr]);
  uimenu(g1,'label','Zoom In','callback','zoom on','separ','on');
  uimenu(g1,'label','Refresh','callback',['gvs=get(0,''userdata'');gvs.DL=1;' parvstr]);
  g2=uimenu('label','Objectives/Variables');
  parvstre='set(0,''''userdata'''',gvs);parvis';
  for i=1:ff(2)+ff(3)
     if i==ff(2)+1
       eval(['uimenu(g2,''label'',perfs(i,:),''callback'',' ...
          '''gvs=get(0,''''userdata'''');gvs.DL=1;gvs.PS=' num2str(i) ';' parvstre ''',''separ'',''on'')']);
     else
       eval(['uimenu(g2,''label'',perfs(i,:),''callback'',' ...
          '''gvs=get(0,''''userdata'''');gvs.DL=1;gvs.PS=' num2str(i) ';' parvstre ''')']);
     end   
  end
  g3=uimenu('label','Y-Param');
  for i=1:ff(1)
    eval(['uimenu(g3,''label'',pars(i,:),''callback'',' ...
      '''gvs=get(0,''''userdata'''');gvs.DL=1;gvs.Py=' num2str(i) ';' parvstre ''')']);
  end
  g4=uimenu('label','X-Param');
  for i=1:ff(1)
    eval(['uimenu(g4,''label'',pars(i,:),''callback'',' ...
      '''gvs=get(0,''''userdata'''');gvs.DL=1;gvs.Px=' num2str(i) ';' parvstre ''')']);
  end
  g5=uimenu('label','Colormap');
  uimenu(g5,'label','Hot','callback',['gvs=get(0,''userdata'');gvs.CM=''hot'';' parvstr]);
  uimenu(g5,'label','Cool','callback',['gvs=get(0,''userdata'');gvs.CM=''cool'';' parvstr]);
  uimenu(g5,'label','Gray','callback',['gvs=get(0,''userdata'');gvs.CM=''gray'';' parvstr]);
  uimenu(g5,'label','Copper','callback',['gvs=get(0,''userdata'');gvs.CM=''copper'';' parvstr]);
  uimenu(g5,'label','Pink','callback',['gvs=get(0,''userdata'');gvs.CM=''pink'';' parvstr]);
  g6=uimenu('label','View');
  uimenu(g6,'label',['45' setstr(176)],'callback',['gvs=get(0,''userdata'');gvs.VA=45;' parvstr]);
  uimenu(g6,'label',['135' setstr(176)],'callback',['gvs=get(0,''userdata'');gvs.VA=135;' parvstr]);
  uimenu(g6,'label',['225' setstr(176)],'callback',['gvs=get(0,''userdata'');gvs.VA=225;' parvstr]);
  uimenu(g6,'label',['315' setstr(176)],'callback',['gvs=get(0,''userdata'');gvs.VA=315;' parvstr]);
end

if gvs.DL % select data
  set(gcf,'pointer','watch');
  drawnow
  x=dat(:,gvs.Px);
  y=dat(:,gvs.Py);
  z=dat(:,ff(1)+gvs.PS);
  % Map the data on to a grid
  x1 = linspace(min(x),max(x),gvs.gridd);
  y1 = linspace(min(y),max(y),gvs.gridd);
  [gvs.Xi1,gvs.Yi1] = meshgrid(x1,y1);
  gvs.Zi1 = griddata(x,y,z,gvs.Xi1,gvs.Yi1,'linear'); 
  gvs.DL=0;set(0,'userdata',gvs);
  set(gcf,'pointer','arrow');
end

cc=get(gcf,'child');
for i=1:length(cc)
  if strcmp(get(cc(i),'type'),'axes');delete(cc(i));end
end
set(gcf,'nextplot','add')
cla reset

if comm==0 % new
  figure(FH)
  set(FH,'numbertitle','off')
  set(FH,'name','PARAMVIEW')
  gvs.PCOMMAND='2ds';set(0,'userdata',gvs);
  parvis 
elseif comm==1 % 2-D surface
  set(gcf,'name',['2-D surface plot for ' gvs.id ' (' deblank(perfs(gvs.PS,:)) ')'])
  pcolor(gvs.Xi1,gvs.Yi1,gvs.Zi1)
  axis tight
  surfh=gca;
  surfpos=get(gca,'pos');
  shading interp
  eval(['colormap(flipud(' gvs.CM '));']);
  xlabel(deblank(pars(gvs.Px,:)));
  ylabel(deblank(pars(gvs.Py,:)));
  h=colorbar;
  tickpos=get(h,'ytick');
  set(h,'ytick',[tickpos(1) tickpos(length(tickpos))]);
  set(h,'yaxislocation','left');
  set(h,'pos',[.97 .117 .02 .33]);
  %axes(h);
  ylabel(deblank(perfs(gvs.PS,:)))
  set(get(h,'ylabel'),'verticalalignment','top');
  surfpos(1)=surfpos(1)-0.02;
  set(surfh,'pos',surfpos);
elseif comm==2 % 2-D contour
  set(gcf,'name',['Contour plot for ' gvs.id ' (' deblank(perfs(gvs.PS,:)) ')'])
  eval(['set(gcf,''defaultaxescolororder'',' gvs.CM '(10))']);
  [cc,hh]=contour(gvs.Xi1,gvs.Yi1,gvs.Zi1,10);
  hold on;
  axis tight
  set(hh,'linewidth',1.5);
  surfh=gca;surfpos=get(gca,'pos');
  xlabel(pars(gvs.Px,:));
  ylabel(pars(gvs.Py,:));
  
  % INCLUDE PARETOSET?
  paretoset = questdlg('Do you want to plot the paretoset on the plot?','Input Window'); 
  if paretoset(1)=='Y';  
     if ~isempty(gvs.pareto)
        pranks=gvs.pareto;
     else
        [pranks]=pareto;
     end  
     plot(pranks(:,1+gvs.Px),pranks(:,1+gvs.Py),'d','markeredgecolor','k','markerfacecolor','b','markersize',10);
  end  
  hold off;
  
  eval(['colormap(' gvs.CM ');']);
  h=colorbar;
  tickpos=get(h,'ytick');
  set(h,'ytick',[tickpos(1) tickpos(length(tickpos))]);
  set(h,'yaxislocation','left');
  set(h,'pos',[.97 .117 .02 .33]);
  axes(h);ylabel(deblank(perfs(gvs.PS,:)))
  set(get(h,'ylabel'),'verticalalignment','top');
  surfpos(1)=surfpos(1)-0.02;
  set(surfh,'pos',surfpos);

elseif comm==3 % 3-D surface
  set(gcf,'name',['3-D surface plot for ' gvs.id ' (' deblank(perfs(gvs.PS,:)) ')'])
  eval(['set(gcf,''defaultaxescolororder'',' gvs.CM '(5))']);
  surfc(gvs.Xi1,gvs.Yi1,gvs.Zi1)
  axis tight
  eval(['colormap(' gvs.CM ');']);
  shading interp
  xlabel(pars(gvs.Px,:));
  ylabel(pars(gvs.Py,:));
  zlabel(perfs(gvs.PS,:));
  view(gvs.VA,30)
elseif comm==4 % 3-D mesh
  set(gcf,'name',['3-D mesh plot for ' gvs.id ' (' deblank(perfs(gvs.PS,:)) ')'])
  mesh(gvs.Xi1,gvs.Yi1,gvs.Zi1)
  eval(['colormap(' gvs.CM ');']);
  pcpos=min(get(gca,'zlim'));
  hold on
  hh=pcolor(gvs.Xi1,gvs.Yi1,gvs.Zi1);
  eval(['colormap(' gvs.CM ');']);
  shading interp
  xlabel(pars(gvs.Px,:));
  ylabel(pars(gvs.Py,:));
  zlabel(perfs(gvs.PS,:));
  hidden off
  set(hh,'zdata',get(hh,'zdata')+pcpos);
  axis tight
  view(gvs.VA,30);
end