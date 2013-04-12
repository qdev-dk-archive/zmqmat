function internal_load_zmq()
    savedir=pwd;
    [mydir, filename, extension] = fileparts(mfilename('fullpath'));
    cd(mydir);
    cd('win64');
    loadlibrary('libzmq', @libzmq_proto);
    cd(savedir);
end