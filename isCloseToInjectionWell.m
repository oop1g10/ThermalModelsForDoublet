function [ closeToInjWell ] = isCloseToInjectionWell( x, y, a, rw )
% is the stream line xy point close to injection well?
% true or false
% distance of injection well with coordinates (-a, 0) 
   distanceFromInjectionWell = sqrt( (x -(-a))^2 + (y - 0)^2 );
   % old version: a * 0.005 % if streamline end point is closer than 0.5% of well distance
   % point close to well if it is smaller or = to location of wall of the well
   if distanceFromInjectionWell <= rw 
       closeToInjWell = true;
   else
       closeToInjWell = false;       
   end

end

