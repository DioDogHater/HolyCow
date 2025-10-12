#include "dev/libs.h"
#include "dev/types.h"
#include "lexer/lexer.h"
#include <stdlib.h>

// Debug (comment out before running)
#define COMPILER_DEBUG

static const char* input_file = NULL;
static const char* output_file = NULL;

static void show_usage(const char* msg){
    if(msg)
        HC_PRINT("%s\n",msg);
    HC_PRINT(
        "Usage: hcc [options] <input file> [-o <output file>]\n"
        "Options:\n"
        "   -h, --help : Show this menu\n"
        "   -o, --output : Set the output file path\n"
    );
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

static void parse_compiler_args(int argc, char* argv[]){
    enum{
        C_ARG_NONE = 0,
        C_ARG_OUTPUT = 1,
    };
    uint8_t last_arg = C_ARG_NONE;
    for(int i = 1; i < argc; i++){
        const char* arg = argv[i];
        while(*arg){
            // Whitespace
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
                    show_usage(NULL);

                // Output file argument
                else if(match_arg(&arg, "-o") || match_arg(&arg, "--output")){
                    if(output_file)
                        show_usage("Output file given two times!");
                    last_arg = C_ARG_OUTPUT;
                }

                // Invalid option
                else
                    show_usage("Invalid option!");

            // We assume it's the input file
            }else if(last_arg == C_ARG_NONE && !input_file){
                input_file = arg;
                for(; *arg; arg++);

            // In case of an invalid arg
            }else
                show_usage("Invalid argument!");
        }
    }

    // Check if any arg didn't get its value
    if(last_arg != C_ARG_NONE)
        show_usage("Missing option value!");

    if(!input_file)
        show_usage("Missing input file!");

    if(!output_file)
        output_file = "a.out";

    // DEBUG
#ifdef COMPILER_DEBUG
    HC_DEBUG_PRINT(input_file,"%s");
    HC_DEBUG_PRINT(output_file,"%s");
#endif
}

int main(int argc, char* argv[]){
    // Parse compiler args
    parse_compiler_args(argc, argv);

    // Create an arena allocator with 16 KB
    arena_t arena = NEW_ARENA();
    if(!arena_init(&arena, 16 * KB))
        return EXIT_FAILURE;

    tokenize(NULL, &arena);

    arena_destroy(&arena);

    return 0;
}
