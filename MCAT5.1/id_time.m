function id_time(ff,id,pars,lhoods,vars,dat,PS)

% function id_time(ff,id,pars,lhoods,vars,dat,PS)
%
% Dynamic Identifiability Plots
%
% Thorsten Wagener, Penn State, October 2004

% read data
gvs=get(0,'userdata');

ff=gvs.ff;
id=gvs.id;
pars=gvs.pars;
lhoods=gvs.lhoods;
vars=gvs.vars;
dat=gvs.dat;
lp=gvs.PS;
mct=gvs.mct;
obs=gvs.obs;
t=size(mct,1); % length of time series
perfs=str2mat(lhoods,vars);
L=zeros(length(t));

% input window ************************************************************************************************************************************
% enter the algorithm parameters through an input window
prompt={'Enter the parameter to analyse (1,2,...):','Enter n (2n+1 = window size):'};
def={'1','10'};
dlgTitle='Input for DYNIA algorithm';
lineNo=1;
AddOpts.Resize='on';
AddOpts.WindowStyle='normal';
AddOpts.Interpreter='tex';
answer=inputdlg(prompt,dlgTitle,lineNo,def);

p1      = str2num(answer{1}); % selected parameter
window  = str2num(answer{2}); % * 2 + 1 = size of moving window

% 'fixed' algorithm parameters ********************************************************************************************************************
containers  = 20; % split of parameter range
aa          =  1; % [1] medium window (running mean) [2] right boundary window (regressive)
grouping    = 10; % number of 'horizontal' groups

% 'fixed' algorithm parameters in the code
ff(1)       =  p1; 	% last selected parameter equals first one
timestep    = ' ';  % time-series time step

if ~isempty(gvs.dt)
  timestep='minutes';
  if gvs.dt>59&gvs.dt<1440
    timestep='hours';gvs.dt=gvs.dt/60;
  elseif gvs.dt>1439&gvs.dt<10079
    timestep='days';gvs.dt=gvs.dt/1440;
  elseif gvs.dt>10079&gvs.dt<40000
    timestep='weeks';gvs.dt=gvs.dt/10080;
  elseif gvs.dt>40000
    timestep='months';gvs.dt=gvs.dt/10080;
  end
else
   timestep='samples';
end

% DYNIA *******************************************************************************************************************************************
h_wait=waitbar(0,'Running DYNIA Algorithm');  
for dt=1:t

   % calculate "likelihood" at every time step dt
   if aa==1 % medium window (running mean)
   	for no=1:size(mct,2)
   	   if dt<window+1
   	   	    residual(no,dt)=mean(abs(mct(1:dt+window,no)-obs(1:dt+window))); % mean absolute error in moving window
   	   elseif t-dt<window+1
   	        residual(no,dt)=mean(abs(mct(dt-window:t,no)-obs(dt-window:t))); % mean absolute error in moving window
   	   else
			residual(no,dt)=mean(abs(mct(dt-window:dt+window,no)-obs(dt-window:dt+window))); % mean absolute error in moving window         
   	   end      
   	end
	elseif aa==2 % right boundary window (recursive)
   	for no=1:size(mct,2)
   	    if dt<2*window+1
   	   	    residual(no,dt)=mean(abs(mct(1:dt+2*window,no)-obs(1:dt+2*window))); % mean absolute error in moving window
        else
			residual(no,dt)=mean(abs(mct(dt-2*window:dt,no)-obs(dt-2*window:dt))); % mean absolute error in moving window         
   	    end      
   	end
	end            
   
   if max(residual)~=0
      L=residual(:,dt)./max(residual(:,dt)); % normalise criterion
   else
      L=residual(:,dt);
   end
   L=1-L; % likelihood (high values indicate more likely [probable] models)
   if min(L)<0|min(L)==0, L=L-min(L)+1000*eps;end; % transform negative lhoods
   L=L';
   
   % sort data according to selected perf measure
	[I,J]=sort(L);
	pop=dat(J,:);
	cls=floor(length(pop)/grouping);
	tmx=zeros(cls,grouping);tmy=tmx;
      
	for i=p1:ff(1)
      
      % calculate cumulative distribution of top 10% of the model population ******************************************************************
      
      tm=pop(cls*(grouping-1)+1:cls*grouping,i);
      tmx=sort(tm);
	  tmy=(1:length(tmx))/cls; 
      
      % calculate the 90% confidence limits *************************************************************************************************
      
      tucl=find(tmy>0.95); ucl(dt)=tmx(tucl(1));
      tlcl=find(tmy>0.05); lcl(dt)=tmx(tlcl(1));
      
	  % calculate gradients *******************************************************************************************************************
	   
	  step=(max(dat(:,i))-min(dat(:,i)))/containers;
	  XI(:,i)=[min(dat(:,i)):step:max(dat(:,i))]';
      
      temp1=min(dat(:,i))-.001;
      if temp1<0
         temp1=0;
      end
      temp2=max(dat(:,i))+.001;    

      for kk=1:length(tmx)-2
          if tmx(kk)==tmx(kk+1)
              tmx(kk+1)=tmx(kk+1)+[tmx(kk+2)-tmx(kk)]/1000;
          end
      end
      
      [YI]=interp_special([temp1;tmx;temp2],[0 tmy 1],XI(:,i));
      
      [FX(:,dt,i)] = gradient(YI); % calculate gradient within containers
      
      % select best performing model as a function of the highest gradient
      % try select best model as point estimate!!!!
      
      location=find(FX(:,dt,i)==max(FX(:,dt,i)));
      location=location(1);
      best(dt)=XI(location,i);
      
      % find number of models within best segment (i.e. pixel)
      
      if location<size(XI,1)
          [YY,ZZ]=find(tmx>XI(location,i)&tmx<XI(location+1,i));
      else
          [YY,ZZ]=find(tmx>XI(location,i));
      end
                 
      clusterline_pixel(dt)=size(YY,1);
      clear YY ZZ
      
      % find number of models within 90% cfls
      
      [YY,ZZ]=find(tmx>lcl(dt)&tmx<ucl(dt));
      clusterline_cfls(dt)=size(YY,1);      
      clear YY
      
	  % **********************************************************************************************************************************

      dtcolor(:,dt,i)=FX(:,dt,i); % let color values run from min (bottom) to max (top) parameter value
       
      clear tm YI
       
	end
   
   clear L 
   waitbar(dt/t);
   
