#ifndef HCC_GENERATOR_H
#define HCC_GENERATOR_H

#include "../compiler.h"

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

#include "user_defined.h"

// Scopes
// A snapshot of the moment before the scope starts
typedef struct{
    size_t stack_sz, stack_ptr;
    size_t var_sz, size;
} scope_t;

// Get the size of a scope (the size of all variables inside)
size_t get_scope_size(node_stmt* scope);

// Initialise the scope and save the state before it starts
scope_t gen_init_scope(HC_FILE, node_stmt* scope);

// Quit the scope and return to the state before it started
void gen_quit_scope(HC_FILE, scope_t scope);


// GENERATION
bool save_struct(HC_FILE, struct_t* stru, reg_t* dest, node_expr* src);
bool save_union(HC_FILE, union_t* unio, reg_t* dest, node_expr* src);
bool save_expr(HC_FILE, node_expr* dest, node_expr* src);
bool inc_expr(HC_FILE, node_expr* expr, reg_t* dest, bool before, bool inc);
bool get_expr_address(HC_FILE, reg_t* dest, node_expr* expr);
size_t generate_func_call(HC_FILE, node_expr* expr, func_t** func, reg_t* struct_ptr);

// Provided by target (C calling convention of the target architecture)
extern size_t generate_cfunc_call(HC_FILE, node_expr* expr, func_t* func, reg_t* struct_ptr);

// Generate a function
bool generate_func(HC_FILE, func_t* func, node_stmt* func_stmts, token_t* parent, token_t* _this);

// Generate an integer expression.
// Returns the register where the value is stored.
// Last arg is the prefered register or NULL if it can be any of them.
void fail_gen_expr(HC_FILE);
#define EXPR_ONCE(expr, type, reg) free_reg(generate_expr(fptr, (expr), (type), (reg)))
reg_t* generate_expr(HC_FILE, node_expr* expr, type_t target_type, reg_t* prefered_reg);

// Generates a float expression
// Returns true if successful, otherwise false
bool generate_float_expr(HC_FILE, node_expr* expr);

// Necessary information over the current scope
typedef struct{
    size_t continue_label;
    size_t break_label;
    size_t end_label;
    size_t next_label;
    size_t stack_sz;
} scope_info;

// Generate a statement
bool generate_stmt(HC_FILE, node_stmt*, type_t, scope_info);

// Generates the assembly for the program
// For now, there is no optimisation step
bool generate(const char*, node_stmt*, bool);

#endif
