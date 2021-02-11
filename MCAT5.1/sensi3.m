function sensi2(ff,id,pars,lhoods,vars,dat,PS)

% function sensi(ff,id,pars,lhoods,vars,dat,PS)
%
% Sensitivity Plots
%
% Thorsten Wagener, Penn State, October 2004

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

for lp=1:ff(2)

% calculate likelihood
of=dat(:,ff(1)+lp);  % criteria (low values indicate better models)
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

for i=1:ff(1)
  if ff(1)>1,eval(['subplot(' subp num2str(i) ')']),end
  for j=1:10
    tm=dat(cls*(j-1)+1:cls*j,i);
    tm=sort(tm);
    tmx(:,j)=tm;
    tmy=(1:length(tmx))/cls;
  end

  if lp==1
      plot([min(min(tmx)) max(max(tmx))],[0 1],'c','linewidth',2); hold on;
  end
  
  if lp==1
      plot(tmx(:,10),tmy,'k:','linewidth',2);hold on;
  elseif lp==2
      plot(tmx(:,10),tmy,'k--','linewidth',2);hold on;
  elseif lp==3
      plot(tmx(:,10),tmy,'k.','linewidth',1);hold on;
  elseif lp==4
      plot(tmx(:,10),tmy,'k-','linewidth',1);hold on;
  elseif lp==5
      plot(tmx(:,10),tmy,'ko','linewidth',1);hold on;
  end
   
  axis([min(min(tmx)) max(max(tmx)) min(min(tmy)) max(max(tmy))]);
  xlabel(pars(i,:))
  if i==1
     temp=deblank(perfs(lp,:));
     ylabel('cum. norm.')
 end
          
end

clear tmx tmy of

end