#ifndef PARSER_H
#define PARSER_H

#include "../dev/libs.h"
#include "../dev/types.h"
#include "../dev/utils.h"

#include "../lexer/lexer.h"


// ==== Expressions ====
#define NODE_EXPR_BASE struct{ tk_type type; union node_expr* next; }
union node_expr;

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
} node_unary_expr;

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
} node_bin_expr;

// Expression node
typedef union node_expr{
    NODE_EXPR_BASE;
    node_term term;
    node_unary_expr unary_op;
    node_bin_expr bin_op;
} node_expr;

// ===== Statements =====
#define NODE_STMT_BASE struct{ tk_type type; union node_stmt* next; }
union node_stmt;

// tk_var_decl
typedef struct{
    NODE_STMT_BASE;
    token_t* var_type;
    token_t* identifier;
    union node_expr* expr;
} node_var_decl;

// tk_var_assign
typedef struct{
    NODE_STMT_BASE;
    token_t* identifier;
    union node_expr* expr;
} node_var_assign;

// Statement node
typedef union node_stmt{
    NODE_STMT_BASE;
    node_var_decl var_decl;
    node_var_assign var_assign;
} node_stmt;

node_expr* parse_term(token_t*);
node_expr* parse_expr(token_t*);

node_stmt* parse_stmt(token_t*);
node_stmt* parse(token_t*);

#endif
