function uncert

% function uncert
%
% GLUE variable uncertainty plots
%
% Matthew Lees, Imperial College London, June 1999

gvs   =get(0,'userdata');
ff    =gvs.ff;
id    =gvs.id;
pars  =gvs.pars;
lhoods=gvs.lhoods;
vars  =gvs.vars;
dat   =gvs.dat;
LS    =gvs.LS;
VS    =gvs.VS;

va    =dat(:,ff(1)+ff(2)+VS);
lh    =dat(:,ff(1)+LS);
nn    =find(lh<0);
lh(nn)=[];va(nn)=[];
lh    =lh/sum(lh); % scale to 1
[va,i]=sort(va);
lh    =lh(i);
% plot cumlative density
dx  =va;
dy  =cumsum(lh);
pcl =find(dy>gvs.lci);pcl=pcl(1);
pcu =find(dy>gvs.uci);pcu=pcu(1);
subplot(211)
plot(dx,dy,'b','linewidth',3);hold on;
plot(dx(pcl),dy(pcl),'d','markeredgecolor','k','markerfacecolor','c','markersize',10);hold on;
plot(dx(pcu),dy(pcu),'d','markeredgecolor','k','markerfacecolor','c','markersize',10);hold off;
axis([min(dx) max(dx) min(dy) max(dy)])
title(['Cumulative density plot ('...
      num2str(floor(gvs.lci*100)) '% Prediction Quantile = ' num2str(dx(pcl))...
      ', ' num2str(floor(gvs.uci*100)) '% Prediction Quantile = ' num2str(dx(pcu)) ')'])
ylabel('Likelihood')
% plot density
[n,x]=hist(va,20);
nc=1;
for i=1:length(n)
  cl(i)=sum(lh(nc:nc+n(i)-1));
  nc=nc+n(i);
end
subplot(212)
bar(x,cl,'b');
axis([min(dx) max(dx) min(cl) max(cl)+.1*(max(cl)-min(cl))])
title('Density plot')
xlabel(vars(VS,:))
ylabel('Likelihood')