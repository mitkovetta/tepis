function I = byteArrayToImage(byteArray)
% Convert a image data byte array to image matrix.
%
% The image data should be in one of the formats that is supported by
% the Java BufferedImage class (GIF, PNG, JPEG).
%
% Usage:
% ------
% I = byteArrayToImage(byteArray);
%
% NOTE: Make sure that there is sufficient Java heap memory for the
% conversion.
%
% ---------------------------------------------------------------------
% Author: Mitko Veta (MVeta@tue.nl)
%

import java.io.*;
import javax.imageio.*;

try    
    bufferedImage = ImageIO.read(ByteArrayInputStream(byteArray));
    
    h = bufferedImage.getHeight();
    w = bufferedImage.getWidth();
    
    pixels = uint8(bufferedImage.getData.getPixels(0, 0, w, h, []));    
catch e
    error('Error converting image.');
end

I = uint8(zeros(h, w, 3));

for i_h = 1:h    
    base = (i_h - 1) * w * 3 + 1;
    
    I(i_h, 1:w, :) = deal(reshape(pixels(base:(base + 3*w - 1)), 3, w)');    
end

end
