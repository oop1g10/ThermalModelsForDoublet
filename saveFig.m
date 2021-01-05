function saveFig( figName )
%Save figure without title as png file with 300 and 1000 dpi as fig file Matlab figure
% inbuilt matlab fnction savefig does only fig file, while this one also does png file

    fig = gcf;
    fig.Units = 'inches'; %do not allow rescaling of axis
    %remove title
    ax = get(fig,'Children');
    for i = 1:numel(ax)
        if isequal(class(ax(i)), 'matlab.graphics.axis.Axes')
            title(ax(i), ' '); %remove title
            ax(i).XLimMode = 'manual';
            ax(i).XLim = ax(i).XLim;
            ax(i).XTickMode = 'manual';
            ax(i).XTick = ax(i).XTick;
            %ax(i).XTickLabel = ax(i).XTickLabel;
        end
    end
    fig.PaperPositionMode = 'auto';
    
    % Replace dot with comma to be able to save the figure
    figNameNoDots = regexprep(figName, '\.', ','); 
    
    %Check that figure file does not exist, stop otherwise
    figNameNoDotsPng = [figNameNoDots '.png'];
    fileExists = exist(figNameNoDotsPng, 'file') == 2;
    if fileExists
        warning(['Figure already exists: ' figNameNoDotsPng]);
    else
        % Save as PNG file
        print(figNameNoDots,'-dpng','-r300')
%         fprintf('Saving 600 DPI for poster!\n')
%         print(figNameNoDots,'-dpng','-r600')
%         fprintf('Saving 1000 DPI for article!\n')
%         print([figNameNoDots '_1000dpi'],'-dpng','-r1000')
        % Save again as .fig for possible editing
        savefig(figNameNoDots)
    end
end

