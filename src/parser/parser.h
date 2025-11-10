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
//! const and constexpr will get ignored !
typedef struct{
    NODE_EXPR_BASE;
} node_builtin_type;

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
// tk_type_cast
// tk_inc
// tk_dec
// tk_bin_flip
typedef struct{
    NODE_EXPR_BASE;
    union node_expr* lhs;
} node_unary_op;

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

// Expression node
typedef union node_expr{
    NODE_EXPR_BASE;
    node_builtin_type builtin_type;
    node_term term;
    node_unary_op unary_op;
    node_bin_op bin_op;
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

// Returns the precedence value of an operator
int get_operator_precedence(tk_type);

node_expr* parse_term(token_t**, arena_t*);
node_expr* parse_expr(token_t**, int, arena_t*);

node_stmt* parse_stmt(token_t**, arena_t*);
node_stmt* parse(token_t*, arena_t*);

#endif
