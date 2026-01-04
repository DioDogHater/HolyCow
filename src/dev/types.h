#ifndef HCC_TYPES_H
#define HCC_TYPES_H

#include "libs.h"

// Arena allocator
#define NEW_ARENA() (arena_t){0,0,NULL,NULL}
typedef struct arena_t {
    size_t size;
    size_t ptr;
    uint8_t* data;
    struct arena_t* next;
} arena_t;

// Initialise an arena allocator
bool arena_init(arena_t*,size_t);

// Allocate a space in the arena
void* arena_alloc(arena_t*,size_t);
#define ARENA_ALLOC(_a, _type) (_type*)arena_alloc((_a), sizeof(_type))

// Deallocate a space in the arena
bool arena_dealloc(arena_t*,size_t);

// Destroy the arena (free its resources)
void arena_destroy(arena_t*);

// File structure
#define HCC_FILE_NAME_LEN 256
#define NEW_FILE(name) (file_t){(name),0,NULL,NULL}
#define GET_FILENAME(_file_start) (*(const uint8_t**)((_file_start) - sizeof(const uint8_t*)))
typedef struct file_t {
    uint8_t* file_name;
    size_t size;
    uint8_t* data;
    struct file_t* next;
} file_t;

// Read the contents of a file
bool file_read(file_t*);

// Destroy the file (free the file contents)
void file_destroy(file_t*);

// Vectors
#define VECTOR_INIT_SIZE 64
#define _NEW_VECTOR(sz) {(sz),0,0,NULL,NULL}
#define NEW_VECTOR(type) _NEW_VECTOR(sizeof(type))
typedef struct vector_t {
    size_t _data_size;
    size_t size;
    size_t memsize;
    uint8_t* data;
    struct vector_t* next;
} vector_t;
// Allocate an amount of data
bool vector_alloc(vector_t*, size_t);
// Get the size of a vector
size_t vector_size(vector_t*);
// Get an element of data in the vector
void* vector_at(vector_t*,size_t);
// Get the last element of the vector
void* vector_back(vector_t*);
// Add an element to the end of the vector
bool vector_append(vector_t*,const void*);
// Remove the last element of the vector
bool vector_popback(vector_t*);
// Destroy the vector (free the vector's data)
void vector_destroy(vector_t*);

// Hashset (simple array, only allocated when needed)
#define NEW_HASHSET() (hashset_t){0, NULL}
typedef struct {
    size_t size;
    uint8_t* pairs;
} hashset_t;

// Hashtable
#define HASHTABLE_GROW(n) ((n) * 2)
#define HASHTABLE_MAX_SET_SIZE 8
#define NEW_HASHTABLE(pair_size,hash_func,cmp_func) {0, NULL, (pair_size), (hash_func), (cmp_func)}
typedef struct {
    size_t size;
    hashset_t* sets;
    size_t pair_size;
    size_t (*hashing_func)(const void*);
    bool (*cmp_func)(const void*,const void*);
} hashtable_t;
// Initialise the hashtable
bool hashtable_init(hashtable_t*,size_t);
// Grow the hashtable (make a new one, but bigger)
bool hashtable_grow(hashtable_t*,size_t);
// Add an element to the hashtable
bool hashtable_set(hashtable_t*,const void*);
// Get an element from the hashtable
void* hashtable_get(hashtable_t*,const void*);
// Destroy the hashtable (free the hashsets)
void hashtable_destroy(hashtable_t*);

#endif
