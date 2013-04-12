classdef Context < handle
% Context
%
%   A program written for the zmq library should
%   instantiate one context and use it to make 
%   all the sockets it needs.

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

        function sock = socket(obj, typ)
            if not(metaclass(typ) == ?zmq.SocketType)
                error('typ should be a SocketType');
            else
                sock = zmq.Socket(...
                    calllib('libzmq', 'zmq_socket', obj.ptr, int32(typ)),...
                    obj, obj.ptr, typ);
            end
        end
    end
    methods (Static)
        function load_zmq()
        % load_zmq
        %
        %   Load the zmq dll.
        %   This is called automatically when needed.
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