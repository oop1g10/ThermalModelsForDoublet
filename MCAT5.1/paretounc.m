function paretounc;

% function paretounc
%
% Plot the Pareto Uncertainty Bounds
%
% Thorsten Wagener, Imperial College London, October 1999

% READ DATA
gvs	= get(0,'userdata');
dat   = gvs.dat;
mct   = gvs.mct';
np    = gvs.ff(1);
obs   = gvs.obs;

% READ OR IDENTIFY PARETO RANKING
if ~isempty(gvs.pareto)
   pranks = gvs.pareto;
else
   [pranks]=pareto;
end

temp_pop = pranks(:,2:(1+np));
pop      = dat(:,1:np);

% FIND FLOW SERIES CORRESPONDING TO PARETO SET
for i=1:size(pranks,1);
   
   [I,J] = find (temp_pop(i,1)==pop(:,1)); 
   pos(i)= I;
   
end
paretoflow = mct(pos,:);

for i=1:size(paretoflow,2);  % find the pareto boundary values
   
   maxp(i) = max(paretoflow(:,i));
   minp(i) = min(paretoflow(:,i));
   
end

for i=1:size(mct,2);  % find the absolute boundary values
   
   maxf(i) = max(mct(:,i));
   minf(i) = min(mct(:,i));
   
end

% PLOT INITIAL-, PARETO- AND OBSERVED-FLOW
if isempty(gvs.t),t=1:size(paretoflow,2);else,t=gvs.t;end

area(t,maxf,'faceColor',[0.8 0.8 0.8],'edgeColor','k');hold on;
plot(t,obs,'o','markersize',5,'MarkerEdgeColor','k','MarkerFaceColor','b');hold on;  % observed time series
area(t,maxp,'faceColor','c','edgeColor','k');hold on;
legend('Observed','Initial Population','Pareto Population');

area(t,maxf,'faceColor',[0.8 0.8 0.8],'edgeColor','k');hold on;
plot(t,maxf,'k');hold on;

area(t,maxp,'faceColor','c','edgeColor','k');hold on;
plot(t,maxp,'k');hold on;
area(t,minp,'faceColor',[0.8 0.8 0.8],'edgeColor','k');hold on;
plot(t,minp,'k'); hold on;

area(t,minf,'faceColor','w','edgeColor','k');hold on;
plot(t,minf,'k');hold on;

plot(t,obs,'o','markersize',5,'MarkerEdgeColor','k','MarkerFaceColor','b');  % observed time series

xlabel('Time Step');
ylabel('Output');

   