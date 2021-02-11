function [outhandle,outarea3options]=area3(x,y,z,E,area3options);
% _______________________________________________________________________
% 
% AREA3 filled area plot but in 3d
%    Such an filled area consists of two walls, one roof and one floor. 
%    Their properties can be specified by using the OPTIONS. 
%    Read the explanations in the function or type AREA3 for a demo. 
% _______________________________________________________________________
%

% Syntax:
% ---------------------
% AREA3;   
%    demo 
% [ha,opt]=AREA3;  
%    the demo but returns the handle ha and the options AREA3OPTIONS 
% [ha,opt]=AREA3(x,y,z); 
%    filled area plot in 3d from data x,y,z
% [ha,opt]=AREA3(x,y,z,options);  
%    filled area plot in 3d with the specified options
%
%
% Input arguments:
% --------------------
% x   matrix of x-values
%       SIZE(x) is one row per column of y, 
%       so SIZE(x) has to be m-by-n.
% y   vector of y-values 
%       SIZE(y) is ether 1-by-m or m-by-1
% z   matrix of z-values 
%       SIZE(z) must be SIZE(x)
%     
% Options:
% --------------------
% options.barwidth
%    the width of the bars. a scalar > 0.
% options.ColormapWall
%    the colormap of the walls. a string, the name of a function, 
%    that accepts a integer M as input an returns a 3 x M matrix
%    with RGB-values.
% options.ColormapRoof
%    the colormap of the roof. see above.
% options.FacealphaWall
%    the FaceAlpha value of the walls. a non-NaN scalar between 0 and 1.
% options.FacealphaRoof
%    the FaceAlpha value of the roof. see above.
% options.FacealphaFloor
%    the FaceAlpha value of the floor. see above.
% options.SurfRoof
%    if set to 1, the roofs will be drawn as surfaces with
%    interpolated shading. note that in this case 
%    the function AREA3LEGEND can only correct work if the option
%    LegendSym is set to 'wall'. If set to 'roof', you'll get a warning
%    message from Matlab,of course.
% options.LegendSym
%    this option defines with which handle the legend will be 
%    created, ether the string 'wall' or 'roof' and 'none' for no legend.
% options.LegendText
%    a cell with the strings used for the legendtext. if an empty cell 
%    is supplied, the function creates automatically a legendtext. this
%    will also happen, if the number of strings does not match the number 
%    of bars.
% options.TScaling
%    a "transparency scaling" option. this is a 3-by-2 matrix consisting
%    of scalars between 0 and 1. the meaning behind is like the 
%    following:
%    options.TScaling=[Facealpha_Startvalue_Floor   Facealpha_Endvalue_Floor ;
%                      Facealpha_Startvalue_Walls   Facealpha_Endvalue_Walls ; 
%                      Facealpha_Startvalue_Roof   Facealpha_Endvalue_Roof],
%    with linear interpolation between the start and the end values.
% options.Edgecolor
%    a string defining the color of the edges. see PLOT for more details.
%    = 'none' for no color.
% options.Linestyle
%    also a string. the linestyle of the lines drawn. see PLOT for more details.
%    = 'none' for no line.
%
% This function calls AREA3LEGEND. 

% Please note: I have written this function for my own purposes, so some of 
% the features may not fully satisfy you. If you have suggestions (or something
% like that), please feel free to mail me.
% Tested with Matlab 6.0, but it should also work with older versions.
% DH/3Ap2004, (mailto:dirk.heber@gmx.de)
%
% _____________________________________________________________________
%

if nargin==0
    [out1,out2]=area3demo;
    if nargout > 0
        outhandle=out1;
        outarea3options=out2;
    end;
    return;
end;

% the demo is only called with no input arguments passed:
if nargin > 0 
    if ~exist('x','var') |  ~exist('y','var') | ~exist('z','var')
       error('Not enough input arguments!');
    end;
end;

if exist('x','var') & exist('y','var') & exist('z','var')
    y=y(:); y=y';
    [rx,cx]=size(x); [ry,cy]=size(y); [rz,cz]=size(z);
    if size(x) ~= size(z)
        error('Matrix dimensions of input arguments x and z must agree!');
    end;
    if cy ~= rx & cy ~= rz
         error('Matrix dimensions of input argument y must fit x and z!');
    end;
    
end;    

% default options:
area3default=struct('barwidth',0.4,'ColormapWall','cool',...
                     'ColormapRoof','cool','FacealphaWall',0.41,...
                     'FacealphaRoof',0.81,'FacealphaFloor',0.4,...
                     'SurfRoof',0,'LegendSym','wall','LegendText',[],...
                     'TScaling',[0.3 1; 0.3 1; 0.3 1],...
                     'Edgecolor','k','Linestyle','-');

if ~exist('area3options','var')
    area3options=area3default;
end;   

% checking the supplied options:
if exist('area3options','var')
    
