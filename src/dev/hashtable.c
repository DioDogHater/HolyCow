#include "libs.h"
#include "types.h"

bool hashtable_init(hashtable_t* table, size_t size){
    if(!table){
        HC_ERR("HASHTABLE : Invalid table");
        return false;
    }
    table->size = size;
    table->sets = (hashset_t*) HC_REALLOC(table->sets, sizeof(hashset_t) * table->size);
    if(!table->sets){
        HC_ERR("HASHTABLE : Failed to allocate %lu bytes", sizeof(hashset_t) * table->size);
        return false;
    }
    for(size_t i = 0; i < size; i++)
        table->sets[i] = NEW_HASHSET();
    return true;
}

bool hashtable_grow(hashtable_t* table, size_t size){
    if(!table || table->size >= size){
        HC_ERR("HASHTABLE : Invalid table");
        return false;
    }
    HC_PRINT("HASHTABLE : Growing hashtable...");
    hashtable_t new_table = NEW_HASHTABLE(table->pair_size, table->hashing_func, table->cmp_func);
    if(!hashtable_init(&new_table, size))
        return false;
    for(size_t i = 0; i < table->size; i++){
        hashset_t* set = &table->sets[i];
        for(size_t j = 0; j < set->size; i++){
            if(!hashtable_set(&new_table, set->pairs + table->pair_size * j))
                return false;
        }
    }
    hashtable_destroy(table);
    *table = new_table;
    return true;
}

bool hashtable_set(hashtable_t* table, const void* pair){
    if(!table || !table->size || !table->sets || !table->hashing_func){
        HC_ERR("HASHTABLE : Invalid table");
        return false;
    }
    size_t hash = table->hashing_func(pair) % table->size;
    hashset_t* set = &table->sets[hash];
    if(set->size == 0){
        set->pairs = (uint8_t*) HC_MALLOC(table->pair_size * HASHTABLE_MAX_SET_SIZE);
        if(!set->pairs){
            HC_ERR("HASHTABLE : Failed to allocate %lu bytes", table->pair_size * HASHTABLE_MAX_SET_SIZE);
            return false;
        }
    }
    if(set->size == HASHTABLE_MAX_SET_SIZE){
        if(!hashtable_grow(table, HASHTABLE_GROW(table->size)))
            return false;
        return hashtable_set(table, pair);
    }else{
        memcpy(set->pairs + table->pair_size * set->size, pair, table->pair_size);
        set->size++;
    }
    return true;
}

void* hashtable_get(hashtable_t* table, const void* key){
    if(!table || !table->size || !table->sets || !table->hashing_func){
        HC_ERR("HASHTABLE : Invalid table");
        return NULL;
    }
    size_t hash = table->hashing_func(key) % table->size;
    hashset_t* set = &table->sets[hash];
    for(size_t i = 0; i < set->size; i++){
        if(table->cmp_func(set->pairs + table->pair_size * i, key))
            return (void*) (set->pairs + table->pair_size * i);
    }
    return NULL;
}

void hashtable_destroy(hashtable_t* table){
    if(!table || !table->size || !table->sets)
        return;
    for(size_t i = 0; i < table->size; i++)
        if(table->sets[i].pairs) HC_FREE(table->sets[i].pairs);
    HC_FREE(table->sets);
    table->size = 0;
}
