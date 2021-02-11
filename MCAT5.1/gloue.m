function gloue;

% function gloue
%
% Calculation and plotting of GLUE confidence limits
%
% Thorsten Wagener & Matthew Lees, Imperial College London, May 2000

% CALCULATE LIKELIHOOD
gvs=get(0,'userdata');
of=gvs.dat(:,gvs.ff(1)+gvs.LS);  % criteria (low values indicate better models)
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
bestm=gvs.mct(:,cc);

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

% CALCULATE CONFIDENCE LIMITS AND MEAN VALUES FOR EACH TIME STEP

% create objective function matrix
[ndt,junk] =size(gvs.mct);
of_matrix_1=of(:,ones(1,ndt))';    % Tony's trick
of_matrix_2=of_matrix_1;           % Intialisation
[sq,index] =sort(gvs.mct');
sq         =sq';
index      =index';
S          =size(of_matrix_1);
for i=1:S(1)
   for j=1:S(2)
      of_matrix_2(i,j)=of_matrix_1(i,index(i,j));
   end
end

% create mean and CIs
for i=1:ndt
   pcsof(i,:)=cumsum(of_matrix_2(i,:))./sum(of_matrix_2(i,:));
   cc=find(pcsof(i,:)<gvs.lci);pclci(i)=sq(i,max(cc));
   cc=find(pcsof(i,:)>gvs.uci);pcuci(i)=sq(i,min(cc));
   %pclci(i)  =interp1(pcsof(i,:),sq(i,:),gvs.lci);
   %pcuci(i)  =interp1(pcsof(i,:),sq(i,:),gvs.uci);
   mq(i)     =mean(sq(i,:));
end

% calculate the (normalized) width of the confidence limits
dq=(pcuci-pclci)./(max(pcuci-pclci));

% PLOT FIGURE
if isempty(gvs.t),t=1:length(bestm);else,t=gvs.t;end
subplot('position',[0.13 0.22 .775 .7]);
area(t,pcuci,'faceColor',[.8 .8 .8],'edgeColor','k');hold on;
area(t,pclci,'faceColor','w','edgeColor','k');hold on;
if ~isempty(gvs.obs),plot(t,gvs.obs,'o','markeredgecolor','k','markerfacecolor','b','markersize',5);hold on;end
%plot(t,bestm,'k--','linewidth',2);
set(gca,'xlim',[min(t) max(t)]);
legend('Observed','Confidence Limits',0)
title(['Model output and associated confidence limits' ' (UCI=' num2str(gvs.uci) ', LCI=' num2str(gvs.lci) ')']);
set(gca,'xticklabel',' ');

subplot('position',[0.13 0.11 .775 .1]);
area(t,dq,'facecolor',[0.8 0.8 0.8],'edgecolor','k');
xlabel(['Time [' ustr ']']);
ylabel('dCFL');
set(gca,'xlim',[min(t) max(t)]);