if ~isfield(area3options,'barwidth')|...
        isempty(area3options.barwidth)|...
             area3options.barwidth<=0
    area3options.barwidth=area3default.barwidth;
end;

if ~isfield(area3options,'ColormapWall')|...
        isempty(area3options.ColormapWall)
    area3options.ColormapWall=area3default.ColormapWall;
end;

if ~isfield(area3options,'ColormapRoof')|...
       isempty(area3options.ColormapRoof)
    area3options.ColormapRoof=area3default.ColormapRoof;
end;

if ~isfield(area3options,'FacealphaWall')|...
       isempty(area3options.FacealphaWall)
    area3options.FacealphaWall=area3default.FacealphaWall;
end;

if ~isfield(area3options,'FacealphaRoof')|...
       isempty(area3options.FacealphaRoof)
    area3options.FacealphaRoof=area3default.FacealphaRoof;
end;

if ~isfield(area3options,'FacealphaFloor')|...
       isempty(area3options.FacealphaFloor)
    area3options.FacealphaFloor=area3default.FacealphaFloor;
end;

if ~isfield(area3options,'LegendSym')
    area3options.LegendSym=area3default.LegendSym;
end;

if ~isfield(area3options,'SurfRoof')|...
      isempty(area3options.SurfRoof)
    area3options.SurfRoof=area3default.SurfRoof;
end;

% the TScaling option
if ~isfield(area3options,'TScaling')
    area3options.TScaling=area3default.TScaling;
end;

if ~isfield(area3options,'Linestyle')|...
      isempty(area3options.Linestyle) 
        area3options.Linestyle=area3default.Linestyle;
end;

if ~isfield(area3options,'Edgecolor')|...
      isempty(area3options.Edgecolor) 
        area3options.Edgecolor=area3default.Edgecolor;
end;

% checking the supplied legendtext:
% must be a cell array
if ~isfield(area3options,'LegendText')|...
        isempty(area3options.LegendText)|...
           ~iscellstr(area3options.LegendText)|...
              ndims(area3options.LegendText)~=ndims(y) 
        area3options.LegendText=area3default.LegendText;
end;

end; % end of checking

% set the colormap limits to correspond with the error
elim=[min(E(:)) max(E(:))];
if elim(1)>0,elim(1)=0;end
if elim(2)<0,elim(2)=0;end
caxis([min(E(:)) max(E(:))]);

ColormapWall=feval(area3options.ColormapWall,64);
ColormapRoof=feval(area3options.ColormapRoof,64);
spalt=area3options.barwidth;

plotoptions=struct('EdgeColor',area3options.Edgecolor,...
                   'LineStyle',area3options.Linestyle);
hold on;
% main loop:
for jj=1:1:cy
    
    xx=[x(jj,1) x(jj,:)  x(jj,cx)];
    yy=ones(1,cx+2)*y(jj);
    zz=[0 z(jj,:) 0];
    ee=[E(jj,1) E(jj,:) E(jj,cx)];
    
    % the two walls:
    wall1(jj)=fill3(xx,yy-spalt/2,zz,ColormapWall(1,:)); 
    wall2(jj)=fill3(xx,yy+spalt/2,zz,ColormapWall(1,:));
    % the roof:
    roof(jj)=surf([xx' xx'],[yy'-spalt/2 yy'+spalt/2],[zz' zz'],[ee' ee']);
    % ...and the floor:
    floor(jj)=surf([xx' xx'],[yy'-spalt/2 yy'+spalt/2],...
                 [zeros(length(zz),1) zeros(length(zz),1)],[ee' ee']); 
             
    % checking the TScaling option 
    if ~isempty(area3options.TScaling)
        [nrowsts,ncolsts]=size(area3options.TScaling);
        tsinput=area3options.TScaling;
        if max(max(tsinput))>1 | min(min(tsinput))<0
           error('The FaceAlpha values must be scalar values between 0 and 1!');
        end;
       
      
       % creating the interpolation matrix
       tsscal=[linspace(tsinput(1,1),tsinput(1,2),length(y));
               linspace(tsinput(2,1),tsinput(2,2),length(y));
               linspace(tsinput(3,1),tsinput(3,2),length(y))];
        
       set(wall1(jj),'FaceAlpha',tsscal(2,jj),plotoptions);   
       set(wall2(jj),'FaceAlpha',tsscal(2,jj),plotoptions);   
       
       if  area3options.SurfRoof == 1
          set(roof(jj),'FaceAlpha',tsscal(3,jj),...
              'FaceColor','interp',plotoptions); 
          set(floor(jj),'FaceAlpha',tsscal(1,jj),...
              'FaceColor','interp',plotoptions);       
          colormap(ColormapRoof);
       else
          set(roof(jj),'FaceColor',ColormapRoof(jj,:),...
                       'FaceAlpha',tsscal(3,jj),plotoptions);          
          set(floor(jj),'FaceColor',ColormapRoof(jj,:),...
                         'FaceAlpha',tsscal(1,jj),plotoptions);  
       end;
    
    % if not TScaling then the common options will work
    else
             
      set(wall1(jj),'FaceAlpha',area3options.FacealphaWall,...
          plotoptions);
      set(wall2(jj),'FaceAlpha',area3options.FacealphaWall,...
          plotoptions);
    
      if  area3options.SurfRoof == 1
          set(roof(jj),'FaceAlpha',area3options.FacealphaRoof,...
              'FaceColor','flat',plotoptions);
          set(floor(jj),'FaceAlpha',area3options.FacealphaFloor,...
              'FaceColor','flat',plotoptions);       
          colormap(ColormapRoof);
      else
          set(roof(jj),'FaceColor',ColormapRoof(jj,:),...
              'FaceAlpha',area3options.FacealphaRoof,plotoptions);
          set(floor(jj),'FaceColor',ColormapRoof(jj,:),...
              'FaceAlpha',area3options.FacealphaFloor,plotoptions);    
      end;
    
    end; 
        
