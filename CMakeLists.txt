cmake_minimum_required(VERSION 3.20)

set(CMAKE_C_STANDARD 17)

set(CMAKE_BUILD_TYPE Debug)

# The HCC, Holy Cow Compiler
project(HolyCowCompiler)

# Create the static library of the language
add_library(HolyCow STATIC
# dev (Dev tools / library)
src/dev/arena.c
src/dev/file.c
src/dev/vector.c
src/dev/hashtable.c

# lexer (Lexical analyser)
src/lexer/keywords.c
src/lexer/lexer.c

# parser (Abstract Syntax Tree (AST) generator)
src/parser/parser.c

# generator (Assembly Generator)
src/generator/regs.c
src/generator/hc_types.c
src/generator/generator.c
)

# Currently available target
# - TARGET_x64_Linux -> x64 Linux

# Change the target here
target_compile_definitions(HolyCow PRIVATE TARGET_x64_Linux)

# Create the executable
add_executable(hcc src/compiler.c)

# Link library
target_link_libraries(hcc PRIVATE HolyCow)

# Add compiler debug info
# NOTE Kinda annoying, so remove if not needed
# target_compile_definitions(hcc PRIVATE COMPILER_DEBUG)
