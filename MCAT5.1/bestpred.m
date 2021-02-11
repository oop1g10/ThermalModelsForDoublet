function bestpred;

% function bestpred
%
% Calculation and plotting of best predictions
% with respect to the different objective functions used.
%
% Thorsten Wagener, Imperial College London, September 2001

% CALCULATE LIKELIHOOD
gvs=get(0,'userdata');

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

% PLOT FIGURE
if isempty(gvs.t),t=1:length(bestm);else,t=gvs.t;end

plot(t,gvs.obs,'o','markeredgecolor','k','markerfacecolor','b','markersize',5);hold on;

plot(t,bestm(:,1),'-','color','c');hold on;

if gvs.ff(2)>1
    plot(t,bestm(:,2),'-','color','m');hold on;
end
if gvs.ff(2)>2
    plot(t,bestm(:,3),'-','color','k');hold on;
end
if gvs.ff(2)>3
    plot(t,bestm(:,2),'-','color','g');hold on;
end
if gvs.ff(2)>4
    plot(t,bestm(:,2),'-','color','r');hold on;
end
if gvs.ff(2)>5
    plot(t,bestm(:,2),'-','color','b');hold on;
end
if gvs.ff(2)>6
    plot(t,bestm(:,2),'-','color','y');hold on;
end

title(['Model output and best predictions with respect to the different objective functions']);

ylabel('Output');
xlabel(['Time [' ustr ']']);

set(gca,'xlim',[min(t) max(t)]);

legend1=str2mat('Observed',str2mat(gvs.lhoods));
legend(mat2str(legend1));