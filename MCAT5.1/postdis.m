% function postdis

% function postdis
%
% A Posteriori Parameter Distributions
%
% Thorsten Wagener, Imperial College London, February 2000

% set parameters
ncontainers=20;

% read data
gvs=get(0,'userdata');
ff=gvs.ff;
id=gvs.id;
pars=gvs.pars;
vars=gvs.vars;
dat=gvs.dat;
PS=gvs.PS;
lhoods=gvs.lhoods;
perfs=str2mat(lhoods,vars);


% calculate likelihood
of=gvs.dat(:,ff(1)+PS);  % criterion (low values indicate better models)
L=1-of; 									% likelihood (high values indicate more likely [probable] models)
if min(L)<0|min(L)==0, L=L-min(L)+1000*eps;end; % transform negative lhoods

k=length(L);
i=1;
while i<=k
   if isnan(L(i))==1
      gvs.dat(i,:)=[];
      dat(i,:)=[];
      L(i)=[];
      k=k-1;
      i=i-1;
   end
   i=i+1;
end

L=L./sum(L); % sum(likelihoods)=1      problem if NaN in vector

%Eliminate data that is below the slider threshold
L = sortrows(L);
dat = sortrows(dat,ff(1)+PS);
L = flipud(L);
numdat = floor((slider_value / 100) * size(L));
L(numdat+1:size(L),:) = [];
dat(numdat+1:size(dat),:) = [];

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
   if ff(1)>1,
      eval(['subplot(' subp num2str(i) ')']),
   end

   width=(max(dat(:,i))-min(dat(:,i)))/ncontainers; % container width
   
   for n=1:ncontainers
      [K,J]=find(dat(:,i)>min(dat(:,i))+(n-1)*width&dat(:,i)<min(dat(:,i))+n*width); % find all values within the container
      temp1=dat(K,i);
      temp2=L(K);
      
      bx(i,n)=min(dat(:,i))+.5*width+(n-1)*width; % middle of container
      by(i,n)=sum(temp2)/length(temp2); % mean likelihood in container
      
      clear temp 1 temp2 K
   end
   
   bar(bx(i,:),by(i,:),'k');hold on;
   
   ymax=(max(by(i,:))+0.1*(max(by(i,:))));
   ymin=(min(by(i,:))-0.1*(min(by(i,:))));
   
   axis([min(dat(:,i)) max(dat(:,i)) ymin ymax]);
   
   if i==1
   	temp=deblank(perfs(PS,:)); % remove the blanks behind the string
   	ylabel(['D(',temp,')'])
	end
   
   xlabel(pars(i,:))
   
end


