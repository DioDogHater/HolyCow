#ifndef HCC_LEXER_H
#define HCC_LEXER_H

#include "../dev/libs.h"
#include "../dev/types.h"
#include "../dev/utils.h"
#include "../dev/style.h"

enum{
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
    tk_float,
    tk_string,
    tk_bool,
    tk_flag,
    tk_void,
    tk_const,
    tk_constexpr,

    // Values
    tk_int_lit,     // Integer literal
    tk_char_lit,    // Character literal
    tk_float_lit,   // Floating point literal
    tk_str_lit,     // String literal
    tk_bool_lit,    // Boolean literal
    tk_nothing,     // nothing

    // Arithmetic operations
    tk_neg,         // Negation (-)
//  tk_open_parent  // Parentheses ( )
    tk_add,         // Addition
    tk_add_assign,  // Addition assignment (+=)
    tk_inc,         // Increment (++)
    tk_sub,         // Subtraction
    tk_sub_assign,  // Subtraction assignment (-=)
    tk_dec,         // Decrement (--)
    tk_mult,        // Multiplication
    tk_mult_assign, // Multplication assignment (*=)
    tk_div,         // Division
    tk_div_assign,  // Division assignment (/=)
    tk_mod,         // Modulo
    tk_mod_assign,  // Modulo assignment (%=)
    tk_bin_and,     // AND (&)
    tk_bin_or,      // OR (|)
    tk_bin_xor,     // XOR (^)
    tk_bin_flip,    // Flip integer bits (~)
    tk_shl,         // Shift left
    tk_shr,         // Shift right

    // Boolean operations / comparisons
    tk_cmp_eq,      // ==
    tk_cmp_neq,     // !=
    tk_cmp_l,       // <
    tk_cmp_b,       // < (unsigned)
    tk_cmp_g,       // >
    tk_cmp_a,       // > (unsigned)
    tk_cmp_le,      // <=
    tk_cmp_be,      // <= (unsigned)
    tk_cmp_ge,      // >=
    tk_cmp_ae,      // >= (unsigned)
    tk_cmp_approx,  // ~=
    tk_and,         // && or "and"
    tk_or,          // || or "or"
    tk_not,         // ! or "not"

    // Keywords
    tk_if,
    tk_else_if,
    tk_else,
    tk_while,
    tk_for,
    tk_repeat,
    tk_switch,
    tk_next,           // @next
    tk_return,
    tk_break,
    tk_continue,
    tk_asm,            // @asm("...")
    tk_last_val,       // @last
    tk_sizeof,         // sizeof(...)
    tk_typeof,         // typeof(...)

    // Preprocessor directives
    //tk_include,        // #include
    //tk_define,         // #define
    //tk_macro,          // #macro
    //tk_ifdef,          // #ifdef
    //tk_ifndef,         // #ifndef
    //tk_endif,          // #endif

    // Symbols
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
    tk_dot,            // .
    tk_comma,          // ,

    // Parser values
    tk_var_decl,    // Variable declaration
    tk_deref,       // Dereferencing (*)
    tk_getaddr,     // Get address (&)
    tk_type_cast,   // Type cast e.g. (type)
    tk_expr_stmt,   // An expression statement
    tk_func_call,   // A function call
    tk_post_inc,    // Post increment
    tk_post_dec,    // Post decrement

    // Invalid
    tk_invalid
};
typedef size_t tk_type;

typedef struct token_t {
    tk_type type;
    const char* str;
    size_t strlen;
    struct token_t* next;
} token_t;

// Keywords
struct keyword_pair {
    const char* str;
    size_t strlen;
    tk_type value;
};
extern hashtable_t keyword_table;
bool keyword_table_setup();
void keyword_table_destroy();

// Utilities for parsing and generation

// Print the context of a token
void print_context_ex(const char*, const char*, size_t);
void print_context(const char*, token_t*);

// Print the token itself (for debugging)
void print_token(token_t*);

// Check and return for next token
token_t* peek_token(token_t**);

// Check if next token is a certain type
bool peek_tk_type(token_t**, tk_type);

// Consume a token (go to the next token)
token_t* consume_token(token_t**);

// Consume a token only if its type is the one we want
bool consume_tk_type(token_t**, tk_type);

// Tokenize a file's contents
token_t* tokenize(file_t*, arena_t*, token_t*);

#endif
