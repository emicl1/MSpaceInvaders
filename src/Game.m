classdef Game < handle
    % MAIN GAME CLASS 
    % handles game loop, game logic, game object, sometimes it handles me 
    % Comments are explaing just the code, if tou want game explanation 
    % and other stuff check README 
    properties
        monitorPositions
        selectedMonitor
        fig
        alienfleets
        player
        movingRight % Boolean to track if fleets are moving right
        edgeReached % Boolean to track if edge has been reached
        bulletsship
        bulletsalien
        barriers
        lives
        nonmodifiedstepsize 
        stepsize
        stepsizeTimer
        increasesize
        score 
        scoreboard
        gameOverText
        bulletspeed
        lastShotTime  
        shotInterval
        alienship
        alienspaceshipinterval
        alienshipcounter
    end

    methods
        % Constructor
        function obj = Game(selectedMonitor)
            if nargin < 1
                selectedMonitor = 1; % Default to primary monitor if not specified
            end

            % Get positions and sizes of all monitors
            obj.monitorPositions = get(groot, 'MonitorPositions');
            obj.selectedMonitor = selectedMonitor;

            % Extract selected monitor's dimensions

            monitorWidth = obj.monitorPositions(selectedMonitor, 3);
            monitorHeight = obj.monitorPositions(selectedMonitor, 4);

            % Define margins and figure size
            margin = 90; % Small margin in pixels
            
            figWidth = monitorWidth / 3 + 120; % One-third of the monitor width + some pixels 
            figHeight = monitorHeight -  margin;% Height minus margins

            % Calculate position to center the figure
            figX = (monitorWidth - figWidth) / 2;
            figY = margin;

            % Create the uifigure
            obj.fig = uifigure('Name', 'My UIFigure');
    
            obj.fig.Position = [figX, figY, figWidth, figHeight];
            obj.fig.Color = [0 0 0]; % Set background to black

            % presetting all the obejcts 
            obj.alienfleets = [];
            obj.bulletsship = [];
            obj.bulletsalien = [];
            obj.barriers = [];
            obj.alienship = [];

            obj.lives = 3;
            
            obj.increasesize = 5;

            obj.bulletspeed = 50;
            
            %timer fun 
            obj.stepsize = 20;
            obj.nonmodifiedstepsize = 20;
            obj.stepsizeTimer = timer;
            obj.stepsizeTimer.Period = 10; % Trigger every 10 seconds
            obj.stepsizeTimer.ExecutionMode = 'fixedRate';
            obj.stepsizeTimer.TimerFcn = @(~, ~) obj.updateSpeed();
            start(obj.stepsizeTimer); 

            obj.movingRight = true;  % Initially moving right
            obj.edgeReached = false;

            set(obj.fig, 'CloseRequestFcn', @obj.figureCloseRequest);

            obj.score = 0;
         
            obj.shotInterval = 0.75;
            obj.lastShotTime = tic; % tic to limit player's ability to shoot

            obj.alienspaceshipinterval = randi([1,4]);
            obj.alienshipcounter = 0;
        end
        
        % MAIN FUNCTION WITH MAIN GAME LOOP
        function run(obj)
            % Spawn the objects 
            obj.spawn_enemies();
            obj.spawn_ship();
            obj.spawn_barrier();
            obj.spawn_scoreboard();
            
            %MAIN GAME LOOP
            while true
                
                if obj.lives == 0
                    disp("you've died")
                    obj.displayGameOver();
                    obj.clearspace();
                    break
                end
                
                %HANDLE ALIEN FLEETS 
                %spawns their bullets, checks if any fleets were
                %slaughtered and if they've reached bottom                
                empty_aliens = 0;
                for i = 1:length(obj.alienfleets)
                    num = randi([1, 2]);
                    num2 = randi([1,6]);
                    
                    if num2 == 4
                        bullets = obj.alienfleets(i).shootRandomAliens(num);
                        if ~isempty(bullets)
                        obj.bulletsalien = [obj.bulletsalien, bullets];
                        break
                        end
                    end
                    if isempty(obj.alienfleets(i).Aliens)
                        empty_aliens = empty_aliens + 1;
                    end

                    if obj.alienfleets(i).checkForLowerBoundery()
                        obj.lives = 0;
                    end

                end
                
                % If all fleets were killed, it spawns another fleet
                % and makes their speed bigger. 
                if empty_aliens ==  3    
                    empty_aliens = 0;
                    obj.spawn_enemies();
                    obj.nonmodifiedstepsize = obj.nonmodifiedstepsize + 30;
                    obj.stepsize = obj.nonmodifiedstepsize;
                    obj.increasesize = obj.increasesize + 10;

                end
                
                % Handles mystical alien ship, so that another 
                % ship doesn't spawn when another is flying around
                if obj.alienshipcounter == obj.alienspaceshipinterval
                     if isempty(obj.alienship)
                        obj.spawn_alienship
                     end
                     obj.alienshipcounter = 0;
                     obj.alienspaceshipinterval = randi([1,3]); 
                end
                
                % UPDATE ALL THE POSTIONS
                obj.updateAlienMovement();
                obj.updateBulletsShip();
                obj.updateBulletsAlien();
                obj.updateAlienship();
                           
                pause(0.1);  % Adjust the pause for desired speed
             end
           
        end
        
        % SPAWING METHODS  

        function spawn_scoreboard(obj)
            obj.scoreboard = Scoreboard(obj.fig);
        end
        
          function spawn_ship(obj)
            % Determine the path to the resources directory
            currentFilePath = mfilename('fullpath');
            [currentDir, ~, ~] = fileparts(currentFilePath);
            resourcesDir = fullfile(currentDir, '..', 'resources');
        
            % Full path to the spaceship image file
            spaceshipImagePath = fullfile(resourcesDir, 'spaceship.png');
        
            % Get figure dimensions
            figWidth = obj.fig.Position(3);
            figHeight = obj.fig.Position(4);
            width = figWidth / 10;
            height = figHeight * 0.23;
        
            % Create the player spaceship
            obj.player = Player(spaceshipImagePath, ...
                                (figWidth/2 - width/2), 0, width, height, obj.fig);
        
            % Set the key press function for the figure
            set(obj.fig, 'KeyPressFcn', @obj.keyPressHandler);
        end


        function spawn_enemies(obj)
            % Determine the path to the resources directory
            currentFilePath = mfilename('fullpath');
            [currentDir, ~, ~] = fileparts(currentFilePath);
            resourcesDir = fullfile(currentDir, '..', 'resources');
        
            % Create a list of full paths for alien images
            alien_filenames = {'crab.png', 'jellyfish.png', 'octopus.png'};
            alien_paths = cellfun(@(x) fullfile(resourcesDir, x), alien_filenames, 'UniformOutput', false);
        
            % Get figure dimensions
            figWidth = obj.fig.Position(3);
            figHeight = obj.fig.Position(4);
        
            % Define the size for the alien fleets
            alienSpaceWidth = figWidth / 17;  
            width = alienSpaceWidth * 1;  % Width of each alien
            height = figHeight * 0.1; % Height of each alien
        
            % Define the starting position for the alien fleets
            startX = alienSpaceWidth * 3;
            startY = figHeight - height * 4; % Starting y position
            num_of_aliens = 10;  % Number of aliens in a row
        
            % Create alien fleets
            rows_of_aliens = 2;
            obj.alienfleets = [];
        
            for i = 1:length(alien_paths)
                alienFleet = AlienFleet(obj.fig, alien_paths{i}, startX, ...
                            startY + (i-1) * (height + height / 10), alienSpaceWidth, ...
                            height, rows_of_aliens, num_of_aliens, ...
                            obj.monitorPositions, obj.selectedMonitor);              
                obj.alienfleets = [obj.alienfleets, alienFleet];
            end
        end


        function spawn_barrier(obj)
            % Determine the path to the resources directory
            currentFilePath = mfilename('fullpath');
            [currentDir, ~, ~] = fileparts(currentFilePath);
            resourcesDir = fullfile(currentDir, '..', 'resources');
        
            % Full path to the image file
            imagePath = fullfile(resourcesDir, 'barrier.png');
        
            figWidth = obj.fig.Position(3);
            figHeight = obj.fig.Position(4);
            y = obj.player.height;
            height = 1/10 * figHeight;
            width = 1/9 * figWidth;
            for i = 1:3
                x = figWidth/4 * i - figWidth/15;
                obj.barriers = [obj.barriers, ...
                                Barrier(imagePath, x, y, width, height, obj.fig)];
            end
        end


        function spawn_alienship(obj)
            % Determine the path to the resources directory
            currentFilePath = mfilename('fullpath');
            [currentDir, ~, ~] = fileparts(currentFilePath);
            resourcesDir = fullfile(currentDir, '..', 'resources');
        
            % Full path to the image file
            imagePath = fullfile(resourcesDir, 'alienship.png');
        
            figWidth = obj.fig.Position(3);
            figHeight = obj.fig.Position(4);
        
            height = 1/11 * figHeight;
            width = 1/10 * figWidth;
            y = figHeight - height * 2;
            x = 0;
            obj.alienship = AlienSpaceship(imagePath, x, y, width, height, obj.fig);
        end

    
        %UPDATE METHODS  
        function updateAlienship(obj)
            if isempty(obj.alienship)  || ~isvalid(obj.alienship) 
                   return;
            end
            figWidth = obj.fig.Position(3);
            alienstepsize = figWidth/20;
            if obj.alienship.checkforboundery()
                obj.alienship.deleteImage()
                obj.alienship = [];
            end
            try
                obj.alienship.move(alienstepsize, "right");
            
            end
        end


        function updateAlienMovement(obj)
      
            stepDown = 50;  % Define the step size for moving down

            if obj.movingRight                
                % Move all fleets to the right              
                for i = 1:length(obj.alienfleets)                 
                    if obj.alienfleets(i).moveRight(obj.stepsize)
                        
                        obj.edgeReached = true;
                        break;
                    end
                end

                % Check if edge was reached to switch direction and move down
                if obj.edgeReached
                    for i = 1:length(obj.alienfleets)
                        obj.alienfleets(i).moveDown(stepDown);
                    end
                    obj.movingRight = false; % Switch direction
                    obj.edgeReached = false; % Reset edge flag
                end
            else
                % Move all fleets to the left
                for i = 1:length(obj.alienfleets)
                    if obj.alienfleets(i).moveLeft(obj.stepsize)
                        obj.edgeReached = true;
                        break;
                    end
                end

                % Check if edge was reached to switch direction and move down
                if obj.edgeReached
                    for i = 1:length(obj.alienfleets)
                        obj.alienfleets(i).moveDown(stepDown);
                    end

                    obj.movingRight = true; % Switch direction
                    obj.edgeReached = false; % Reset edge flag
                end
            end
        end
        

      function updateBulletsShip(obj)
 
        for i = length(obj.bulletsship):-1:1
            % Move each bullet upwards
            obj.bulletsship(i).moveUp(obj.bulletspeed); 
            % Check for collision with aliens, barriers and alienship

            if obj.checkCollisionAlien(obj.bulletsship(i))
                % Delete the alien and the bullet
                delete(obj.bulletsship(i).ImageObject);
                obj.bulletsship(i) = [];
            
            else if obj.checkCollisionBarrier(obj.bulletsship(i))                   
                delete(obj.bulletsship(i).ImageObject);
                obj.bulletsship(i) = [];
             
            
            else if obj.checkCollisionAlienship(obj.bulletsship(i))
                    obj.alienship.deleteImage();
                    obj.alienship = [];
            end 
            end
            end
        end
    end



        function updateBulletsAlien(obj)
            bulletSpeed = 50;
            for i = length(obj.bulletsalien):-1:1
                % Move each bullet upwards
                obj.bulletsalien(i).moveDown(bulletSpeed);
             
                % Check for collision with barriers and ship
                % if bullet goes under the image it delets it too
                if obj.checkCollisionBarrier(obj.bulletsalien(i))
                    obj.bulletsalien(i).deleteImage();
                    clear obj.bulletsalien(i);
                    obj.bulletsalien(i) = [];
               
                else if obj.checkCollisionShip(obj.bulletsalien(i))
                    disp("we got here")
                    % Delete the alien and the bullet
                    obj.bulletsalien(i).deleteImage();
                    clear obj.bulletsalien(i);
                    obj.lives = obj.lives - 1;
                    obj.bulletsalien(i) = [];
                
                else if obj.bulletsalien(i).y < 0
               
                    obj.bulletsalien(i).deleteImage();
                    clear obj.bulletsalien(i);
                    obj.bulletsalien(i) = [];
                end
                end
                end
            end
            end


    % METHODS TO CHECK COLLSIONS 
   
        function hit = checkCollisionAlien(obj, bullet)
            hit = false;
            for i = 1:length(obj.alienfleets)
                   hitAlien = obj.alienfleets(i).checkCollision(bullet);
                    if ~isempty(hitAlien)
                        hit = true;
                        hitAlien(1).deleteImage;
                        obj.score = obj.score + 10;
                        obj.scoreboard.updateScore(obj.score)
                       
                        return;
                    end
             end
         end 
        

        function hit = checkCollisionShip(obj, bullet)
        hit = false;
        % boundery checks
         if (bullet.x > (obj.player.x - obj.player.width/2)) && ...
                   ((bullet.x < (obj.player.x + obj.player.width/2))) && ...
                   (bullet.y > (obj.player.y - obj.player.height/2)) && ...
                   ((bullet.y < (obj.player.y + obj.player.height/2)))
             
             hit = true;
             
         end
        end 


        function hit = checkCollisionBarrier(obj, bullet)
            hit = false;

            for i = 1:length(obj.barriers)
                try
                    if ~isvalid(obj.barriers(i).ImageObject)
                            obj.barriers(i) = [];        
                    end
                    % boundery checks
                     if (bullet.x < obj.barriers(i).x + obj.barriers(i).width) && ... 
                        (bullet.x + bullet.width > obj.barriers(i).x) && ...  
                        (bullet.y < obj.barriers(i).y + obj.barriers(i).height) && ...  
                        (bullet.y + bullet.height > obj.barriers(i).y - obj.barriers(i).height)
                        
                        obj.barriers(i).hitByBullet()                                          
                        hit = true;
                     end
                end
            end
        end


        function hit = checkCollisionAlienship(obj, bullet)
              hit = false;
            if ~isempty(obj.alienship)
                % boundery checks
                if (bullet.x > (obj.alienship.x - obj.alienship.width)) && ...
                       ((bullet.x < (obj.alienship.x + obj.alienship.width))) && ...
                       (bullet.y > (obj.alienship.y - obj.alienship.height)) && ...
                       ((bullet.y < (obj.alienship.y + obj.alienship.height)))
                 obj.score = obj.score + 100;
                 hit = true;               
                end
            end
        end 
        

        % METHOD FOR PLAYER SHOOITNG
        % makes it easier to deal with time limit for shooting 
        function shoot(obj)
            if toc(obj.lastShotTime) >= obj.shotInterval
                newBullet = obj.player.shoot();
                obj.bulletsship = [obj.bulletsship, newBullet];
                obj.lastShotTime = tic;
            end
        end

        % TIMER FUN METHODS
         function updateSpeed(obj)
             % making it prograsivly faster, thus harder 
             obj.stepsize = obj.stepsize + obj.increasesize; 
             obj.bulletspeed = obj.bulletspeed + 20; 
             disp(['Speed updated to ', num2str(obj.stepsize)]); % Display the updated speed
             % handling if alienship should spawn                      
            obj.alienshipcounter = obj.alienshipcounter + 1;
         end

        function deletetimer(obj)
            stop(obj.stepsizeTimer);
            delete(obj.stepsizeTimer);
        end

        % RESTART FUNCTION
        function restartgame(obj)
            obj.run();
        end

    

        %MENU MAKER 
        function displayGameOver(obj)
        % Calculate font size and label size based on figure size
            fontSize = max(round(min(obj.fig.Position(3), obj.fig.Position(4)) / 20), 12); 
            labelWidth = obj.fig.Position(3) * 0.8;   % 80% of figure width
            labelHeight = obj.fig.Position(4) * 0.4;  % 40% of figure height

            % Calculate position for centered label
            labelX = (obj.fig.Position(3) - labelWidth) / 2;
            labelY = (obj.fig.Position(4) - labelHeight) / 2;

            % Create a label for game over text
            obj.gameOverText = uilabel(obj.fig, ...
                                       'Text', ['GAME OVER', newline, ...
                                                'PRESS S FOR NEXT GAME', newline, ...
                                                'YOUR SCORE IS ' num2str(obj.score)], ...
                                       'FontSize', fontSize, ...
                                       'FontWeight', 'bold', ...
                                       'HorizontalAlignment', 'center', ...
                                       'VerticalAlignment', 'center', ...
                                       'Position', [labelX, labelY, labelWidth, labelHeight]);
            obj.gameOverText.FontColor = [1, 1, 1];  % i prefer white, but anything might be used 
        end

        %MENU TEXT CLEANER 
       function clearGameOverText(obj)
        % Check if the game over text exists and is valid
        if isvalid(obj.gameOverText)
            % Delete the game over text label
            delete(obj.gameOverText);
            obj.gameOverText = [];
            end
        end

        %EVENT HANDLERES 
         function keyPressHandler(obj, ~, event)
              % If player is not initialized or not a Player object, return early
               if isempty(obj.player) || ~isa(obj.player, 'Player')  || ~isvalid(obj.player) 
                   return;
               end
        
            stepSize = 10; % Define the step size
            disp(obj.player.x)
            switch event.Key
                case 'leftarrow'
                    obj.player.move("left", stepSize, obj.fig.Position(3));
                    obj.player.x = obj.player.x - stepSize;
                case 'rightarrow'
                    obj.player.move("right", stepSize, obj.fig.Position(3));
                      obj.player.x = obj.player.x + stepSize;             
                case 'space'
                    obj.shoot();
                case 's'
                    % restart game option
                    obj.lives = 3;
                    obj.stepsize = 20;
                    obj.nonmodifiedstepsize = 20;
                    obj.clearGameOverText();
                    obj.bulletspeed = 50;
                    obj.restartgame();
            end        
         end
        
        % HELPER FOR RESETTING THE GAME 
        function clearspace(obj)
             
            %delte all images 
             for i = 1:3
                obj.barriers(i).deleteImage()          
             end

             for i = 1:length(obj.alienfleets)
                obj.alienfleets(i).deleteAllAliens();
             end 

             for i = 1:length(obj.bulletsalien)
                 obj.bulletsalien(i).deleteImage();
             end

             for i = 1:length(obj.bulletsship)
                 obj.bulletsship(i).deleteImage();
             end
             
             try
                obj.alienship.deleteImage();
                obj.alienship = [];
             end
          
            %empty and resets all the objects 
            obj.barriers = [];
            obj.alienfleets = [];
            obj.bulletsalien = [];
            obj.bulletsship = [];

            obj.player.deleteImage();

            obj.score = 0;
            obj.scoreboard.ScoreLabel.Text = " ";
        end

         %DELETE FUNCTION 

        function figureCloseRequest(obj, src, ~)
            % Code to execute when the figure closes
            disp('Figure is being closed.');

            % Delete the figure
            delete(src);
            
            obj.deletetimer();
        end
    end 
end


