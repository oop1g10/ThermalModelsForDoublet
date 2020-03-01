function [ modelBoundary, maxModelDistance ] = calc_modelBoundary( Xmesh, Ymesh, a )
% calculate model boudaries from point and distance between injection and abstraction wells
    % Calculate minimal required model boundary based on distance between injection and abstraction well 
    % to be larger than well locations
    modelBoundary_a = 3 * [-a, -a ; a, a]; % [xmin,ymin;xmax,ymax]
    % Calculate model boundary based on largest absolute given coordinate in x and y directions 
    % works also for single point (i.e. no error produced)
    modelBoundary_mesh = [(min(min(Xmesh))), min(min(Ymesh)); ...
                            max(max(Xmesh)), max(max(Ymesh))];
    % Compare both methods of model boundary calculation for minimum values and choose the minimal one
    modelBoundary_XYmin = min(modelBoundary_a(1,:), modelBoundary_mesh(1,:) );
    % Same for maximum values and choose the maximal one
    modelBoundary_XYmax = max(modelBoundary_a(2,:), modelBoundary_mesh(2,:) );
    % Combine to return result
    modelBoundary = [modelBoundary_XYmin; modelBoundary_XYmax];
    
    % Longest model side
    maxModelDistance = max( modelBoundary(2,1) - modelBoundary(1,1), ... % maxX - minX
                            modelBoundary(2,2) - modelBoundary(1,2) );   % maxY - minY
end

