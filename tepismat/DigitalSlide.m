classdef DigitalSlide < ImageAdapter
    % Provides access to digital slides stored on a Philips IMS.
    %
    % Basic usage:
    % ------------
    % Login to the tEPIS server:
    % DigitalSlide.login('https://<domain>/', '<username>', '<password>');
    %
    % Create a digital slide object:
    % slide = DigitalSlide('<image-ID>');
    %
    % Read a region of size 1000-by-1000 pixels from the top level of the
    % slide and the lowest (largest) level:
    % I = slide.getImagePixelData(0, 0, 1000, 1000);
    %
    % Read a region of size 1000-by-1000 pixels from the top level of the
    % slide and the second level:
    % I = slide.getImagePixelData(0, 0, 1000, 1000, 'level', 1);
    %
    % Read the macro image of the slide:
    % I = slide.getAssociatedImage('macro');
    %
    % Subscripted referencing:
    % ------------------------
    % The class supports easy access to the image data by  subscripted
    % referencing in the following formats:
    % I = slide(rows, cols);
    % I = slide(rows, cols, level);
    % I = slide(rows, cols, level, colorChannel);
    %
    % If not specified, the lowest level and all color channels are
    % returned by default.
    %
    % Note that the subscripted indices begin from '1' instead of '0' and
    % are in row-column order to comply with the MATLAB style. The colon
    % (':') operator is supported for rows, columns and color channel
    % only. The 'end' keyword is supported for level and color channel
    % only.
    %
    % Block processing:
    % -----------------
    % DigitalSlide inherits from the ImageAdapter class, which enables the
    % use of the blockproc function from the Image Processing Toolbox.
    % Prior to the using blockproc, the BlockProcessingLevel propery needs
    % to be set.
    %
    % For example, this applies someFunction to each distinct 1000-by-1000
    % block from the larges level of the slide and stores the results in B:
    % slide.BlockProcessingLevel = 0;
    % B = blockproc(slide, [1000 1000], @(X)someFunction(X.data));
    %
    % Slide display:
    % --------------
    % The DigitalSlide.show method implements slide visualization
    % functionalities similar to the MATLAB imshow function. The level from
    % which the image data is read is automatically determined based on the
    % displayed area and the (optional) targetResolution argument.
    %
    % Example:
    % slide.show();
    %
    % Tissue microarray (TMA) support:
    % --------------------------------
    % The class supports handling of TMA slides by implementing detection
    % and visualization of TMA cores and retrival of image data for
    % inividual TMA cores.
    %
    % Example:
    % slide.detectTMACores();
    % slide.show();
    % slide.plotTMACores();
    % I = getTMACore(1);
    %
    % Troubleshooting:
    % ----------------
    % URL errors may be caused by untrusted security certificate of the
    % Philips IMS server. See this answer in MATLAB Central for solution:
    % http://www.mathworks.com/matlabcentral/answers/92506
    %
    % See also: login, getImagePixelData, getTiledImagePixelData,
    % getAssociatedImage, show, blockproc, ImageAdapter, ImageID, Metadata,
    % BlockProcessingLevel
    %
    % ---------------------------------------------------------------------
    % Author: Mitko Veta (mitko@isi.uu.nl)
    %
    % Copyright (c) 2014 TraiT (http://www.ctmm-trait.nl/)
    %
    % Permission is hereby granted, free of charge, to any person obtaining
    % a copy of this software and associated documentation files (the
    % "Software"), to deal in the Software without restriction, including
    % without limitation the rights to use, copy, modify, merge, publish,
    % distribute, sublicense, and/or sell copies of the Software, and to
    % permit persons to whom the Software is furnished to do so, subject to
    % the following conditions:
    %
    % The above copyright notice and this permission notice shall be
    % included in all copies or substantial portions of the Software.
    %
    % THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    % EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    % MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    % NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
    % BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
    % ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    % CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    % SOFTWARE.
    %
    
    properties (GetAccess = public, SetAccess = private)
        
        % Unique image ID on the server (string).
        ImageID;
        
        % Structure containing the image metadata.
        %
        % Fields:
        % -------
        % numberOfLevels: 1-by-1 double.
        % pixelSize: numberOfLevels-by-2 double.
        % physicalOrigin: numberOfLevels-by-2 double.
        % physicalSpacing: numberOfLevels-by-2 double.
        % scanFactor: numberOfLevels-by-1 double.
        % isNativeLevel: numberOfLevels-by-1 logical.
        % isLossyCompressed: numberOfLevels-by-1 logical.
        % tileSize: numberOfLevels-by-2 double.
        %
        Metadata;
        
        % Code version used to create the object.
        Version = DigitalSlide.CURRENT_VERSION;
        
        % Time when the object was created.
        Timestamp = now;
        
        % List of tissue microarray core locations.
        TMACores = [];
        
        % Parameters used for the detection of the TMA cores.
        TMACoresDetectionParameters = [];
        
    end
    
    properties (Access = public, Dependent)
        
        % Slide level used for block processing.
        BlockProcessingLevel;
        
    end
    
    properties (Access = private)
        
        % Stores the value for the dependend BlockProcessingLevel property.
        %
        % BlockProcessingLevel needs to be a dependent property in
        % order to be safe to set other properties within it's set
        % method (in this case the ImageSize property), although for this
        % particular case this should not represent a problem.
        %
        % See 'Avoiding Property Initialization Order Dependency' in
        % the MATLAB documentation for a better explanation.
        %
        PrivateBlockProcessingLevel;
        
    end
    
    properties (Constant, Hidden)
        
        % Current code version.
        CURRENT_VERSION = '1.0';
        
        % Default resolution for visualization.
        DEFAULT_TARGET_RESOLUTION = 800^2;
        % Default padding for visualization.
        DEFAULT_PADDING = 0.15;
        
    end
    
    methods
        
        % Property set/get methods
        % ------------------------
        
        function val = get.BlockProcessingLevel(obj)
            
            val = obj.PrivateBlockProcessingLevel;
            
        end
        
        function set.BlockProcessingLevel(obj, val)
            
            if val < 0 || val >= obj.Metadata.numberOfLevels
                error('Invalid level.');
            end
            
            obj.PrivateBlockProcessingLevel = val;
            
            % update the ImageSize propery from the ImageAdapter superclass
            % when BlockProcessingLevel is set
            % convert to row-column coordinate order (from x-y)
            obj.ImageSize = obj.Metadata.pixelSize(val+1, [2 1]);
            
        end
        
    end
    
    methods (Access = public)
        % Constructor
        % -----------
        
        function obj = DigitalSlide(imageID)
            % Constructor for the DigitalSlide class.
            %
            % The class must first bee initialized.
            %
            % Usage:
            % ------
            % slide = DigitalSlide(imageID);
            %
            % Input arguments:
            % ----------------
            % imageID - Unique image ID on the server (string).
            %
            % See also: initialize
            %
            
            if nargin > 0 % enables initialization of arrays
                
                obj.ImageID = imageID;
                
                obj.setMetadata();
                
            end
            
        end
        
        % Image data access
        % -----------------
        
        function I = getImagePixelData(obj, x, y, width, height, varargin)
            % Get image pixel data by specifying point and size.
            %
            % Usage:
            % ------
            % I = getImagePixelData(slide, x, y, width, height, varargin);
            % I = getImagePixelData(..., name, value, ...);
            %
            % Input arguments:
            % ----------------
            % The x, y, width, and height arguments define the coordinates
            % of the requested rectangular region.
            %
            % x: Horizontal top left coordinate of the rectangular region.
            % y: Vertical top left coordinate of the rectangular region.
            % width: Width of the rectangular region.
            % height: Height of the rectangular region.
            %
            % Optional input arguments:
            % -------------------------
            % These arguments should be passed as name-value pairs.
            %
            % level: Level of the rectangular region.
            % unit: Units of the rectangular region coordinates.
            % quality: Quality for the compression of the returned image
            % data (only valid for 'jpeg' format).
            % format: Format of the returned image data.
            %
            % Output arguments:
            % -----------------
            % I: Matrix with dimensions height-by-width-by-3 containing the
            % requested region in RGB format.
            %
            % See also: getTiledImagePixelData, getAssociatedImage
            
            import tepisclient.*;
            
            parametersStruct = parseParameters;
            
            imageRegionParam = ImageRegionParam(...
                javaFloat(x),...
                javaFloat(y),...
                javaFloat(width),...
                javaFloat(height),...
                javaInteger(parametersStruct.level),...
                parametersStruct.unit);
            
            imageFormatParam = ImageFormatParam(...
                parametersStruct.format,...
                javaInteger(parametersStruct.quality));
            
            byteArray = DigitalSlide.TepisClient.getImagePixelData(...
                obj.ImageID,...
                imageRegionParam,...
                imageFormatParam);
            
            I = byteArrayToImage(byteArray);
            
            % Nested functions
            % ----------------
            
            function parametersStruct = parseParameters
                
                import tepisclient.*;
                
                ip = inputParser();
                
                ip.addParamValue('level', []);
                ip.addParamValue('unit', []);
                ip.addParamValue('quality', []);
                ip.addParamValue('format', []);
                
                ip.parse(varargin{:});
                
                parametersStruct = ip.Results;
                
                if ~isempty(parametersStruct.unit)
                    parametersStruct.unit = Unit.valueOf(upper(parametersStruct.unit));
                end
                
                if ~isempty(parametersStruct.format)
                    parametersStruct.format = Format.valueOf(upper(parametersStruct.format));
                end
                
            end
            
        end
        
        function I = getTiledImagePixelData(obj, col, row, dir, varargin)
            % Get a single image tile.
            %
            % Usage:
            % ------
            % I = getTiledImagePixelData(slide, col, row, dir);
            % I = getTiledImagePixelData(..., name, value, ...);
            %
            % Input arguments:
            % ----------------
            % col: Horizontal position of the top left corner of the tile.
            % row: Vertical position of the top left corner of the tile.
            % dir: Level of the image from which the tile is requested.
            %
            % Optional input arguments:
            % -------------------------
            % These arguments should be passed as name-value pairs.
            %
            % quality: Quality for the compression of the returned image
            % data (only valid for 'jpeg' format).
            % format: Format of the returned image data.
            %
            % Output arguments:
            % -----------------
            % I: Matrix with dimensions height-by-width-by-3 containing the
            % requested region in RGB format.
            %
            % See also: getImagePixelData, getAssociatedImage
            %
            
            import tepisclient.*;
            
            if isempty(obj.Metadata.tileSize)
                error('Not a tiled image format.');
            end
            
            parametersStruct = getParameters();
            
            imageTileParam = ImageTileParam(...
                javaInteger(col),...
                javaInteger(row),...
                javaInteger(dir));
            
            imageFormatParam = ImageFormatParam(...
                parametersStruct.format,...
                javaInteger(parametersStruct.quality));
            
            byteArray = DigitalSlide.TepisClient.getTiledImagePixelData(...
                obj.ImageID,...
                imageTileParam,...
                imageFormatParam);
            
            I = byteArrayToImage(byteArray);
            
            % Nested functions
            % ----------------
            
            function parametersStruct = getParameters
                
                import tepisclient.*;
                
                ip = inputParser();
                
                ip.addParamValue('quality', []);
                ip.addParamValue('format', []);
                
                ip.parse(varargin{:});
                
                parametersStruct = ip.Results;
                
                if ~isempty(parametersStruct.format)
                    parametersStruct.format = Format.valueOf(upper(parametersStruct.format));
                end
                
            end
            
        end
        
        function I = getAssociatedImage(obj, type, varargin)
            % Get label, macro or thumbnail image.
            %
            % Usage:
            % ------
            % I = getAssociatedImage(slide, type);
            % I = getAssociatedImage(..., name, value, ...);
            %
            % Input arguments:
            % ----------------
            % type: Associated image type. Can be 'label', 'macro' or
            % 'thumbnail'.
            %
            % Optional input arguments:
            % -------------------------
            % These arguments should be passed as name-value pairs.
            %
            % quality: Quality for the compression of the returned image
            % data (only valid for 'jpeg' format).
            % format: Format of the returned image data.
            %
            % Output arguments:
            % -----------------
            % I: Matrix with dimensions height-by-width-by-3 containing the
            % associated image in RGB format.
            %
            % See also: getImagePixelData, getTiledImagePixelData
            %
            
            import tepisclient.*;
            
            parametersStruct = getParameters();
            
            imageFormatParam = ImageFormatParam(...
                parametersStruct.format,...
                javaInteger(parametersStruct.quality));
            
            byteArray = DigitalSlide.TepisClient.getAssociatedImage(...
                obj.ImageID,...
                AssociatedImageType.valueOf(upper(type)),...
                imageFormatParam);
            
            I = byteArrayToImage(byteArray);
            
            % Nested functions
            % ----------------
            function parametersStruct = getParameters
                
                import tepisclient.*;
                
                ip = inputParser();
                
                ip.addParamValue('quality', []);
                ip.addParamValue('format', []);
                
                ip.parse(varargin{:});
                
                parametersStruct = ip.Results;
                
                if ~isempty(parametersStruct.format)
                    parametersStruct.format = Format.valueOf(upper(parametersStruct.format));
                end
                
            end
            
        end
        
        % Vizualization
        % -------------
        
        function varargout = show(obj, varargin)
            % Display slide.
            %
            % Usage:
            % ------
            % show(slide);
            % show(..., name, value, ...);
            %
            % Optional input arguments:
            % -------------------------
            % These arguments should be passed as name-value pairs.
            %
            % parent: Handle of an axes where the slide will be shown
            % (default: new axes is created).
            % targetResolution: Target resolution of the displayed region.
            % The image data that is displayed will have at least
            % targetResolution pixels unless the number of pixels of the
            % displayed region in the largest level is smaller (default:
            % 800^2).
            % padding: Padding of the displayed region (default: 0.15).
            %
            
            parametersStruct = getParameters();
            
            newFigure = isempty(get(0,'CurrentFigure')) || ...
                strcmp(get(get(0,'CurrentFigure'), 'NextPlot'), 'new');
            
            if ~isempty(parametersStruct.parent)
                axesHandle = parametersStruct.parent;
            elseif newFigure
                figureHandle = figure('Visible', 'off');
                axesHandle = axes('Parent', figureHandle);
            else
                axesHandle = newplot;
            end
            
            figureHandle = ancestor(axesHandle, 'figure');
            
            imageHandle = [];
            
            set(axesHandle,...
                'XLim', [0 obj.Metadata.pixelSize(1,1) - 1], ...
                'YLim', [0 obj.Metadata.pixelSize(1,2) - 1]);
            
            showRegion();
            
            if newFigure
                set(figureHandle, 'Visible', 'on');
            end
            
            set(figureHandle, 'NumberTitle', 'off', 'Name', ['Digital slide: ' obj.ImageID]);
            
            drawnow; % prevents unnecessary call to resizeCallback
            
            set(figureHandle, 'ResizeFcn', @resizeCallback);
            set(pan(figureHandle), 'ActionPostCallback', @panCallback);
            set(zoom(figureHandle), 'ActionPostCallback', @zoomCallback);
            
            if nargout > 0
                varargout{1} = imageHandle;
            end
            
            % Nested functions
            % ----------------
            
            function showRegion()
                
                xLim = get(axesHandle, 'XLim');
                yLim = get(axesHandle, 'YLim');
                
                % padding
                deltaX = diff(xLim);
                deltaY = diff(xLim);
                xLim(1) = xLim(1) - deltaX * parametersStruct.padding;
                xLim(2) = xLim(2) + deltaX * parametersStruct.padding;
                yLim(1) = yLim(1) - deltaY * parametersStruct.padding;
                yLim(2) = yLim(2) + deltaY * parametersStruct.padding;
                
                % ensure bounds
                xLim(xLim < 0) = 0;
                xLim(xLim > obj.Metadata.pixelSize(1,1) - 1) = obj.Metadata.pixelSize(1,1) - 1;
                yLim(yLim < 0) = 0;
                yLim(yLim > obj.Metadata.pixelSize(1,2) - 1) = obj.Metadata.pixelSize(1,2) - 1;
                
                % determine the image level
                downsampling = bsxfun(@rdivide, obj.Metadata.physicalSpacing, obj.Metadata.physicalSpacing(1,:));
                
                area = ((xLim(2)-xLim(1))*(yLim(2)-yLim(1)))./(prod(downsampling,2));
                
                selectedLevel = find(area - parametersStruct.targetResolution>0, 1, 'last');
                
                if isempty(selectedLevel)
                    selectedLevel = 1;
                end
                
                % read the image data
                x = round(xLim(1)/downsampling(selectedLevel,1));
                y = round(yLim(1)/downsampling(selectedLevel,2));
                height = round(diff(xLim)/downsampling(selectedLevel,1));
                width = round(diff(yLim)/downsampling(selectedLevel,2));
                
                I = obj.getImagePixelData(x, y, height, width, 'level', selectedLevel-1);
                
                % update the limits
                xLim(1) = x * downsampling(selectedLevel,1);
                xLim(2) = (x + height - 1) * downsampling(selectedLevel,1);
                yLim(1) = y * downsampling(selectedLevel,2);
                yLim(2) = (y + width - 1) * downsampling(selectedLevel,2);
                
                if isempty(imageHandle)
                    imageHandle = image(I, ...
                        'Parent', axesHandle, ...
                        'XData', xLim, ...
                        'YData', yLim, ...
                        'HandleVisibility', 'off');
                    
                    set(axesHandle, ...
                        'Visible', 'off', ...
                        'Position', [0 0 1 1], ...
                        'DataAspectRatio', [1 1 1]);
                    
                else
                    set(imageHandle, 'CData', I, 'XData', xLim, 'YData', yLim);
                    
                end
                
            end
            
            function panCallback(~, ~)
                
                showRegion();
                
            end
            
            function zoomCallback(~, ~)
                
                % first show the currently loaded image data
                drawnow;
                
                showRegion();
                
            end
            
            function resizeCallback(~, ~)
                
            end
            
            function parametersStruct = getParameters
                
                ip = inputParser();
                
                resolutionCheck = @(X)validateattributes(X, {'numeric'}, {'scalar', '>=', 1});
                paddingCheck = @(X)validateattributes(X, {'numeric'}, {'scalar', '>=', 0, '<=', 1});
                
                ip.addParamValue('parent', [], @validateAxesHandle);
                ip.addParamValue('targetResolution', obj.DEFAULT_TARGET_RESOLUTION, resolutionCheck);
                ip.addParamValue('padding', obj.DEFAULT_PADDING, paddingCheck);
                
                ip.parse(varargin{:});
                
                parametersStruct = ip.Results;
                
            end
            
            function check = validateAxesHandle(handle)
                
                check = true;
                
                if isempty(handle)
                    return;
                end
                
                if ~ishghandle(handle)
                    error('Invaid axes.');
                end
                
                type = get(handle, 'type');
                
                if ~strcmp(type, 'axes');
                    error('Invaid axes.');
                end
                
            end
            
        end
        
        % TMA support
        % -----------
        
        function detectTMACores(obj, varargin)
            % Detect tissue microarray (TMA) cores.
            %
            % This method sets the TMACores propery.
            %
            % Usage:
            % ------
            % detectTMACores(slide);
            % detectTMACores(..., name, value, ...);
            %
            % Optional input arguments:
            % -------------------------
            % These arguments should be passed as name-value pairs.
            %
            % coreDiameter: Diameter of the TMA cores in mm (default: 0.6).
            % radiusTolerance: Tolerance for the radius of the TMA cores in
            % percents. Use larger value if the diameter of the cores
            % varies significantly. (default: 10).
            % strictness: Strictness of the TMA cores detection. Must be a
            % number between 0 and 100 (default: 90).
            %
            
            parametersStruct = getParameters();
            
            % note: only horizontal physical spacing is used
            coreDiameterPixels = parametersStruct.coreDiameter./obj.Metadata.physicalSpacing(:,1);
            
            selectedLevel = find(coreDiameterPixels - parametersStruct.targetCoreDiameterPixels > 0, 1, 'last');
            
            if isempty(selectedLevel)
                selectedLevel = obj.Metadata.numberOfLevels;
            end
            
            height = obj.Metadata.pixelSize(selectedLevel,1);
            width = obj.Metadata.pixelSize(selectedLevel,2);
            
            I = obj.getImagePixelData(0, 0, height, width, 'level', selectedLevel-1);
            
            % convert to grayscale
            img = mean(I,3);
            
            radius = round(coreDiameterPixels(selectedLevel))/2;
            tolerance = round(coreDiameterPixels(selectedLevel)*parametersStruct.radiusTolerance/100)/2;
            
            % fast radial symmetry transform
            S = frst(img, radius-tolerance:radius+tolerance);
            
            % non-maxima suppression
            [r c] = nonmaxsupp(S, 2*radius, prctile(S(S>0), parametersStruct.strictness));
            
            % get the pixel coordinates in the lowest layer
            x = c*(obj.Metadata.physicalSpacing(selectedLevel,1)/obj.Metadata.physicalSpacing(1,1));
            y = r*(obj.Metadata.physicalSpacing(selectedLevel,2)/obj.Metadata.physicalSpacing(1,2));
            
            r = coreDiameterPixels(1)*ones(length(r),1)/2;
            
            obj.TMACores = [x y r];
            
            function parametersStruct = getParameters
                
                ip = inputParser();
                
                diameterCheck = @(X)validateattributes(X, {'numeric'}, {'scalar', '>', 0});
                percentageCheck = @(X)validateattributes(X, {'numeric'}, {'scalar', '>=', 0, '<=', 100});
                
                ip.addParamValue('coreDiameter', 0.6, diameterCheck);
                ip.addParamValue('radiusTolerance', 10, percentageCheck);
                ip.addParamValue('strictness', 90, percentageCheck);
                ip.addParamValue('targetCoreDiameterPixels', 20, diameterCheck); % undocumented
                
                ip.parse(varargin{:});
                
                parametersStruct = ip.Results;
                
            end
            
            obj.TMACoresDetectionParameters = parametersStruct;
            
        end
        
        function I = getTMACoreImage(obj, coreID, level)
            % Get image pixel data of a single tissue microarray (TMA)
            % core.
            %
            % Usage:
            % ------
            % I = getTMACoreImage(slide, coreID, level);
            %
            % Input arguments:
            % ----------------
            % coreID: ID of the requested TMA core. The ID is the row
            % number of the TMACores property. The TMA core IDs can be
            % visualized with the plotTMACores method.
            % level: Slide level from which the pixel data is read.
            %
            
            if isempty(obj.TMACores)
                error('No TMA cores to plot. Use the detectTMACores method to detect TMA cores before using this method.');
            end
            
            core = obj.TMACores(coreID,:);
            
            core = core / (obj.Metadata.physicalSpacing(level+1,2)/obj.Metadata.physicalSpacing(1,2));
            
            x = core(1) - core(3);
            y = core(2) - core(3);
            h = 2*core(3);
            w = 2*core(3);
            
            I = obj.getImagePixelData(x, y, h, w, 'level', level);
            
        end
        
        function varargout = plotTMACores(obj, varargin)
            % Plot the tissue microarray (TMA) core regions and IDs.
            %
            % Usage:
            % ------
            % plotTMACores(slide);
            % h = plotTMACores(slide);
            % h = plotTMACores(..., name, value, ...);
            %
            % Optional input arguments:
            % -------------------------
            % viscircleParametes: Cell array of parameters passed to the
            % viscircle function that is used to plot the TMA cores
            % (default: {'EdgeColor', 'r', 'LineStyle', '-', 'LineWidth',
            % 2}).
            % textParametes: Cell array of parameters passed to the text
            % function that is used to plot the TMA core IDs  (default:
            % {'HorizontalAlignment', 'center', 'Color', 'b', 'FontWeight',
            % 'bold', 'Clipping', 'on'}).
            %
            % Optional output arguments:
            % --------------------------
            % h: Handles to the graphical objects. The first column are
            % handles to the circle objects and the second column are
            % handles to the text objects.
            %
            
            if isempty(obj.TMACores)
                error('No TMA cores to plot. Use the detectTMACores method to detect TMA cores before using this method.');
            end
            
            parametersStruct = getParameters();
            
            h = zeros(size(obj.TMACores,1), 2);
            
            stringIDs = arrayfun(@num2str, 1:size(obj.TMACores,1), 'Uniform', false);
            
            h(:,1) = viscircles(obj.TMACores(:,1:2), obj.TMACores(:,3), parametersStruct.viscircleParametes{:});
            h(:,2) = text(obj.TMACores(:,1), obj.TMACores(:,2), stringIDs, parametersStruct.textParametes{:});
            
            if nargout == 1
                varargout{1} = h;
            end
            
            function parametersStruct = getParameters
                
                ip = inputParser();
                
                cellCheck = @(X)validateattributes(X, {'cell'}, {});
                
                defaultViscircleParameters = {'EdgeColor', 'r', 'LineStyle', '-', 'LineWidth', 2};
                defaultTextParameters = {'HorizontalAlignment', 'center', 'Color', 'b', 'FontWeight', 'bold', 'Clipping', 'on'};
                
                ip.addParamValue('viscircleParametes', defaultViscircleParameters, cellCheck);
                ip.addParamValue('textParametes', defaultTextParameters, cellCheck);
                
                ip.parse(varargin{:});
                
                parametersStruct = ip.Results;
                
            end
            
        end
        
        
    end
    
    methods (Hidden, Access = public)
        
        % Overloaded operators
        % --------------------
        
        function index = end(obj, k, n)
            % 'end' keyword for subscripted referencing.
            %
            
            if numel(obj) > 1
                % use the builtin function for object arrays
                index = builtin('end', obj, k, n);
            else
                switch k
                    case 1
                        if n == 2
                            index = obj.Metadata.pixelSize(1, 2);
                        else
                            error('The ''end'' keyword cannot be used for rows and columns when specifying the level.');
                        end
                    case 2
                        if n == 2
                            index = obj.Metadata.pixelSize(1, 1);
                        else
                            error('The ''end'' keyword cannot be used for rows and columns when specifying the level.');
                        end
                    case 3
                        index = obj.Metadata.numberOfLevels;
                    case 4
                        index = 3; % color channels
                end
            end
            
        end
        
        function varargout = subsref(obj, s)
            % Subscripted referencing.
            %
            % Only '()' subscripted reference is implemented. '{}' is not
            % supported and for '.' the MATLAB built-in subsref is called.
            %
            
            if numel(obj) > 1 || length(s) > 1
                % use the builtin function for object arrays and complex
                % indexed references
                
                [varargout{1:nargout}] = builtin('subsref', obj, s);
                
            else
                switch s.type
                    case '.'
                        [varargout{1:nargout}] = builtin('subsref', obj, s);
                    case '{}'
                        error('Not a supported subscripted reference.');
                    case '()'
                        % must be called with 2, 3 or 4 indices
                        if ~ismember(length(s.subs), [2 3 4])
                            error('Invalid subscripted reference.');
                        end
                        
                        % first, get the level
                        if length(s.subs) == 2
                            level = 0;
                        else
                            if strcmp(s.subs{3}, ':')
                                error('The colon operator cannot be used for level.');
                            elseif isempty(s.subs{3})
                                level = 0;
                            else
                                level = s.subs{3} - 1;
                            end
                        end
                        
                        if strcmp(s.subs{2}, ':')
                            s.subs{2} = 1:obj.Metadata.pixelSize(level + 1, 1);
                        end
                        
                        maxCols = max(s.subs{2});
                        minCols = min(s.subs{2});
                        x = minCols - 1;
                        width =  maxCols - minCols + 1;
                        
                        if strcmp(s.subs{1}, ':')
                            s.subs{1} = 1:obj.Metadata.pixelSize(level + 1, 2);
                        end
                        
                        maxRows = max(s.subs{1});
                        minRows = min(s.subs{1});
                        y = minRows - 1;
                        height =  maxRows - minRows + 1;
                        
                        if length(s.subs) == 4
                            if isempty(s.subs{4}) || strcmp(s.subs{4}, ':')
                                channels = 1:3;
                            else
                                channels = s.subs{4};
                            end
                        else
                            channels = 1:3; % return all color channels by default
                        end
                        
                        reference = obj.getImagePixelData(x, y, width, height, 'level', level);
                        reference = reference(s.subs{1} - minRows + 1, ...
                            s.subs{2} - minCols + 1, channels);
                        
                        varargout{1} = reference;
                end
                
            end
        end
        
        % Alternative method names
        % ------------------------
        function varargout = imshow(obj, varargin)
            
            [varargout{1:nargout}] = show(obj, varargin{:});
            
        end
        
        % Method required by ImageAdapter
        % -------------------------------
        
        function close(~)
        end
        
        function data = readRegion(obj, regionStart, regionSize)
            
            x = regionStart(2)-1;
            y = regionStart(1)-1;
            width = regionSize(2);
            height = regionSize(1);
            
            data = obj.getImagePixelData(x, y, width, height, 'level', obj.BlockProcessingLevel);
            
        end
        
        function writeRegion(~,~,~)
        end
        
    end
    
    methods (Access = private)
        
        function setMetadata(obj)
            
            pixelMetadata = DigitalSlide.TepisClient.getImageMetadata(obj.ImageID).getPixelMetadata();
            
            metadata.numberOfLevels = pixelMetadata.getNumberOfLevels();
            
            for i_levels = 1:metadata.numberOfLevels
                
                currentLevel = pixelMetadata.getLevels().getPixelLevelMetadata().get(i_levels-1);
                
                metadata.pixelSize(i_levels,1:2) = toArray(currentLevel.getPixelSize(), '%f, ');
                metadata.physicalOrigin(i_levels,1:2) = toArray(currentLevel.getPhysicalOrigin(), '%f, ');
                metadata.physicalSpacing(i_levels,1:2) = toArray(currentLevel.getPhysicalSpacing(), '%f, ');
                metadata.scanFactor(i_levels) = currentLevel.getScanFactor();
                
                metadata.isNativeLevel(i_levels) = currentLevel.isIsNativeLevel();
                metadata.isLossyCompressed(i_levels) = currentLevel.isIsLossyCompressed();
                metadata.tileSize(i_levels,1:2) = toArray(currentLevel.getTileSize(), '%f, ');
                
            end
            
            obj.Metadata = metadata;
            
            function x = toArray(javaString, format)
                % Convert Java String object to MATLAB array.
                %
                
                x = cell2mat(textscan(char(javaString), format));
                
            end
            
        end
        
    end
    
    methods (Static, Access = public)
        
        function initialize(domain, username, password)
            % Log in to the Philips IMS.
            %
            % Usage:
            % ------
            % DigitalSlide.initialize(domain);
            % DigitalSlide.initialize(domain, username, password);
            %
            % Input arguments:
            % ----------------
            % domain: Domain name of the Philips IMS.
            %
            % Optional input arguments:
            % -------------------------
            % username, password: User credentials.
            %
            
            
            import tepisclient.*;
            
            tepisClient = TepisClient(domain);
            
            if exist('username', 'var') && exist('password', 'var') && ...
                    ~isempty(username) && ~isempty(password)
                tepisClient.authenticate(username, password);
            end
            
            DigitalSlide.TepisClient(tepisClient);
            
        end
        
    end
    
    methods (Static, Access = public)
        
        function outVal = TepisClient(inVal)
            % Has the role of a static property.
            %
            
            persistent TepisClient;
            
            if nargin >=1
                TepisClient = inVal;
            end
            
            outVal = TepisClient;
            
        end
        
    end
    
end

function i = javaInteger(i)
% Convert a value to the Java Integer class.

if ~isempty(i)
    i = javaObject ('java.lang.Integer', i);
end

end

function f = javaFloat(f)
% Convert a value to the Java Float class.

if ~isempty(f)
    f = javaObject ('java.lang.Float', f);
end

end
