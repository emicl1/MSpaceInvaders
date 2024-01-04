classdef Alien < GameObject
    % class for intercating with one alien
    methods
        % Constructor
        function obj = Alien(name, x, y, width, height, UIfigure)
            obj@GameObject(name, x, y, width, height, UIfigure);
        end
        
        %BASIC MOVEMENT FUNCTIONS
         function obj = move(obj, stepSize, direction)
                if direction == "left"
                     obj.x = obj.x - stepSize;
                elseif direction == "right"
                    obj.x = obj.x + stepSize;
                end
                obj.updatePosition();
         end     

        function obj = moveDown(obj, stepSize)
            obj.y = obj.y + stepSize;
            obj.updatePosition();
        end
        
        %SHOOOT THEM 
        function bullet = shoot(obj)
            % Determine the path to the resources directory
            currentFilePath = mfilename('fullpath');
            [currentDir, ~, ~] = fileparts(currentFilePath);
            resourcesDir = fullfile(currentDir, '..', 'resources');
        
            % Full path to the image file
            imagePath = fullfile(resourcesDir, 'fish.png');
        
            % Rest of the shoot method
            figWidth = obj.UIfigure.Position(3);
            figHeight = obj.UIfigure.Position(4);
        
            bulletX = obj.x - obj.width / 2; % Adjust to shoot from the center/top of the alien
            bulletY = obj.y - obj.height;
            bulletWidth = figWidth / 27; 
            bulletHeight = figHeight / 27; 
            bullet = Bullet(imagePath, bulletX, bulletY, bulletWidth, ...
                            bulletHeight, obj.UIfigure);
        end

    end
end
