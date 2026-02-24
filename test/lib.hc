#include "std/stdlib.hhc"

int get_int(){
    char buffer[64];
    int n = input(buffer, 64);
    return string_to_int(buffer, n);
}
