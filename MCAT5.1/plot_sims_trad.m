function [params,objs] = plot_sims_trad(sims);
%
% Joshua Kollat, Penn State University, Spring 2005

gvs=get(0,'userdata');

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

perfs=str2mat(gvs.lhoods,gvs.vars);
lp=gvs.PS;

% CALCULATE LIKELIHOOD
% CALCULATE LIKELIHOOD
of=gvs.dat(:,gvs.ff(1)+1:gvs.ff(1)+gvs.ff(2));  % criteria (low values indicate better models)
of=1-of; % likelihood (high values indicate more likely [probable] models)
for i = 1:size(of,2)
    if min(of(:,i))<0|min(of(:,i))==0, of(:,i)=of(:,i)-min(of(:,i))+1000*eps;end; % transform negative lhoods 
end

% Set up the observations and outputs
p_obs = gvs.obs';
output = [gvs.mct' gvs.dat(:,1:gvs.ff(1)) of];
output = flipud(sortrows(output,size(gvs.obs)+gvs.ff(1)+lp));

% Set up the model error matrix for the selected simulations
for i = 1:1:size(sims)
    p_error(i,:) = abs(output(sims(i),1:size(gvs.obs,1))-p_obs);
    params(i,:) = output(sims(i),size(gvs.obs,1)+1:size(gvs.obs,1)+gvs.ff(1));
    objs(i,:) = output(sims(i),size(gvs.obs,1)+gvs.ff(1)+1:size(gvs.obs,1)+gvs.ff(1)+gvs.ff(2));
end

mct_fig = figure;
hold on;
x = [1:1:size(p_obs,2)];
plot(x,p_obs,'k-');
plot(x,output(sims(1),1:size(p_obs,2)),'r--');
plot(x,output(sims(2),1:size(p_obs,2)),'g--');
plot(x,output(sims(3),1:size(p_obs,2)),'b--');
plot(x,output(sims(4),1:size(p_obs,2)),'m--');
plot(x,output(sims(5),1:size(p_obs,2)),'c--');
for i = 1:1:size(sims)
    sim_label(i) = cellstr(strcat('Sim ',num2str(sims(i))));
end
legend('Observed',...
    strcat('Sim',num2str(sims(1))),...
    strcat('Sim',num2str(sims(2))),...
    strcat('Sim',num2str(sims(3))),...
    strcat('Sim',num2str(sims(4))),...
    strcat('Sim',num2str(sims(5))));
hold off;

zoomfig = figure;
magnifyrecttofig(mct_fig,zoomfig);

