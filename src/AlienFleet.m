classdef AlienFleet < handle
    % Class is used to spawn mutiple aliens 
    % and is used to move them around in a 
    % nice way
    properties
        Aliens % Array of Alien objects
        UIfigure % The uifigure on which the aliens are drawn
    end
    
    methods
        % Constructor
        function obj = AlienFleet(uiFig, alienName, startX, startY, width, ...
                height, rows, numAliensPerRow, monitorPosition, selectedMonitor)
            obj.UIfigure = uiFig;
            obj.Aliens = [];
            
            % Get dimensions of the selected monitor
            monitorWidth = monitorPosition(selectedMonitor, 3);
            monitorHeight = monitorPosition(selectedMonitor, 4);

            % Spacing constants
             xSpacing = width/10; %spacing is witdth/ times the aliens
             ySpacing = height/10; %same thing 
               
            % Create aliens in rows
            for row = 1:rows
                for col = 1:numAliensPerRow
                    x = startX + (col-1) * (width + xSpacing);
                    y = startY + (row-1)*(height/2 + ySpacing);
                  
                    % Create and add an Alien object to the array
                    alien = Alien(alienName, x, y, width, height, uiFig);
                    obj.Aliens = [obj.Aliens, alien];
                end
            end
        end
        
        function edgeReached = moveRight(obj, stepSize)
            edgeReached = false; 
            figWidth = obj.UIfigure.Position(3);  
            
            % Check if any alien on the right edge will go out of bounds
            for i = 1:length(obj.Aliens)
                if (obj.Aliens(i).x + obj.Aliens(i).width + stepSize) > figWidth
                    edgeReached = true;
                    return;  % Stop moving if edge is reached
                end
            end

            % Move each alien in the fleet if edge is not reached
            if ~edgeReached
                for i = 1:length(obj.Aliens)
                    obj.Aliens(i).move(stepSize, "right");
                    
                end
            end
        end


        function edgeReached = checkForLowerBoundery(obj)
            edgeReached = false; 
            for i = 1:length(obj.Aliens)
                if (obj.Aliens(i).y - obj.Aliens(i).height) < 0 
                    edgeReached = true;
                    return;  % Stop moving if edge is reached
                end
            end
        end
        
        function edgeReached = moveLeft(obj, stepSize)
            edgeReached = false;  % Initialize return value

            % Check if any alien on the left edge will go out of bounds
            for i = 1:length(obj.Aliens)
                if (obj.Aliens(i).x - stepSize) < 0
                    edgeReached = true;
                    return;  % Stop moving if edge is reached
                end
            end

            % Move each alien in the fleet if edge is not reached
            if ~edgeReached
                for i = 1:length(obj.Aliens)
                    obj.Aliens(i).move(stepSize, "left");
                end
            end
        end
        
       function moveDown(obj, stepSize)
            for i = 1:length(obj.Aliens)
                obj.Aliens(i).y = obj.Aliens(i).y - stepSize;
                obj.Aliens(i).updatePosition();
            end
       end

       function hitAlien = checkCollision(obj, bullet)
            hitAlien = [];  % Initialize as empty, indicating no hit

            for i = 1:length(obj.Aliens)
                alien = obj.Aliens(i);
                % Check for overlap between bullet and alien
                if (bullet.x < (alien.x + alien.width)) && ...
                   ((bullet.x + bullet.width) > alien.x) && ...
                   (bullet.y < (alien.y + alien.height)) && ...
                   ((bullet.y + bullet.height) > alien.y)
                    % Collision detected
                    obj.Aliens(i) = [];
                    hitAlien = alien;
                    return;  % Return the hit alien
                end
            end
       end

        %method that lets random aliens shoot 
        function bullets = shootRandomAliens(obj, numAliensToShoot)
            numAliens = numel(obj.Aliens); % Total number of aliens
            bullets = []; 

            if numAliens == 0 || numAliensToShoot <= 0
                return; % No aliens to shoot or invalid number of shooters
            end

            % Select random unique indices for aliens to shoot
            shootingIndices = randperm(numAliens, min(numAliensToShoot, numAliens));

            % For each selected alien, make it shoot and collect the bullet
            for idx = shootingIndices
                newBullet = obj.Aliens(idx).shoot();
                bullets = [bullets, newBullet];
            end
        end 
        
        % Method to delete all aliens
        function deleteAllAliens(obj)
            for i = 1:length(obj.Aliens)
                obj.Aliens(i).deleteImage();
            end
            obj.Aliens = [];
        end
        end
    end

