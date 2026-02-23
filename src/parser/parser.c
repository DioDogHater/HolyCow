#include "parser.h"

bool print_context_expr(const char* msg, node_expr* expr){
    switch(expr->type){
    case tk_add:
    case tk_sub:
    case tk_mult:
    case tk_div:
    case tk_mod:
    case tk_and:
    case tk_or:
    case tk_bin_and:
    case tk_bin_or:
    case tk_bin_xor:
    case tk_shl:
    case tk_shr:
    case tk_cmp_eq:
    case tk_cmp_neq:
    case tk_cmp_g:
    case tk_cmp_ge:
    case tk_cmp_l:
    case tk_cmp_le:
    case tk_cmp_approx:
    case tk_open_bracket:
        // Boolean operations
        if(print_context_expr(msg, expr->bin_op.lhs))
            return true;
        return print_context_expr(msg, expr->bin_op.rhs);
    case tk_neg:
    case tk_not:
    case tk_bin_flip:
    case tk_inc:
    case tk_dec:
    case tk_post_inc:
    case tk_post_dec:
    case tk_sizeof:
    case tk_deref:
    case tk_getaddr:
        // Unary operations
        return print_context_expr(msg, expr->unary_op.lhs);
    case tk_int8:
        // Type
        print_context(msg, expr->type_expr.start);
        return true;
    case tk_type_cast:
        // Type cast
        return print_context_expr(msg, (node_expr*) expr->type_cast.lhs);
    case tk_func_call:
        // Function call
        print_context(msg, expr->func.identifier);
        return true;
    case tk_str_lit:
    case tk_bool_lit:
    case tk_char_lit:
    case tk_int_lit:
    case tk_float_lit:
    case tk_identifier:
        // Term expression
        print_context_ex(msg, expr->term.str, expr->term.strlen);
        return true;
    default:
        HC_ERR("%s : Expression type %lu not implemented in print_context_expr", msg, expr->type);
        return false;
    }
}

// Operator precedences
// Very long but useful
int get_operator_precedence(tk_type type){
    switch(type){
    case tk_or:
        return 1;
    case tk_and:
        return 2;
    case tk_bin_or:
        return 3;
    case tk_bin_xor:
        return 4;
    case tk_bin_and:
        return 5;
    case tk_cmp_eq:
    case tk_cmp_neq:
    case tk_cmp_approx:
        return 6;
    case tk_cmp_ge:
    case tk_cmp_g:
    case tk_cmp_le:
    case tk_cmp_l:
        return 7;
    case tk_shl:
    case tk_shr:
        return 8;
    case tk_add:
    case tk_sub:
        return 9;
    case tk_mult:
    case tk_div:
    case tk_mod:
        return 10;
    case tk_deref:
    case tk_getaddr:
    case tk_type_cast:
    case tk_neg:
    case tk_not:
    case tk_bin_flip:
    case tk_sizeof:
        return 11;
    case tk_dot:
    case tk_open_bracket:
    case tk_inc:
    case tk_dec:
        return 12;
    }
    return -1;
}

