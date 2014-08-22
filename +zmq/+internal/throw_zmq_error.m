function throw_zmq_error(err)
% throw_zmq_error
%   This function will throw an error based on
%   the last zmq error. Note, it will always throw,
%   it should only be called when zmq api call has given 
%   a null pointer or similar to indicate an error.
    zmq.Context.load_zmq();
    if nargin == 0
        err = zmqraw.ZmqLibrary.zmq_errno();
    end
    if err == 0
        error(...
            ['A zmq error occured, but errno has not '...
            'been set (should not happen).']);
    end
    str = zmqraw.ZmqLibrary.zmq_strerror(err);
    err_string = char(str.getCString());
    error(['zmq_error:' num2str(err) ':' err_string]);
end