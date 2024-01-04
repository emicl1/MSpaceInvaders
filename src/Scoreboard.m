classdef Scoreboard < handle
    % Class to mainly display the score 
    % though can be used to maintain the socre too
    properties
        UIFigure    
        ScoreLabel  
        CurrentScore 
    end
    
    methods
        % Constructor
        function obj = Scoreboard(uiFigure)
            obj.UIFigure = uiFigure;
            obj.CurrentScore = 0;

            % Create the label for the score
            obj.ScoreLabel = uilabel(obj.UIFigure);
            obj.ScoreLabel.Position = [10, obj.UIFigure.Position(4) - 30, 200, 30]; % Position at the upper left
            obj.ScoreLabel.Text = 'Score: 0';
            obj.ScoreLabel.FontSize = 21;
            obj.ScoreLabel.FontWeight = 'bold';
            obj.ScoreLabel.FontColor = [0.5, 0.5, 0.5];
        end

        % Method to update the score
        function updateScore(obj, newScore)
            obj.CurrentScore = newScore;
            obj.ScoreLabel.Text = ['Score: ' num2str(obj.CurrentScore)];
        end
    end
end