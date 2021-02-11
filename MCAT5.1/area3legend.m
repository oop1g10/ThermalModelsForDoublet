function [outlegendhandle]=area3legend(varargin);
%
% AREA3LEGEND creates a legend for AREA3
% 
%    Syntax:
%    [legend_handle]=AREA3LEGEND(ha1,txt1,ha2,txt2,...);
%    
%    Inputs:
%    ha     handle or vector of handles 
%    txt    legendtext (== area3options.LegendText)
%           if an empty field is supplied the text is
%           automatically created.

% Intended for use with AREA3. Tested under Matlab 6.
% DH/3Ap2004,(mailto:dirk.heber@gmx.de)
%

% the default position of the legend
DefaultPos=1;

if isempty(varargin)
    error('Not enough input arguments for this function!');
end;

[nrows,ncols]=size(varargin);
if rem(ncols,2)>0 
    error('Wrong number of arguments in AREA3LEGEND');
end;

% for splitting the varargin
f1=linspace(1,length(varargin)-1,length(varargin)/2);
f2=linspace(2,length(varargin),length(varargin)/2);
index=[f1;f2];

for jjj=1:1:length(varargin)/2
    inputs.ha{jjj}=varargin{index(1,jjj)};
    inputs.legte{jjj}=varargin{index(2,jjj)};
end;


 numberdata=[];
 legendtext=[];

for kkk=1:1:length(varargin)/2
    if isempty(inputs.ha{kkk})
        error('Missing entry for required handle!');
    end;
    
    if isstr(inputs.ha{kkk})
        error('Invalid supplied handle!');
    end;
    
    if  isempty(inputs.legte{kkk}) | ~iscell(inputs.legte{kkk})|...
            ~iscellstr(inputs.legte{kkk}) |...
                 length(inputs.ha{kkk})<length(inputs.legte{kkk}) |...
                    length(inputs.ha{kkk})>length(inputs.legte{kkk})
         gentext=[];
         for vvv=1:1:length(inputs.ha{kkk})
             gentext{vvv}=(['Data ',int2str(vvv),' (',int2str(kkk),')']);
         end;
         inputs.legte{kkk}=gentext;
    end;
    
    zwha=inputs.ha{kkk};
    inputs.ha{kkk}=zwha(:);
    
    zwlegte=inputs.legte{kkk};
    inputs.legte{kkk}=zwlegte(:);
    
    numberdata=[numberdata; inputs.ha{kkk}];
    legendtext=[legendtext; inputs.legte{kkk}];
end;

if nargout > 1
    error('Too many output arguments from this function!');
else
    outlegendhandle=legend([numberdata],legendtext,DefaultPos);
end;

% END OF AREA3LEGEND ----------------------------------------------------------










