function elementsCountComsol = comsolElementsCount(modelMethod, comsolResultsRow)
% return how many elements the total model domain contains fro 3D and 2D models.
    
% Element count in mesh
    if isModel3D( modelMethod )
        % in 3D model only mesh as 2D plane view for plan and profile were exported
        % the total number of elements was not exported
        % therefore Total number of elements was recorded manualy and are taken from the table below
        elementsCount3D = table;
        % EXAMLE VALUES. for 3D model needs to be updated
        error('STOP :O, values for 3D doublet are not updated yet!!!')
        elementsCount3D.maxMeshSize = [ ...
                                    0.037; ...
                                    0.038; ...
                                    0.039; ...
                                    0.04; ...
                                    0.041; ...
                                    0.044; ...
                                    0.045; ...
                                    0.046; ...
                                    0.047; ...
                                    0.048; ...
                                    0.049; ...
                                    0.05; ...
                                    0.06; ...
                                    0.07; ...
                                    0.08];
        elementsCount3D.comsolElementsCount = [ ...
                                        2402426; ...
                                        2150660; ...
                                        1922846; ...
                                        1658972; ...
                                        1450320; ...
                                        1095436; ...
                                        1041269; ...
                                        963370; ...
                                        922163; ...
                                        792995; ...
                                        736659; ...
                                        687308; ...
                                        409133; ...
                                        271272; ...
                                        238071 ];
        elementsCountComsol = elementsCount3D.comsolElementsCount(elementsCount3D.maxMeshSize == comsolResultsRow.maxMeshSize{1}); 
        if isempty(elementsCountComsol)
            error('The required mesh was not tested for 3D model :(')
        end
    else % for 2D model
        % based on the delaunay triangulation, count how many elements model contains.
        elementsCountComsol = size(comsolResultsRow.delaunayTriang{1}.ConnectivityList, 1); 
    end         
end

