classdef GameObject < handle
    % Mother class with basic functions 
    properties
        name
        x 
        y
        width
        height
        UIfigure
        ImageObject 
    end
    
    methods
        % Constructor
        function obj = GameObject(name, x, y, width, height, UIfigure)
            obj.name = name;
            obj.x = x;
            obj.y = y;
            obj.width = width; 
            obj.height = height;
            obj.UIfigure = UIfigure;
            obj.ImageObject = uiimage(UIfigure, 'Position', [x, y, width, height]);
            obj.ImageObject.ImageSource = obj.name;
        end

        % Method to delete the image
        function deleteImage(obj)
            if isvalid(obj.ImageObject)
                
                delete(obj.ImageObject);
            end
        end

        % Update the image position
        function updatePosition(obj)
            try
                obj.ImageObject.Position = [obj.x, obj.y, obj.width, obj.height];
            end
            drawnow;
        end
    end
end

