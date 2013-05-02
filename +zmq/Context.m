classdef Context < handle
% Context
%
%   A program written for the zmq library should instantiate one context and
%   use it to make all the sockets it needs. Use get_default_context to do
%   this automatically unless you know better.

    properties (Access = private)
        ptr
    end

    properties (Constant)
        types = containers.Map(...
            {'pair', 'pub', 'sub', 'req', 'rep', 'dealer', 'router', 'pull', 'push', 'xpub', 'xsub'},...
            [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    end

    methods
        function obj = Context()
            zmq.Context.load_zmq();
            obj.ptr = calllib('zmq', 'zmq_ctx_new');
        end

        function delete(obj)
            calllib('zmq', 'zmq_ctx_destroy', obj.ptr);
        end

        function sock = socket(obj, socket_type)
        % socket(socket_type)
        %
        %   Constructs a socket in this context.
        %   See <a href="http://api.zeromq.org/3-2:zmq-socket">the ZeroMQ refference</a> for a description of the various types.
            if ~obj.types.isKey(socket_type)
                error('No such socket type: %s', socket_type)
            end
            sock_ptr = calllib('zmq', 'zmq_socket',...
                obj.ptr, int32(obj.types(socket_type)));
            if sock_ptr.isNull()
                zmq.internal.throw_zmq_error();
            end
            sock = zmq.SocketT(sock_ptr, obj, obj.ptr, socket_type);
        end

        function ptr = get_raw_ptr(obj)
        % get_raw_ptr
        %   Returns a ptr to the underlying zmq context.
            ptr = obj.ptr;
        end
    end
    methods (Static)

        function ctx = get_default_context()
        % get_default_context
        %
        %   Contructs a context on the first call. Returns the same context on
        %   every subsequent call.
            persistent def_ctx
            if isempty(def_ctx) || ~isvalid(def_ctx)
                disp('Creating default ctx.');
                def_ctx = zmq.Context();
            end
            ctx = def_ctx;
        end

        function load_zmq()
        % load_zmq
        %
        %   Load the zmq dll. This is called automatically when needed but you
        %   can trigger it early if you want to isolate problems related to
        %   dll loading.
            if ~libisloaded('zmq') || ~libisloaded('zmqmat')
                savedir=pwd;
                [mydir, filename, extension] = fileparts(mfilename('fullpath'));
                cd(mydir);
                cd('win64');
                if ~libisloaded('zmq')
                    loadlibrary('libzmq-v100-mt-3_2_2.dll', @libzmq_proto, 'alias', 'zmq');
                end
                if ~libisloaded('zmqmat')
                    loadlibrary('zmqmat', @zmqmat);
                end
                cd(savedir);
            end
        end
    end
end