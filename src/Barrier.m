classdef Barrier < GameObject
    properties
        ImageData  % Additional property to store the image data
    end
    
    methods
        % Constructor
        function obj = Barrier(name, x, y, width, height, UIfigure)
            obj@GameObject(name, x, y, width, height, UIfigure);
            
            % Read and store the image data
            obj.ImageData = imread(name);
            obj.ImageObject.ImageSource = name;
        end
        
        
        %PROBLEM FUNCTION
        %TODO: fix it :]
        %PROBLEM: function can't recongnize if the image is black
        % and thanks to this doesn't delete the picture, when it takes
        % enough hits.
        %QUICK FIX: init a taken hits variable and delete the barrier
        %if enoguh hits are taken. CONS: isn't that cool
        function hitByBullet(obj)
            if ~isvalid(obj.ImageObject)
                return
            end
            
            % Find indices of non-black pixels
            nonBlackPixelsMatrix = sum(obj.ImageData, 3) ~= 0; % true for non-black pixels, false otherwise
            indexOfNonBlackPixels = find(nonBlackPixelsMatrix); % linear index of non-blackPixels
            
            % Determine the number of pixels to change
            numPixelsToChange = round(numel(nonBlackPixelsMatrix) / 6);  % 1/6 of all pixels -> barrier need 6 hits to be destroyed
            
            % Randomly select pixels to turn black
            if length(indexOfNonBlackPixels) > numPixelsToChange
                pixelsToBlacken = indexOfNonBlackPixels(randperm(length(indexOfNonBlackPixels), numPixelsToChange));
            else
                pixelsToBlacken = indexOfNonBlackPixels;
            end
            
            % Change selected pixels to black
            for thisPixelIndex = pixelsToBlacken'
                % Convert linear index back to subscript indices
                [row, col] = ind2sub(size(nonBlackPixelsMatrix), thisPixelIndex);
                
                obj.ImageData(row, col, :) = 0;
            end
            
            obj.ImageObject.ImageSource = obj.ImageData;
                       
            if isempty(find(obj.ImageData, 1))
                delete(obj.ImageObject);
            end
        end
    end
end

