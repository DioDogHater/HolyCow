#include "lexer.h"
#include <string.h>

token_t* tokenize(const char* code, arena_t* arena){
    if(!keyword_table_setup())
        return false;

    const char* str = code;

    hashtable_destroy(&keyword_table);
    return NULL;
}
