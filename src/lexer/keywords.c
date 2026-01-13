#include "lexer.h"

#define KEYWORD(str) {#str, sizeof(#str)-1, tk_##str}
#define ALIAS_KW(a,b) {#a, sizeof(#a)-1, tk_##b}
#define KEYWORD_COUNT (sizeof(keywords)/sizeof(struct keyword_pair))
static struct keyword_pair keywords[] = {
    KEYWORD(void),
    ALIAS_KW(char,uint8),
    ALIAS_KW(int,int64),
    ALIAS_KW(uint,uint64),
    KEYWORD(int8),
    KEYWORD(uint8),
    KEYWORD(int16),
    KEYWORD(uint16),
    KEYWORD(int32),
    KEYWORD(uint32),
    KEYWORD(int64),
    KEYWORD(uint64),
    KEYWORD(bool),
    KEYWORD(flag),
    KEYWORD(const),
    KEYWORD(constexpr),
    KEYWORD(nothing),
    KEYWORD(if),
    ALIAS_KW(elif, else_if),
    KEYWORD(else),
    KEYWORD(while),
    KEYWORD(for),
    KEYWORD(switch),
    KEYWORD(break),
    KEYWORD(continue),
    KEYWORD(return),
    KEYWORD(repeat),
    ALIAS_KW(true, bool_lit),
    ALIAS_KW(false, bool_lit),
    KEYWORD(and),
    KEYWORD(or),
    KEYWORD(not),
    ALIAS_KW(@next,next),
    ALIAS_KW(@asm,asm),
    KEYWORD(sizeof),
    KEYWORD(typeof),
    ALIAS_KW(@stack_alloc,stack_alloc)
};

// http://www.cse.yorku.ca/~oz/hash.html
// djb2 hashing function (adapted)
static size_t keyword_hashing_function(const void* key){
    const struct keyword_pair* keyword = key;
    size_t hash = 5381;
    const char* str = keyword->str;
    for(size_t i = 0; i < keyword->strlen; i++, str++)
        hash = ((hash << 5) + hash) + *str;
    return hash;
}
static bool keyword_cmp_function(const void* a, const void* b){
    const struct keyword_pair* a_key = a;
    const struct keyword_pair* b_key = b;
    if(a_key->strlen != b_key->strlen)
        return false;
    return strncmp(a_key->str, b_key->str, a_key->strlen) == 0;
}

hashtable_t keyword_table = NEW_HASHTABLE(sizeof(struct keyword_pair), keyword_hashing_function, keyword_cmp_function);

bool keyword_table_setup(){
    if(!hashtable_init(&keyword_table, 16))
        return false;
    for(size_t i = 0; i < KEYWORD_COUNT; i++)
        if(!hashtable_set(&keyword_table, &keywords[i]))
            return false;
    return true;
}

void keyword_table_destroy(){
    hashtable_destroy(&keyword_table);
}
