function install_jar()
    [mydir, ~, ~] = fileparts(mfilename('fullpath'));
    jarfile = char(java.io.File(fullfile(mydir, 'jar', 'zmq.jar')).getCanonicalPath());
    if verLessThan('matlab', '8')
        classpath = fullfile(matlabroot(), 'toolbox', 'local', 'classpath.txt');
    else
        classpath = fullfile(prefdir(), 'javaclasspath.txt');
    end
    fprintf('Putting the line\n%s\nin\n%s.\n', jarfile, classpath);
    f = fopen(classpath, 'at');
    fprintf(f, '\n%s\n', jarfile);
    fclose(f);
    disp('Please restart matlab to complete installation.');
end