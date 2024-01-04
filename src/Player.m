classdef Player < GameObject
    % Player gonna play 
    methods
        % Constructor
        function obj = Player(name, x, y, width, height, UIfigure)
            obj@GameObject(name, x, y, width, height, UIfigure);
        end
    
        % Movement method 
        function obj = move(obj, direction, stepSize, figWidth)
            if direction == "left"
                 % Move left and prevent moving out of bounds
                obj.x = max(obj.x - stepSize, 0);
            elseif direction == "right"
                % Move right and prevent moving out of bounds
                obj.x = min(obj.x + stepSize, figWidth - obj.width); 
            end
            obj.updatePosition();
        end

        % Shooting function
        function bullet = shoot(obj)
            % Determine the path to the resources directory
            currentFilePath = mfilename('fullpath');
            [currentDir, ~, ~] = fileparts(currentFilePath);
            resourcesDir = fullfile(currentDir, '..', 'resources');
        
            % Full path to the image file
            imagePath = fullfile(resourcesDir, 'fish.png');
        
            figWidth = obj.UIfigure.Position(3);
            figHeight = obj.UIfigure.Position(4);
        
            bulletX = obj.x + obj.width / 2; % Adjust to shoot from the center/top of the player
            bulletY = obj.y + obj.height / 1.25;
            bulletWidth = figWidth / 27; 
            bulletHeight = figHeight / 27; 
            bullet = Bullet(imagePath, bulletX, bulletY, bulletWidth, bulletHeight, obj.UIfigure);
        end


    end
end


