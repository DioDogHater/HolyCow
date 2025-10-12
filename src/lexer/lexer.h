#ifndef HCC_LEXER_H
#define HCC_LEXER_H

#include "../dev/libs.h"
#include "../dev/types.h"

typedef enum{
    tk_identifier,

    // Types
    tk_int8,
    tk_uint8,
    tk_int16,
    tk_uint16,
    tk_int32,
    tk_uint32,
    tk_int64,
    tk_uint64,
    tk_string,
    tk_bool,
    tk_flag,
    tk_const,
    tk_constexpr,

    // Values
    tk_int_lit,     // Integer literal
    tk_str_lit,     // String literal
    tk_bool_lit,    // Boolean literal

    // Arithmetic operations
    // Used in parsing
    tk_unary_op,    // Unary operation
    tk_binary_op,   // Binary operation
    tk_neg,         // Negation (-)
//  tk_open_parent  // Parentheses ( )
    tk_add,         // Addition
    tk_add_assign,  // Addition assignment (+=)
    tk_sub,         // Subtraction
    tk_sub_assign,  // Subtraction assignment (-=)
    tk_mult,        // Multiplication
    tk_mult_assign, // Multplication assignment (*=)
    tk_div,         // Division
    tk_div_assign,  // Division assignment (/=)
    tk_mod,         // Modulo
    tk_bin_and,     // AND (&)
    tk_bin_or,      // OR (|)
    tk_bin_xor,     // XOR (^)
    tk_bin_flip,    // Flip integer bits (~)
    tk_shl,         // Shift left
    tk_shr,         // Shift right

    // Boolean operations
    tk_cmp_eq,      // ==
    tk_cmp_neq,     // !=
    tk_cmp_l,       // <
    tk_cmp_g,       // >
    tk_cmp_le,      // <=
    tk_cmp_ge,      // >=
    tk_cmp_approx,  // ~=, or ~n= where n is the accepted range
    tk_and,         // && or "and"
    tk_or,          // || or "or"
    tk_not,         // ! or "not"
    tk_xor,         // ^^ or "xor"

    // Keywords
    tk_if,
    tk_else_if,
    tk_else,
    tk_while,
    tk_for,
    tk_repeat,
    tk_switch,
    tk_next,           // @next
    tk_break,
    tk_continue,
    tk_last_val,       // @last

    // Symbols
    tk_forward_slash,  // '\'
    tk_exponent,       // ^
    tk_assign,         // =
    tk_exclam,         // !
    tk_open_parent,    // (
    tk_close_parent,   // )
    tk_open_bracket,   // [
    tk_close_bracket,  // ]
    tk_open_braces,    // {
    tk_close_braces,   // }
    tk_semicolon,      // ;
    tk_colon,          // :
    tk_dot             // .
} tk_type;

typedef struct token_t {
    tk_type type;
    const char* str;
    size_t strlen;
    struct token_t* next;
} token_t;

struct keyword_pair {
    const char* str;
    size_t strlen;
    tk_type value;
};
extern hashtable_t keyword_table;
bool keyword_table_setup();

token_t* append_token(token_t*, token_t);
void free_tokens(token_t*);

void peek_token(token_t*);
void consume_token(token_t*);

token_t* tokenize(const char*,arena_t*);

#endif