end; % end of main loop


% preparing the outputs of area3 and the inputs to area3legend:
switch lower(area3options.LegendSym)
case 'wall'
    %area3legend([wall2],area3options.LegendText);
    outh=wall2;
case 'roof'
    %area3legend([roof],area3options.LegendText);
    outh=roof;
case 'none'
    outh=wall2;
end;

% output the options for further use: 
if nargout > 0
   outarea3options=area3options;
   outhandle=outh;
end;

% some viewpoints:
axis tight;
view([-40 30]);

% END OF AREA3 -----------------------------------------------------



% ------------------------------------------------------------------
function [ha,opt]=area3demo;
%
% Demo function for area3.
%
% DH/3Ap2004

% example data: ---------------------
x=repmat(linspace(1,7,4),4,1);

y=[1 3 5 7];

z=[-3.0 -1.5 -0.4 0.0 ;
    0.1  0.3  0.3 0.9 ;
    1.0  1.5  1.9 2.6 ;
    2.0  3.2  3.5 4.9 ];

z2=[-4.1 -2.7 -2.5 -2.1 ;
    -0.4 -0.9 -0.1  0.5 ;
     0.4  0.5  0.8  1.6 ;
     2.0  2.6  3.9  4.5 ];

x3=meshgrid(1:1:6);
y3=[1:1:6];
z3=rand(size(x3));;

% plots ---------------------------------------------

figure;

% subplot 1 : ----------------------------

opt1=struct('barwidth',1.2,'FacealphaWall',0.3,...
     'FacealphaRoof',1,'FacealphaFloor',0.1,...
'TScaling',[],'ColormapWall','winter','ColormapRoof','spring',...
'Edgecolor','k','Linestyle','-','LegendSym','roof');

opt1.LegendText={'\bfdata from x','data from y',...
           'data from z','data from #+*?#'};

subplot(2,2,1);
area3(x,y,z+3,opt1);
view([46 18]);


% subplot 2 : ---------------------------

opt2=struct('barwidth',0.4,'TScaling',[1 1;1 1;1 1],...
    'ColormapWall','winter','ColormapRoof','spring',...
    'SurfRoof',1,'Edgecolor','k','Linestyle','-','LegendSym','wall');


subplot(2,2,2)
area3(x3,y3,z3+3,opt2);
view([-66 50]);

% subplot 3 : --------------------------

opt3=struct('TScaling',[0.1 1;0.1 1;0.1 1],...
    'ColormapWall','cool','ColormapRoof','cool',...
    'SurfRoof',0,'Edgecolor','k','Linestyle','-','LegendSym','none',...
    'barwidth',1);

subplot(2,2,3)
area3(x,y,z+3,opt3);


% subplot 4 : -------------------------

opt4=struct('barwidth',1.2,'FacealphaWall',0.1,...
     'FacealphaRoof',0.41,'FacealphaFloor',0.1,...
'TScaling',[],'ColormapWall','spring','ColormapRoof','spring',...
'Edgecolor','k','Linestyle','-','LegendSym','roof',...
'SurfRoof',0);

opt4.LegendText={'\bfdata from x','data from y',...
        'data from z','data from #+*?#'};


opt5=struct('barwidth',1.2,'FacealphaWall',1,...
     'FacealphaRoof',1,'FacealphaFloor',1,...
'TScaling',[],'ColormapWall','winter','ColormapRoof','winter',...
'Edgecolor','k','Linestyle','-','LegendSym','roof',...
'SurfRoof',0);


subplot(2,2,4)
hold on
[ha4,opt4]=area3(x,y,z+3,opt4);
[ha5,opt5]=area3(x,y+10,z2+4,opt5);
area3legend(ha4,opt4.LegendText,ha5,[]);
view([65 30])
hold off


% ----------------------------------------
if nargout>0
    ha=ha5;
    opt=opt5;
end;
% END OF AREA3DEMO   ----------------------------------------------