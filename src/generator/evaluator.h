#ifndef HCC_EVALUATOR_H
#define HCC_EVALUATOR_H

#include "../dev/libs.h"
#include "../dev/types.h"

#include "../lexer/lexer.h"
#include "../parser/parser.h"
#include "hc_types.h"
#include "target_requirements.h"

uint64_t eval_char_lit(node_term*);
uint64_t eval_int_lit(node_term*);
double eval_float_lit(node_term*);

// Returns true if expression has been evaluated,
// false if expression cannot be entirely evaluated at compile-time
// Last argument is pointer to result (will set result if evaluated)
bool eval_int_expr(node_expr*, int64_t*);
bool eval_uint_expr(node_expr*, uint64_t*);
bool eval_float_expr(node_expr*, double*);

#endif
