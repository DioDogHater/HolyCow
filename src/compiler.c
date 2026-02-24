#include "dev/libs.h"
#include "dev/types.h"

// 3 stages of this compiler

// Lexical Analyser aka "Lexer"
// Divides a source file into tokens, which all have a specific meaning
// Way easier to handle meaningful groups of letters than letters individually
#include "lexer/lexer.h"

// Parser => Abstract Syntax Tree Generator
// Abstract Syntax Tree :
// * A structure capable of representing a programming language's abstract concepts
//   like statements, expressions, definitions, etc. Should represent how the syntax
//   of the programming language is structured.
#include "parser/parser.h"

// Code / Assembly Generator aka "Generator"
// Also referred to as the "Backend" of a compiler
// As you can see, there is no optimization step for now
#include "generator/generator.h"

// Arena allocator (used to swiftly allocate / free without trouble everything)
static arena_t arena[1] = { NEW_ARENA() };

// The compilation options
static struct{
    file_t input_files;
    const char* output_file;
    char* link_files;
    bool debug;
    bool library;
} options = {.input_files = NEW_FILE(NULL), .output_file = NULL, .link_files = "", .debug = false, .library = false};

// Show the usage of the compiler
static void show_usage(const char* msg){
    if(msg)
        HC_ERR("%s",msg);
    HC_PRINT(
        "Usage: hcc <input file(s)> [options]\n"
        "Options:\n"
        "   -h, --help      : Displays this help menu\n"
        "   -o, --output    : Set the output file path\n"
        "   -l, --link      : Set libraries to be linked, each separated by a comma (,)\n"
        "   -s, --static    : Compiles a static library (object file) instead of executable\n"
        "   -d, --debug     : Adds debug info to output executable\n"
        "   --target-info   : Displays the target's information\n"
    );
    arena_destroy(arena);
    HC_FAIL();
}


// Match a compiler argument
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
static void parse_compiler_args(int argc, char* argv[]){
    enum{
        C_ARG_NONE = 0,
        C_ARG_OUTPUT = 1,
        C_ARG_LINK = 2,
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
                    options.output_file = arg;
                    for(; *arg; arg++);
                    break;
                case C_ARG_LINK:
                    options.link_files = (char*) arg;
                    for(; *arg; arg++);
                    break;
                }
                last_arg = C_ARG_NONE;

            // Option argument
            }else if(*arg == '-'){

                // Help menu
                if(match_arg(&arg, "-h") || match_arg(&arg, "--help"))
                    show_usage(NULL);

                // Output file argument
                else if(match_arg(&arg, "-o") || match_arg(&arg, "--output")){
                    if(options.output_file)
                        show_usage("Output file given two times!");
                    last_arg = C_ARG_OUTPUT;
                }

                // Link files argument
                else if(match_arg(&arg, "-l") || match_arg(&arg, "--link")){
                    if(*options.link_files)
                        show_usage("Linking files given two times, they must be separated by a single ',' instead\n"
                                   "Example: -l lib1.o,lib2.o,lib3.o");
                    last_arg = C_ARG_LINK;
                }

                // Static library
                else if(match_arg(&arg, "-s") || match_arg(&arg, "--static")){
                    options.library = true;
                }

                // Debug enabled
                else if(match_arg(&arg, "-d") || match_arg(&arg, "--debug"))
                    options.debug = true;

                else if(match_arg(&arg, "--target-info")){
                    HC_CONFIRM("Target %s : %d bit architecture, %lu byte addresses.\n", target_architecture, target_cpu, target_address_size);
                    HC_CONFIRM("Assembler used : %s\nLinker used : %s\n", target_assembler, target_linker);
                    HC_FAIL();
                }

                // Invalid option
                else
                    show_usage("Invalid option!");

            // We assume it's a input file
            }else if(last_arg == C_ARG_NONE){
                file_t* last_input = &options.input_files;
                while(last_input->next) last_input = last_input->next;
                last_input->next = ARENA_ALLOC(arena, file_t);
                *last_input->next = (file_t) NEW_FILE((uint8_t*)arg);
                if(!file_read(last_input->next)){
                    arena_destroy(arena);
                    HC_FAIL();
                }
                for(; *arg; arg++);

            // In case of an invalid arg
            }else
                show_usage("Invalid argument!");
        }
    }

    // Check if any arg didn't get its value
    if(last_arg != C_ARG_NONE)
        show_usage("Missing option value!");

    if(!options.input_files.next)
        show_usage("Missing input file!");

    if(!options.output_file){
        HC_WARN("Output file will be \"a.out\" by default.");
        options.output_file = "a.out";
    }
}

void compiler_quit(){
    file_destroy(&options.input_files);
    free_included_files();
    arena_destroy(arena);
}

int main(int argc, char* argv[]){
    // Create an arena allocator with 2 MB of memory
    if(!arena_init(arena, 2 * MB))
        return EXIT_FAILURE;

    // Parse compiler args
    parse_compiler_args(argc, argv);

    // Setup the keyword table setup
    keyword_table_setup();
    token_t* all_tokens = NULL;
    token_t* last_token = NULL;
    file_t* input_file = options.input_files.next;

    // Tokenize the input files one by one
    while(input_file){
        token_t* tokens = tokenize(input_file, arena, last_token);
        if(!tokens){
            HC_ERR("\nTOKENIZATION FAILED!");
            compiler_quit();
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
    node_stmt* AST = parse(all_tokens, arena);
    if(!AST){
        HC_ERR("\nPARSING FAILED!");
        compiler_quit();
        return EXIT_FAILURE;
    }

    // Generate the assembly
    // We need a buffer to store the .nasm filepath
    char buffer[512];
    snprintf(buffer, 511, "%s.nasm", options.output_file);
    if(!generate(buffer, AST, arena, options.library)){
        HC_ERR("\nGENERATION FAILED!");
        compiler_quit();
        return EXIT_FAILURE;
    }

    if(options.debug)
        HC_CONFIRM("Intermediate assembly %s.nasm was generated.", options.output_file);

    int sts = assemble(options.output_file, options.debug);

    if(sts){
        HC_ERR("\nASSEMBLY FAILED! Error code: %d", sts);
        compiler_quit();
        return EXIT_FAILURE;
    }else if(options.library)
        HC_CONFIRM("Assembled successfully, %s.o generated.", options.output_file);

    if(!options.library){
        sts = link(options.output_file, options.link_files);

        if(sts){
            HC_ERR("\nLINKING FAILED! Error code: %d", sts);
            compiler_quit();
            return EXIT_FAILURE;
        }else
            HC_CONFIRM("Linked successfully, %s generated.", options.output_file);
    }

    // If debug option is enabled, we keep the .nasm file
    // Otherwise, we just destroy it
    // For the object file, we keep it only if we are compiling a library
    if(!options.debug)
        HC_DELETE_FILE(buffer);
    snprintf(buffer, 511, "%s.o", options.output_file);
    if(!options.library)
        HC_DELETE_FILE(buffer);

    HC_CONFIRM("COMPILATION SUCCESSFUL!");

#ifdef COMPILER_DEBUG
    HC_CONFIRM("Used %.2f%% of arena memory", (float)arena->ptr / (float)arena->size * 100.f);
#endif

    compiler_quit();
    return 0;
}
