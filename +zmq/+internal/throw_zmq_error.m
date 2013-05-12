function throw_zmq_error()
% throw_zmq_error
%   This function will throw an error based on
%   the last zmq error. Note, it will always throw,
%   it should only be called when zmq api call has given 
%   a null pointer or similar to indicate an error.
    zmq.Context.load_zmq();
    err = zmqraw.ZmqLibrary.zmq_errno();
    if err == 0
        error(...
            ['A zmq error occured, but errno has not '...
            'been set (should not happen).']);
    end
    err_string = zmqraw.ZmqLibrary.zmq_strerror(err);
    error(['zmq_error:' num2str(err) ':' err_string]);
end