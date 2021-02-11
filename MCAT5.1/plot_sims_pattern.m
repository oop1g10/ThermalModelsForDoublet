function [params,objs] = plot_sims(sims);
%
% Joshua Kollat, Penn State University, Spring 2005

text('Interpreter','latex');
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

perfs=str2mat(gvs.lhoods,gvs.vars);
lp=gvs.PS;

% CALCULATE LIKELIHOOD
of=gvs.dat(:,gvs.ff(1)+1:gvs.ff(1)+gvs.ff(2));  % criteria (low values indicate better models)
of=1-of; % likelihood (high values indicate more likely [probable] models)
for i = 1:size(of,2)
    if min(of(:,i))<0|min(of(:,i))==0, of(:,i)=of(:,i)-min(of(:,i))+1000*eps;end; % transform negative lhoods 
end

% Set up the observations and outputs
%p_obs = gvs.obs';
output_temp = [gvs.mct gvs.dat(:,1:gvs.ff(1)) of];
output_temp = flipud(sortrows(output_temp,size(gvs.obs)+gvs.ff(1)+lp));

% Set up the model error matrix for the selected simulations
% for i = 1:1:size(sims)
%     p_error(i,:) = abs(output(sims(i),1:size(gvs.obs,1))-p_obs);
%     params(i,:) = output(sims(i),size(gvs.obs,1)+1:size(gvs.obs,1)+gvs.ff(1));
%     objs(i,:) = output(sims(i),size(gvs.obs,1)+gvs.ff(1)+1:size(gvs.obs,1)+gvs.ff(1)+gvs.ff(2));
% end

%Simulation Plots

figure;
plot_count = 1;

for simulation = 1:1:size(sims)
    k = 1;
    for i = 1:1:wholeyears
        for j = 1:1:timeinterval
            p_obs(i,j) = gvs.obs(k);
            p_output(i,j) = output_temp(sims(simulation),k);
            p_error(i,j) = abs(gvs.obs(k) - output_temp(sims(simulation),k));
            k = k + 1;
        end
    end

    for i = 1:1:partyears
        p_obs(wholeyears+1,i) = gvs.obs(k);
        p_output(wholeyears+1,i) = output_temp(sims(simulation),k);
        p_error(wholeyears+1,i) = abs(gvs.obs(k) - output_temp(sims(simulation),k));
        k = k + 1;
    end

    %p_obs(wholeyears+1,partyears+1:1:timeinterval) = [NaN];
    %p_output(wholeyears+1,partyears+1:1:timeinterval) = [NaN];
    %p_error(wholeyears+1,partyears+1:1:timeinterval) = [NaN];

    % Plot

    clims_out = [min(min(gvs.obs),min(min(gvs.mct,[],2))) max(max(gvs.obs),max(max(gvs.mct,[],2)))];
    caxis([log(clims_out(1)+1) log(clims_out(2)+1)]);

    observed1 = subplot(5,3,plot_count);
    caxis(observed1,[log(clims_out(1)+1) log(clims_out(2)+1)]);
    image(log(p_obs+1),'CDataMapping','scaled');
    xlabel('Day'); ylabel('Year'); title('Observed');
    set(observed1,'YDir','normal');
    plot_count = plot_count+1;
    output1 = subplot(5,3,plot_count);
    caxis(output1,[log(clims_out(1)+1) log(clims_out(2)+1)]);
    image(log(p_output+1),'CDataMapping','scaled');
    xlabel('Day'); ylabel('Year'); title('Output');
    set(output1,'YDir','normal');
    plot_count = plot_count+1;
    error1 = subplot(5,3,plot_count);
    caxis(error1,[log(clims_out(1)+1) log(clims_out(2)+1)]);
    image(log(p_error+1),'CDataMapping','scaled');
    xlabel('Day'); ylabel('Year'); title('Error');
    set(error1,'YDir','normal');
    plot_count = plot_count+1;
end


