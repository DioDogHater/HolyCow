#ifndef HCC_HOLY_COW_TYPES_H
#define HCC_HOLY_COW_TYPES_H

#include "../lexer/lexer.h"
#include "../parser/parser.h"

// Types of data
enum data_types{
    DATA_INVALID = 0,
    DATA_INT,       // Integers OR pointers
    DATA_FLOAT,     // Floats are handled differently
    DATA_STRUCT,    // Structs are trickier to handle
    DATA_CLASS,     // Classes are way trickier to handle
};

typedef struct{
    size_t size;        // Size in bytes of a value of said type
    token_t* repr;      // Representation (tokens used to represent the type) (optional)
    short sign;         // Sign of type (difference between int64 and uint64)
    short data;         // Type of data
    int ptr_depth;      // 0 = direct value, 1 = pointer to value, 2 = pointer to pointer to value, etc.
} type_t;
#define INVALID_TYPE (type_t){0, NULL, false, DATA_INVALID, 0}

// Types that can be used temporarily without
// actually being in the source files
#define DUMMY_TYPE(t) {tk_##t, NULL, 0, NULL}
#define GET_DUMMY_TYPE(t) (&dummy_types[(tk_##t - tk_int8)])
extern token_t dummy_types[];

// Print a type with text before and after
void print_type(const char* before, type_t type, const char* after);

// Interpret some tokens as a type
type_t type_from_tk(token_t* tk);

// Get the sign of a type
bool signof_type(token_t* tk);

// Get the size of a type
size_t sizeof_type(token_t* tk);

// Interpret the type of an expression
type_t typeof_expr(node_expr* expr);

#endif
