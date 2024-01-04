classdef Bullet < GameObject
    % Universal bullet class
    methods
        % Constructor
        function obj = Bullet(name, x, y, width, height, UIfigure)
            obj@GameObject(name, x, y, width, height, UIfigure);
        end

        %BASIC MOVEMENT CLASSES 
        function obj = moveUp(obj, stepSize)
            obj.y = obj.y + stepSize;
            obj.updatePosition();
        end
        function obj = moveDown(obj, stepSize)
            obj.y = obj.y - stepSize;
            obj.updatePosition();
        end
    end
end


