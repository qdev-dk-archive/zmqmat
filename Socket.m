classdef Socket < handle
    properties (SetAccess = private, GetAccess = private)
        ptr
        % ctx is a reference to the parent context to prevent
        % it from being garbage collected until all sockets have
        % been closed properly.
        ctx
        ctx_ptr
        socket_type
    end
    methods (Access=?zmq.Context)
        function obj = Socket(ptr, ctx, ctx_ptr, socket_type)
            obj.ptr = ptr;
            obj.ctx = ctx;
            obj.ctx_ptr = ctx;
            obj.socket_type = socket_type;
        end
    end
    methods
        function delete(obj)
            calllib('libzmq', 'zmq_close', obj.ptr)
        end

        function bind(obj, endpoint)
            r = calllib('libzmq', 'zmq_bind', obj.ptr, endpoint)
            if r ~= 0
                zmq.ThrowZMQError()
            end
        end

        function unbind(obj, endpoint)
            r = calllib('libzmq', 'zmq_unbind', obj.ptr, endpoint)
            if r ~= 0
                zmq.ThrowZMQError()
            end
        end

        function connect(obj, endpoint)
            r = calllib('libzmq', 'zmq_connect', obj.ptr, endpoint)
            if r ~= 0
                zmq.ThrowZMQError()
            end
        end

        function disconnect(obj, endpoint)
            r = calllib('libzmq', 'zmq_disconnect', obj.ptr, endpoint)
            if r ~= 0
                zmq.ThrowZMQError()
            end
        end
    end
end