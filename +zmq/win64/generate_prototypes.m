function generate_prototypes()
    [zmq_dll_file, zmq_dll_path] = uigetfile('*.dll', 'zmq dll');
    zmq_dll = fullfile(zmq_dll_path, zmq_dll_file);
    [zmq_h_file, zmq_h_path] = uigetfile('*.h', 'zmq h');
    zmq_h = fullfile(zmq_h_path, zmq_h_file);
    [zmqdir, libname, libextension] = fileparts(zmq_dll);
    copyfile(zmq_dll, pwd);
    loadlibrary(libname, zmq_h, 'mfilename', 'libzmq_proto');
    loadlibrary('zmqmat', fullfile('..', 'src', 'zmqmat.h'), 'mfilename', 'zmqmat');
    delete('*.obj');
    delete('*.exp');
    delete('*.lib');
end