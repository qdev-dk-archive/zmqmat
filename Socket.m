classdef Socket < handle
    properties (SetAccess = private, GetAccess = private)
        ptr
        % ctx is a reference to the parent context to prevent
        % it from being garbage collected until all sockets have
        % been closed properly.
        ctx
        ctx_ptr
        socket_type
        msg
        msg_ptr
    end
    methods (Access=?zmq.Context)
        function obj = Socket(ptr, ctx, ctx_ptr, socket_type)
            obj.ptr = ptr;
            obj.ctx = ctx;
            obj.ctx_ptr = ctx;
            obj.socket_type = socket_type;

            % Initialize a zmq_msg_t that we will use
            % to receive messages.
            obj.msg.m_ = 0;
            obj.msg_ptr = libpointer('zmq_msg_t', obj.msg);
            calllib('libzmq', 'zmq_msg_init', obj.msg_ptr);
        end
    end
    methods
        function delete(obj)
            calllib('libzmq', 'zmq_close', obj.ptr);
            calllib('libzmq', 'zmq_msg_close', obj.msg_ptr);
        end

        function bind(obj, endpoint)
            r = calllib('libzmq', 'zmq_bind', obj.ptr, endpoint);
            if r == -1
                zmq.internal.ThrowZMQError();
            end
        end

        function unbind(obj, endpoint)
            r = calllib('libzmq', 'zmq_unbind', obj.ptr, endpoint);
            if r == -1
                zmq.internal.ThrowZMQError();
            end
        end

        function connect(obj, endpoint)
            r = calllib('libzmq', 'zmq_connect', obj.ptr, endpoint);
            if r == -1
                zmq.internal.ThrowZMQError();
            end
        end

        function disconnect(obj, endpoint)
            r = calllib('libzmq', 'zmq_disconnect', obj.ptr, endpoint);
            if r == -1
                zmq.internal.ThrowZMQError();
            end
        end

        function send(obj, string)
            obj.send_bytes(int8(string));
        end

        function send_bytes(obj, bytes)
            if metaclass(bytes) ~= ?int8
                error('bytes should be an array of int8')
            end
            bytes_ptr = libpointer('voidPtr', bytes);
            r = calllib('libzmq', 'zmq_send', ...
                obj.ptr, bytes_ptr, numel(bytes), 0);
            if r == -1
                zmq.internal.ThrowZMQError();
            end
        end

        function string = recv(obj)
            string = char(obj.recv_bytes());
        end

        function bytes = recv_bytes(obj)
            [received, bytes] = obj.recv_base(true);
        end

        function [received, string] = recv_dont_wait(obj)
            [received, bytes] = obj.recv_base(false);
            string = char(bytes);
        end

        function [received, bytes] = recv_bytes_dont_wait(obj)
            [received, bytes] = obj.recv_base(false);
        end
    end
    methods (Access=private)
        function [received, bytes] = recv_base(obj, block)
            if block
                flags = 0;
            else
                flags = 1; % ZMQ_DONTWAIT from zmq.h
            end
            mor = true;
            bytes = int8([]);
            received = true;
            while mor
                r = calllib('libzmq', 'zmq_msg_recv', ...
                    obj.msg_ptr, obj.ptr, flags);
                if r == -1
                    err = calllib('libzmq', 'zmq_errno');
                    % If this is not a blocking receive, then
                    % we should accept errno == EAGAIN as
                    % nonexceptional. It merely signals that
                    % nothing has been received.
                    % 11 is used as EAGAIN by the included dll.
                    if ~block and err == 11
                        received = false;
                        return;
                    end
                    zmq.internal.ThrowZMQError();
                end
                siz = calllib('libzmq', 'zmq_msg_size', obj.msg_ptr);
                if siz ~= 0
                    data = calllib('libzmq', 'zmq_msg_data', obj.msg_ptr);
                    setdatatype(data, 'int8Ptr', 1, siz);
                    bytes = [bytes data.Value];
                end
                mor = calllib('libzmq', 'zmq_msg_more', obj.msg_ptr);
            end
        end
    end
end