classdef Context < handle
    properties (SetAccess = private, GetAccess = private)
        ptr
    end
    methods
        function obj = Context()
            zmq.Context.load_zmq();
            obj.ptr = calllib('libzmq', 'zmq_ctx_new');
        end
        function delete(obj)
            calllib('libzmq', 'zmq_ctx_destroy', obj.ptr);
        end
    end
    methods (Access = private, Static)
        function load_zmq()
            if ~libisloaded('libzmq')
                savedir=pwd;
                [mydir, filename, extension] = fileparts(mfilename('fullpath'));
                cd(mydir);
                cd('win64');
                loadlibrary('libzmq', @libzmq_proto);
                cd(savedir);
            end
        end
    end
end