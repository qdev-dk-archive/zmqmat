#ifndef __ZMQMAT_H_INCLUDED__
#define __ZMQMAT_H_INCLUDED__

#include <stdlib.h>

#define zmqmat_export __declspec(dllexport) 

zmqmat_export void* zmqmat_marray(size_t size);
zmqmat_export void zmqmat_insert(void* array, void* socket);
zmqmat_export int zmqmat_wait(void* array, long timeout);

#undef zmqmat_export

#endif