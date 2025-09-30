#ifndef HCC_TYPES_H
#define HCC_TYPES_H

#include "libs.h"

#define NEW_ARENA() (arena_t){0,0,NULL,NULL}
typedef struct arena_t {
    size_t size;
    size_t ptr;
    uint8_t* data;
    struct arena_t* next;
} arena_t;
bool arena_init(arena_t*,size_t);
void* arena_alloc(arena_t*,size_t);
bool arena_dealloc(arena_t*,size_t);
void arena_destroy(arena_t*);

#define HCC_FILE_NAME_LEN 256
#define NEW_FILE(name) (file_t){(name),0,NULL,NULL}
typedef struct file_t {
    uint8_t file_name[HCC_FILE_NAME_LEN];
    size_t size;
    uint8_t* data;
    struct file_t* next;
} file_t;
bool file_read(file_t*);
void file_destroy(file_t*);

#define VECTOR_INIT_SIZE 128
#define NEW_VECTOR(type) {sizeof(type),0,0,NULL,NULL}
typedef struct vector_t {
    size_t _data_size;
    size_t size;
    size_t memsize;
    uint8_t* data;
    struct vector_t* next;
} vector_t;
bool vector_append(vector_t*,void*);
bool vector_popback(vector_t*);
void* vector_at(vector_t*,size_t);
void vector_destroy(vector_t*);

#define NEW_LIST(...) {NULL,##__VA_ARGS__}
typedef struct list_t {
    struct list_t* next;
} list_t;
void list_append(list_t*, list_t*);

#endif
