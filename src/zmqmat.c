#include "zmqmat.h" 
#include <zmq.h>

int zmqmat_wait(void** sockets, int nsockets, long timeout) {
    int i, r;
    zmq_pollitem_t* items = (zmq_pollitem_t*) calloc(nsockets, sizeof(zmq_pollitem_t));
    for(i = 0; i < nsockets; i++) {
        items[i].socket = sockets[i];
        items[i].events = ZMQ_POLLIN;
    }
    r = zmq_poll(items, nsockets, timeout);
    free(items);
    return r;
}