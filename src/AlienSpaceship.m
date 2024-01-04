classdef AlienSpaceship < GameObject
    % Mythical spaceship class 
    methods

        % Constructor
        function obj = AlienSpaceship(name, x, y, width, height, UIfigure)
            obj@GameObject(name, x, y, width, height, UIfigure);
        end

        % Movement 
        function obj = move(obj, stepSize, direction)
                if direction == "left"
                     obj.x = obj.x - stepSize;
                elseif direction == "right"
                    obj.x = obj.x + stepSize;
                end

                obj.updatePosition();
        end 

        % Cheking bounds 
        function ret = checkforboundery(obj)
            % it goes from letf to right 
            % so nothing crazy
            figWidth = obj.UIfigure.Position(3);
            ret = false;
            if obj.x > figWidth
                ret = true;
                return
            end
        end

    end
end