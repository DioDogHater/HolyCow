#include "dev/libs.h"
#include "dev/types.h"
#include "generator/generator.h"
#include "lexer/lexer.h"
#include "parser/parser.h"
#include <stdlib.h>

#define COMPILER_DEBUG

static file_t input_files = NEW_FILE(NULL);
static const char* output_file = NULL;
static struct{
    bool debug;
} options = {.debug = false};

// Show the usage
static void show_usage(const char* msg, arena_t* arena){
    if(msg)
        HC_ERR("%s",msg);
    HC_PRINT(
        "Usage: hcc <input file(s)> [options]\n"
        "Options:\n"
        "   -h, --help : Show this menu\n"
        "   -o, --output : Set the output file path\n"
    );
    arena_destroy(arena);
    exit((msg) ? EXIT_FAILURE : EXIT_SUCCESS);
}

static bool match_arg(const char** arg, const char* value){
    bool long_arg = (value[2] != '\0');

    // Starting character
    const char* arg_ptr = *arg;

    // Go through each char in value
    for(; *value; arg_ptr++, value++){
        // If arg ends short or is not equals to value
        if(!(*arg_ptr) || (*arg_ptr) != *value)
            // It is not the arg we need
            return false;
    }

    // If we are matching for long argument,
    // we check if there's something unexpected at the end
    if(long_arg && *arg_ptr != '\0')
        return false;

    // We skip the matched argument
    *arg = arg_ptr;

    return true;
}

// Parse the arguments given to the compiler
static void parse_compiler_args(int argc, char* argv[], arena_t* arena){
    enum{
        C_ARG_NONE = 0,
        C_ARG_OUTPUT = 1,
    };
    uint8_t last_arg = C_ARG_NONE;
    for(int i = 1; i < argc; i++){
        const char* arg = argv[i];
        while(*arg){
            // Whitespace (shouldn't be there but better safe than sorry)
            if(*arg == ' ' || *arg == '\t' || *arg == '\n')
                arg++;  // Skip it

            // Last argument needs an answer
            else if(last_arg != C_ARG_NONE){
                switch(last_arg){
                case C_ARG_OUTPUT:
                    output_file = arg;
                    for(; *arg; arg++);
                    last_arg = C_ARG_OUTPUT;
                }
                last_arg = C_ARG_NONE;

            // Option argument
            }else if(*arg == '-'){

                // Help menu
                if(match_arg(&arg, "-h") || match_arg(&arg, "--help"))
                    show_usage(NULL, arena);

                // Output file argument
                else if(match_arg(&arg, "-o") || match_arg(&arg, "--output")){
                    if(output_file)
                        show_usage("Output file given two times!", arena);
                    last_arg = C_ARG_OUTPUT;
                }

                else if(match_arg(&arg, "-d") || match_arg(&arg, "--debug"))
                    options.debug = true;

                // Invalid option
                else
                    show_usage("Invalid option!", arena);

            // We assume it's a input file
            }else if(last_arg == C_ARG_NONE){
                file_t* last_input = &input_files;
                while(last_input->next) last_input = last_input->next;
                last_input->next = ARENA_ALLOC(arena, file_t);
                *last_input->next = (file_t) NEW_FILE((uint8_t*)arg);
                if(!file_read(last_input->next)){
                    arena_destroy(arena);
                    exit(EXIT_FAILURE);
                }
                for(; *arg; arg++);

            // In case of an invalid arg
            }else
                show_usage("Invalid argument!", arena);
        }
    }

    // Check if any arg didn't get its value
    if(last_arg != C_ARG_NONE)
        show_usage("Missing option value!", arena);

    if(!input_files.next)
        show_usage("Missing input file!", arena);

    if(!output_file){
        HC_WARN("Output file will be \"a.out\" by default.");
        output_file = "a.out";
    }
}

int main(int argc, char* argv[]){
    // Create an arena allocator with 64 KB of memory
    arena_t arena = NEW_ARENA();
    if(!arena_init(&arena, 64 * KB))
        return EXIT_FAILURE;

    // Parse compiler args
    parse_compiler_args(argc, argv, &arena);

    // Setup the keyword table setup
    keyword_table_setup();
    token_t* all_tokens = NULL;
    token_t* last_token = NULL;
    file_t* input_file = input_files.next;

    // Tokenize the input files one by one
    while(input_file){
        token_t* tokens = tokenize(input_file, &arena, last_token);
        if(!tokens){
            HC_ERR("\nTOKENIZATION FAILED!");
            file_destroy(&input_files);
            arena_destroy(&arena);
            return EXIT_FAILURE;
        }
        if(!all_tokens)
            all_tokens = tokens;
        last_token = tokens;
        while(last_token->next != NULL)
            last_token = last_token->next;
        input_file = input_file->next;
    }

    // Destroy the keyword table
    keyword_table_destroy();

#ifdef COMPILER_DEBUG
{
    int i = 0;
    token_t* tk = all_tokens;
    while(tk){
        HC_PRINT("tk[%d] = ", i);
        print_token(tk);
        tk = tk->next;
        i++;
    }
    putchar('\n');
}
#endif

    // Parse the tokens and turn them into an AST
    node_stmt* AST = parse(all_tokens, &arena);
    if(!AST){
        HC_ERR("\nPARSING FAILED!");
        file_destroy(&input_files);
        arena_destroy(&arena);
        return EXIT_FAILURE;
    }

    HC_CONFIRM("Parsed successfully!");

    // Generate the assembly
    {
        char buffer[512];
        sprintf(buffer, "%.*s.nasm", 511 - 5, output_file);
        if(!generate(buffer, AST)){
            HC_ERR("\nGENERATION FAILED!");
            file_destroy(&input_files);
            arena_destroy(&arena);
            return EXIT_FAILURE;
        }
    }

    HC_CONFIRM("Output file %s.nasm was generated.", output_file);

    int sts = assemble(output_file, options.debug);

    if(sts){
        HC_ERR("\nASSEMBLY FAILED! Error code: %d", sts);
        file_destroy(&input_files);
        arena_destroy(&arena);
        return EXIT_FAILURE;
    }else
        HC_CONFIRM("Assembled successfully, %s.o generated.", output_file);

    sts = link(output_file);

    if(sts){
        HC_ERR("\nLINKING FAILED! Error code: %d", sts);
        file_destroy(&input_files);
        arena_destroy(&arena);
        return EXIT_FAILURE;
    }else
        HC_CONFIRM("Linked successfully, %s generated.", output_file);

    HC_CONFIRM("COMPILATION SUCCESSFUL!");

    file_destroy(&input_files);
    arena_destroy(&arena);

    return 0;
}
