% mcat_eg2
%
% MCAT EXAMPLE 2 - PARALLEL LINEAR STORAGE MODEL
%
% Matthew Lees, Imperial College London, July 1999

disp(' ')
disp('This example runs a monte-carlo sampling simulation of a')
disp('simple dynamic model (a parallel linear store), sets up')
disp('the data input matrices for MCAT, and then starts MCAT')
disp(' ')
disp('to see the code in this batch file open the file MCAT_EG2.m')
disp(' ')
disp('Hit any key to continue...');pause
disp(' ')

% model parameters
disp('The model parameters are: 1st store, residence time (rt1) = 3 and gain = 1')
disp('                        : 2nd store residence time (rt2) = 20 and gain = 1')
disp('50 % of the input passes through each linear store');disp(' ')
disp('Hit any key to continue...');pause;disp(' ')
rt1=3;		 		% residence time
gain1=1;				% gain
rt2=20;		 		% residence time
gain2=1;				% gain
split=0.5;			% percentage flow through upper store

disp('A synthetic input is generated as input to the parallel linear storage model')
disp('This model is then run to produce the output response (nb. no error is added)')
disp(' ')
disp('Hit any key to continue...');pause;disp(' ')

% generate a synthetic input
u=zeros(100,1);
y1=u;
y2=u;
u(5:7)=[1 1 1];u(30:32)=[1 1 1];u(70)=1;

% generate the system output
for i=2:100
   y1(i)=(1-1/rt1)*y1(i-1)+(1/rt1)*gain1*u(i)*split; % discrete linear store;
   y2(i)=(1-1/rt2)*y2(i-1)+(1/rt2)*gain2*u(i)*(1-split); % discrete linear store;
end
y=y1+y2;

% plot data
hh=figure;
plot([u y]);
legend('input','output')
title('Input-Output data')
disp('Hit any key to continue...');pause
close(hh);

disp('A Monte-Carlo experiment is now carried out where 1000 sets of output data')
disp('are simulated using the model with parameters sampled from a uniform distribution')
disp(' ')
disp('The uniform distribution boundaries are: rt1 (2-10); gain1(0.5-2); rt2 (10-50); gain2(0.5-2)')
disp(' ');
disp('For each model (parameter set) a number of objectives are calculated by')
disp('comparing the model output with the ''real'' output. The objectives calculated')
disp('are the sum of the squared errors (sse), 1-the Nash and Sutcliffe Efficiency (nse)')
disp('and the root mean squared error of output values < 0.05 (rmselow)')
disp(' ')
disp('The variable, peak output, is also stored for input into MCAT')
disp(' ')
disp('Hit any key to continue...');pause;disp(' ')

% MC options
rt1lb    =2; 	% residence time uniform distribution lower bound
rt1up    =10; 	% residence time uniform distribution upper bound
gain1lb  =0.5;  % gain uniform distribution lower bound
gain1up  =2;  	% gain uniform distribution upper bound
rt2lb    =10; 	% residence time uniform distribution lower bound
rt2up    =50; 	% residence time uniform distribution upper bound
gain2lb  =0.5;  % gain uniform distribution lower bound
gain2up  =2;  	% gain uniform distribution upper bound
ns       =1000; % no. of MC sims

% generate matrix of random samples from parameter distributions
rt1mc=(rand(ns,1)*(rt1up-rt1lb))+rt1lb;
gain1mc=(rand(ns,1)*(gain1up-gain1lb))+gain1lb;
rt2mc=(rand(ns,1)*(rt2up-rt2lb))+rt2lb;
gain2mc=(rand(ns,1)*(gain2up-gain2lb))+gain2lb;

% intialise output matrices (speeds program up)
sse=zeros(ns,1);nse=zeros(ns,1);FL=zeros(ns,1);peako=zeros(ns,1);abias=zeros(ns,1);
mct1=zeros(ns,100);
mct2=zeros(ns,100);
% run MC simulation
h = waitbar(0,'Running Monte-Carlo simulation, please wait...');
for k=1:ns
   for i=2:100
      mct1(k,i)=(1-1/rt1mc(k))*mct1(k,i-1)+(1/rt1mc(k))*gain1mc(k)*u(i)*split; % discrete linear store;
      mct2(k,i)=(1-1/rt2mc(k))*mct2(k,i-1)+(1/rt2mc(k))*gain2mc(k)*u(i)*(1-split); % discrete linear store;
   end
   mct(k,:)=mct1(k,:)+mct2(k,:);
   e=y-mct(k,:)';
   sse(k)=sum(e.^2);
   nse(k)=(var(e)/var(y)); % 1-Nash and Sutcliffe Efficiency (coefficient of determination)   
   
   hl=zeros(ns,1);
   for i=1:length(y)
      if y(i)<0.05 % only consider time steps with flow below 0.05
         hl(i)=1;
      end
   end
   [I]=find(hl==1); % find the positions with values equal to 1 
   FL(k)=sqrt(mean((e(I)).^2)); % RMSE for low flow period
   clear I
   
   peako(k)=max(mct(k,:));
   
   waitbar(k/ns);
end
close(h);

disp('setting up the data input matrices for MCAT, and starting MCAT')
disp(' ')
disp('Hit any key to continue...');pause;disp(' ')

% set up input for MCAT
pars=[rt1mc rt2mc gain1mc gain2mc];	        % MC parameter matrix [no. of sims x no. of pars]
crit=[sse nse FL]; 	                        % MC criteria matrix [no. of sims x no. of criteria]
vars=[peako];			                    % MC variable matrix [no. of sims x no. of pars]
mct=mct;					                % MC ouput time-series matrix [no. of sims x no. of samples]
obs=y;					                    % observed time-series vector [no. of samples x 1]
id='parallel linear storage model example';	% descriptor [string]
pstr=str2mat('rt1','rt2','gain1','gain2');	% parameter names [string matrix - use str2mat to create]
cstr=str2mat('sse','nse','rmselow');		% criteria names [string matrix - use str2mat to create]
vstr=str2mat('peak output');			    % variable names [string matrix - use str2mat to create]
dt=1;										% sampling interval in minutes
t=[];										% time vector if irregularly spaced samples

% start MCAT
mcat(pars,crit,vars,mct,[],obs,id,pstr,cstr,vstr,dt,t);

