function sida_b()
    sock = zmq.socket('rep');
    sock.bind('tcp://127.0.0.1:5678/');
    % echo a few times
    sock.send(sock.recv());
    sock.send(sock.recv('multi'));
    sock.send(sock.recv('multi'));

    strequal(sock.recv() , 'ping');
    sock.send('pong');
end