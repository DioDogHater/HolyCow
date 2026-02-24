#include "std/stdlib.hhc"

int get_int();

int main(uint argc, char** argv){
    print("Enter a number: ");
    int i = get_int();
    println("%i * 5 = %i", i, i * 5);

    return 0;
}
