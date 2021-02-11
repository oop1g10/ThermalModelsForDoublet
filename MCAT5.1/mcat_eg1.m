% mcat_eg1
%
% MCAT EXAMPLE 1 - SINGLE LINEAR STORAGE MODEL
%
% Matthew Lees, Imperial College London, July 1999

disp(' ')
disp('This example runs a monte-carlo sampling simulation of a')
disp('simple dynamic model (a discrete linear store), sets up')
disp('the data input matrices for MCAT, and then starts MCAT')
disp(' ')
disp('to see the code in this batch file open the file MCAT_EG1.m')
disp(' ')
disp('Hit any key to continue...');
disp(' ') 

% set model parameters
disp('The model parameters are: residence time (rt) = 20 and gain = 1');disp(' ')
disp('Hit any key to continue...');disp(' ')
rt=20;		 		% residence time
gain=1;				% gain
noiselev=0.01; 	% noise level

% generate a synthetic input
u=zeros(100,1);
y=u;
u(5:7)=[1 1 1];u(30:32)=[1 1 1];u(70)=1;

% generate the system output
for i=2:100
   y(i)=(1-1/rt)*y(i-1)+(1/rt)*gain*u(i); % discrete linear store;
end

% add some white measurement noise to the output
yn=y+randn(size(y))*noiselev;

disp('A synthetic input is generated as input to the linear storage model')
disp('This model is then run and data error is added to the output response')
disp(' ')
disp('Hit any key to continue...');disp(' ')

% plot data
hh=figure;
plot([u yn]);
legend('input','output')
title('Input-Output data')
disp('Hit any key to continue...');
close(hh);

disp('A Monte-Carlo experiment is now carried out where 1000 sets of output data')
disp('are simulated using the model with parameters sampled from a uniform distribution')
disp(' ')
disp('The uniform distribution boundaries are: rt (10-30); gain(0.5-2)')
disp(' ');
disp('For each model (parameter set) a number of objectives are calculated by')
disp('comparing the model output with the ''real'' output. The objectives calculated')
disp('are the sum of the squared errors (sse) and the absolute bias (abias)')
disp(' ')
disp('The variable, peak output, is also stored for input into MCAT')
disp(' ')
disp('Hit any key to continue...');disp(' ')

% MC options
rtlb    =10; 		% residence time uniform distribution lower bound
rtup    =30; 		% residence time uniform distribution upper bound
gainlb  =0.5; 		% gain uniform distribution lower bound
gainup  =2;  		% gain uniform distribution upper bound
ns      =1000; 	    % no. of MC sims

% generate matrix of random samples from parameter distributions
rtmc=(rand(ns,1)*(rtup-rtlb))+rtlb;
gainmc=(rand(ns,1)*(gainup-gainlb))+gainlb;

% intialise output matrices (speeds program up)
sse=zeros(ns,1);abias=zeros(ns,1);peako=zeros(ns,1);
mct=zeros(ns,100);

h = waitbar(0,'Running Monte-Carlo simulation, please wait...');
% run MC simulation
for k=1:ns
   for i=2:100
     mct(k,i)=(1-1/rtmc(k))*mct(k,i-1)+(1/rtmc(k))*gainmc(k)*u(i); % discrete linear store;
   end
   e=yn-mct(k,:)';
   sse(k)=sum(e.^2); % sum of squared errors
   abias(k)=abs(sum(e)/length(mct(k,:))); % absolute bias
   peako(k)=max(mct(k,:));
   waitbar(k/ns)
end
close(h)

disp('setting up the data input matrices for MCAT, and starting MCAT')
disp(' ')
disp('Hit any key to continue...');disp(' ')

% set up input for MCAT
pars=[rtmc gainmc];	                % MC parameter matrix [no. of sims x no. of pars]
crit=[sse abias]; 	                % MC criteria matrix [no. of sims x no. of criteria]
vars=[peako];			            % MC variable matrix [no. of sims x no. of pars]
mct=mct;					        % MC ouput time-series matrix [no. of sims x no. of samples]
obs=y;					            % observed time-series vector [no. of samples x 1]
id='Linear storage model example';	% descriptor [string]
pstr=str2mat('rt','gain');		    % parameter names [string matrix - use str2mat to create]
cstr=str2mat('sse','abias');	    % criteria names [string matrix - use str2mat to create]
vstr=str2mat('peak output');	    % variable names [string matrix - use str2mat to create]
dt=1;								% sampling interval in minutes
t=[];								% time vector if irregularly spaced samples

% start MCAT
mcat(pars,crit,vars,mct,[],obs,id,pstr,cstr,vstr,dt,t);