node_expr* parse_term(token_t** tokens, arena_t* arena){
    node_expr* expr = NULL;
    token_t* token = consume_token(tokens);
    if(!token)
        return NULL;

    // If it's a built-in type
    if((token->type >= tk_int8 && token->type <= tk_const)){
        if(token->type == tk_const && peek_token(tokens) &&
           ((peek_token(tokens)->type >= tk_int8 && peek_token(tokens)->type < tk_const) || peek_token(tokens)->type == tk_identifier)){
            token = consume_token(tokens);
        }else if(token->type == tk_const){
            print_context("Type expected after const", token);
            return NULL;
        }
        // Consume * after type for pointer
        while(consume_tk_type(tokens, tk_mult));
        expr = (node_expr*) ARENA_ALLOC(arena, node_type);
        expr->type_expr = (node_type) {tk_int8, NULL, token};
        return expr;
    }

    // If it's a structure / class / union type
    if(token->type == tk_identifier && peek_tk_type(tokens, tk_mult)){
        token_t* tk = token->next;
        for(; tk && tk->type == tk_mult; tk = tk->next);
        if(tk && tk->type == tk_close_parent){
            print_context("User defined type", token);
            expr = (node_expr*) ARENA_ALLOC(arena, node_type);
            expr->type_expr = (node_type){tk_int8, NULL, token};
            while(peek_token(tokens) != tk)
                (void) consume_token(tokens);
            return expr;
        }
    }

    switch(token->type){
    case tk_str_lit:
    case tk_bool_lit:
    case tk_char_lit:
    case tk_int_lit:
    case tk_float_lit:
        expr = (node_expr*) ARENA_ALLOC(arena, node_term);
        expr->term = (node_term) {token->type, NULL, token->str, token->strlen};
        break;
    case tk_identifier:
        // For a function call
        // TODO Change this to be an operator instead
        if(peek_tk_type(tokens, tk_open_parent)){
            (void) consume_token(tokens);
            node_expr *args = NULL, *head = NULL;

            if(!peek_tk_type(tokens, tk_close_parent)){
                if(peek_tk_type(tokens, tk_comma)){
                    args = head = (node_expr*) ARENA_ALLOC(arena, node_nothing_expr);
                    args->none = (node_nothing_expr){tk_nothing, NULL};
                }else{
                    args = head = parse_expr(tokens, 1, arena);
                    if(!args){
                        print_context("Expected expression", *tokens);
                        return NULL;
                    }
                }
            }

            // Parse arguments
            if(args) while(consume_tk_type(tokens, tk_comma)){
                node_expr* new_head = NULL;
                if(peek_tk_type(tokens, tk_comma)){
                    new_head = (node_expr*) ARENA_ALLOC(arena, node_nothing_expr);
                    new_head->none = (node_nothing_expr){tk_nothing, NULL};
                }else if(!(new_head = parse_expr(tokens, 1, arena))){
                    print_context("Expected expression", *tokens);
                    return NULL;
                }
                head->next = new_head;
                head = new_head;
            }

            if(!consume_tk_type(tokens, tk_close_parent)){
                print_context("Expected closing ')'", *tokens);
                return NULL;
            }

            expr = (node_expr*) ARENA_ALLOC(arena, node_func_expr);
            expr->func = (node_func_expr) {tk_func_call, NULL, token, args};
        }
        // For a simple identifier (variable)
        else{
            expr = (node_expr*) ARENA_ALLOC(arena, node_term);
            expr->term = (node_term) {tk_identifier, NULL, token->str, token->strlen};
        }
        break;
    case tk_not:
    case tk_bin_flip:
    case tk_inc:
    case tk_dec:
        // Unary operations
        expr = (node_expr*) ARENA_ALLOC(arena, node_unary_op);
        expr->unary_op = (node_unary_op) {token->type, NULL, parse_expr(tokens, get_operator_precedence(token->type), arena)};
        if(!expr->unary_op.lhs){
            print_context("Missing expression", token);
            return NULL;
        }
        break;
    case tk_sub:
        // Negation
        expr = (node_expr*) ARENA_ALLOC(arena, node_unary_op);
        expr->unary_op = (node_unary_op) {tk_neg, NULL, parse_expr(tokens, get_operator_precedence(tk_neg), arena)};
        break;
    case tk_mult:
    case tk_bin_and:
        // Dereferencing and getting a reference (address)
        expr = (node_expr*) ARENA_ALLOC(arena, node_unary_op);
        expr->unary_op = (node_unary_op) {(token->type == tk_mult) ? tk_deref : tk_getaddr, NULL,
            parse_expr(tokens, get_operator_precedence((token->type == tk_mult) ? tk_deref : tk_getaddr), arena)};
        if(!expr->unary_op.lhs){
            print_context("Missing expression", token);
            return NULL;
        }
        break;
    case tk_typeof:
    case tk_sizeof:
        // sizeof()
        if(!consume_tk_type(tokens, tk_open_parent)){
            print_context("Expected '('", token);
            return NULL;
        }
        expr = (node_expr*) ARENA_ALLOC(arena, node_unary_op);
        expr->unary_op = (node_unary_op){token->type, NULL, parse_expr(tokens, 0, arena)};
        if(!expr->unary_op.lhs){
            print_context("Expected expression to get size of", token);
            return NULL;
        }
        if(!consume_tk_type(tokens, tk_close_parent)){
            print_context("Expected ')'", *tokens);
            return NULL;
        }
        break;
    case tk_stack_alloc:
        // stack_alloc()
        if(!consume_tk_type(tokens, tk_open_parent)){
            print_context("Expected '('", token);
            return NULL;
        }
        node_expr* elem_type = parse_term(tokens, arena);
        if(!elem_type || elem_type->type != tk_int8){
            print_context("Expected type of elements allocated", token);
            return NULL;
        }
        (void) consume_tk_type(tokens, tk_comma);
        node_expr* elem_count = parse_term(tokens, arena);
        if(!elem_count || elem_count->type != tk_int_lit){
            print_context("Expected number of elements to allocate", token);
            return NULL;
        }
        if(!consume_tk_type(tokens, tk_close_parent)){
            print_context("Expected ')'", *tokens);
            return NULL;
        }
        expr = (node_expr*) ARENA_ALLOC(arena, node_stack_alloc);
        expr->salloc = (node_stack_alloc){tk_stack_alloc, NULL, elem_type->type_expr.start, &elem_count->term};
        break;
    case tk_open_parent:
        // Parentheses
        expr = parse_expr(tokens, 0, arena);
        if(!consume_tk_type(tokens, tk_close_parent)){
            print_context("Expected closing ')'", token);
            return NULL;
        }
        // Type cast
        if(expr->type == tk_int8){
            node_type* lhs = &expr->type_expr;
            expr = (node_expr*) ARENA_ALLOC(arena, node_type_cast);
            expr->type_cast = (node_type_cast){tk_type_cast, NULL, lhs, parse_expr(tokens, get_operator_precedence(tk_type_cast), arena)};
            if(!expr->type_cast.rhs){
                print_context("Expected valid right hand side of type cast", lhs->start);
                return NULL;
            }
        }
        break;
    }
    return expr;
}

