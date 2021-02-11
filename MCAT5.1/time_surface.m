function time_surface;
%
% Joshua Kollat, Penn State University, Spring 2005

gvs=get(0,'userdata');
PS = gvs.PS;

for ii=1:gvs.ff(2)

    of=gvs.dat(:,gvs.ff(1)+ii);  % criteria (low values indicate better models)
    of=1-of; % likelihood (high values indicate more likely [probable] models)
    if min(of)<0, of=of-min(of);end; % transform negative lhoods
    if min(of)==0 % move slightly above zero so that the CFD is monotonic 
       [junk]=sort(of);
       cc=find(junk>0);cc=min(cc);
       of=of+junk(cc);
    end
    of=of./max(of); % scaling from 0 to 1

    % BEST MODEL
    cc=find(of==max(of));
    if length(cc)==1
        bestm(:,ii)=gvs.mct(:,cc);
    else
        bestm(:,ii)=gvs.mct(:,cc(1));
    end
    
    clear cc of
    
end

% TIME STEP
if ~isempty(gvs.dt)
  ustr='minutes';
  if gvs.dt>59&gvs.dt<1440
    ustr='hours';gvs.dt=gvs.dt/60;
  elseif gvs.dt>1439&gvs.dt<10079
    ustr='days';gvs.dt=gvs.dt/1440;
  elseif gvs.dt>10079&gvs.dt<40000
    ustr='weeks';gvs.dt=gvs.dt/10080;
  elseif gvs.dt>40000
    ustr='months';gvs.dt=gvs.dt/10080;
  end
else
   ustr='samples';
end

if strcmp(ustr,'minutes') && length(gvs.obs) < 1050000
    disp('The data is not suitable for this type of plot!');
    return;
elseif strcmp(ustr,'hours') && length(gvs.obs) < 17500
    disp('The data is not suitable for this type of plot!');
    return;
elseif strcmp(ustr,'days') && length(gvs.obs) < 730
    disp('The data is not suitable for this type of plot!');
    return;
elseif strcmp(ustr,'weeks') && length(gvs.obs) < 104
    disp('The data is not suitable for this type of plot!');
    return;
elseif strcmp(ustr,'months') && length(gvs.obs) < 24
    disp('The data is not suitable for this type of plot!');
    return;
end

if strcmp(ustr,'days')
    timeinterval = 365;
elseif strcmp(ustr,'weeks')
    timeinterval = 52;
elseif strcmp(ustr,'months')
    timeinterval = 12;
end

numyears = length(gvs.obs)/timeinterval;
wholeyears = floor(numyears);
partyears = (numyears - wholeyears)*timeinterval;

%need to change this to user selected
obj = PS;

k = 1
for i = 1:1:wholeyears
    for j = 1:1:timeinterval
        Z_obs(i,j) = gvs.obs(k);
        Z_error(i,j) = abs(gvs.obs(k) - gvs.mct(k,obj));
        k = k + 1;
    end
end

for i = 1:1:partyears
    Z_obs(wholeyears+1,i) = gvs.obs(k);
    Z_error(wholeyears+1,i) = abs(gvs.obs(k) - gvs.mct(k,obj));
    k = k + 1;
end

Z_obs(wholeyears+1,partyears+1:1:timeinterval) = [NaN];
Z_error(wholeyears+1,partyears+1:1:timeinterval) = [NaN];

%Z_obs = flipud(Z_obs);

figure;

% This plots the data using a surface
%surf(Z_obs);

% This plots the data using bars
% [X,Y]=meshgrid(1:timeinterval,1:wholeyears+1);
% scatterbar3(X,Y,Z_obs,Z_error,0.25);
% set(gcf,'EdgeColor','none','CData',Z_error);

% This plots the data using 3d areas
X = meshgrid(1:timeinterval);
Y = [1:wholeyears+1];
% Options settings for the area3 function
area3options=struct('barwidth',0.3,'ColormapWall','jet',...
                     'ColormapRoof','jet','FacealphaWall',1,...
                     'FacealphaRoof',1,'FacealphaFloor',1,...
                     'SurfRoof',1,'LegendSym','wall','LegendText',[],...
                     'TScaling',[1 1; 0.6 0.6; 1 1],...
                     'Edgecolor','none','Linestyle','-');
[h options] = area3(X,Y,Z_obs,log(Z_error+1),area3options);

axis normal;
cbar = colorbar;
c_label_increment = ...
    (max(max(Z_error)) - min(min(Z_error)))/(length(get(cbar,'YTick'))-1);
c_labels = round([min(min(Z_error)):c_label_increment:max(max(Z_error))]);
set(cbar,'YTickLabel',c_labels,'XTick',0.5,'XTickLabel','Output Error');

grid on;

if strcmp(ustr,'minutes') xlabel('Minutes'); end;
if strcmp(ustr,'hours') xlabel('Hours'); end;
if strcmp(ustr,'days') xlabel('Days'); end;
if strcmp(ustr,'weeks') xlabel('Weeks'); end;
if strcmp(ustr,'months') xlabel('Months'); end;
ylabel('Years');
zlabel('Observed Output');

%explore3d(gca);
%magnifyrecttofig('m');

    