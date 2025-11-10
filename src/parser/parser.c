#include "parser.h"

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
        return 6;
    case tk_cmp_ge:
    case tk_cmp_g:
    case tk_cmp_le:
    case tk_cmp_l:
        return 7;
    case tk_shl:
    case tk_shr:
        return 8;
    case tk_mult:
    case tk_div:
    case tk_mod:
        return 9;
    case tk_deref:
    case tk_getaddr:
    case tk_type_cast:
    case tk_neg:
    case tk_not:
    case tk_bin_flip:
    case tk_sizeof:
        return 10;
    case tk_dot:
    case tk_open_parent:
    case tk_open_bracket:
    case tk_inc:
    case tk_dec:
        return 11;
    }
    return -1;
}

node_expr* parse_term(token_t** tokens, arena_t* arena){
    node_expr* expr = NULL;
    token_t* token = consume_token(tokens);
    if(!token)
        return NULL;

    // If it's a built-in type
    if(token->type >= tk_int8 && token->type < tk_const){
        expr = (node_expr*) ARENA_ALLOC(arena, node_builtin_type);
        expr->builtin_type = (node_builtin_type) {token->type, NULL};
        return expr;
    }

    // Expression terms
    switch(token->type){
    case tk_str_lit:
    case tk_bool_lit:
    case tk_char_lit:
    case tk_int_lit:
        expr = (node_expr*) ARENA_ALLOC(arena, node_term);
        expr->term = (node_term) {token->type, NULL, token->str, token->strlen};
        break;
    case tk_identifier:
        expr = (node_expr*) ARENA_ALLOC(arena, node_term);
        expr->term = (node_term) {tk_identifier, NULL, token->str, token->strlen};
        break;
    case tk_not:
    case tk_bin_flip:
    case tk_neg:
        expr = (node_expr*) ARENA_ALLOC(arena, node_unary_op);
        expr->unary_op = (node_unary_op) {token->type, NULL, parse_expr(tokens, get_operator_precedence(token->type), arena)};
        if(!expr->unary_op.lhs){
            print_context("Missing expression", token);
            return NULL;
        }
        break;
    case tk_mult:
    case tk_bin_and:
        expr = (node_expr*) ARENA_ALLOC(arena, node_unary_op);
        expr->unary_op = (node_unary_op) {token->type, NULL, parse_expr(tokens, get_operator_precedence((token->type == tk_mult) ? tk_deref : tk_bin_and), arena)};
        if(!expr->unary_op.lhs){
            print_context("Missing expression", token);
            return NULL;
        }
        break;
    case tk_sizeof:
        if(consume_token(tokens)->type != tk_open_parent){
            print_context("Expected (", token);
            return NULL;
        }
    case tk_open_parent:
        expr = (node_expr*) ARENA_ALLOC(arena, node_unary_op);
        expr->unary_op = (node_unary_op) {token->type, NULL, parse_expr(tokens, get_operator_precedence(token->type), arena)};
        if(!expr->unary_op.lhs){
            print_context("Missing expression", token);
            return NULL;
        }
        if(peek_token(tokens)->type != tk_close_parent){
            print_context("Expected closing )", token);
            return NULL;
        }else
            (void) consume_token(tokens);
        break;
    }
    return expr;
}

node_expr* parse_expr(token_t** tokens, int min_precedence, arena_t* arena){
    node_expr* lhs = parse_term(tokens, arena);
    if(lhs){
        while(true){
            // Test if it's an operator and its precedence
            token_t* operator = peek_token(tokens);
            int op_precedence;
            if(!operator || (op_precedence = get_operator_precedence(operator->type)) < min_precedence)
                break;
            (void) consume_token(tokens);

            // Set the lhs as expr
            node_expr* expr = NULL;
            switch(operator->type){
            case tk_inc:
            case tk_dec:{
                expr = (node_expr*) ARENA_ALLOC(arena, node_unary_op);
                expr->unary_op = (node_unary_op) {operator->type, NULL, lhs};
                break;
            }default:{
                expr = (node_expr*) ARENA_ALLOC(arena, node_bin_op);
                expr->bin_op = (node_bin_op) {operator->type, NULL, lhs, NULL};
                expr->bin_op.rhs = parse_expr(tokens, op_precedence + 1, arena);
                if(!expr->bin_op.rhs){
                    print_context("Missing right hand side operand", operator);
                    return NULL;
                }
                break;
            }}

            lhs = expr;
        }
        return lhs;
    }else
        return NULL;
}

node_stmt* parse_stmt(token_t** tokens, arena_t* arena){
    node_stmt* stmt = NULL;
    token_t* token = consume_token(tokens);
    if(!token)
        return NULL;

    // Variable assignment
    if(token->type >= tk_int8 && token->type <= tk_constexpr){
        while(peek_token(tokens)->type >= tk_int8 && peek_token(tokens)->type <= tk_constexpr)
            (void) consume_token(tokens);
        token_t* identifier = consume_token(tokens);
        if(identifier->type != tk_identifier){
            print_context("Expected identifier!", identifier);
            return NULL;
        }
        if(!peek_token(tokens)){
            print_context("Expected semicolon", identifier);
            return NULL;
        }
        if(peek_token(tokens)->type == tk_assign)
            (void) consume_token(tokens);
        else if(consume_token(tokens)->type != tk_semicolon){
            print_context("Expected semicolon", identifier);
            return NULL;
        }
        node_expr* expr = parse_expr(tokens, 1, arena);
        if(!expr){
            print_context("Missing expression", identifier->next);
            return NULL;
        }
        stmt = (node_stmt*) ARENA_ALLOC(arena, node_var_decl);
        stmt->var_decl = (node_var_decl) {tk_var_decl, NULL, token, identifier, expr};
    }else{
        print_context("Not implemented yet",token);
    }

    if(!peek_token(tokens) || peek_token(tokens)->type != tk_semicolon){
        print_context("Expected semicolon", *tokens);
        return NULL;
    }else
        (void) consume_token(tokens);

    return stmt;
}

node_stmt* parse(token_t* tokens, arena_t* arena){
    token_t token_root = (token_t){tk_invalid,"",0,tokens};
    tokens = &token_root;
    node_stmt root = (node_stmt){tk_invalid,NULL};
    node_stmt* head = &root;
    while(peek_token(&tokens)){
        head->next = parse_stmt(&tokens, arena);
        if(!head->next){
            print_context("Invalid statement", tokens);
            return NULL;
        }
        head = head->next;
    }
    return root.next;
}
