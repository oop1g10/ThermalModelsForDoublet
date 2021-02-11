function prange(ff,id,pars,lhoods,vars,dat,PS)

% function prange(ff,id,pars,lhoods,vars,dat,PS)
%
% Normalised Parameter Range Plots
%
% Thorsten Wagener, Imperial College London, April 2000

% load data
gvs=get(0,'userdata');
ff=gvs.ff;
id=gvs.id;
pars=gvs.pars;
lhoods=gvs.lhoods;
vars=gvs.vars;
dat=gvs.dat;
PS=gvs.PS;
pareto=gvs.pareto;
perfs=str2mat(lhoods,vars);
lp=PS;

signs=str2mat('b','c','m','y','r','g','k');

for k=1:ff(2)
   
   if k==1
      subplot(2,1,1);
   end
      
	of=gvs.dat(:,gvs.ff(1)+k);  % criteria (low values indicate better models)
	[y,I]=sort(of);
	par=dat(I,:);

	% normalise parameter values
	for i=1:ff(1)
	   npar(:,i)=(par(:,i)-min(par(:,i)))/(max(par(:,i))-min(par(:,i)));
	   if ~isempty(gvs.pareto)
	      npareto(:,i)=(pareto(:,i+1)-min(par(:,i)))/(max(par(:,i))-min(par(:,i)));
	   end
	end

	% plot pareto solutions
	if ~isempty(gvs.pareto)
		if k==1
		   plot(npareto(1,1:ff(1))','color',[.8 .8 .8],'linewidth',4);
		   hold on;
		end
	end

	% plot best individual solutions
	plot(npar(1,1:ff(1)),signs(k),'linewidth',4); hold on;

end

if ~isempty(gvs.pareto)
   legend1=str2mat('Pareto',str2mat(lhoods));
else
   legend1=str2mat(str2mat(lhoods));
end

legend(mat2str(legend1));

for k=1:ff(2)

	of=gvs.dat(:,gvs.ff(1)+k);  % criteria (low values indicate better models)
	[y,I]=sort(of);
	par=dat(I,:);

	% normalise parameter values
	for i=1:ff(1)
	   npar(:,i)=(par(:,i)-min(par(:,i)))/(max(par(:,i))-min(par(:,i)));
	   if ~isempty(gvs.pareto)
	      npareto(:,i)=(pareto(:,i+1)-min(par(:,i)))/(max(par(:,i))-min(par(:,i)));
	   end
	end

	% plot pareto solutions
	if ~isempty(gvs.pareto)
		if k==1
         area(max(npareto(:,1:ff(1)))','facecolor',[.8 .8 .8],'edgecolor',[.8 .8 .8]); hold on;
         area(min(npareto(:,1:ff(1)))','facecolor','w','edgecolor','w'); hold on;
		end
	end

   % plot best individual solutions
   plot(npar(1,1:ff(1)),signs(k),'linewidth',4);
   hold on;
      
   plot([1 1],[0 1],'k-');
   hold on;
   
   for i=1:ff(1)
      plot([i i],[0 1],'k--');
      hold on;
   end
      
   plot([ff(1) ff(1)],[0 1],'k-');
   hold on;

	plot(zeros(size(npar(1,1:ff(1)))),'k');
	hold on;
   
end

set(gca,'ylim',[0 1]);

np=1:ff(1);
set(gca,'xtick',np);
set(gca,'xticklabel',mat2str(pars));

set(gca,'ytick',[0 0.2 0.4 0.6 0.8 1]);

xlabel('Parameter Name');
ylabel('Normalised Range');
