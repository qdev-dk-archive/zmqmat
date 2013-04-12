function ready = wait(sockets, timeout)
% wait(sockets, timeout)
%
%   Wait up to timeout milliseconds on one or more
%   sockets. The function returns when one of the 
%   sockets has a message ready to be received without
%   blocking. wait returns false if the function timed out before 
%   anything was received, otherwise it returns true.
%   Use recv_no_wait to figure out which socket is ready.
%
%   timeout can be 0 to not wait at all, or -1 to wait 
%   indefinitely. Timeout must be an integer.
    items = [];
    for socket = sockets
        item.socket = socket.get_raw_ptr();
        item.fd = 0;
        item.events = 1; % 1 is ZMQ_POLLIN
        item.revents = 0;
        items = [items item];
    end
    items_ptr = libpointer('zmq_pollitem_tPtr', items);
    r = calllib('libzmq', 'zmq_poll', items_ptr, numel(items), timeout);
    if r == -1
        zmq.internal.throw_zmq_error();
    end
    ready = r >= 1;
end