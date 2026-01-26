#include "std/stdlib.hhc"

// You can have default arguments
// A comma in the middle of args = default argument
// No argument provided = default argument
// add()   = 15
// add(7)  = 17
// add(,5) = 10
int add(int a = 5, int b = 10){
    return a + b;
}

// You can even have them in the middle
// test(1,,2) = 1 - 26 * 2 = -51
int test(int a, int b = -26, int c){
    return a + b * c;
}

// Variable arguments
// VARGS is an array of all extra arguments
// Recommended to store VARGS in a variable
void print_numbers(uint count, ...){
    // In this case, the numbers are ints,
    // so vargs is an array of ints
    int* vargs = VARGS;
    char c = '>';
    repeat(count){
        print("%c %i", c, *vargs);

        // Careful! In HolyCow, pointers are like ints.
        // Ints handled with pointers are not scaled
        // by the size of the pointer's contents!
        // Not like C, where (int*)ptr + 5 is actually:
        // (int*)ptr + 5 * sizeof(int) = (int*)ptr + 80
        vargs += 8;
        c = ',';
    }
    print_char('\n');
}

int main(uint argc, char** argv){
    println("Hello world!");

    // This is a demo of all format specifiers available

    // Print a null terminated string
    println("string:            \"%s\"", "HolyCow!");

    // Print a string of specified length
    // length must be followed by string
    println("length string:     \"%*s\"", 5, "1234567890");

    // Print a single character
    println("character:         '%c'", '@');

    // Print a character n times
    // n must be followed by the character
    println("repeated character: %*c", 5, '*');

    // Print a signed / unsigned int
    println("signed int:         %i", -647);
    println("unsigned int:       %u", 102532);

    // Print an unsigned int in hexadecimal form
    println("uint (hex):         %x", 0xBEEF);

    // Print a boolean
    println("bool                %b", true);

    // Print a fixed point number
    fixed x = string_to_fixed("-16.2126");
    println("fixed point number: %F", x);

    // Print a floating point number
    println("float number:       %f", -16.2126);
}
