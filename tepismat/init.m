addpath(genpath(pwd));

javaaddpath(fullfile(fullfile(pwd, 'backends'), 'tepis', ...
    'tepisclient-0.0.1-SNAPSHOT-jar-with-dependencies.jar'));

OpenSlide.initialize;