classdef OpenSlide < DigitalSlide
    
    properties (Access = private);
        
        SlidePointer;
        
    end
    
    methods (Access = public)
        
        function obj = OpenSlide(imageID)
            % Constructor for the OpenSlide class.
            %
            
            if nargin > 0 % enables initialization of arrays
                
                obj.ImageID = imageID;
                
                if ~calllib('libopenslide','openslide_can_open', obj.ImageID)
                    error(['Openslide cannot open the specified file.' ...
                        'Either it does not exist or it is in an unsupported format']);
                end
                
                obj.SlidePointer = calllib('libopenslide', ...
                    'openslide_open', obj.ImageID);
                
                obj.setMetadata();
                
            end
            
        end
        
    end
    
    methods (Access = public)
        
        % Image data access
        % -----------------
        
        function I = getImagePixelData(obj, x, y, width, height, varargin)
                        
            parametersStruct = parseParameters;
            
            x = floor(x * obj.Metadata.downsampling(parametersStruct.level+1, 1));
            y = floor(y * obj.Metadata.downsampling(parametersStruct.level+1, 2));

            data = uint32(zeros(width * height, 1));
            region = libpointer('uint32Ptr', data);
            
            [~, region] = calllib('libopenslide', 'openslide_read_region', ...
                obj.SlidePointer, region, int64(x), int64(y), ...
                int32(parametersStruct.level), int64(width), int64(height));
            
            regionRGBA = typecast(region, 'uint8');
            
            I = zeros(width, height, 3, 'uint8');
            
            I(:,:,1) = reshape(regionRGBA(3:4:end), width, height);
            I(:,:,2) = reshape(regionRGBA(2:4:end), width, height);
            I(:,:,3) = reshape(regionRGBA(1:4:end), width, height);
            
            I = permute(I, [2 1 3]);
            
            % Nested functions
            % ----------------
            
            function parametersStruct = parseParameters
                
                import tepisclient.*;
                
                ip = inputParser();
                
                ip.addParamValue('level', 0);
                
                ip.parse(varargin{:});
                
                parametersStruct = ip.Results;
                
            end
            
        end
        
        function I = getAssociatedImage(obj, type, varargin)
            
            error('NOT_IMPLEMENTED');
            
        end
        
    end
    
    methods (Static, Access = public)
        
        function initialize(openslideIncludePath)
            % Initialize libopenslide.
            %
            
            if ~libisloaded('libopenslide')
                openslideHeaderPath = fileparts(which('matlab-openslide-wrapper.h'));
                
                if ~exist('openslideIncludePath', 'var') || ...
                        isempty(openslideIncludePath)
                    % assume by default that openslide.h is in the same
                    % location as matlab-openslide-wrapper.h
                    openslideIncludePath = openslideHeaderPath;
                else
                    addpath(openslideIncludePath);
                end
                
                [notFound, warnings] = loadlibrary('libopenslide', ...
                    'matlab-openslide-wrapper.h',...
                    'addheader', 'openslide.h',...
                    'includepath', openslideIncludePath); %#ok<ASGLU>
            else
                warning('libopenslide is already loaded.')
            end
            
        end
        
    end
    
    methods (Access = private)
        
        function setMetadata(obj)
            
            obj.Metadata.numberOfLevels = calllib('libopenslide', ...
                'openslide_get_level_count', obj.SlidePointer);
            
            for i_levels = 1:obj.Metadata.numberOfLevels
                
                width = 0;
                height = 0;
                
                [~, width, height] = calllib('libopenslide', ...
                    'openslide_get_level_dimensions', obj.SlidePointer, ...
                    i_levels-1, width, height);
                
                obj.Metadata.pixelSize(i_levels,:) = double([width height]);
                
                % note: libopenslide seems to return one downsampling
                % factor for both dimensions
                obj.Metadata.downsampling(i_levels,1:2) = calllib('libopenslide', ...
                    'openslide_get_level_downsample', obj.SlidePointer, i_levels-1);
                
            end
            
            physicalSpacingX0 = calllib('libopenslide', ...
                'openslide_get_property_value', obj.SlidePointer, ...
                'openslide.mpp-x');
            
            physicalSpacingY0 = calllib('libopenslide', ...
                'openslide_get_property_value', obj.SlidePointer, ...
                'openslide.mpp-y');
            
            % convert from /mum to /mm
            physicalSpacingX0 = str2double(physicalSpacingX0) * 10^-3;
            physicalSpacingY0 = str2double(physicalSpacingY0) * 10^-3;
            
            obj.Metadata.physicalSpacing = bsxfun(@mtimes, ...
                obj.Metadata.downsampling, [physicalSpacingX0 physicalSpacingY0]);
            
        end
        
    end
    
end