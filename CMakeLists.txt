cmake_minimum_required(VERSION 3.20)

set(CMAKE_C_STANDARD 17)

set(CMAKE_BUILD_TYPE Debug)

# The HCC, Holy Cow Compiler
project(HolyCowCompiler)

# Create the static library of the language
add_library(HolyCow STATIC
src/dev/arena.c
src/dev/file.c
)

# Create the executable
add_executable(hcc src/compiler.c)

# Link library
target_link_libraries(hcc PRIVATE HolyCow)
