function sida_a()
    for i = 1:2
        sock = zmq.socket('req');
        sock.connect('tcp://127.0.0.1:5678/');
        sock.send('echo');
        strequal(sock.recv(), 'echo');
    end

    sock.send({'Hello', 'world!'});
    rep = sock.recv('multi');
    assert(length(rep) == 2);
    strequal(rep{1}, 'Hello');
    strequal(rep{2}, 'world!');

    epsilon = 0.01; % 10 ms grace
    tic;
    r = zmq.wait(sock, 1000); 
    t = toc;
    assert(~r);
    assert(abs(t - 1.0) < epsilon);
    sock.send('ping');
    tic; r = zmq.wait(sock, 1000); t = toc;
    assert(r);
    assert(t < epsilon);
    strequal(sock.recv(), 'pong');

end