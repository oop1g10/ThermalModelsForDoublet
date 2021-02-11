% function dotlhoods

% function dotlhoods
%
% dotty plots likelihoods
%
% Thorsten Wagener, Imperial College London, May 2000

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
of=gvs.dat(:,gvs.ff(1)+gvs.PS);  % criteria (low values indicate better models)
of=1-of; % likelihood (high values indicate more likely [probable] models)
if min(of)<0|min(of)==0, of=of-min(of)+1000*eps;end; % transform negative lhoods
L=of./sum(of); % values add up to one

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
if ff(1)>1,eval(['subplot(' subp num2str(i) ')']),end
nn=find(L==max(L));
nn=nn(1);

plot(dat(:,i),L,'o','markersize',3,'MarkerEdgeColor','k','MarkerFaceColor','k'); hold on;
plot(dat(nn,i),L(nn),'s','markersize',10,'MarkerEdgeColor','k','MarkerFaceColor','m'); hold off; % best parameter

yaxmin=min(L);%-0.1*(max(L)-min(L));
yaxmax=max(L)+0.1*(max(L)-min(L));
axis([min(dat(:,i)) max(dat(:,i)) yaxmin yaxmax]);

temp2=deblank(perfs(lp,:)); % remove the blanks behind the string
ylabel(['L(',temp2,')'])
xlabel(pars(i,:));


end

