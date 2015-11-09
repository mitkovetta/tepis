# tepismat

MATLAB client for the tEPIS digital pathology image management and sharing platform. See http://www.ctmm-trait.nl/trait-tools/tepis for more information. Reading of locally stored slides is also provided via OpenSlide (http://openslide.org/).

## Setup

Run ```init.m``` to initialize the MATLAB and Java paths. 

Access to locally stored slides is provided trough the OpenSlide library. Please check out the OpenSlide website for installation instructions: http://openslide.org/.

## Usage

Check out the documentation for the ```DigitalSlide```, ```TepisSlide``` and ```OpenSlide``` classes for detailed usage instructions and explanation of the parameters.

### Initialization

The ```TepisSlide``` and ```OpenSlide``` classess need to be initialized before accessing digital slides. The initialization for the ```TepisSlide``` class authenticates the user on the tEPIS server and the initialization for the ```OpenSlide``` class initializes the OpenSlide library.

```
%% tEPIS slide

TepisSlide.initialize('https://ucu00-tepis', 'user', 'pass');

slide = TepisSlide('VeryLongID');

%% OpenSlide

OpenSlide.initialize('path/to/openslide/include');

slide = TepisSlide('SlidePath');
```
### Slide display:

The DigitalSlide.show method implements slide visualization functionalities similar to the MATLAB imshow function. The level from which the image data is read is automatically determined based on the displayed area and the (optional) targetResolution argument.

``` 
slide.show();
```

### Subscripted referencing
    
The classes support easy access to the image data by  subscripted referencing in the following formats:

```
I = slide(rows, cols);
I = slide(rows, cols, level);
I = slide(rows, cols, level, colorChannel);
```
    
If not specified, the lowest level and all color channels are returned by default.

Note that the subscripted indices begin from '1' instead of '0' and are in row-column order to comply with the MATLAB style. The colon (':') operator is supported for rows, columns and color channel only. The 'end' keyword is supported for level and color channel only.

### Block processing

DigitalSlide inherits from the ImageAdapter class, which enables the use of the blockproc function from the Image Processing Toolbox. Prior to the using blockproc, the BlockProcessingLevel propery needs to be set.     %

For example, this applies someFunction to each distinct 1000-by-1000 block from the larges level of the slide and stores the results in B:

```
slide.BlockProcessingLevel = 0;
B = blockproc(slide, [1000 1000], @(X)someFunction(X.data));
```
    
### Tissue microarray (TMA) support

The class supports handling of TMA slides by implementing detection and visualization of TMA cores and retrival of image data for inividual TMA cores.

```    
slide.detectTMACores();
slide.show();
slide.plotTMACores();

% Get image data for the first TMA core from the second level.
I = slide.getTMACore(1, 1);
```

### Troubleshooting

Make sure you use a recent version of OpenSlide that supports simplified headers (see: https://github.com/openslide/openslide/issues/116#issuecomment-65187001).
