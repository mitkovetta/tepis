function [r c] = nonmaxsupp(I, radius, threshold)
% Non-maxima suppression.
%
% Usage:
% ------
% [r c] = nonmaxsupp(I, radius, threshold);
% [r c] = nonmaxsupp(I, radius);
% [r c] = nonmaxsupp(I);
%
% Input arguments:
% ----------------
% I: Grayscale image.
%
% Optional input arguments:
% -------------------------
% radius: Radius of the region for non-maxima suppression (default: 1). 
% threshold: Maxima below the specified threshold value are ignored
% (defailt: -inf).
%
% Output arguments:
% -----------------
% r, c: Row and column coordinates of the detected maxima.
%
% -------------------------------------------------------------------------
% Author: Mitko Veta (mitko@isi.uu.nl)
%
% Copyright (c) 2014 TraiT (http://www.ctmm-trait.nl/)
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the 
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
% 
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.
%

if ~exist('radius', 'var') || isempty(radius)
    radius = 1;
end

if ~exist('threshold', 'var') || isempty(threshold)
    threshold = -inf;
end

se = strel('disk', radius, 4);

E = imdilate(I, se);

M = E == I;

T = I > threshold;

[r c] = find(M & T);

end
