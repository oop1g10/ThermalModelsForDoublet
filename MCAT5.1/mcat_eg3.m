% mcat_comp
%
% comparison of methods of parameter/output uncertainty estimation
% using the simplest dynamic model possible, an autoregressive model
% with a single parameter.
%
% Matthew Lees, Imperial College London, February 2000

close all

disp(' ')
disp('Comparison of methods of parameter/output uncertainty estimation');
disp('using the simplest dynamic model possible, an autoregressive model');
disp('with a single parameter (AR(1)).');
disp(' ')
disp('The methods compared are, ')
disp(' ')
disp('1. Theoretical least squares regression (see for e.g. numerical recipes)')
disp('2. Classical monte carlo simulation (see for e.g. numerical recipes)')
disp('3. Generalised Likelihood Uncertainty Estimation (GLUE) using MCAT')
disp(' ')
disp('Hit any key to continue...');pause
disp(' ')

disp('Generate some synthetic data using an AR(1) model with the parameter set')
disp('to 0.7, an intial output of 0.2, and normally distributed output error')
disp('with a standard deviation of 0.005');
disp(' ')
disp('Hit any key to continue...');pause
disp(' ')

% generate a 'true' error free data set
y=pefilt(0,[1 -.7],ones(25,1),0.2); % AR(1) model

% add some normally distributed data error
nsd=0.005;
n=randn(25,1)*nsd;
yn=y+n;

% plot the data
h=figure(gcf);clf;
plot([y yn n])
axis tight
set(gca,'xlim',[1 25]);
title('Data')
legend('data','corrupted data','error')
disp('Hit any key to continue...');pause;disp(' ')
close(h);

disp('Estimate the parameter and associated PDF using least squares regression');disp(' ')
disp('Hit any key to continue...');pause
disp(' ')

% estimate the parameter and parameter pdf using LS
[a,R2,Pbest,Pse,yhat,ebest]=linreg(yn(2:25),yn(1:25-1));
ybest=pefilt(0,[1 -a],ones(25,1),0.2); % AR(1) model
xv=a-0.1:.001:a+0.1;
fx=normdist(xv,a,sqrt(Pbest));

% plot the data
h=figure(gcf);clf;
plot([yn ybest])
axis tight
set(gca,'xlim',[1 25]);
title('LS model fit')
legend('data','model');
disp('Hit any key to continue...');pause;disp(' ')
close(h);

disp('Using the parameter estimate and standard deviation of the residuals,')
disp('estimate the parameter PDF using monte carlo simulation');disp(' ')
disp('Hit any key to continue...');pause
disp(' ')

% estimate the pdf using classical MC simulation
am=zeros(1000,1);
yh=zeros(1000,25);
nm=randn(25,1000)*nsd;
ynm=ybest(:,ones(1,1000))+nm;

h = waitbar(0,'Running Monte-Carlo simulation, please wait...');
for j=1:1000
   [am(j),R2,P,Pse,yhat,e]=linreg(ynm(2:25,j),ynm(1:25-1,j));
   yhat=pefilt(0,[1 -am(j)],ones(25,1),0.2); % AR(1) model
   yh(j,:)=yhat';
   waitbar(j/1000);
end
close(h)

% plot the results
subplot(121)
plot(xv,fx);
set(gca,'xlim',[a-0.1 a+0.1]);
title('PDF estimated using LS')
xlabel('Parameter')
ylabel('Probability')
subplot(122)
hist(am,100);
set(gca,'xlim',[a-0.1 a+0.1]);
title('PDF estimated using MC simulation')
xlabel('Parameter')
ylabel('Frequency')
disp('Hit any key to continue...');pause;disp(' ')

disp('Calculate the model output confidence intervals from the MC generated PDF, and')
disp('the data confidence intervals from the standard deviation of the residuals');disp(' ')
disp('Hit any key to continue...');pause
disp(' ')

% calculate CIs
for i=1:25
   ysort=sort(yh(:,i));
   ciml(i)=ysort(25);cimu(i)=ysort(975);
end
cidu=ybest+(1.96*sqrt(var(ebest)));
cidl=ybest-(1.96*sqrt(var(ebest)));

% plot
figure
t=1:25;
plot(t,yn,'g-',t,ybest,'b-',t,ciml,'b:',t,cidl,'r:',t,cimu,'b:',t,cidu,'r:');
axis tight
legend('data','model','95% Model CIs','95% Data CIs');
set(gca,'xlim',[1 25]);
title('Predictive uncertainty')
disp('Hit any key to continue...');pause;disp(' ')

disp('A Monte-Carlo sampling experiment is now carried out where 1000 sets of output data')
disp('are simulated using the model with the parameter sampled from a uniform distribution')
disp(' ')
disp('The uniform distribution boundaries are 0.6 to 0.8')
disp(' ');
disp('For each model (parameter) a number of objectives are calculated by')
disp('comparing the model output with the ''real'' output. The objectives calculated')
disp('are the sum of the squared errors (sse), 1-the coefficient of determination (1-R2)')
disp('and 1-likelihood where likelihood is the product of the probability of each error')
disp('assuming the errors to be normally distributed with mean=0 and sd=0.005')
disp(' ')
disp('Hit any key to continue...');pause;disp(' ')

% perform uniform prior MC sampling
yh=zeros(1000,25);
sse=zeros(1000,1);r2=sse;L=sse;
au=rand(1000,1)*0.2+0.6;

h = waitbar(0,'Running Monte-Carlo sampling, please wait...');
for i=1:1000
   ym=pefilt(0,[1 -au(i)],ones(25,1),0.2);
   e=yn-ym;
   sse(i)=sum(e.^2);
   r2(i)=(var(e)/var(yn));
   L(i)=1-prod(normdist(e,0,nsd));
   yh(i,:)=ym';
   waitbar(i/1000);
end
close(h)

disp('setting up the data input matrices for MCAT, and starting MCAT')
disp(' ')
disp('you can use MCAT to examine the parameter likelihood distribution,')
disp('and the output uncertainty')
disp(' ')
disp('Hit any key to continue...');pause;disp(' ')

% set up input for MCAT
pars=[au];			% MC parameter matrix [no. of sims x no. of pars]
crit=[sse r2 L]; 	% MC criteria matrix [no. of sims x no. of criteria]
vars=[];				% MC variable matrix [no. of sims x no. of pars]
mct=yh;				% MC ouput time-series matrix [no. of sims x no. of samples]
obs=yn;				% observed time-series vector [no. of samples x 1]
id='AR(1) example';		% descriptor [string]
pstr=str2mat('a1');		% parameter names [string matrix - use str2mat to create]
cstr=str2mat('sse','1-R2','1-L');	% criteria names [string matrix - use str2mat to create]
vstr=[];										% variable names [string matrix - use str2mat to create]
dt=1;							% sampling interval in minutes
t=[];							% time vector if irregularly spaced samples

% start MCAT
mcat(pars,crit,vars,mct,[],obs,id,pstr,cstr,vstr,dt,t);