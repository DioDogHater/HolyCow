#include "std/stdlib.hhc"

int main(uint argc, char** argv){
    int x = 5;
    repeat(x){
        print_str("Hello world!\n");
    }
    return 0;
}
