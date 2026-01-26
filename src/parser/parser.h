#ifndef PARSER_H
#define PARSER_H

#include "../dev/libs.h"
#include "../dev/types.h"
#include "../dev/utils.h"

#include "../lexer/lexer.h"


// ==== Expressions ====
#define NODE_EXPR_BASE struct{ tk_type type; union node_expr* next; }
union node_expr;

// A built-in type such as
// int8, int16, int32, int64
// uint8, uint16, uint32, uint64
// bool, flag, string
// tk_int8 is its type
typedef struct{
    NODE_EXPR_BASE;
    token_t* start;
} node_type;

// A single expression term
// Either:
// tk_char_lit,
// tk_int_lit,
// tk_str_lit,
// tk_float_lit,
// tk_bool_lit,
// tk_identifer (variable / constant expression)
typedef struct{
    NODE_EXPR_BASE;
    const char* str;
    size_t strlen;
} node_term;

// Unary operation expression
// (Unary expression)
// tk_neg
// tk_open_parent
// tk_inc
// tk_dec
// tk_bin_flip
typedef struct{
    NODE_EXPR_BASE;
    union node_expr* lhs;
} node_unary_op;

// tk_type_cast
typedef struct{
    NODE_EXPR_BASE;
    node_type* lhs;
    union node_expr* rhs;
} node_type_cast;

// Binary operation expression
// (Binary expression)
// Either:
// tk_add
// tk_sub
// tk_mult
// tk_div
// tk_mod
// tk_bin_and
// tk_bin_or
// tk_bin_xor
// tk_shl
// tk_shr
typedef struct{
    NODE_EXPR_BASE;
    union node_expr* lhs;
    union node_expr* rhs;
} node_bin_op;

// Nothing (used for default args)
typedef struct{
    NODE_EXPR_BASE;
} node_nothing_expr;

// Function call
typedef struct{
    NODE_EXPR_BASE;
    token_t* identifier;
    union node_expr* args;
} node_func_expr;

// Stack alloc
typedef struct{
    NODE_EXPR_BASE;
    token_t* elem_type;
    node_term* elem_count;
} node_stack_alloc;

// tk_reg_expr
typedef struct{
    NODE_EXPR_BASE;
    void* reg;
} node_reg_expr;

// Expression node
typedef union node_expr{
    NODE_EXPR_BASE;
    node_type type_expr;
    node_term term;
    node_unary_op unary_op;
    node_type_cast type_cast;
    node_bin_op bin_op;
    node_nothing_expr none;
    node_func_expr func;
    node_stack_alloc salloc;
    node_reg_expr reg;
} node_expr;

// ===== Statements =====
#define NODE_STMT_BASE struct{ tk_type type; union node_stmt* next; }
union node_stmt;

// tk_func_decl
typedef struct{
    NODE_STMT_BASE;
    token_t* func_type;
    token_t* identifier;
    union node_stmt* args;
    union node_stmt* stmts;
} node_func_decl;

// tk_var_decl
typedef struct{
    NODE_STMT_BASE;
    token_t* var_type;
    token_t* identifier;
    node_expr* expr;
} node_var_decl;

// tk_arr_decl
typedef struct{
    NODE_STMT_BASE;
    token_t* elem_type;
    token_t* identifier;
    node_term* elem_count;
} node_arr_decl;

// tk_var_assign
typedef struct{
    NODE_STMT_BASE;
    node_expr* var;
    node_expr* expr;
} node_var_assign;

// tk_if
// tk_else_if
// tk_while
// tk_repeat (is similar in structure)
typedef struct{
    NODE_STMT_BASE;
    node_expr* cond;
    union node_stmt* stmts;
} node_if;

// tk_else
// tk_scope
// tk_open_braces
typedef struct{
    NODE_STMT_BASE;
    union node_stmt* stmts;
} node_scope;

// tk_for
// for(init; cond; step){ ... }
typedef struct{
    NODE_STMT_BASE;
    node_var_decl* init;
    node_expr* cond;
    union node_stmt* step;
    union node_stmt* stmts;
} node_for;

// tk_expr_stmt
typedef struct{
    NODE_STMT_BASE;
    node_expr* expr;
} node_expr_stmt;

// tk_return
typedef struct{
    NODE_STMT_BASE;
    node_expr* expr;
} node_return;

// tk_continue
// tk_break
// tk_next
// tk_end
typedef struct{
    NODE_STMT_BASE;
    token_t* token;
} node_control;

// tk_asm
typedef struct{
    NODE_STMT_BASE;
    node_term* used_regs;
    node_term* code;
    node_expr* args;
} node_asm;

// Statement node
typedef union node_stmt{
    NODE_STMT_BASE;
    node_func_decl func_decl;
    node_var_decl var_decl;
    node_arr_decl arr_decl;
    node_var_assign var_assign;
    node_if if_stmt;
    node_if while_stmt;
    node_if repeat_stmt;
    node_scope scope;
    node_for for_stmt;
    node_expr_stmt expr;
    node_return ret;
    node_asm asm_stmt;
    node_control control;
} node_stmt;

// Prints the context of an expression (same as print_context but with node_expr's)
bool print_context_expr(const char*, node_expr*);

// Prints the context of a statement
//bool print_context_stmt(const char*, node_stmt*);

// Returns the precedence value of an operator
int get_operator_precedence(tk_type);

// Parse a term of an expression
node_expr* parse_term(token_t**, arena_t*);

// Parse an entire expression
node_expr* parse_expr(token_t**, int, arena_t*);

// Parse a statement
node_stmt* parse_stmt(token_t**, arena_t*, bool);

// Parse a scope
node_stmt* parse_scope(token_t**, arena_t*);

// Parse the entire program
node_stmt* parse(token_t*, arena_t*);

#endif