end
close(h_wait);
G = find(isnan(dtcolor)); dtcolor(G)=zeros(size(G));

for i=p1:ff(1) % every parameter

	infocontent=1-[(ucl-lcl)/(max(dat(:,i))-min(dat(:,i)))];
   
	nucl=ucl/(max(dat(:,i))-min(dat(:,i))); % normalise ucl
	nlcl=lcl/(max(dat(:,i))-min(dat(:,i))); % normalise lcl

end

% PLOTTING *****************************************************************************************************************************************

dt=1:t;
if ff(1)<4|ff(1)==4
  subp='22';
else
  subp='32';
end

% create x matrix for patch function
% one x vector for every time step
% matrix is the same for all parameters
for dt=1:t
   xmatrix(1:2,dt)=dt-0.5;
   xmatrix(3:4,dt)=dt+0.5;
end
% create y matrix for patch function
for C=1:containers
   ymatrix(1,C)=(C-1)*(1/containers);
   ymatrix(2:3,C)=C*(1/containers);
   ymatrix(4,C)=(C-1)*(1/containers);
end

for i=p1:ff(1) % every parameter
  
  subplot(211); % DYNIA PLOT ****************************************************************************************************************************
  
  for dt=1:t % every time step
     for C=1:containers % every container
		tcolor=[abs(1-dtcolor(C,dt,i)./max(max(dtcolor(:,:,i)))) abs(1-dtcolor(C,dt,i)./max(max(dtcolor(:,:,i)))) abs(1-dtcolor(C,dt,i)./max(max(dtcolor(:,:,i))))];
        patch(xmatrix(:,dt),ymatrix(:,C).*(max(XI(:,i))-min(XI(:,i)))+min(XI(:,i)),tcolor,'edgecolor',tcolor);hold on;
     end
  end
  
  plot(ucl,':','color','k','linewidth',1);hold on; % upper confidence limit
  plot(lcl,':','color','k','linewidth',1);hold on; % lower confidence limit
  plot([obs./(max(obs)+0.1*max(obs))]*[max(XI(:,i))-min(XI(:,i))]+[min(XI(:,i))+0.01*(max(XI(:,i))-min(XI(:,i)))],'k','linewidth',2);hold on; % normalized observed flow

  plot([(window+1) (window+1)],[min(XI(:,i)) max(XI(:,i))],'k--','linewidth',2);hold on;
  plot([t-(window+1) t-(window+1)],[min(XI(:,i)) max(XI(:,i))],'k--','linewidth',2);
  
  axis([1 t min(XI(:,i)) max(XI(:,i))]);
  
  xlabel(['time step [' timestep ']']);
  temp2=deblank(mat2str(pars(i,:)));
  ylabel(temp2);
  temp3=mat2str(window*2+1);
  title(['window size: ' temp3 ' [' timestep ']']); 
  
  set(gca,'layer','top');
  set(get(gca,'xlabel'),'fontsize',14);
  set(get(gca,'ylabel'),'fontsize',14);
  set(get(gca,'title'),'fontsize',14);
  
  set(gca,'layer','top');
  set(gca,'fontsize',14,'linewidth',2);
  
  subplot(212); % INFORMATION CONTENT PLOT *************************************************************************************************************
  
  infocontent=1-[(ucl-lcl)/(max(dat(:,i))-min(dat(:,i)))];
  
  bar(infocontent,'k');hold on;
  plot([obs./(max(obs)+0.1*max(obs))]+0.025,'linewidth',2,'color',[.7 .7 .7]);hold on;

  save infocontent infocontent;
  
  axis([1 t 0 1]);
  
  xlabel(['time step [' timestep ']']);
  ylabel(['information content(' temp2 ')']);
  temp3=mat2str(window*2+1);
  title(['window size: ' temp3 ' [' timestep ']']); 
  
  set(gca,'layer','top');
  set(get(gca,'xlabel'),'fontsize',14);
  set(get(gca,'ylabel'),'fontsize',14);
  set(get(gca,'title'),'fontsize',14);
  
  set(gca,'layer','top');
  set(gca,'fontsize',14,'linewidth',2);
  
end