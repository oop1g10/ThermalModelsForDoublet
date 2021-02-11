function [pranks]=pareto;

% Pareto Ranking based on Nondommination
%
% function [pranks]=pareto; 
%
% OUTPUT
% pranks      population with pareto ranks
%
% Thorsten Wagener, Imperial College London, October 1999

% READ INPUT DATA

gvs	=get(0,'userdata');

%pop = dat;
pop = gvs.dat;

% ALGORITHM

np  = gvs.ff(1); % number of parameters
nof = gvs.ff(2); % number of objective functions

pop = [ones(size(pop,1),1),pop];

rank = 1;
tt   = 2;

while rank<tt;
   
   pop(:,1) = ones(size(pop,1),1)*rank;
   
   h=waitbar(0,'Identifying Pareto Set.');
   
   for i=1:size(pop,1)

		for j=1:size(pop,1)

			for k=1:nof
            
				if pop(i,np+1+k)>pop(j,np+1+k)                              
               
	            p(k)=0;
               
            else
               
               p(k)=1;
               
				end
         			
			end                  
         
	      if sum(p)==0
            
            pop(i,1)=0;
            
         end                  
         
		end
      
      waitbar(i/size(pop,1));
      
	end
   
   close(h);
   
   I = find(pop(:,1)~=0);
   
   if rank==1
      
      pranks = pop(I,:);
      
   else
      
      pranks = [pranks;pop(I,:)];
      
   end
   
   pop(I,:)=[];   
   
   rank   = rank + 1;
   
end

gvs.pareto = pranks;

set(0,'userdata',gvs);


