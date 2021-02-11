function [params,objs] = plot_sims(sims);
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

% Plot

clims_error = [min(min(p_error,[],2)) max(max(p_error,[],2))];
clims_out = [min(min(gvs.obs),min(min(gvs.mct,[],2))) max(max(gvs.obs),max(max(gvs.mct,[],2)))];
caxis([log(clims_out(1)+1) log(clims_out(2)+1)]);

figure;

first = axes('Position',[0.07 0.84 0.9 0.075]);
caxis([log(clims_out(1)+1) log(clims_out(2)+1)]);
p = [p_obs; output(sims(1),1:size(gvs.obs,1)); p_error(1,:)];
image(log(p+1),'CDataMapping','scaled');
set(first,'YTick',[1 2 3],'YTickLabel','Observed|Ouput|Error','FontSize',8);
sim_label = ['Simulation ' num2str(sims(1))];
title(sim_label,'Fontsize',8);
clear p;

cbar = colorbar('peer',first,'location','North');
set(cbar,'Position',[0.07 0.97 0.9 0.02],'FontSize',8);
c_label_increment = ...
    ((clims_out(2) - clims_out(1))/(length(get(cbar,'XTick'))-1));
c_labels = round([clims_out(1):c_label_increment:clims_out(2)]);
set(cbar,'XTickLabel',c_labels);

second = axes('Position',[0.07 0.7 0.9 0.075]);
caxis([log(clims_out(1)+1) log(clims_out(2)+1)]);
p = [p_obs; output(sims(2),1:size(gvs.obs,1)); p_error(2,:)];
image(log(p+1),'CDataMapping','scaled');
set(second,'YTick',[1 2 3],'YTickLabel','Observed|Ouput|Error','FontSize',8);
sim_label = ['Simulation ' num2str(sims(2))];
title(sim_label,'Fontsize',8);
clear p;

third = axes('Position',[0.07 0.55 0.9 0.075]);
caxis([log(clims_out(1)+1) log(clims_out(2)+1)]);
p = [p_obs; output(sims(3),1:size(gvs.obs,1)); p_error(3,:)];
image(log(p+1),'CDataMapping','scaled');
set(third,'YTick',[1 2 3],'YTickLabel','Observed|Ouput|Error','FontSize',8);
sim_label = ['Simulation ' num2str(sims(3))];
title(sim_label,'Fontsize',8);
clear p;

fourth = axes('Position',[0.07 0.4 0.9 0.075]);
caxis([log(clims_out(1)+1) log(clims_out(2)+1)]);
p = [p_obs; output(sims(4),1:size(gvs.obs,1)); p_error(4,:)];
image(log(p+1),'CDataMapping','scaled');
set(fourth,'YTick',[1 2 3],'YTickLabel','Observed|Ouput|Error','FontSize',8);
sim_label = ['Simulation ' num2str(sims(4))];
title(sim_label,'Fontsize',8);
clear p;

fifth = axes('Position',[0.07 0.25 0.9 0.075]);
caxis([log(clims_out(1)+1) log(clims_out(2)+1)]);
p = [p_obs; output(sims(5),1:size(gvs.obs,1)); p_error(5,:)];
image(log(p+1),'CDataMapping','scaled');
set(fifth,'YTick',[1 2 3],'YTickLabel','Observed|Ouput|Error','FontSize',8);
sim_label = ['Simulation ' num2str(sims(5))];
title(sim_label,'Fontsize',8);
clear p;

clear sim_label;
summary = axes('Position',[0.07 0.05 0.9 0.125]);
caxis([log(clims_out(1)+1) log(clims_out(2)+1)]);
%p = [p_obs; output(sims(5),1:size(gvs.obs,1)); p_error(5,:)];
image(log(p_error+1),'CDataMapping','scaled');
for i = 1:1:size(sims)
    sim_label(i) = cellstr(['Sim ' num2str(sims(i))]);
end
set(summary,'YTick',[1 2 3 4 5],'YTickLabel',[sim_label(1) sim_label(2) sim_label(3) sim_label(4) sim_label(5)],'FontSize',8);
title('Error','Fontsize',8);
%clear p;


