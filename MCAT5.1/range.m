function range

% INPUT
a=[1 2 3 2 4;2 1.8 3.3 2 3.5];			% parameter sets

m=[2 2.5 4 2.5 6];   % upper parameter boundaries

% NORMALISE PARAMETERS USING UPPER BOUNDARIES
for i=1:size(a,1)
   for j=1:size(a,2)
      na(i,j)=a(i,j)/m(j);
   end
end

% PARAMETER NAMES
par=['p1';'p2';'p3';'p4';'p5'];

% PLOT PARAMETERS
for i=1:size(a,1)
   plot(na(i,:),'b','LineWidth',2);hold on;
end
grid on;
ylabel('Normalized Range');
axis([1 length(m) 0 1]);

% only vertical grid lines
% parameter names as xlabel