addpath('improc');
addpath('util');

javaaddpath(fullfile('backends', 'tepis', ...
    'tepisclient-0.0.1-SNAPSHOT-jar-with-dependencies.jar'));

TepisSlide.initialize('https://ucu00-tepis', 'user', 'pass');

slide = TepisSlide('VeryLongID');
slide.show();
