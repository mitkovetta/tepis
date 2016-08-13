function P = processWSI(slide, level, blockSize, net, filterSize)
% Example of block processing a whole slide image with a fully
% convolutional neural network implemented in the Caffe deep learning
% framework (http://caffe.berkeleyvision.org). The function returns a
% probability map for an entire slide level.
%
% The entire probability map is kept in memory so this example is feasible
% only for smaller layers. filterSize is the size of the patches used to
% train the network (it is assumed that the FC network was obtained by
% casting inner product layers to convolutional).
%

% for skipping mostly empty regions
MAX_INTENSITY = 220;

net.blobs('data').reshape([blockSize+filterSize blockSize+filterSize 3 1]);
net.reshape();

% row-column order
levelSize = slide.PixelSize(level, [2 1]);

% padding
p = filterSize/2;

P = zeros(levelSize, 'uint8');

% ignore the border
for row = 1:blockSize:levelSize(1)-blockSize
    for col = 1:blockSize:levelSize(2)-blockSize
        
        disp([row col]);        
        
        I = slide(row-p:row+blockSize-1+p, col-p:col+blockSize-1+p, level);
        
        % for testing purposes: just copy the red channel
        % P(row:row+blockSize-1, col:col+blockSize-1) = I(p+1:end-p, p+1:end-p, 1);
        
        % skip mostly empty regions
        if mean(I(:)) < MAX_INTENSITY
            I = single(permute(I(:,:,[3, 2, 1]), [2, 1, 3]));
            prob = net.forward({I});
            % label "1" is the target class
            prob = permute(prob{1}(:,:,2), [2, 1, 3]);
            P(row:row+blockSize-1, col:col+blockSize-1) = ...
                uint8(255*imresize(prob, [blockSize blockSize], 'nearest'));
        end
        
    end
end

end
