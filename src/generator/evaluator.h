#ifndef HCC_EVALUATOR_H
#define HCC_EVALUATOR_H

#include "../dev/libs.h"
#include "../dev/types.h"

#include "../lexer/lexer.h"
#include "../parser/parser.h"
#include "hc_types.h"
#include "target_requirements.h"

// Evaluate literals
uint64_t eval_char_lit(node_term* lit);
uint64_t eval_int_lit(node_term* lit);
double eval_float_lit(node_term* lit);

// Returns true if expression has been evaluated,
// false if expression cannot be entirely evaluated at compile-time
// Last argument is pointer to result (will set result if evaluated)
bool eval_int_expr(node_expr* expr, int64_t* result);
bool eval_uint_expr(node_expr* expr, uint64_t* result);
bool eval_float_expr(node_expr* expr, double* result);

#endif
