function sensi(plotParams) % plotParams options added by Pedchenko)

% function sensi(ff,id,pars,lhoods,vars,dat,PS)
%
% GLUE sensitivity plots
%
% Matthew Lees & Thorsten Wagener, Imperial College London, May 2000

    gvs=get(0,'userdata');
    ff=gvs.ff;
    id=gvs.id;
    pars=gvs.pars;
    lhoods=gvs.lhoods;
    vars=gvs.vars;
    dat=gvs.dat;
    PS=gvs.PS;

    perfs=str2mat(lhoods,vars);
    lp=PS;

    % calculate likelihood
    of=gvs.dat(:,gvs.ff(1)+lp);  % criteria (low values indicate better models)
    of=of./max(of); % normalise of
    of=1-of; % likelihood (high values indicate more likely [probable] models)
    if min(of)<0|min(of)==0, of=of-min(of)+1000*eps;end; % transform negative lhoods

    % sort data according to selected perf
    [y,i]=sort(of);
    dat=dat(i,:);
    cls=floor(length(dat)/10);
    tmx=zeros(cls,10);tmy=tmx;

    if ff(1)<=4
      subp='2,2,';
    elseif ff(1)>4&ff(1)<=9
       subp='3,3,';
    elseif ff(1)>9&ff(1)<=12
       subp='4,3,';
    else %ff(1)>12&ff(1)<=16
       subp='4,4,';
    end

    set(gcf,'DefaultAxesColorOrder',cool(10));
    for i=1:ff(1)
      if ff(1)>1,eval(['subplot(' subp num2str(i) ')']),end
      for j=1:10
        tm=dat(cls*(j-1)+1:cls*j,i);
        tm=sort(tm);
        tmx(:,j)=tm;
        tmy=(1:length(tmx))/cls;
      end
      plot(tmx,tmy,'linewidth',1);hold on;
      plot(tmx(:,10),tmy,'m','linewidth',3);hold on;
      plot(tmx(:,1),tmy,'c','linewidth',3);hold off;
      axis([min(min(tmx)) max(max(tmx)) min(min(tmy)) max(max(tmy))]);
      xlabel(pars(i,:))
      if i==1
         temp=deblank(perfs(lp,:));
         ylabel(['cum. norm. ' temp ''])
     end

    end
    colormap(cool(10));
    h1=axes('position',[.96 .117 .02 .33]);
    h1.Visible = 'off'; % Do not show scale for likelyhood, Pedchenko
    h=colorbar(h1);
    %set(h,'ytick',[2 10]);
    set(h,'ytick',[0.1 0.9]);  % Pedchenko
    set(h,'yticklabel',['L';'H']);
    set(h,'yaxislocation','left');
    %set(get(gca,'ylabel'),'verticalalignment','top'); % Pedchenko
    temp=deblank(perfs(lp,:));
    %ylabel(['Likelihood(' temp ')'])
    ylabel(h, ['Likelihood(' temp ')'])  % Pedchenko
    
    % Apply the options for saving (Pedchenko)
    if plotParams.plotSave
        plotName = sprintf('Sensi1_%s', temp );
        saveFig([plotParams.plotExportPath plotName])
    end   
end