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
        HC_ERR("ARENA : Failed to allocate %lu bytes", size);
        return false;
    }
    return true;
}

// Allocate memory in arena
void* arena_alloc(arena_t* arena, size_t size){
    if(!arena || !arena->size || !arena->data){
        HC_ERR("ARENA : Invalid arena");
        return NULL;
    }
    if(arena->ptr + size > arena->size){
        HC_WARN("Couldn't allocate %lu bytes with %lu/%lu bytes of free space in arena", size, arena->size - arena->ptr, arena->size);
        if(!arena->next){
            arena->next = (arena_t*) HC_MALLOC(sizeof(arena_t));
            *arena->next = NEW_ARENA();
            if(!arena->next){
                HC_ERR("ARENA : Failed to allocate %lu bytes", sizeof(arena_t));
                return NULL;
            }if(!arena_init(arena->next, (size > arena->size) ? (size + arena->size) : (arena->size)))
                return NULL;
            // TODO Remove this line
            HC_WARN("Allocating a new arena...");
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
        HC_ERR("ARENA : Invalid arena");
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
