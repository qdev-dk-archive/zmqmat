function sock = socket(typ)
% socket(socket_type)
%
%   Constructs a socket using the default, global context.
%   See <a href="http://api.zeromq.org/3-2:zmq-socket">the ZeroMQ refference</a> for a description of the various types.
    ctx = zmq.Context.get_default_context();
    sock = ctx.socket(typ);
end