% function multiobj
%
% mulit-objective dotty plots
%
% Thorsten Wagener, Imperial College London, July 1999

dat=gvs.dat;
ff=gvs.ff;
PS=gvs.PS;

% SETTINGS
pranks  =[];
[n junk]=size(gvs.lhoods);

%Eliminate data that is below the slider threshold
dat = sortrows(dat,ff(1)+PS);
if ~isempty(slider_value) %if introduced in 20/03/2015
numdat = floor((slider_value / 100) * size(dat));
dat(numdat+1:size(dat),:) = [];end

if n > 4 & n < 7
   set(gcf,'defaultaxesfontsize',8)
elseif n > 7
  set(gcf,'defaultaxesfontsize',6)
else
  set(gcf,'defaultaxesfontsize',10)
end

% READ PARETO RANKING
if ~isempty(gvs.pareto)
   gvs.pareto = pareto;
   pranks = gvs.pareto;
end

% PLOT MULTI OJECTIVE PLOTS
for i=1:n
  for j=1:n
    eval(['subplot(' num2str(n) ',' num2str(n) ',' num2str(((i-1)*n)+j) ')'])    
            
    xcrit=dat(:,ff(1)+j);
    ycrit=dat(:,ff(1)+i);
   
    totalcrit=dat(:,ff(1));
    
    if j==i
        plot(xcrit(1),ycrit(1),'w.','MarkerSize',.3);
        LH1=legend(unpad(gvs.lhoods(j,:),' ','e'),2);
        LH1.Box='off';LH1.FontSize=10;LH1.FontWeight='bold';LH1.Color='w';
        %set(LH1,'box','off','xcolor','w','ycolor','w','fontsize',10,'fontweight','bold');
        %above not valid any longer on legend objects 20/03/2015
    elseif j>i
        plot(xcrit(1),ycrit(1),'w.','MarkerSize',.3);
        CC=corrcoef(xcrit,ycrit);
        LH1=legend(num2str(CC(1,2)),2);
        LH1.Box='off';LH1.FontSize=10;LH1.FontWeight='bold';
        %set(LH1,'box','off','xcolor','w','ycolor','w','fontsize',10,'fontweight','bold');        
    else
        plot(xcrit,ycrit,'o','MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',3);
        
        if ~isempty(gvs.pareto)
       		hold on;
       		xpareto=pranks(:,1+ff(1)+j);
       		ypareto=pranks(:,1+ff(1)+i);
       		plot(xpareto,ypareto,'d','MarkerEdgeColor','k','MarkerFaceColor','c','MarkerSize',5);
       		hold off;
        end
        
    end
    
    if j~=1
      set(gca,'ytick',[])
    end
    if i==j, set(gca,'ytick',[]), end
    if i<n, set(gca,'xtick',[]), end
    if j==n, set(gca,'xtick',[]), end
  end
end

