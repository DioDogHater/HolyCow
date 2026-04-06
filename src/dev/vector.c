#include "libs.h"
#include "types.h"

static arena_t* vector_arena = NULL;

bool vector_alloc(vector_t* vector, size_t size){
    if(!vector){
        HC_ERR("VECTOR : Invalid vector");
        return false;
    }
    if((ssize_t)vector->memsize - (ssize_t)vector->size < (ssize_t)size){
        if(vector->memsize){
            if(!vector->next){
                if(vector_arena)
                    vector->next = ARENA_ALLOC(vector_arena, vector_t);
                else
                    vector->next = HC_MALLOC(sizeof(vector_t));
                if(!vector->next){
                    HC_ERR("VECTOR : Failed to allocate %lu bytes",sizeof(vector_t));
                    return false;
                }
                *vector->next = (vector_t) _NEW_VECTOR(vector->_data_size);
            }
            vector->size = vector->memsize;
            return vector_alloc(vector->next, size - (vector->memsize - vector->size));
        }else{
            vector->memsize = size + VECTOR_INIT_SIZE;
            if(vector_arena)
                vector->data = arena_alloc(vector_arena, vector->_data_size * vector->memsize);
            else
                vector->data = HC_MALLOC(vector->_data_size * vector->memsize);
            if(!vector->data){
                HC_ERR("VECTOR : Failed to allocate %lu bytes", vector->_data_size * size);
                return false;
            }
            vector->size = size;
        }
    }else
        vector->size += size;

    return true;
}

static void* vector_traverse(vector_t* vector, size_t count){
    if(!vector){
        HC_ERR("VECTOR : Index out of range");
        return NULL;
    }
    if(count < vector->size)
        return (void*) &vector->data[vector->_data_size * count];
    if(vector->size == vector->memsize && vector->next)
        return vector_traverse(vector->next, count - vector->size);
    HC_ERR("VECTOR : Index out of range");
    return NULL;
}

size_t vector_size(vector_t* vector){
    if(!vector)
        return 0;
    size_t sz = vector->size;
    if(vector->next)
        sz += vector_size(vector->next);
    return sz;
}

void* vector_at(vector_t* vector, size_t index){
    if(!vector)
        return NULL;
    return vector_traverse(vector, index);
}

void* vector_back(vector_t* vector){
    if(!vector)
        return NULL;
    return vector_traverse(vector, vector_size(vector) - 1);
}

void* vector_append(vector_t* vector, const void* elem){
    if(!vector || !vector_alloc(vector, 1))
        return NULL;
    void* ptr = vector_back(vector);
    if(!ptr)
        return false;
    memcpy(ptr, elem, vector->_data_size);
    return ptr;
}

bool vector_popback(vector_t* vector){
    if(!vector){
        HC_ERR("VECTOR : Invalid vector");
        return false;
    }
    if(vector->next && vector->next->size)
        vector_popback(vector->next);
    else if(vector->size)
        vector->size--;
    else{
        HC_ERR("VECTOR : Tried popping empty vector");
        return false;
    }
    return true;
}

void vector_destroy(vector_t* vector){
    if(!vector)
        HC_ERR("VECTOR : Invalid vector");
    else if(!vector_arena){
        if(vector->next){
            vector_destroy(vector->next);
            HC_FREE(vector->next);
        }
        if(vector->data)
            HC_FREE(vector->data);
        *vector = (vector_t) _NEW_VECTOR(0);
    }
}

void vector_set_arena(arena_t* a){ vector_arena = a; }
