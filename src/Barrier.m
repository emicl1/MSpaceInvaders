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
            nonBlackBlocksMatrix = squeeze(sum(sum(reshape(nonBlackPixelsMatrix,64,16,64,16),1), 3)); % finds non-black blocks of size 64x64, see https://stackoverflow.com/questions/26280418/sum-over-blocks-in-a-2d-matrix-matlab
            indexOfNonBlackPixels = find(nonBlackBlocksMatrix); % linear index of non-blackPixels
            
            % Determine the number of blocks to make black
            numBlocksToChange = round(numel(nonBlackBlocksMatrix) / 6);  % 1/6 of all pixels -> barrier need 6 hits to be destroyed
            
            % Randomly select blocks to turn black
            if length(indexOfNonBlackPixels) > numBlocksToChange
                blocksToBlacken = indexOfNonBlackPixels(randperm(length(indexOfNonBlackPixels), numBlocksToChange));
            else
                blocksToBlacken = indexOfNonBlackPixels;
            end
            
            % Change selected pixels to black
            for thisBlockIndex = blocksToBlacken'
                % calculate linear index of all pixels in given block...
                % its magic :D
                nonBlackPixelsInds = rem(thisBlockIndex-1, 16)*64 + repmat((1:64).', 1, 64) + fix((thisBlockIndex-1)/16)*1024*64 + (0:1024:1024*63);
                
                for thisPixelIndex = nonBlackPixelsInds(:)'
                % Convert linear index back to subscript indices
                    [row, col] = ind2sub(size(nonBlackPixelsMatrix), thisPixelIndex);
                
                    obj.ImageData(row, col, :) = 0;
                end
            end
            
            obj.ImageObject.ImageSource = obj.ImageData;
                       
            if isempty(find(obj.ImageData, 1))
                delete(obj.ImageObject);
            end
        end
    end
end

