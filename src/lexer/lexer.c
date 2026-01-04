#include "lexer.h"

// STATIC FUNCTIONS
static size_t count_lines(const char** str){
    size_t count = 1;
    while(**str){
        if(**str == '\n') count++;
        (*str)--;
    }
    return count;
}

static token_t* append_token(token_t* target, token_t tk, arena_t* arena){
    if(tk.type == tk_invalid)
        return target;
    target->next = ARENA_ALLOC(arena, token_t);
    *target->next = tk;
    return target->next;
}

// PUBLIC FUNCTIONS
void print_context_ex(const char* msg, const char* str, size_t strlen){
    const char* start = str - 1;
    while(*start && *start != '\n') start--;
    start++;
    const char* end = str;
    while(*end && *end != '\n') end++;
    const char* file_start = start;
    size_t lines = count_lines(&file_start);
    const uint8_t* file_name = GET_FILENAME(file_start);
    HC_PRINT(BOLD BLUE_FG "%s:%lu:%lu:" RESET_ATTR " %s" RESET_ATTR "\n", file_name, lines, str - start + 1, msg);
    if(end > str + strlen)
    HC_PRINT("%*lu | %.*s" BOLD WHITE_FG "%.*s" RESET_ATTR "%.*s\n     | %*s" BOLD GREEN_FG "^%.*s" RESET_ATTR "\n",
            4, lines,
            (int)(str - start), start,
            (int)strlen, str,
            (int)(end - (str + strlen)), str + strlen,
            (int)(str - start), "",
            (int)strlen - 1, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~...");
    else
    HC_PRINT("%*lu | %.*s" BOLD WHITE_FG "%.*s" RESET_ATTR "\n     | %*s" BOLD GREEN_FG "^%.*s..." RESET_ATTR "\n",
            4, lines,
            (int)(str - start),start,
            (int)(end - str), str,
            (int)(str - start), "",
            (int)(end - str - 1), "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
}

void print_context(const char* msg, token_t* token){
    print_context_ex(msg, token->str, token->strlen);
}

void print_token(token_t* token){
    if(token)
        HC_PRINT("(%.*s, %lu)\n",(int)token->strlen,token->str,token->type);
    else
        HC_PRINT("(NULL)\n");
}

token_t* peek_token(token_t** tokens){
    if(!(*tokens) || !(*tokens)->next)
        return NULL;
    return (*tokens)->next;
}

bool peek_tk_type(token_t** tokens, tk_type type){
    return (peek_token(tokens) && peek_token(tokens)->type == type);
}

token_t* consume_token(token_t** tokens){
    if(!(*tokens) || !(*tokens)->next)
        return NULL;
    *tokens = (*tokens)->next;
    return *tokens;
}

bool consume_tk_type(token_t** tokens, tk_type type){
    if(peek_tk_type(tokens, type)){
        (void) consume_token(tokens);
        return true;
    }
    return false;
}

token_t* tokenize(file_t* src, arena_t* arena, token_t* token_start){
    if(!src || !src->data || !arena)
        return false;

    // Macros
    // A fair limit of 256 macros for a single program
    static token_t macros[256];
    static size_t macro_count = 0;
    bool recording_macro = false;

    const char* str = (const char*) src->data;

    token_t tokens = (token_t){tk_invalid, NULL, 0, token_start};
    token_t* end_token = (token_start) ? token_start : &tokens;
    while(*str){
        // New token
        token_t tk = (token_t){tk_invalid, str, 1, NULL};

        // Skip whitespace
        if(isspace(*str)){
            if(recording_macro && *str == '\n')
                recording_macro = false;
            str++;
        }

        // Identifiers / keywords
        else if(isalpha(*str) || *str == '@' || *str == '$' || *str == '_'){
            const char* start = str++;
            while(*str && (isalnum(*str) || *str == '_')) str++;
            tk = (token_t){tk_identifier, start, str - start, NULL};
            bool is_macro = false;
            for(size_t i = 0; i < macro_count; i++){
                if(tk.strlen == macros[i].strlen && strncmp(tk.str, macros[i].str, tk.strlen) == 0){
                    token_t* macro_contents = macros[i].next;
                    while(macro_contents){
                        end_token = append_token(end_token, *macro_contents, arena);
                        macro_contents = macro_contents->next;
                    }
                    is_macro = true;
                    break;
                }
            }
            if(is_macro)
                continue;
            struct keyword_pair* kw = hashtable_get(&keyword_table, &tk.str);
            if(kw)
                tk.type = kw->value;

        // Numerical constants
        }else if(isdigit(*str)){
            const char* start = str++;
            if(*str == 'x' || *str == 'b')
                str++;
            tk.type = tk_int_lit;
            while(*str && isdigit(*str)) str++;
            if(*str == '.'){
                tk.type = tk_float_lit;
                while(*str && isdigit(*str)) str++;
            }
            tk = (token_t){tk.type, start, str - start, NULL};

        // Symbols / other constants
        }else{
            switch(*str){
            case '=':
                if(*(str+1) == '='){
                    tk.type = tk_cmp_eq;
                    tk.strlen = 2;
                }else
                    tk.type = tk_assign;
                break;
            case '-':
            case '+':
                if(*(str+1) == '='){
                    tk.type = (*str == '+') ? tk_add_assign : tk_sub_assign;
                    tk.strlen = 2;
                }else if(*(str+1) == *str){
                    tk.type = (*str == '+') ? tk_inc : tk_dec;
                    tk.strlen = 2;
                }else
                    tk.type = (*str == '+') ? tk_add : tk_sub;
                break;
            case '/':
                if(*(str+1) == '/'){
                    str += 2;
                    while(*str && *str != '\n') str++;
                    continue;
                }else if(*(str+1) == '*'){
                    str += 2;
                    while(*str && *str != '*' && *(str+1) != '/') str++;
                    str += 2;
                    continue;
                }
            case '*':
                if(*(str+1) == '='){
                    tk.type = (*str == '*') ? tk_mult_assign : tk_div_assign;
                    tk.strlen = 2;
                }else
                    tk.type = (*str == '*') ? tk_mult : tk_div;
                break;
            case '%':
                if(*(str+1) == '='){
                    tk.type = tk_mod_assign;
                    tk.strlen = 2;
                }else
                    tk.type = tk_mod;
                break;
            case '>':
            case '<':
                if(*(str+1) == '='){
                    tk.type = (*str == '>') ? tk_cmp_ge : tk_cmp_le;
                    tk.strlen = 2;
                }else if(*(str+1) == *str){
                    tk.type = (*str == '>') ? tk_shr : tk_shl;
                    tk.strlen = 2;
                }else
                    tk.type = (*str == '>') ? tk_cmp_g : tk_cmp_l;
                break;
            case '|':
            case '&':
                if(*(str+1) == *str){
                    tk.type = (*str == '|') ? tk_or : tk_and;
                    tk.strlen = 2;
                }else
                    tk.type = (*str == '|') ? tk_bin_or : tk_bin_and;
                break;
            case '^':
                tk.type = tk_bin_xor;
                break;
            case '!':
                if(*(str+1) == '='){
                    tk.type = tk_cmp_neq;
                    tk.strlen = 2;
                }else
                    tk.type = tk_exclam;
                break;
            case '~':
                if(*(str+1) == '='){
                    tk.type = tk_cmp_approx;
                    tk.strlen = 2;
                }else
                    tk.type = tk_bin_flip;
                break;
            case '(':
            case ')':
                tk.type = (*str == '(') ? tk_open_parent : tk_close_parent;
                break;
            case '{':
            case '}':
                tk.type = (*str == '{') ? tk_open_braces : tk_close_braces;
                break;
            case '[':
            case ']':
                tk.type = (*str == '[') ? tk_open_bracket : tk_close_bracket;
                break;
            case ',':
                tk.type = tk_comma;
                break;
            case '.':
                tk.type = tk_dot;
                break;
            case ':':
                tk.type = tk_colon;
                break;
            case ';':
                tk.type = tk_semicolon;
                break;
            case '"':
            case '\'':{
                tk.type = (*str == '\'') ? tk_char_lit : tk_str_lit;
                const char* start = str++;
                while(*str && *str != *start) str++;
                tk.strlen = str - start + 1;
                if(!*str){
                    tk.strlen--;
                    print_context("Missing closing quotes",&tk);
                    return NULL;
                }
                str -= tk.strlen - 1;
                break;
            }case '#':{
                // Preprocessor directives
                const char* start = str++;
                while(*str && isalpha(*str)) str++;
                tk.strlen = str - start;

                // #include "PATH"
                if(tk.strlen == 8 && strncmp(start, "#include ", 9) == 0){
                    tk.type = tk_invalid;
                    while(*str && *str != '\n' && isspace(*str)) str++;
                    if(*str++ != '"'){
                        print_context("Expected valid path at include",&tk);
                        return NULL;
                    }
                    const char* path_start = str;
                    while(*str && *str != '"' && *str != '\n') str++;
                    if(*str != '"'){
                        print_context("Expected valid path at include",&tk);
                        return NULL;
                    }
                    // Allocate the file and read it
                    src->next = ARENA_ALLOC(arena, file_t);
                    src->next->file_name = (uint8_t*) arena_alloc(arena, str - path_start + 1);
                    memcpy(src->next->file_name, path_start, str - path_start);
                    src->next->file_name[str - path_start] = '\0';
                    if(!file_read(src->next)){
                        tk.strlen = str - start + 1;
                        print_context("Failed to include here",&tk);
                        return NULL;
                    }
                    // Skip the last double quote
                    str++;
                    continue;
                }else if(tk.strlen == 7 && strncmp(start, "#define ", 8) == 0){
                    while(*str && *str != '\n' && isspace(*str)) str++;
                    if(*str == '\n' || !(isalpha(*str) || *str == '_')){
                        print_context("Expected valid macro name", &tk);
                        return NULL;
                    }
                    const char* start = str;
                    str++;
                    while(*str && (isalnum(*str) || *str == '_')) str++;
                    tk = (token_t){tk_identifier, start, str - start, NULL};
                    macros[macro_count++] = tk;
                    recording_macro = true;
                    continue;
                }else{
                    print_context("Unknown preprocessor directive",&tk);
                    return NULL;
                }
                break;
            }default:
                print_context("Unexpected character",&tk);
                return NULL;
            }
            str += tk.strlen;
        }

        if(!recording_macro)
            end_token = append_token(end_token, tk, arena);
        else{
            token_t* last_tk = &macros[macro_count-1];
            while(last_tk->next) last_tk = last_tk->next;
            append_token(last_tk, tk, arena);
        }
    }
    if(!tokens.next)
        HC_WARN("First input file is empty! This compiler does not like when the first input file is empty :(");
    return tokens.next;
}
