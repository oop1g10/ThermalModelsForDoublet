% function idmain(ff,id,pars,lhoods,vars,dat,PS,slider_value)

% function idmain(ff,id,pars,lhoods,vars,dat)
%
% 'static' identifiability plots
%
% Thorsten Wagener, Imperial College London, June 2000

gvs=get(0,'userdata');
ff=gvs.ff;
id=gvs.id;
pars=gvs.pars;
lhoods=gvs.lhoods;
vars=gvs.vars;
dat=gvs.dat;
lp=gvs.PS;

perfs=str2mat(lhoods,vars);

containers=10; % division of each parameter range
grouping=10;  % number of groups

% calculate likelihood
of=gvs.dat(:,gvs.ff(1)+gvs.PS);  % criteria (low values indicate better models)
of=1-of; % likelihood (high values indicate more likely [probable] models)
if min(of)<0|min(of)==0, of=of-min(of)+1000*eps;end; % transform negative lhoods

% sort data according to selected perf
[I,J]=sort(of);
dat=dat(J,:);
%Eliminate data that is below the slider threshold
numdat = floor((slider_value / 100) * size(dat));
dat(numdat+1:size(dat),:) = [];

cls=floor(length(dat)/grouping);
tmx=zeros(cls,grouping);tmy=tmx;

% select parameters to analyse
%ff(1)=3;
p1=1;

if ff(1)<=4
  subp='2,2,';
elseif ff(1)>4&ff(1)<=9
   subp='3,3,';
elseif ff(1)>9&ff(1)<=12
   subp='4,3,';
else %ff(1)>12&ff(1)<=16
   subp='4,4,';
end

for i=p1:ff(1)
  if ff(1)>1,eval(['subplot(' subp num2str(i) ')']),end
  for j=1:grouping
    tm=dat(cls*(j-1)+1:cls*j,i);
    tm=sort(tm);
    tmx(:,j)=tm;
    tmy=(1:length(tmx))/cls; 
  end
  
   % calculate and plot gradients ***************************
  
   step=(max(dat(:,i))-min(dat(:,i)))/containers; % it is necessary that the boundaries are the same
   XI=[min(dat(:,i)):step:max(dat(:,i))]; % if a parameter id should be compared between two models
   
   % test for monotony
   for ii=1:5
      [II]=find(diff(tmx(1:length(tmx(:,grouping))-1,grouping))==0);
      tmx(II+1,grouping)=tmx(II+1,grouping)+[(tmx(II+2,grouping)-tmx(II+1,grouping))/2];
   end               
   
   [YI]=interp1([min(dat(:,i))-.0001; tmx(1:length(tmx(:,grouping))-1,grouping); max(tmx(:,grouping))+0.000001; max(dat(:,i))+.0001],[0 tmy 1],XI);
   
   [FX] = gradient(YI); % calculate gradient within containers
   
   ID_max(i)=max(FX); % keep the maximum gradient for information
   III=find(FX==max(FX));
   pos_max(i)=XI(III);
   
   ID(i,:)=FX; % keep the whole vector for each parameter
   pos(i,:)=XI;
   
   %hpatches=bar('v6',XI,2*FX,'g');hold on;
   hpatches=bar(XI,2*FX,'g');hold on;
   xd = get(hpatches,'xdata');
   yd = get(hpatches,'ydata');
   
   for n=1:size(yd,2)
     temp=max(yd(:,n));     % color value needs to be between 0 and 1
     tcolor=[abs(1-temp) abs(1-temp) abs(1-temp)];
     patch(xd(:,n),yd(:,n),tcolor);hold on;
   end

   clear FX
   
   % ********************************************************
   
   plot([min(dat(:,i)); tmx(:,grouping); max(dat(:,i))],[0 tmy 1],'color','k','linewidth',2);hold on;
   
   grid off;
   
   axis([min(min(tmx)) max(max(tmx)) min(min(tmy)) max(max(tmy))]);
   
   temp1=deblank(pars(i,:));
   xlabel(['' temp1 '']);
   temp2=deblank(perfs(lp,:));
   ylabel(['cum. distr.(' temp2 ') | id.']);
   
   set(gca,'layer','top');
   

   
end

% PLOT BEST VALUES ON SCREEN
i=p1:ff(1);

disp('[i] parameter no., [x] position of max(id) [id] max(id) value'); 
disp('');
disp('	i	x	id');
[i' pos_max' ID_max']
disp('');
disp('	mean(id)');
mean(ID_max)


