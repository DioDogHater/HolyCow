#ifndef HCC_GENERATOR_H
#define HCC_GENERATOR_H

#include "../dev/libs.h"
#include "../dev/types.h"
#include "../dev/utils.h"

#include "../lexer/lexer.h"
#include "../parser/parser.h"

#include "target_requirements.h"

// Stack size and pointer
extern size_t stack_ptr;
extern size_t stack_sz;

// Number of labels created in current func
extern size_t label_count;

// A linked list of all string literals
extern node_term* str_literals;
extern size_t str_literal_count;

enum data_types{
    DATA_INT,       // Integers OR pointers (they're still ints under the hood)
    DATA_FLOAT,     // Floats are handled differently
    DATA_STRUCT,    // Structs are trickier to handle
    DATA_CLASS      // Classes are way trickier to handle
};

typedef struct{
    size_t size;        // Size in bytes of a value of said type
    token_t* repr;      // Representation (tokens used to represent the type) (optional)
    short sign;         // Sign of type (difference between int64 and uint64)
    short data;         // Type of data
    int ptr_depth;      // 0 = direct value, 1 = pointer to value, 2 = pointer to pointer to value, etc.
} type_t;
#define INVALID_TYPE (type_t){0, NULL, false, DATA_INT, 0}

// A structure to represent a variable
enum var_locations {
    VAR_STACK,
    VAR_GLOBAL,
    VAR_ARG,
    VAR_MEMBER
};
typedef struct{
    const char* str;
    size_t strlen;
    int stack_ptr;
    int location;
    type_t type;
} var_t;

// The vector that holds all variables in the current scope
extern vector_t vars[1];

// Find a variable
var_t* get_var(const char*, size_t);

// Generate an expression.
// Returns the register where the value is stored.
// Last arg is the prefered register or NULL if it can be any of them.
reg_t* generate_expr(HC_FILE, node_expr*, type_t, reg_t*);

// Generate a statement
bool generate_stmt(HC_FILE, node_stmt*, type_t);

// Generates the assembly for the program
// For now, there is no optimisation step
bool generate(const char*, node_stmt*);

#endif
