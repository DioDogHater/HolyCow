# The Holy Cow programming language
is a language inspired by the ***C Programming Language***, ***Rust*** and
***Holy C***, the legendary language created by *Terry A. Davis*. This is
an attempt at making a more programmer-friendly C-like programming language
without delving too much in complex concepts. A simpler and enjoyable C++
is close to what I aim for. 

# Requirements
For now, you can only use the language with **Linux**, but compatibility is an issue I'm willing to work on.
You will need *cmake*, *make*, *nasm* and *ld* to start compiling right away.

# Building
```
git clone https://github.com/DioDogHater/HolyCow
cd HolyCow
cmake -S . -B ./build
cmake --build ./build
```
You can then run `./build/hcc` or `.\build\hcc.exe`

# Features
This the end goal of how my language will look like.
```
// Comments are like in C (they start with "//")
/* Multiple
   line comments
   are also possible */

/* Variable types:
- void (only for typeless pointers and functions)
- uint8 or char, int8
- uint16, int16
- uint32, int32
- uint64 or uint, int64 or int
- float (64 bit floating point number)
- flag (a flag is a boolean that occupies a single bit)
- bool (boolean as a single byte, but (bool)54 == (bool)100)
- string, built-in string type with extra features.
- pointer (type*), same as C syntax
*/

string x = "Hello world!";
int16 my_variable = 0;

// Preprocessor directives
// Source files end with .hc
// Header files end with .hhc
#include "header_file.hhc"

#define twenty_five "twenty_five"

#macro test(x, y) (x * y)

// It is possible to create modules (namespaces)
module test{
    void greet(){
        println("Hello!");
    }
}

// Now to access greet() you must use test.greet()

// Constant expression
constexpr float five_over_2 = 5 / 2;

// Functions can have default values, as long as they're constant
void hello_world(string msg = "Default"){
    // Displays a string on screen (can have formats)
    println(msg.str);
    
    // Gets a value from stdin (input)
    // try ... except ... is a way to handle exceptions
    int64 value;
    try{
        scan("%i",&value);
    }except{
        // fail() is a println() + exit()
        fail("Invalid integer value.");
    }
    
    // If statements
    if(value > 100){
        if(value < 150)
            @next;              // Goes to the next condition
        print(msg + "Huh?\n");
    }else if(value == 0){
        print("Null.\n");
    }else{
        print("Bro...\n");
    }
    
    // Switch statements
    switch(value){
    case 0 .. 5:
        print("Between 0 and 5, inclusive\n");
    case 6 || 7:
        print("6 ... 7?");
        @next;              // Goes to next case
    default:
        print("Value: %l\n",value);
    }
    
    // While loop
    flag condition = true;
    flag other_flag = false;
    while(condition){
        if(!other_flag){
            other_flag = true;
            continue;
        }
        break;
    }
    
    // For loop
    for(int i = 0; i < 50; i += 2){
        print("i = %i\n", i);
    }
    
    // Print a new line
    println();
    
    // Repeat loop
    repeat(25){
        print(".");
    }
    
    // Loop loop (infinite loop)
    loop{
        println("Hello world!");
        break;
    }
    
    println();
}

/*
* Classes ressemble C++ classes
* No polymorphism, but inheritance is possible
* Function overloading works
* No security (public, private)
* Basic operator overloading
*/
class Animal{
    string name;
    int age;
    
    static Animal new(string _name, int _age){
        // You can construct a class like a struct
        return Animal{_name, _age};
    }
    string to_string(){
        // "this" is a pointer to the class calling the method
        return format("%s : %d yo", this.name, this.age);
    }
}

// Child class
class Pet from Animal{
    int owner_count;
    string* owners;
    
    /*
    * Variable arguments
    * Allocate on the stack if possible (otherwise error will appear)
    * Stack allocation is possible for max 1024KB
    * (only in a scope with compile time constants)
    * vargs.size is a compile time constant in this case
    */
    static Pet new(string _name, int _age, ...vargs) : @stack(sizeof(string) * vargs.size) {
        super(_name, _age);
        owners = @stack;
        for(int i = 0; i < vargs.size; i++)
            owners[i] = vargs.get(i, const char*);
    }
    string to_string(){
        return super() + format(", %d owners", this.name, this.age);
    }
}

```
