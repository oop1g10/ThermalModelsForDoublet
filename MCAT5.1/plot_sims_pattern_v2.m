%function [params,objs] = plot_sims_pattern_v2();
%
% Joshua Kollat, Penn State University, Spring 2005

text('Interpreter','latex');
gvs=get(0,'userdata');

% Figure out the time step
if ~isempty(gvs.dt)
  ustr = 'Minutes';
  if gvs.dt > 59 & gvs.dt < 1440
    ustr = 'Hours'; gvs.dt = gvs.dt/60;
  elseif gvs.dt > 1439 & gvs.dt < 10079
    ustr = 'Days'; gvs.dt = gvs.dt/1440;
  elseif gvs.dt > 10079 & gvs.dt < 40000
    ustr = 'Weeks'; gvs.dt = gvs.dt/10080;
  elseif gvs.dt > 40000
    ustr = 'Months'; gvs.dt = gvs.dt/10080;
  end
else
   ustr = 'Samples';
end

if strcmp(ustr,'Days')
    timeinterval = 365;
elseif strcmp(ustr,'Weeks')
    timeinterval = 52;
elseif strcmp(ustr,'Months')
    timeinterval = 12;
end

numyears = length(gvs.obs)/timeinterval;
wholeyears = floor(numyears);
partyears = (numyears - wholeyears)*timeinterval;

perfs=str2mat(gvs.lhoods,gvs.vars);
lp=gvs.PS;

%Simulation Plots

figure;
plot_count = 1;

% CALCULATE LIKELIHOOD

of=gvs.dat(:,gvs.ff(1)+1:gvs.ff(1)+gvs.ff(2));  % criteria (low values indicate better models)
of=1-of; % likelihood (high values indicate more likely [probable] models)
for i = 1:size(of,2)
    if min(of(:,i))<0|min(of(:,i))==0, of(:,i)=of(:,i)-min(of(:,i))+1000*eps;end; % transform negative lhoods
end

for objective = 1:1:gvs.ff(1,2)
    
    % Set up the observations and outputs
    
    output_temp = [gvs.mct gvs.dat(:,1:gvs.ff(1)) of];
    output_temp = flipud(sortrows(output_temp,size(gvs.obs)+gvs.ff(1)+objective));

    k = 1;
    for i = 1:1:wholeyears
        for j = 1:1:timeinterval
            p_obs(i,j) = gvs.obs(k);
            p_output(i,j) = output_temp(1,k);
            p_error(i,j) = abs(gvs.obs(k) - output_temp(1,k));
            k = k + 1;
        end
    end

    for i = 1:1:partyears
        p_obs(wholeyears+1,i) = gvs.obs(k);
        p_output(wholeyears+1,i) = output_temp(1,k);
        p_error(wholeyears+1,i) = abs(gvs.obs(k) - output_temp(1,k));
        k = k + 1;
    end

    blank(1:(timeinterval-partyears)) = [NaN];
    p_obs(wholeyears+1,partyears+1:1:timeinterval) = [NaN];
    p_output(wholeyears+1,partyears+1:1:timeinterval) = [NaN];
    p_error(wholeyears+1,partyears+1:1:timeinterval) = [NaN];

    % Plot

    clims_out = [min(min(gvs.obs),min(min(gvs.mct,[],2))) max(max(gvs.obs),max(max(gvs.mct,[],2)))];
    %caxis([log(clims_out(1)+1) log(clims_out(2)+1)]);
    %customcolor = feval('jet',256);
    %colormap(customcolor);
    colormap('jet');
    
    observed1 = subplot(3,3,plot_count);
    caxis(observed1,[log(clims_out(1)+1) log(clims_out(2)+1)]);
    image(log(p_obs+1),'CDataMapping','scaled');
    %colormap('gray');
    %axes('Position',get(gca,'Position'));
    image([255 255 255],'XData',[partyears+1:1:timeinterval],'YData',[wholeyears+1]);
    %set(get(gca),'YAxisLocation','right','Color','none','XTickLabel',[])
    xlim([1 timeinterval]);
    ylim([1 wholeyears+1]);
    xlabel('Day'); ylabel('Year'); title('Observed');
    set(observed1,'YDir','normal');
    plot_count = plot_count+1;
    output1 = subplot(3,3,plot_count);
    caxis(output1,[log(clims_out(1)+1) log(clims_out(2)+1)]);
    image(log(p_output+1),'CDataMapping','scaled');
    xlabel('Day'); ylabel('Year'); title('Output');
    set(output1,'YDir','normal');
    plot_count = plot_count+1;
    error1 = subplot(3,3,plot_count);
    caxis(error1,[log(clims_out(1)+1) log(clims_out(2)+1)]);
    image(log(p_error+1),'CDataMapping','scaled');
    xlabel('Day'); ylabel('Year'); title('Error');
    set(error1,'YDir','normal');
    plot_count = plot_count+1;
end


