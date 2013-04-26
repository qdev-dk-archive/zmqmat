#ifndef __ZMQMAT_H_INCLUDED__
#define __ZMQMAT_H_INCLUDED__

#include <stdlib.h>

#define zmqmat_export __declspec(dllexport) 

/*
    Since matlab can't constuct arrays of zmq_poll_items or
    even void*'s, we use instead an ad hoc container which is filled
    one socket at a time. We then construct an array of zmq_poll_items
    on the c side to call zmq_poll.
*/
zmqmat_export void* zmqmat_array_new(size_t size); /* Make array */
zmqmat_export void zmqmat_array_free(void* array); /* Free array */
zmqmat_export void zmqmat_array_insert(void* array, void* socket);
zmqmat_export int zmqmat_wait(void* array, long timeout);

/*
    Small wrappers which are simpler for matlab to handle than
    what zmq offers.
*/
zmqmat_export int zmqmat_set_recv_timeout(void* socket, int milliseconds);
zmqmat_export int zmqmat_set_send_timeout(void* socket, int milliseconds);

#undef zmqmat_export

#endif