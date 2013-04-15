#include "zmqmat.h" 
#include <zmq.h>

typedef struct {
    size_t size;
    size_t index;
    void** content; // An array of socket pointers (void*).
} sock_array_t;

void* zmqmat_marray(size_t size){
    sock_array_t* r = (sock_array_t*) malloc(sizeof(sock_array_t));
    r->size = size;
    r->index = 0;
    r->content = NULL;
    if(size != 0) r->content = (void**) calloc(size, sizeof(void*));
    return r;
}

void zmqmat_insert(void* array_, void* socket){
    sock_array_t* array = (sock_array_t*) array_;
    size_t index = array->index;
    if(index >= array->size) return;
    array->content[index] = socket;
    array->index++;
}

int zmqmat_wait(void* array_, long timeout) {
    sock_array_t* array = (sock_array_t*) array_;
    int r;
    size_t i;
    zmq_pollitem_t* items = (zmq_pollitem_t*) calloc(array->size, sizeof(zmq_pollitem_t));
    for(i = 0; i < array->size; i++) {
        items[i].socket = array->content[i];
        items[i].events = ZMQ_POLLIN;
    }
    r = zmq_poll(items, (int) array->size, timeout);
    free(items);
    free(array->content);
    free(array);
    return r;
}

int zmqmat_set_recv_timeout(void* socket, int milliseconds){
    return zmq_setsockopt(socket, ZMQ_RCVTIMEO, &milliseconds, sizeof milliseconds);
}

int zmqmat_set_send_timeout(void* socket, int milliseconds){
    return zmq_setsockopt(socket, ZMQ_SNDTIMEO, &milliseconds, sizeof milliseconds);
}
