#include "libs.h"
#include "types.h"

bool arena_init(arena_t* arena, size_t size){
    if(!arena)
        return false;
    arena->size = size;
    arena->ptr = 0;
    // Add enough space to create new arena for backup
    arena->data = HC_MALLOC(size);
    if(!arena->data){
        HC_PRINT("ARENA : Failed to allocate %lu bytes\n", size);
        return false;
    }
    return true;
}

// Allocate memory in arena
void* arena_alloc(arena_t* arena, size_t size){
    if(!arena || !arena->size || !arena->data){
        HC_PRINT("ARENA : Invalid arena\n");
        return NULL;
    }
    if(arena->ptr + size >= arena->size){
        if(!arena->next){
            arena->next = HC_MALLOC(sizeof(arena_t));
            if(!arena->next){
                HC_PRINT("ARENA : Failed to allocate %lu bytes\n", sizeof(arena_t));
                return NULL;
            }if(!arena_init(arena->next, arena->size))
                return NULL;
        }
        return arena_alloc(arena->next, size);
    }
    void* ptr = arena->data + arena->ptr;
    arena->ptr += size;
    return ptr;
}

// Deallocate memory linearly from arena
bool arena_dealloc(arena_t* arena, size_t size){
    if(!arena || !arena->size)
        HC_PRINT("ARENA : Invalid arena\n");
    else if(arena->next && arena_dealloc(arena->next, size) && arena->ptr >= size){
        arena->ptr -= size;
        return true;
    }else if(arena->ptr >= size){
        arena->ptr -= size;
        return true;
    }
    return false;
}

void arena_destroy(arena_t* arena){
    if(arena->data)
        HC_FREE(arena->data);
    if(arena->next){
        arena_destroy(arena->next);
        HC_FREE(arena->next);
    }
    *arena = NEW_ARENA();
}
