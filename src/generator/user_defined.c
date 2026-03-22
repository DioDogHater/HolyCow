#include "user_defined.h"
#include "evaluator.h"

vector_t vars[1] = { NEW_VECTOR(var_t) };

// http://www.cse.yorku.ca/~oz/hash.html
// djb2 hashing function (adapted)
static size_t func_hashing_function(const void* key){
    const func_t* func = key;
    size_t hash = 5381;
    const char* str = func->str;
    for(size_t i = 0; i < func->strlen; i++, str++)
        hash = ((hash << 5) + hash) + *str;
    //HC_PRINT("hash(\"%.*s\") = %lu\n", (int)func->strlen, func->str, hash % 128);
    return hash;
}
static bool func_cmp_function(const void* a, const void* b){
    const func_t* a_key = a;
    const func_t* b_key = b;
    if(a_key->strlen != b_key->strlen)
        return false;
    return strncmp(a_key->str, b_key->str, a_key->strlen) == 0;
}
hashtable_t funcs[1] = { NEW_HASHTABLE(sizeof(func_t), func_hashing_function, func_cmp_function) };

vector_t structs[1] = { NEW_VECTOR(struct_t) };
vector_t unions[1] = { NEW_VECTOR(union_t) };
vector_t enums[1] = { NEW_VECTOR(enum_t) };

// Find a named thing in a vector
void* find_named_thing(vector_t* vec, const char* str, size_t strlen){
    for(size_t i = 0; i < vector_size(vec); i++){
        struct{ const char* str; size_t strlen; }* thing = vector_at(vec, i);
        if(thing->strlen == strlen && strncmp(thing->str, str, strlen) == 0)
            return thing;
    }
    return NULL;
}

// Find a variable with its name
var_t* get_var(const char* str, size_t strlen){
    return (var_t*) find_named_thing(vars, str, strlen);
}

// Find a function with its name
func_t* get_func(const char* str, size_t strlen){
    struct{ const char* str; size_t strlen; } pair = {str, strlen};
    return (func_t*) hashtable_get(funcs, &pair);
}

// Find a struct with its name
struct_t* get_struct(const char* str, size_t strlen){
    return (struct_t*) find_named_thing(structs, str, strlen);
}

// get_struct wrapper for tokens
struct_t* get_struct_tk(token_t* tk){
    return get_struct(tk->str, tk->strlen);
}

// Find a structure's member
var_t* get_member(struct_t* struc, const char* str, size_t strlen){
    return (var_t*) find_named_thing(struc->members, str, strlen);
}

// Find a structure's method
func_t* get_method(struct_t* struc, const char* str, size_t strlen){
    return (func_t*) find_named_thing(struc->funcs, str, strlen);
}

// Find a union type
union_t* get_union(const char* str, size_t strlen){
    return (union_t*) find_named_thing(unions, str, strlen);
}

union_t* get_union_tk(token_t* tk){
    return get_union(tk->str, tk->strlen);
}

// Find a union's member
node_stmt* get_union_member(union_t* uni, const char* str, size_t strlen){
    for(node_stmt* ptr = uni->members; ptr; ptr = ptr->next){
        if(ptr->var_decl.identifier->strlen == strlen && strncmp(ptr->var_decl.identifier->str, str, strlen) == 0)
            return ptr;
    }
    return NULL;
}

// Find a enum type
enum_t* get_enum(const char* str, size_t strlen){
    return (enum_t*) find_named_thing(enums, str, strlen);
}

// Get an enum elements' value
bool get_enum_val(enum_t* enu, const char* str, size_t strlen, int64_t* result){
    int64_t tmp;
    if(!result)
        result = &tmp;
    *result = 0;
    for(node_expr* ptr = enu->vals; ptr; ptr = ptr->next){
        if(ptr->type == tk_assign){
            if(!eval_int_expr(ptr->bin_op.rhs, result)){
                print_context_expr("Expression is not constant", ptr->bin_op.rhs);
                return false;
            }
            if(ptr->bin_op.lhs->term.strlen == strlen &&
                strncmp(ptr->bin_op.lhs->term.str, str, strlen) == 0)
                return true;
        }else{
            (*result)++;
            if(ptr->term.strlen == strlen && strncmp(ptr->term.str, str, strlen) == 0)
                return true;
        }
    }
    return false;
}