node_expr* parse_expr(token_t** tokens, int min_precedence, arena_t* arena){
    node_expr* lhs = parse_term(tokens, arena);
    if(lhs){
        while(peek_token(tokens)){
            token_t* operator = peek_token(tokens);

            // Ensure precedence order
            // If it's not an operator, its precedence is -1
            int op_precedence = get_operator_precedence(operator->type);
            if(op_precedence < min_precedence)
                break;

            (void) consume_token(tokens);

            // Set the lhs as expr
            node_expr* expr = NULL;
            if(operator->type == tk_inc || operator->type == tk_dec){
                expr = (node_expr*) ARENA_ALLOC(arena, node_unary_op);
                expr->unary_op = (node_unary_op){(operator->type == tk_inc) ? tk_post_inc : tk_post_dec, NULL, lhs};
            }else if(operator->type == tk_open_bracket){
                expr = (node_expr*) ARENA_ALLOC(arena, node_bin_op);
                expr->bin_op = (node_bin_op){tk_open_bracket, NULL, lhs, NULL};
                expr->bin_op.rhs = parse_expr(tokens, 0, arena);
                if(!expr->bin_op.rhs){
                    print_context("Missing index", operator);
                    return NULL;
                }
                if(!consume_tk_type(tokens, tk_close_bracket)){
                    print_context("Expected ']'", operator);
                    return NULL;
                }
            }else{
                expr = (node_expr*) ARENA_ALLOC(arena, node_bin_op);
                expr->bin_op = (node_bin_op) {operator->type, NULL, lhs, NULL};
                expr->bin_op.rhs = parse_expr(tokens, op_precedence + 1, arena);
                if(!expr->bin_op.rhs)
                    return NULL;
            }

            lhs = expr;
        }
        return lhs;
    }else
        return NULL;
}

