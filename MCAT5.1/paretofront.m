function paretofront;

% function paretofront
%
% Plot the Pareto Front
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

% PLOT PARETO FRONT

figure

colors=str2mat('m.','b.','c.','r.','g.','y.','k.');

for i=1:1
   
   I = find(pranks(:,1)==i);
   plot(pranks(I,1+np+1),pranks(I,1+np+2),num2str(colors(i,:)));
   hold on;
   
end
