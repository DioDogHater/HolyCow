#ifndef HC_USER_DEFINED_H
#define HC_USER_DEFINED_H

#include "../compiler.h"
#include "../lexer/lexer.h"
#include "../parser/parser.h"
#include "hc_types.h"

// A structure to represent a variable
enum var_locations {
    VAR_STACK,
    VAR_ARRAY,
    VAR_GLOBAL,
    VAR_GLOBAL_ARR,
    VAR_ARG
};

typedef struct{
    const char* str;
    size_t strlen;
    int stack_ptr;
    short location;
    short flags;
    type_t type;
} var_t;
extern vector_t vars[1];

// Find a variable
var_t* get_var(const char*, size_t);

// Functions
typedef struct{
    const char* str;
    size_t strlen;
    node_stmt* args;
    size_t flags;
    type_t type;
} func_t;
extern hashtable_t funcs[1];

// Find a function
func_t* get_func(const char*, size_t);

// Structs / classes
typedef struct{
    const char* str;
    size_t strlen;
    size_t size;
    size_t align;
    vector_t members[1];
    vector_t funcs[1];
    node_expr* default_values;
} struct_t;
extern vector_t structs[1];

// Find a structure type
struct_t* get_struct(const char*, size_t);
// Find a structure type using a token
struct_t* get_struct_tk(token_t*);
// Find a structure's member
var_t* get_member(struct_t*, const char*, size_t);
// Find a class' method
func_t* get_method(struct_t*, const char*, size_t);

// Unions / variants
typedef struct{
    const char* str;
    size_t strlen;
    size_t size;
    unsigned int align;
    bool is_variant;       // Will be padded between align and members
    node_stmt* members;
} union_t;
extern vector_t unions[1];

// Find a union type
union_t* get_union(const char*, size_t);
// Find a union type with a token
union_t* get_union_tk(token_t*);
// Find a union's member
node_stmt* get_union_member(union_t*, const char*, size_t);

typedef struct enum_t {
    const char* str;
    size_t strlen;
    node_expr* vals;
} enum_t;
extern vector_t enums[1];

// Find an enum type
enum_t* get_enum(const char*, size_t);
// Get an enum elements' value
bool get_enum_val(enum_t*, const char*, size_t, int64_t*);

#endif
