function sida_b()
    sock = zmq.socket('rep');
    sock.bind('tcp://127.0.0.1:5678/');
    req = sock.recv();
    sock.send(req);
end