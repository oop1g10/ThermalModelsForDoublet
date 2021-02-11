function tpage(progname,author,elps)

% function tpage(progname,author,elps)
%
% flashes up an IC title page
%
% progname is the program name string
% author is the author and date string
% elps is the pause time
%
% Matlab 5 version, M.Lees, Imperial College, April 1998

% requires loadbmp, cres.bmp, logo.bmp

[xl,mapl]=loadbmp('su_logo');
[xc,mapc]=loadbmp('su_crest');
bgc=[1 1 0];
txtc=[0 0 .3333];
mapl(xl(1,1),:)=bgc;
mapc(xc(1,1),:)=bgc;
ssize=get(0,'screensize');
%px=ssize(3)/2-250;
px=ssize(3)/2;
%py=ssize(4)/2-125;
py=ssize(4)/2;
fth=figure('Position',[px py 500 250],'IntegerHandle','off'...
  ,'menu','none','color',bgc,'resize','off');
set(gcf,'defaultaxesunits','pixels')
axes('visible','off')
teh=text(1,0.5,progname);
set(teh,'fontsize',30,'color',txtc,'Position',[100 200 0]);
teh=text(1,0.7,[setstr(169) ' ' author]);
set(teh,'fontsize',12,'color',txtc,'Position',[50 10 0]);
axes('position',[50 20 267 102])
image(xl);
colormap(mapl);
set(gca,'visible','off');
axes('position',[350 19 101 105])
image(xc);
colormap(mapc);
set(gca,'visible','off');
colormap(mapl);
pause(elps)
close(fth);