#ifndef HCC_GENERATOR_H
#define HCC_GENERATOR_H

#include "../dev/libs.h"
#include "../dev/types.h"
#include "../dev/utils.h"

#include "../lexer/lexer.h"
#include "../parser/parser.h"

#include "target_requirements.h"
#include "regs.h"
#include "hc_types.h"
#include "evaluator.h"

// Stack size and pointer
extern size_t stack_ptr;
extern size_t stack_sz;

// Number of labels created in current func
extern size_t label_count;

// A linked list of all string literals
extern node_term* str_literals;
extern size_t str_literal_count;

// A linked list of all float literals
extern node_term* float_literals;
extern size_t float_literal_count;

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
    int location;
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
    node_stmt* stmts;
    type_t type;
} func_t;
extern vector_t funcs[1];

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
// Find a structure's member
var_t* get_member(struct_t*, const char*, size_t);
// Find a class' method
func_t* get_method(struct_t*, const char*, size_t);

// Unions / variants
typedef struct{
    const char* str;
    size_t strlen;
    size_t size;
    size_t align;
    node_stmt* members;
} union_t;
extern vector_t unions[1];

// Find a union type
union_t* get_union(const char*, size_t);
// Find a union's member
node_stmt* get_union_member(union_t*, const char*, size_t);

// Scopes
// A snapshot of the moment before the scope starts
typedef struct{
    size_t stack_sz, stack_ptr;
    size_t var_sz, size;
} scope_t;

// Get the size of a scope (the size of all variables inside)
size_t get_scope_size(node_stmt* scope);

// Initialise the scope and save the state before it starts
scope_t gen_init_scope(HC_FILE, node_stmt*);

// Quit the scope and return to the state before it started
void gen_quit_scope(HC_FILE, scope_t);


// GENERATION

// Generate an integer expression.
// Returns the register where the value is stored.
// Last arg is the prefered register or NULL if it can be any of them.
#define EXPR_ONCE(expr, type, reg) free_reg(generate_expr(fptr, (expr), (type), (reg)))
reg_t* generate_expr(HC_FILE, node_expr*, type_t, reg_t*);

// Generates a float expression
// Returns true if successful, otherwise false
bool generate_float_expr(HC_FILE, node_expr*);

// Necessary information over the current scope
typedef struct{
    size_t continue_label;
    size_t break_label;
    size_t end_label;
    size_t next_label;
    size_t stack_sz;
    arena_t* arena;
} scope_info;

// Generate a statement
bool generate_stmt(HC_FILE, node_stmt*, type_t, scope_info);

// Generates the assembly for the program
// For now, there is no optimisation step
bool generate(const char*, node_stmt*, arena_t*, bool);

#endif
