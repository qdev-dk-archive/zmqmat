#include "zmqmat.h" 
#include <zmq.h>

struct sock_array_t {
    size_t size;
    size_t index;
    void** content; // An array of socket pointers (void*).
};

void* zmqmat_marray(size_t size){
    struct sock_array_t* r = (struct sock_array_t*) malloc(sizeof(struct sock_array_t));
    r->size = size;
    r->index = 0;
    r->content = NULL;
    if(size != 0) r->content = (void**) calloc(size, sizeof(void*));
    return r;
}

void zmqmat_insert(void* array_, void* socket){
    struct sock_array_t* array = (struct sock_array_t*) array_;
    size_t index = array->index;
    if(index >= array->size) return;
    array->content[index] = socket;
    array->index++;
}

int zmqmat_wait(void* array_, long timeout) {
    struct sock_array_t* array = (struct sock_array_t*) array_;
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