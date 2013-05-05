function ready = wait(sockets, timeout)
% wait(sockets, timeout)
%
%   Wait up to timeout milliseconds on one or more sockets. The function
%   returns when one of the sockets has a message ready to be received without
%   blocking. wait returns false if the function timed out before anything was
%   received, otherwise it returns true. If you are waiting on multiple
%   sockets, then use recv_no_wait to figure out which socket is ready.
%
%   timeout can be 0 to not wait at all, or Inf to wait indefinitely. Timeout
%   must be an integer.
    socketptrs = [];
    for socket = sockets
        socketptrs = [socketptrs socket.get_raw_ptr()];
    end
    array = calllib('zmqmat', 'zmqmat_array_new', numel(socketptrs));
    cleanup = onCleanup(@()calllib('zmqmat', 'zmqmat_array_free', array));
    
    for socketptr = socketptrs
        calllib('zmqmat', 'zmqmat_array_insert', array, socketptr);
    end

    id = tic();
    r = 0;
    while true
        time_left = timeout - toc(id)*1000;
        tim = max(min(time_left, 200), 0);
        r = calllib('zmqmat', 'zmqmat_wait', array, tim);
        if r == -1
            zmq.internal.throw_zmq_error();
        elseif r > 0 || time_left < 0
            break;
        end
        drawnow();
    end
    ready = r >= 1;
end