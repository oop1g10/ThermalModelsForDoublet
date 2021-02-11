% function correlmatrix
%
% Joshua Kollat, Penn State University, Spring 2005

% SETTINGS
pranks  =[];
[n junk]=size(gvs.pars);

PS = gvs.PS;
ff = gvs.ff;
dat = gvs.dat;

%Calc all values for the correlation plots in 1% threshold increments
for i = 1:1:100
    dat_temp = sortrows(dat,ff(1)+PS);
    numdat = floor((i / 100) * size(dat,1));
    % Check for enough data to calc correl.
    if numdat > 1
        dat_temp(numdat+1:size(dat,1),:) = [];
        pair = 1;
        % Go through all parameter pairs for current threshold and calc
        % correl.
        for j = 1:n
            for k = 1:n
                if j ~= k && k > j
                    xcrit = dat_temp(:,k);
                    ycrit = dat_temp(:,j);
                    CC_temp = corrcoef(xcrit,ycrit);
                    CC(i,pair) = CC_temp(1,2);
                    pair = pair + 1;
                end
            end
        end
        clear dat_temp;
    else
        % if there wasn't enough data to calc correl.
        CC(i,:) = NaN;
        continue;
    end
end

%Eliminate data that is below the slider threshold
dat = sortrows(dat,ff(1)+PS);
if ~isempty(slider_value),
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
% if isempty(gvs.pareto)
%    gvs.pareto = pareto;
% end

%pranks = gvs.pareto;

% Plot Parameter Correlation Matrix
pair = 1;
for i=1:n
  for j=1:n
    eval(['subplot(' num2str(n) ',' num2str(n) ',' num2str(((i-1)*n)+j) ')'])    
            
    xcrit=dat(:,j);
    ycrit=dat(:,i);
   
    totalcrit=dat(:,1);
    
    if j==i
        plot(xcrit(1),ycrit(1),'w.','MarkerSize',.3);
        h1 = gca;
        %LH1=legend(unpad(gvs.pars(j,:),' ','e'),2); %10.1.2018 Pedchenko Not working
        LH1=legend(unpad(gvs.pars(j,:),' ','e')); %corrected
        %set(LH1,'box','off','xcolor','w','ycolor','w','fontsize',10,'fontweight','bold');
        set(LH1,'box','off','fontsize',10,'fontweight','bold')
    elseif j>i
        % plot correlation
        plot(CC(:,pair),[1:1:100],'-k');
        hold on;
        % plot correlation at current threshold
        if ~isempty(slider_value),
        plot([-1 1],[slider_value slider_value],'-r');end
        % calc the correlation coefficient to display
        CC_single=corrcoef(xcrit,ycrit);
        grid on;
        % Set up a new set of axes to position correlation coefficient
        % label
        h1 = gca;
        h2 = axes('Position',get(h1,'Position'));
        set(h2,'XAxisLocation','bottom','Color','none','XTick',[0],'YTick',[],'XTickLabel',num2str(CC_single(1,2)),'YTickLabel',[]);
        set(h2,'XLim',get(h1,'XLim'),'YLim',get(h1,'YLim'),'Layer','bottom');
        pair = pair + 1;
        hold off;
    else
        plot(xcrit,ycrit,'o','MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',3);
        h1 = gca;  
        
        %Plot pareto parameters
%         if ~isempty(gvs.pareto)
%        		hold on;
%        		xpareto=pranks(:,1+j);
%        		ypareto=pranks(:,1+i);
%        		plot(xpareto,ypareto,'d','MarkerEdgeColor','k','MarkerFaceColor','c','MarkerSize',5);
%        		hold off;
%         end
    end
    
    % Remove all axis labels where needed
    if (j > 1 && j < n && i > 1 && i < n) || j == i
        set(h1,'XTickLabel','||','YTickLabel','||');
    end
    if j == 1 && i ~= n, set(h1,'XTickLabel','||'), end
    if j == n && i ~= 1, set(h1,'XTickLabel','||','YAxisLocation','right'), end
    if i == 1 && j ~= n, set(h1,'YTickLabel','||','XAxisLocation','top'), end
    if i == n && j ~= 1, set(h1,'YTickLabel','||'), end
    if i == 1 && j == n, set(h1,'YAxisLocation','right','XAxisLocation','top'), end
  end
end

