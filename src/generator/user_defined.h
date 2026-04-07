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
var_t* get_var(const char* str, size_t strlen);


enum constexpr_types {
    CONST_INT,
    CONST_FLOAT
};

typedef struct{
    const char* str;
    size_t strlen;
    size_t type;
    union{
        int64_t i;
        double f;
    };
} constexpr_t;
extern vector_t consts[1];

// Get a constant
constexpr_t* get_constexpr(const char* str, size_t strlen);

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
func_t* get_func(const char* str, size_t strlen);


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
struct_t* get_struct(const char* str, size_t strlen);
// Find a structure type using a token
struct_t* get_struct_tk(token_t* name);
// Find a structure's member
var_t* get_member(struct_t* stru, const char* str, size_t strlen);
// Find a class' method
func_t* get_method(struct_t* stru, const char* str, size_t strlen);


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
union_t* get_union(const char* str, size_t strlen);
// Find a union type with a token
union_t* get_union_tk(token_t* name);
// Find a union's member
node_stmt* get_union_member(union_t* unio, const char* str, size_t strlen);


typedef struct {
    const char* str;
    size_t strlen;
    node_expr* vals;
} enum_t;
extern vector_t enums[1];

// Find an enum type
enum_t* get_enum(const char* str, size_t strlen);
// Get an enum elements' value
bool get_enum_val(enum_t* enu, const char* str, size_t strlen, int64_t* result);


// A module is kind of a global unique class instance
// Close to the singleton design pattern
typedef struct{
    const char* str;
    size_t strlen;
    size_t size;        // Size in program memory of module
    vector_t consts[1];
    vector_t vars[1];
    vector_t funcs[1];
    node_expr* vals;
    bool external;
} module_t;
extern vector_t modules[1];

// Get a module
module_t* get_module(const char* str, size_t strlen);
// Get a constexpr inside a module
constexpr_t* get_module_const(module_t* mod, const char* str, size_t strlen);
// Get a function inside a module
func_t* get_module_func(module_t* mod, const char* str, size_t strlen);
// Get a variable inside a module
var_t* get_module_var(module_t* mod, const char* str, size_t strlen);

#endif
