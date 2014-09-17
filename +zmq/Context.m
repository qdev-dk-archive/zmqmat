classdef Context < handle
% Context
%
%   A program written for the zmq library should instantiate one context and
%   use it to make all the sockets it needs. Use get_default_context to do
%   this automatically unless you know better.

    properties (Access = private)
        ptr
    end

    properties (SetAccess = private)
        types
    end

    methods
        function obj = Context()
            zmq.Context.load_zmq();
            obj.ptr = zmqraw.ZmqLibrary.zmq_ctx_new();
            obj.types = containers.Map();
            types = {'pair', 'pub', 'sub', 'req', 'rep', 'dealer', ...
                'router', 'pull', 'push', 'xpub', 'xsub'};
            for typ = types
                obj.types(typ{1}) = zmqraw.ZmqLibrary.(['ZMQ_' upper(typ{1})]);
            end
        end

        function delete(obj)
            zmqraw.ZmqLibrary.zmq_ctx_destroy(obj.ptr);
        end

        function sock = socket(obj, socket_type)
        % socket(socket_type)
        %
        %   Constructs a socket in this context.
        %   See <a href="http://api.zeromq.org/3-2:zmq-socket">the ZeroMQ refference</a> for a description of the various types.
            if ~obj.types.isKey(socket_type)
                error('No such socket type: %s', socket_type)
            end
            sock_ptr = zmqraw.ZmqLibrary.zmq_socket(...
                obj.ptr, obj.types(socket_type));
            if isempty(sock_ptr)
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
                def_ctx = zmq.Context();
            end
            ctx = def_ctx;
        end

        function load_zmq()
            if exist('zmqraw.ZmqLibrary','class')
                return
            end
            error('Please call zmq.install_jar to install the zmq matlab bindings.');
        end
    end
end