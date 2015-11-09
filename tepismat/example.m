% IMPORTANT: Do not forget to fill in your tEPIS server username and
% password and/or correct OpenSlide include path

%% tEPIS slide

TepisSlide.initialize('https://ucu00-tepis', 'user', 'pass');

slide = TepisSlide('VeryLongID');
slide.show();

%% OpenSlide

OpenSlide.initialize('path/to/openslide/include');

slide = TepisSlide('SlideName');
slide.show();
