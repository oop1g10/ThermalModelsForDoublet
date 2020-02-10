function [ modelBoundary, maxModelDistance ] = calc_modelBoundary( Xmesh, Ymesh )
% model boudaries
    modelBoundary = [min(min(Xmesh)), min(min(Ymesh)); max(max(Xmesh)), max(max(Ymesh))];
    % longest model side
    maxModelDistance = max( modelBoundary(2,1) - modelBoundary(1,1), ... % maxX - minX
                            modelBoundary(2,2) - modelBoundary(1,2) ); % maxY - minY

end

