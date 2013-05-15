function test(main)
    req_rep_tests = {@simple_test, @multi_test, @wait_test};
    for f = req_rep_tests
        f = f{1};
        endpoint = 'tcp://127.0.0.1:5678/';
        if main
            sock = zmq.socket('req');
            sock.connect(endpoint);
        else
            sock = zmq.socket('rep');
            sock.bind(endpoint);
        end
        f(sock, main);
        delete(sock);
    end
end

function simple_test(sock, isreq)
    if isreq
        sock.send('echo');
        strequal(sock.recv(), 'echo');
        sock.send('echo');
        strequal(sock.recv(), 'echo');
    else
        sock.send(sock.recv());
        sock.send(sock.recv('multi'));
    end
end

function multi_test(sock, isreq)
    if isreq
        sock.send({'Hello', 'world!'});
        rep = sock.recv('multi');
        assert(length(rep) == 2);
        strequal(rep{1}, 'Hello');
        strequal(rep{2}, 'world!');
    else
        sock.send(sock.recv('multi'));
    end
end

function wait_test(sock, isreq)
    if isreq
        epsilon = 0.03; % 30 ms grace
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
    else
        strequal(sock.recv() , 'ping');
        sock.send('pong');
    end
end

function strequal(a, b)
    assert(logical(strcmp(a, b)))
end