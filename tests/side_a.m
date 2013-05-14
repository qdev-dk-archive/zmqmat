function sida_a()
    sock = zmq.socket('req');
    sock.connect('tcp://127.0.0.1:5678/');
    sock.send('abc');
    strequal(sock.recv(), 'abc');
end