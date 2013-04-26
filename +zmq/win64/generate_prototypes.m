function generate_prototypes()
    zmq_dir = uigetdir('zmq installation');
    libname = 'libzmq-v100-mt-3_2_2';
    zmq_dll = fullfile(zmq_dir, 'bin', [libname '.dll']);
    zmq_h = fullfile(zmq_dir, 'include', 'zmq.h');
    copyfile(zmq_dll, pwd);
    loadlibrary(libname, zmq_h, 'mfilename', 'libzmq_proto');
    loadlibrary('zmqmat', fullfile('..', 'src', 'zmqmat.h'), 'mfilename', 'zmqmat');
    delete('*.obj');
    delete('*.exp');
    delete('*.lib');
    prot = '';
    prot_file = fopen('libzmq_proto.m', 'rt');
    while true
        line = fgets(prot_file);
        if line == -1
            break;
        end
        prot = [prot line];
    end
    fclose(prot_file);
    prot = regexprep(prot, '(?-s).*FcnPtrPtr.*', '');
    prot_file = fopen('libzmq_proto.m', 'wt');
    fwrite(prot_file, prot);
    fclose(prot_file);
end