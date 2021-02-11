%function pixel
%
% Joshua Kollat, Penn State University, Spring 2005

gvs=get(0,'userdata');
set(0,'units','pixels');
ss = get(0,'screensize'); sw=ss(3); sh=ss(4);
mct_fig = gvs.HH;

ww = floor(0.8*sw); wh = floor(0.8*sh); % figure out window size
iw = floor(0.9*ww); ih = floor(0.9*wh); % set the maximum image size for the plot

% Figure out the time step
if ~isempty(gvs.dt)
  ustr = 'minutes';
  if gvs.dt > 59 & gvs.dt < 1440
    ustr = 'hours'; gvs.dt = gvs.dt/60;
  elseif gvs.dt > 1439 & gvs.dt < 10079
    ustr = 'days'; gvs.dt = gvs.dt/1440;
  elseif gvs.dt > 10079 & gvs.dt < 40000
    ustr = 'weeks'; gvs.dt = gvs.dt/10080;
  elseif gvs.dt > 40000
    ustr = 'months'; gvs.dt = gvs.dt/10080;
  end
else
   ustr = 'samples';
end

if strcmp(ustr,'days')
    timeinterval = 365;
elseif strcmp(ustr,'weeks')
    timeinterval = 52;
elseif strcmp(ustr,'months')
    timeinterval = 12;
elseif strcmp(ustr,'minutes') % added on 20/03/2015
    disp('The data is not suitable for this type of plot!')
    return
end

numyears = length(gvs.obs)/timeinterval;
wholeyears = floor(numyears);
partyears = (numyears - wholeyears)*timeinterval;

perfs = str2mat(gvs.lhoods,gvs.vars);
lp = gvs.PS;

% CALCULATE LIKELIHOOD
of=gvs.dat(:,gvs.ff(1)+1:gvs.ff(1)+gvs.ff(2));  % criteria (low values indicate better models)
of=1-of; % likelihood (high values indicate more likely [probable] models)
for i = 1:size(of,2)
    if min(of(:,i))<0|min(of(:,i))==0, of(:,i)=of(:,i)-min(of(:,i))+1000*eps;end; % transform negative lhoods 
end

% Set the colormap limits to correspond with the observations and output
clims_out = [min(min(gvs.obs),min(min(gvs.mct,[],2))) max(max(gvs.obs),max(max(gvs.mct,[],2)))];
%caxis([log(clims_out(1)+1) log(clims_out(2)+1)]);
customcolor = feval('gray',64);

% Plot the observed values
p_obs = gvs.obs';

output = [gvs.mct' gvs.dat(:,1:gvs.ff(1)) of];
output = flipud(sortrows(output,size(gvs.obs)+gvs.ff(1)+lp));
numdat = floor((slider_value / 100) * size(gvs.dat));
output(numdat+1:size(gvs.dat),:) = [];
 
timeseries = axes('Position',[0.05 0.875 0.9 0.08]);
set(timeseries,'ActivePositionProperty','Position');
colormap(customcolor);
%caxis([log(clims(1)+1) log(clims(2)+1)]);
x = [1:1:size(p_obs,2)];
plot(x,p_obs,'k-');
axis tight;
title('Observed Time Series','FontSize',8);
set(timeseries,'XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[]);

color_timeseries = axes('Position',[0.05 0.8625 0.9 0.0125]);
set(color_timeseries,'ActivePositionProperty','Position');
caxis([log(clims_out(1)+1) log(clims_out(2)+1)]);
image(log(p_obs+1),'CDataMapping','scaled');
set(color_timeseries,'YTick',[],'FontSize',8);
%xlabel(ustr);

cbar = colorbar('peer',color_timeseries,'location','South');
%Because of a problem with matlab's default locating of tick marks...
set(cbar,'Position',[0.05 0.95 0.9 0.0125],'FontSize',8);
current_ticks = get(cbar,'XTick');
current_ticks = [0 current_ticks];
set(cbar,'XTick',current_ticks);
set(cbar,'XAxisLocation','bottom');
%%%%%%%%
c_label_increment = ...
    ((clims_out(2) - clims_out(1))/(length(get(cbar,'XTick'))-1));
c_labels = round([clims_out(1):c_label_increment:clims_out(2)]);
set(cbar,'XTickLabel',c_labels);

% Plots the model error
for i = 1:1:numdat
    p_error(i,:) = abs(output(i,1:size(gvs.obs,1))-p_obs);
end

%clims = [min(min(p_error,[],2)) max(max(p_error,[],2))];
%caxis([log(clims(1)+1) log(clims(2)+1)]);

pixel_plot = axes('Position',[0.05 0.05 0.9 0.75]);
colormap(customcolor);
caxis([log(clims_out(1)+1) log(clims_out(2)+1)]);
image(log(p_error+1),'CDataMapping','scaled');
title('Model Output Error','FontSize',8);
ylabel(['MCAT Simulations Sorted according to objective ' mat2str(perfs(lp,:))],'FontSize',8);
xlabel(ustr,'FontSize',8);
set(pixel_plot,'FontSize',8);

zoomfig = figure;
magnifyrecttofig(mct_fig,zoomfig);

    