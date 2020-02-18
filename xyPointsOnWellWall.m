function [ xList, yList ] = xyPointsOnWellWall( rw, xWell, yWell, pointsNumber )
% from radius of the well calculate the points on the wall of the well.
% pointsNumber = the amount of points

    deltatheta = (2 * pi) / pointsNumber; % in radians the angle which is used to calculate each point on the cirle
    thetaList = deltatheta * [0:pointsNumber-1];

    xList = (cos(thetaList) * rw) + xWell;
    yList = (sin(thetaList) * rw) + yWell;
    
end

