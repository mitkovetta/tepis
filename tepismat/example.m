addpath('improc');
addpath('util');
javaaddpath(['util' filesep 'tepisclient-0.0.1-SNAPSHOT-jar-with-dependencies.jar']);

DigitalSlide.initialize('https://ucu00-tepis', 'user', 'pass');
slide = DigitalSlide('VeryLongID');

show(slide);

