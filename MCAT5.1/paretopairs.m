function paretopairs(pranks,np);

% function paretopairs(pranks,np)
%
% Plot the Pareto Pairs of two Parameters 
%
% Thorsten Wagener, Imperial College London, October 1999

% READ DATA
gvs	= get(0,'userdata');
dat   = gvs.dat;
mct   = gvs.mct';
np    = gvs.ff(1);
obs   = gvs.obs;

% READ OR PRODUCE PARETO RANKING
if ~isempty(gvs.pareto)
   pranks = gvs.pareto;
else
   [pranks]=pareto;
end

temp_pop = pranks(:,2:(1+np));
pop      = dat(:,1:np);

% PLOT PARAMETER PAIRS

figure

colors=str2mat('m.','b.','c.','r.','g.','y.','k.');

I1 = find(pranks(:,1+np+1)==min(pranks(:,1+np+1)));
I2 = find(pranks(:,1+np+2)==min(pranks(:,1+np+2)));

best1 = pranks(I1,:);
best2 = pranks(I2,:);

set(gcf,'defaultlinemarkersize',50);
plot(best1(1+1),best1(1+2),'c.');
hold on;
plot(best2(1+1),best2(1+2),'c.');
set(gcf,'defaultlinemarkersize',50);
hold on;

set(gcf,'defaultlinemarkersize','default');

for i=1:7
   
   I = find(pranks(:,1)==i);
   plot(pranks(I,1+1),pranks(I,1+2),num2str(colors(i,:)));
   hold on;
   
end

