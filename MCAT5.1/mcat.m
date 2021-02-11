function mcat(pars,crit,vars,mct,pao,obs,id,pstr,cstr,vstr,dt,t, ...
              plotParams) % plotParams is added by Pedchenko

% function mcat(pars,crit,vars,mct,pao,obs,id,pstr,cstr,vstr,dt,t);
%
% Interface between monte-carlo simulation output and MCAT
%
%  pars: 	MC parameter matrix [no. of sims x no. of pars]
%  crit: 	MC criteria matrix [no. of sims x no. of criteria]
%  vars: 	MC variable matrix [no. of sims x no. of pars]
%  mct: 	MC ouput time-series matrix [no. of sims x no. of samples]
%  pao:     Pareto population
%  obs: 	observed time-series vector [no. of samples x 1]
%  id: 		descriptor [string]
%  pstr: 	parameter names [string matrix - use str2mat to create]
%  cstr: 	parameter names [string matrix - use str2mat to create]
%  vstr: 	parameter names [string matrix - use str2mat to create]
%  dt: 		sampling interval in minutes
%  t: 		time vector if irregularly spaced samples
%
%  Enter an empty matrix '[]' for null inputs
%
%  Matthew Lees and Thorsten Wagener, Imperial College London, February 2001
%  Thorsten Wagener, Penn State, October 2004

%tpage('MCAT v.5','Thorsten Wagener, Penn State University, 2004','Formerly Imperial College London',1);

[ns,npars]=size(pars);
[ns,ncrit]=size(crit);
[ns,nvars]=size(vars);
[ns,nout]=size(mct);

HH=figure;

% set up MCAT structure array
gvs.ff      =[npars ncrit nvars ns]; 	% data format 
gvs.id      =id; 						% data file description
gvs.pars    =pstr; 					    % string vector of the parameter names
gvs.lhoods  =cstr; 					    % string vector of the likelihood names
gvs.dat     =[pars crit vars]; 	        % data matrix
gvs.pareto  =pao;						% pareto set
gvs.uci  	=0.95;				        % default upper confidence interval
gvs.lci  	=0.05;				        % default lower confidence interval
if ~isempty(mct)
   gvs.mct  =mct';		 			    % monte-carlo time-series output (no. of samples x no. of sims)
   gvs.dt   =1; 						% time step
   gvs.obs  =obs;						% observed;
   gvs.dt	=dt;						% sampling interval
   gvs.t	=t;						    % time vector
else
   gvs.mct  =[];
end
gvs.HH      =HH; 						% figure handle
gvs.COMMAND ='new'; 				    % command flag
gvs.PS      =1; 						% selected performance criterion (lhood or var)
gvs.LS      =1; 						% selected likelihood
if ~isempty(gvs.ff(3))
   gvs.VS    =1; 						% selected var
   gvs.vars  =vstr;  				    % string vector of the variable names
else
  gvs.Vs    =[]; 						% no variables
end
gvs.THRS    =[]; 						% data threshold
% parvis defaults
gvs.PCOMMAND='new'; 				    % command flag
gvs.Px      =2; 						% x-axis parameter
gvs.Py      =1; 						% y-axis parameter
gvs.FH      =[]; 						% figure handle
gvs.DL      =1; 				   	    % data gridding flag
gvs.CM      ='cool'; 				    % colormap
gvs.VA      =45; 						% view angle
gvs.gridd   =500; 					    % grid dimension (gridd x gridd)
gvs.Xi1     =[]; 						% grid data
gvs.Yi1     =[]; 						% grid data
gvs.Zi1     =[]; 						% grid data
gvs.slide   = 10;

set(0,'userdata',gvs);

%assignin('base','slider_value',10); %assigns the default slider value

mcatool(plotParams); % plotParams options added by Pedchenko