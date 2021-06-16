function  rotateTest2Struct = rotateTest2Info()
%ROTATETEST2INFO 
% Returns params needed for rotation of points in test 2 Rotated
% because analytical solution assumes injection and pumping wells are on
% the x axis. and this was done for test 1 and now points for test 2 need
% to be rotated so it is valid assumption for test 2.
rotateTest2Struct = struct;

rotateTest2Struct.rotationAngleDeg = 29.2583766941949;
rotateTest2Struct.shiftXA2minusA1Halved = -1.82933;
rotateTest2Struct.shiftYA2minusA1Halved = 0;
rotateTest2Struct.rotationPointX = 4.97;
rotateTest2Struct.rotationPointY = 0;

end

