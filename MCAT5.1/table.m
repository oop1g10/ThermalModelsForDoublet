function table

% function table
%
% Print Top 10 Parameter Sets in Command Window
% ranked with respect to the currently seletced
% Objective Function
%
% Thorsten Wagener, Imperial College London, February 2000

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

disp('--------------------------------------------------------------------------')
disp(['The top 10 Parameter Sets with respect to ',perfs(lp,:),'are:'])
disp('--------------------------------------------------------------------------')
for i=1:ff(1)
   if i==ff(1)
      fprintf('%s\n\n',pars(i,:));  % parameter names
   elseif i==1
      fprintf('\t%s\t',pars(i,:));  % parameter names      
   else
      fprintf('%s\t',pars(i,:));  % parameter names
   end   
end
[Y,I]=sortrows(dat,ff(1)+lp); % sort parameter population due to selected of
temp=dat(I,:);
disp(temp(1:10,1:ff(1))) % parameter values
disp('--------------------------------------------------------------------------')
for i=1:ff(2)
   if i==ff(2)
      fprintf(' %s\n\n',perfs(i,:));  % of names
   elseif i==1
      fprintf('\t%s',perfs(i,:));  % of names      
   else
      fprintf(' %s',perfs(i,:));  % of names
   end   
end
disp(temp(1:10,ff(1)+1:ff(1)+ff(2))) % objective function values
disp('--------------------------------------------------------------------------')


