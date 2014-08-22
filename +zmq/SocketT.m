classdef SocketT < handle
    properties (Access = private)
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

    properties (Access = private, Constant)
        EAGAIN = 11
    end

    methods (Access=?zmq.Context)
        function obj = SocketT(ptr, ctx, ctx_ptr, socket_type)
            obj.ptr = ptr;
            obj.ctx = ctx;
            obj.ctx_ptr = ctx_ptr;
            obj.socket_type = socket_type;

            % Since matlab runs everything in the gui thread
            % we set a timeout of 200ms on the sockets and retry
            % recv and send as necessary.
            for opt = [ zmqraw.ZmqLibrary.ZMQ_RCVTIMEO, ...
                        zmqraw.ZmqLibrary.ZMQ_SNDTIMEO]
                v = org.bridj.Pointer.pointerToInt(200);
                obj.set_socket_option_scalar(opt, v);
            end

            % Initialize a zmq_msg_t that we will use
            % to receive messages.
            obj.msg = zmqraw.zmq_msg_t();
            obj.msg_ptr = org.bridj.Pointer.pointerTo(obj.msg);
            zmqraw.ZmqLibrary.zmq_msg_init(obj.msg_ptr);
        end
    end
    methods
        function delete(obj)
            zmqraw.ZmqLibrary.zmq_close(obj.ptr);
            zmqraw.ZmqLibrary.zmq_msg_close(obj.msg_ptr);
        end

        function bind(obj, endpoint)
            r = zmqraw.ZmqLibrary.zmq_bind(obj.ptr, ...
                org.bridj.Pointer.pointerToCString(endpoint));
            if r == -1
                zmq.internal.throw_zmq_error();
            end
        end

        function unbind(obj, endpoint)
            r = zmqraw.ZmqLibrary.zmq_unbind(obj.ptr, ...
                org.bridj.Pointer.pointerToCString(endpoint));
            if r == -1
                zmq.internal.throw_zmq_error();
            end
        end

        function connect(obj, endpoint)
            r = zmqraw.ZmqLibrary.zmq_connect(obj.ptr, ...
                org.bridj.Pointer.pointerToCString(endpoint));
            if r == -1
                zmq.internal.throw_zmq_error();
            end
        end

        function disconnect(obj, endpoint)
            r = zmqraw.ZmqLibrary.zmq_disconnect(obj.ptr, ...
                org.bridj.Pointer.pointerToCString(endpoint));
            if r == -1
                zmq.internal.throw_zmq_error();
            end
        end

        function subscribe(obj, filter)
            obj.set_socket_option_bytes(zmqraw.ZmqLibrary.ZMQ_SUBSCRIBE, filter);
        end

        function unsubscribe(obj, filter)
            obj.set_socket_option_bytes(zmqraw.ZmqLibrary.ZMQ_UNSUBSCRIBE, filter);
        end

        function send(obj, msg)
        % sock.send(msg)
        %   
        % If msg is a string, that string will be sent as a single message. If
        % msg is a cell array of strings, a multi-part message will be sent.
            if iscell(msg)
                assert(~isempty(msg));
                for m = msg
                    assert(ischar(m{1}));
                end
                head = msg{1};
                tail = msg(2:end);
            else
                assert(ischar(msg));
                head = msg;
                tail = {};
            end
            while true
                r = obj.send_base(head, ~isempty(tail));
                if r == -1
                    err = zmqraw.ZmqLibrary.zmq_errno();
                    if err ~= obj.EAGAIN
                        zmq.internal.throw_zmq_error(err);
                    end
                    drawnow();
                else
                    break;
                end
            end
            for i = 1:length(tail)
                r = obj.send_base(tail{i}, i ~= length(tail));
                if r == -1
                    zmq.internal.throw_zmq_error();
                end
            end
        end

        function [msg, varargout] = recv(obj, varargin)
        % msg = sock.recv(['multi'])
        % [msg, received] = sock.recv('dontwait', ['multi'])
        %
        % Without options, receive a single message as a string.
        %
        % Options:
        %   - 'multi': Receive a cell array containing all the parts of a
        %     multi-part message. Without this options, multi-part messages
        %     will be concatenated.
        %   - 'dontwait': Do not block if no messages are immediately
        %     available.
            blocking = true;
            multi = false;
            for opt = varargin
                switch opt{1}
                case 'multi'
                    multi = true;
                case 'dontwait'
                    blocking = false;
                otherwise
                    error('Unsupported option: %s', opt{1})
                end
            end
            [received, msgs] = obj.recv_base(blocking);
            if multi
                msg = msgs;
            else
                msg = cell2mat(msgs);
            end
            if ~blocking
                varargout{1} = received;
            end
        end

        function ptr = get_raw_ptr(obj)
        % get_raw_ptr
        %   
        %   Returns a ptr to the underlying zmq socket. See bridj for more
        %   information. The jar zmqraw is JNAerator generated bridj binding 
        %   of zmq.h.
            ptr = obj.ptr;
        end
    end
    methods (Access=private)

        function r = send_base(obj, msg, sndmore)
            assert(ischar(msg));
            if sndmore
                flags = zmqraw.ZmqLibrary.ZMQ_SNDMORE;
            else
                flags = 0;
            end
            bytes = uint8(msg);
            bytes_ptr = org.bridj.Pointer.pointerToBytes(bytes);
            r = zmqraw.ZmqLibrary.zmq_send(obj.ptr, bytes_ptr, numel(bytes), flags);
        end

        function set_socket_option_scalar(obj, name, v)
            r = zmqraw.ZmqLibrary.zmq_setsockopt(obj.ptr, name, ...
                v, org.bridj.BridJ.sizeOf(v.getTargetType()));
            if r ~= 0
                zmq.internal.throw_zmq_error();
            end
        end

        function set_socket_option_bytes(obj, name, val)
            bytes = uint8(val);
            bytes_ptr = org.bridj.Pointer.pointerToBytes(bytes);
            r = zmqraw.ZmqLibrary.zmq_setsockopt(obj.ptr, name, ...
                bytes_ptr, length(bytes));
            if r ~= 0
                zmq.internal.throw_zmq_error();
            end
        end

        function [received, msgs] = recv_base(obj, block)
            msgs = {};
            received = true;
            while true
                if block
                    flags = zmqraw.ZmqLibrary.ZMQ_DONTWAIT;
                else
                    flags = 0;
                end
                r = zmqraw.ZmqLibrary.zmq_msg_recv(obj.msg_ptr, obj.ptr, flags);
                if r == -1
                    err = zmqraw.ZmqLibrary.zmq_errno();
                    if err == obj.EAGAIN
                        if ~block
                            received = false;
                            return
                        end
                        drawnow();
                    else
                        zmq.internal.throw_zmq_error(err);
                    end
                else
                    break;
                end
            end
            while true
                siz = zmqraw.ZmqLibrary.zmq_msg_size(obj.msg_ptr);
                if siz ~= 0
                    data = zmqraw.ZmqLibrary.zmq_msg_data(obj.msg_ptr);
                    msgs{end + 1} = char(transpose(data.getBytes(siz)));
                else
                    msgs{end + 1} = char([]);
                end
                if ~zmqraw.ZmqLibrary.zmq_msg_more(obj.msg_ptr)
                    return
                end
                r = zmqraw.ZmqLibrary.zmq_msg_recv(obj.msg_ptr, obj.ptr, 0);
                if r == -1
                    zmq.internal.throw_zmq_error();
                end
            end
        end
    end
end