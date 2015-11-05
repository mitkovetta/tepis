classdef TepisSlide < DigitalSlide
    % Provides access to digital slides stored on a Philips IMS.
    %
    % Basic usage:
    % ------------
    % Authenticate on the tEPIS server:
    % TepislSlide.initialize('https://<domain>/', '<user>', '<pass>');
    %
    % Create a digital slide object:
    % slide = TepisSlide('<image-ID>');
    %
    % Read a region of size 1000-by-1000 pixels from the top level of the
    % slide and the lowest (largest) level:
    % I = slide.getImagePixelData(0, 0, 1000, 1000);
    %
    % Read a region of size 1000-by-1000 pixels from the second level:
    % I = slide.getImagePixelData(0, 0, 1000, 1000, 'level', 1);
    %
    % Read the macro image of the slide:
    % I = slide.getAssociatedImage('macro');
    %
    % See also: DigitalSlide, OpenSlide, initialize, getImagePixelData, 
    % getTiledImagePixelData, getAssociatedImage, show, blockproc, 
    % ImageAdapter, ImageID, Metadata, BlockProcessingLevel
    %
    % ---------------------------------------------------------------------
    % Author: Mitko Veta (MVeta@tue.nl)
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
    
    properties (GetAccess = public, SetAccess = protected)
        
        % (NumberOfLevels-by-2)
        PhysicalOrigin;
        % (NumberOfLevels-by-1)
        IsNativeLevel;
        % (NumberOfLevels-by-1)
        IsLossyCompressed;
        % (NumberOfLevels-by-2)
        TileSize;
        
    end
    
    methods (Access = public)
        % Constructor
        % -----------
        
        function obj = TepisSlide(imageID)
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
            
            byteArray = TepisSlide.TepisClient.getImagePixelData(...
                obj.ImageID,...
                imageRegionParam,...
                imageFormatParam);
            
            I = byteArrayToImage(byteArray);
            
            % Nested functions
            % ----------------
            
            function parametersStruct = parseParameters
                
                import tepisclient.*;
                
                ip = inputParser();
                
                ip.addParameter('level', []);
                ip.addParameter('unit', []);
                ip.addParameter('quality', []);
                ip.addParameter('format', []);
                
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
            
            byteArray = TepisSlide.TepisClient.getTiledImagePixelData(...
                obj.ImageID,...
                imageTileParam,...
                imageFormatParam);
            
            I = byteArrayToImage(byteArray);
            
            % Nested functions
            % ----------------
            
            function parametersStruct = getParameters
                
                import tepisclient.*;
                
                ip = inputParser();
                
                ip.addParameter('quality', []);
                ip.addParameter('format', []);
                
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
            
            byteArray = TepisSlide.TepisClient.getAssociatedImage(...
                obj.ImageID,...
                AssociatedImageType.valueOf(upper(type)),...
                imageFormatParam);
            
            I = byteArrayToImage(byteArray);
            
            % Nested functions
            % ----------------
            function parametersStruct = getParameters
                
                import tepisclient.*;
                
                ip = inputParser();
                
                ip.addParameter('quality', []);
                ip.addParameter('format', []);
                
                ip.parse(varargin{:});
                
                parametersStruct = ip.Results;
                
                if ~isempty(parametersStruct.format)
                    parametersStruct.format = Format.valueOf(upper(parametersStruct.format));
                end
                
            end
            
        end
        
        
    end
    
    methods (Static, Access = public)
        
        function initialize(domain, username, password)
            % Authenticate on the Philips IMS.
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
            
            TepisSlide.TepisClient(tepisClient);
            
        end
        
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
    
    methods (Access = private)
        
        function setMetadata(obj)
            
            pixelMetadata = TepisSlide.TepisClient.getImageMetadata(obj.ImageID).getPixelMetadata();
            
            obj.NumberOfLevels = pixelMetadata.getNumberOfLevels();
            
            for i_levels = 1:obj.NumberOfLevels
                
                currentLevel = pixelMetadata.getLevels().getPixelLevelMetadata().get(i_levels-1);
                
                obj.PixelSize(i_levels,1:2) = toArray(currentLevel.getPixelSize(), '%f, ');
                obj.PhysicalSpacing(i_levels,1:2) = toArray(currentLevel.getPhysicalSpacing(), '%f, ');
                obj.ScanFactor(i_levels) = currentLevel.getScanFactor();
                
                % properties specific to tEPIS slides
                obj.PhysicalOrigin(i_levels,1:2) = toArray(currentLevel.getPhysicalOrigin(), '%f, ');
                obj.IsNativeLevel(i_levels) = currentLevel.isIsNativeLevel();
                obj.IsLossyCompressed(i_levels) = currentLevel.isIsLossyCompressed();
                obj.TileSize(i_levels,1:2) = toArray(currentLevel.getTileSize(), '%f, ');
                
            end
            
            obj.Downsampling = bsxfun(@rdivide, ...
                obj.PhysicalSpacing, obj.PhysicalSpacing(1,:));
            
            function x = toArray(javaString, format)
                % Convert Java String object to MATLAB array.
                %
                
                x = cell2mat(textscan(char(javaString), format));
                
            end
            
        end
        
    end
    
end

function i = javaInteger(i)
% Convert a value to the Java Integer class.

if ~isempty(i)
    i = javaObject('java.lang.Integer', i);
end

end

function f = javaFloat(f)
% Convert a value to the Java Float class.

if ~isempty(f)
    f = javaObject('java.lang.Float', f);
end

end