node_stmt* parse_stmt(token_t** tokens, arena_t* arena, bool sc_necessary){
    node_stmt* stmt = NULL;
    token_t* token = peek_token(tokens);
    if(!token)
        return NULL;

    // Variable / array / function declaration
    // Starts with a type and an identifier must follow
    if((token->type >= tk_int8 && token->type <= tk_constexpr) ||
       (token->type == tk_identifier && (peek_tk_type(&token, tk_identifier) || peek_tk_type(&token, tk_mult)))){
        (void) consume_token(tokens); // Consume the first token
        // If it's a composed type, we need to consume the type after
        if((token->type == tk_const /*|| token->type == tk_constexpr*/) && peek_token(tokens) &&
            (peek_token(tokens)->type == tk_identifier || (peek_token(tokens)->type >= tk_int8 && peek_token(tokens)->type < tk_const)))
                (void) consume_token(tokens);
        else if(token->type == tk_const /*|| token->type == tk_constexpr*/){
            print_context("Expected type after const / constexpr", token);
            return NULL;
        }

        // If it's a pointer, we need to consume the *
        while(consume_tk_type(tokens, tk_mult));

        // We get the identifier (the name of the variable)
        token_t* identifier = consume_token(tokens);
        if(!identifier || identifier->type != tk_identifier){
            print_context("Expected identifier after type!", *tokens);
            return NULL;
        }

        // If it's a function declaration
        if(consume_tk_type(tokens, tk_open_parent)){
            node_stmt *args_root = NULL, *head = NULL;
            while(!peek_tk_type(tokens, tk_close_parent)){
                node_stmt* new_head = NULL;
                if(consume_tk_type(tokens, tk_var_args)){
                    new_head = (node_stmt*) ARENA_ALLOC(arena, node_expr_stmt);
                    new_head->expr = (node_expr_stmt){tk_var_args, NULL, NULL};
                    if(peek_tk_type(tokens, tk_identifier)){
                        new_head->expr.expr = (node_expr*) ARENA_ALLOC(arena, node_term);
                        token_t* vargc = consume_token(tokens);
                        new_head->expr.expr->term = (node_term){tk_identifier, NULL, vargc->str, vargc->strlen};
                    }
                }else{
                    new_head = parse_stmt(tokens, arena, false);
                    if(!new_head || new_head->type != tk_var_decl){
                        print_context("Expected valid argument", *tokens);
                        return NULL;
                    }
                }
                if(!args_root) args_root = new_head;
                else head->next = new_head;
                head = new_head;
                if(new_head->type == tk_var_args || !consume_tk_type(tokens, tk_comma)) break;
            }
            if(!consume_tk_type(tokens, tk_close_parent)){
                print_context("Expected ')'", *tokens);
                return NULL;
            }
            node_stmt* stmts = NULL;
            if(consume_tk_type(tokens, tk_semicolon));
            else{
                stmts = parse_scope(tokens, arena);
                if(!stmts)
                    return NULL;
            }
            stmt = (node_stmt*) ARENA_ALLOC(arena, node_func_decl);
            stmt->func_decl = (node_func_decl){tk_func_decl, NULL, token, identifier, args_root, stmts};
            return stmt;
        }

        // Array declaration
        if(consume_tk_type(tokens, tk_open_bracket)){
            node_expr* elem_count = parse_expr(tokens, 0, arena);
            if(!elem_count || elem_count->type != tk_int_lit){
                if(elem_count) print_context_expr("Expected integer constant", elem_count);
                else print_context("Expected size of array (you have to specify it manually)", *tokens);
                return NULL;
            }
            if(!consume_tk_type(tokens, tk_close_bracket)){
                print_context("Expected ']'", *tokens);
                return NULL;
            }

            stmt = (node_stmt*) ARENA_ALLOC(arena, node_arr_decl);
            stmt->arr_decl = (node_arr_decl){tk_arr_decl, NULL, token, identifier, &elem_count->term};
        }else{
            // Variable declaration
            node_expr* expr = NULL;
            if(consume_tk_type(tokens, tk_assign)){
                expr = parse_expr(tokens, 1, arena);
                if(!expr){
                    print_context("Missing expression", identifier->next);
                    return NULL;
                }
            }

            stmt = (node_stmt*) ARENA_ALLOC(arena, node_var_decl);
            stmt->var_decl = (node_var_decl) {tk_var_decl, NULL, token, identifier, expr};
        }
    }// Structs / unions
    else if(token->type == tk_struct || token->type == tk_union){
        (void) consume_token(tokens);
        stmt = (node_stmt*) ARENA_ALLOC(arena, node_struct_decl);
        stmt->struct_decl = (node_struct_decl){token->type, NULL, peek_token(tokens), NULL};
        if(!consume_tk_type(tokens, tk_identifier)){
            print_context("Expected identifier to name structure", *tokens);
            return NULL;
        }
        if(consume_tk_type(tokens, tk_semicolon))
            return stmt;
        stmt->struct_decl.members = parse_scope(tokens, arena);
        if(!stmt->struct_decl.members || stmt->struct_decl.members == (node_stmt*)(~0)){
            print_context("Expected braces containing valid members.", stmt->struct_decl.identifier);
            return NULL;
        }
        return stmt;
    }// if / else if / while / repeat statements (they're all really similar)
    else if(token->type == tk_if || token->type == tk_while || token->type == tk_repeat ||
            token->type == tk_else_if || (token->type == tk_else && token->next && token->next->type == tk_if)){
        (void) consume_tk_type(tokens, tk_else);
        (void) consume_token(tokens);
        if(!consume_tk_type(tokens, tk_open_parent)){
            print_context("Expected '('", *tokens);
            return NULL;
        }
        stmt = (node_stmt*) ARENA_ALLOC(arena, node_if);
        stmt->if_stmt = (node_if) {(token->type != tk_else) ? token->type : tk_else_if, NULL, parse_expr(tokens, 0, arena), NULL};
        if(!stmt->if_stmt.cond){
            if(token->type == tk_repeat) print_context("Expected number of repetitions", token);
            else print_context("Expected condition", token);
            return NULL;
        }
        if(!consume_tk_type(tokens, tk_close_parent)){
            print_context("Expected closing ')'", *tokens);
            return NULL;
        }
        if(consume_tk_type(tokens, tk_semicolon));
        else{
            stmt->if_stmt.stmts = parse_scope(tokens, arena);
            if(!stmt->if_stmt.stmts)
                return NULL;
            if(stmt->if_stmt.stmts == (node_stmt*)(~0))
                stmt->if_stmt.stmts = NULL;
        }
        return stmt;
    }// else / scope statements
    else if(token->type == tk_else || token->type == tk_loop || token->type == tk_open_braces){
        if(token->type == tk_else || token->type == tk_loop)
            (void) consume_token(tokens);
        stmt = (node_stmt*) ARENA_ALLOC(arena, node_scope);
        stmt->scope = (node_scope){token->type, NULL, parse_scope(tokens, arena)};
        if(!stmt->scope.stmts || stmt->scope.stmts == (node_stmt*)(~0)){
            if(stmt->scope.stmts)
                print_context("Scope is empty (if it's intentional, please omit it)", token);
            return NULL;
        }
        return stmt;
    }// for statement
    else if(token->type == tk_for){
        (void) consume_token(tokens);
        // (
        if(!consume_tk_type(tokens, tk_open_parent)){
            print_context("Expected '('", *tokens);
            return NULL;
        }

        node_stmt *init = NULL, *step = NULL;
        node_expr *cond = NULL;

        // init
        if(!consume_tk_type(tokens, tk_semicolon)){
            init = parse_stmt(tokens, arena, false);
            if(!init || init->type != tk_var_decl){
                print_context("Expected variable declaration first", token);
                return NULL;
            }
            node_stmt* head = init;
            while(consume_tk_type(tokens, tk_comma)){
                node_stmt* new_head = parse_stmt(tokens, arena, false);
                if(!new_head || new_head->type != tk_var_decl){
                    print_context("Expected valid variable declaration", *tokens);
                    return NULL;
                }
                head->next = new_head;
                head = new_head;
            }
            if(!consume_tk_type(tokens, tk_semicolon)){
                print_context("Expected semicolon after initialisation", *tokens);
            }
        }

        // cond
        if(!consume_tk_type(tokens, tk_semicolon)){
            cond = parse_expr(tokens, 0, arena);
            if(!cond){
                print_context("Expected condition in for loop", *tokens);
                return NULL;
            }
            if(!consume_tk_type(tokens, tk_semicolon)){
                print_context("Expected semicolon after condition", *tokens);
                return NULL;
            }
        }

        // step
        if(!peek_tk_type(tokens, tk_close_parent)){
            step = parse_stmt(tokens, arena, false);
            if(!step){
                print_context("Expected step expression", *tokens);
                return NULL;
            }
            node_stmt* head = step;
            while(consume_tk_type(tokens, tk_comma)){
                node_stmt* new_head = parse_stmt(tokens, arena, false);
                if(!new_head){
                    print_context("Expected valid step expression", *tokens);
                    return NULL;
                }
                head->next = new_head;
                head = new_head;
            }
        }

        // )
        if(!consume_tk_type(tokens, tk_close_parent)){
            print_context("Expected ')'", *tokens);
            return NULL;
        }

        stmt = (node_stmt*) ARENA_ALLOC(arena, node_for);
        stmt->for_stmt = (node_for){tk_for, NULL, &init->var_decl, cond, step, NULL};

        if(consume_tk_type(tokens, tk_semicolon));
        else{
            stmt->for_stmt.stmts = parse_scope(tokens, arena);
            if(!stmt->for_stmt.stmts)
                return NULL;
            if(stmt->for_stmt.stmts == (node_stmt*)(~0))
                stmt->for_stmt.stmts = NULL;
        }

        return stmt;
    }// return statement
    else if(token->type == tk_return){
        (void) consume_token(tokens);

        stmt = (node_stmt*) ARENA_ALLOC(arena, node_return);
        stmt->ret = (node_return){tk_return, NULL, NULL};

        if(peek_tk_type(tokens, tk_semicolon));
        else if(!(stmt->ret.expr = parse_expr(tokens, 0, arena))){
            print_context("Expected return value.",token);
            return NULL;
        }
    }// asm statement
    else if(token->type == tk_asm){
        (void) consume_token(tokens);
        if(!consume_tk_type(tokens, tk_open_parent)){
            print_context("Expected '('", token);
            return NULL;
        }

        // Masked regs for usage in this format @asm(0, 1, 2, 3, ..., "code...")
        node_expr *mask_root = NULL, *head = NULL;
        while(!peek_tk_type(tokens, tk_str_lit)){
            node_expr* new_head = parse_term(tokens, arena);
            if(!new_head || new_head->type != tk_identifier){
                print_context("Expected used registers, then assembly code", *tokens);
                return NULL;
            }
            if(!mask_root) mask_root = new_head;
            else head->next = new_head;
            head = new_head;
            if(!consume_tk_type(tokens, tk_comma)) break;
        }

        // Code in a string literal
        node_expr* code = parse_term(tokens, arena);
        if(!code || code->type != tk_str_lit){
            print_context("Expected assembly code as string literal", *tokens);
            return NULL;
        }

        // Variable arguments (to use in the assembly code as variables %0 to %9)
        node_expr* vargs_root = NULL; head = NULL;
        if(consume_tk_type(tokens, tk_comma))
          while(!peek_tk_type(tokens, tk_close_parent)){
            node_expr* new_head = parse_expr(tokens, 0, arena);
            if(!new_head){
                print_context("Expected valid argument", *tokens);
                return NULL;
            }
            if(!vargs_root) vargs_root = new_head;
            else head->next = new_head;
            head = new_head;
            if(!consume_tk_type(tokens, tk_comma)) break;
        }

        if(!consume_tk_type(tokens, tk_close_parent)){
            print_context("Expected ')'", *tokens);
            return NULL;
        }

        stmt = (node_stmt*) ARENA_ALLOC(arena, node_asm);
        stmt->asm_stmt = (node_asm){tk_asm, NULL, &mask_root->term, &code->term, vargs_root};
    }else if(token->type == tk_continue || token->type == tk_break || token->type == tk_next || token->type == tk_end){
        (void) consume_token(tokens);
        stmt = (node_stmt*) ARENA_ALLOC(arena, node_control);
        stmt->control = (node_control){token->type, NULL, token};
    }// expression / var assign statement
    else{
        // Try to get the expression
        node_expr* expr = parse_expr(tokens,1,arena);

        if(!expr){
            print_context("Invalid statement", token);
            return NULL;
        }

        // Variable assignment
        // (can also be class / struct members and pointers, etc.)
        if( peek_tk_type(tokens, tk_assign)      ||
            peek_tk_type(tokens, tk_add_assign)  ||
            peek_tk_type(tokens, tk_sub_assign)  ||
            peek_tk_type(tokens, tk_mult_assign) ||
            peek_tk_type(tokens, tk_div_assign)  ||
            peek_tk_type(tokens, tk_mod_assign)) {

            token_t* assign = consume_token(tokens);
            node_expr* expr2 = parse_expr(tokens, 1, arena);
            if(!expr2){
                print_context("Expected expression", token->next);
                return NULL;
            }
            stmt = (node_stmt*) ARENA_ALLOC(arena, node_var_assign);
            stmt->var_assign = (node_var_assign) {assign->type, NULL, expr, expr2};
        }
        // In case it's a loose expression (e.g. "x++;")
        else{
            stmt = (node_stmt*) ARENA_ALLOC(arena, node_expr_stmt);
            stmt->expr = (node_expr_stmt) {tk_expr_stmt, NULL, expr};
        }
    }

    // Parse the semicolon at the end of the statement
    if(sc_necessary && !peek_tk_type(tokens, tk_semicolon)){
        print_context("Expected semicolon", *tokens);
        return NULL;
    }else if(sc_necessary){
        // Remove any duplicate semicolon
        while(consume_tk_type(tokens, tk_semicolon));
    }

    return stmt;
}

