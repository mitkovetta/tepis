function S = frst(I, radii, alpha, beta, kappa)
% Performs the dark orientation-only fast radial symmetry transform for
% detecting points of interest in an image.
%
% Usage:
% ------
% S = frst(I, radii, alpha, beta, kappa);
% S = frst(I, radii, alpha, beta);
% S = frst(I, radii, alpha);
% S = frst(I, radii);
%
% Input arguments:
% ----------------
% I: Grayscale image.
% radii: Vector with radii reflecting the scale of the points of interest.
%
% Optional input arguments:
% -------------------------
% alpha: Radial strictness (default: 1).
% beta: Sobel gradient magnitude threshold for ignoring small gradients
% (default: max(I(:))/2).
% kappa: Vector with normalization factors, same lenght as radii. If kappa
% is a scalar, the same value is used for all radii  (default: 10 for all
% radii).
%
% Output arguments:
% -----------------
% S: The dark orientation-only fast radial symmetry transform of the input
% image.
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

if ~exist('alpha', 'var') || isempty(alpha)
    alpha = 1;
end
   
if ~exist('beta', 'var') || isempty(beta)
    beta = max(I(:))/5;
end

if ~exist('kappa', 'var') || isempty(kappa)
    kappa = 10*ones(1,length(radii));
elseif isscalar(kappa)
    kappa = kappa*ones(1,length(radii));
end
    
I = double(I);

[rows cols] = size(I);

[gm dx dy] = imSobel(I);

gm = gm + eps;

% normalize the gradient vectors to unit lenght
dx = dx./gm;
dy = dy./gm;

% discard the gradient magnitude
v = gm(:) > beta;

[x, y] = meshgrid(1:cols, 1:rows);

S = zeros(rows,cols);

for i_radii = 1:length(radii);
    
    r = radii(i_radii);
    
    % coordinates of the affected pixels
    px = x - round(r*dx);
    py = y - round(r*dy);
    
    px(px<1) = 1;
    px(px>cols) = cols;
    py(py<1) = 1;
    py(py>rows) = rows;
    
    O = accumarray([py(:), px(:)], v, size(I));
    
    O(O > kappa(i_radii)) = kappa(i_radii);
    
    F = (O./kappa(i_radii)).^alpha;
    
    % clear the border
    F(1,:) = 0;
    F(end,:) = 0;
    F(:, 1) = 0;
    F(:, end-1) = 0;
    
    S = S + r*imGauss(F, 0.25*r);
    
end

S = S ./ length(radii);

end

function G = imGauss(I, s)
% Gaussian filtering.
%

sze = roundToOdd(4*s);

f = fspecial('gaussian', sze, s);

G = imfilter(I, f, 'symmetric', 'conv');

end

function [gm dx dy] = imSobel(I)
% Sobel edge detection.
%

s = [1 0 -1; 2 0 -2; 1 0 -1];

dx = imfilter(I, s , 'symmetric', 'conv');
dy = imfilter(I, s', 'symmetric', 'conv');

gm = sqrt(dx.^2 + dy.^2);

end

function x = roundToOdd(x)
% Round to the nearest odd number.
%

x = ceil(x);
x = x + mod(x-1,2);

end