node_stmt* parse_scope(token_t** tokens, arena_t* arena){
    if(!consume_tk_type(tokens, tk_open_braces)){
        print_context("Expected '{'", *tokens);
        return NULL;
    }
    node_stmt root = (node_stmt){tk_invalid, NULL};
    node_stmt* head = &root;
    while(!peek_tk_type(tokens, tk_close_braces)){
        head->next = parse_stmt(tokens, arena, true);
        if(!head->next)
            return NULL;
        head = head->next;
    }
    if(!consume_tk_type(tokens, tk_close_braces)){
        print_context("Expected '}'", *tokens);
        return NULL;
    }
    if(!root.next)
        return (node_stmt*)(~0);
    return root.next;
}

node_stmt* parse(token_t* tokens, arena_t* arena){
    // The token linked list "root"
    token_t token_root = (token_t){tk_invalid, NULL, 0, tokens};
    tokens = &token_root;

    // The statement linked list "root"
    node_stmt root = (node_stmt){tk_invalid, NULL};

    // The last element added to the statement list
    node_stmt* head = &root;

    // While we can read tokens, parse a statement
    while(peek_token(&tokens)){
        token_t* first_token = peek_token(&tokens);
        head->next = parse_stmt(&tokens, arena, true);
        if(!head->next)
            return NULL;
        head = head->next;
    }
    return root.next;
}
