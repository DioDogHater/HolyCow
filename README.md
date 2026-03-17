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
- bool (boolean as a single byte, 1 = true, 0 = false)
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
        // error() is a println() + exit(EXIT_FAILURE)
        error("Invalid integer value.");
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
    bool condition = true;
    while(condition){
        condition = not condition;
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
- No constructors, but same can be achieved with static methods.
  No destructors, but same can be achieved with a method.

- Polymorphism achieved using virtual methods and method overloading.

- Encapsulation implemented, but every attribute is public by default.
  Attributes can be made "peekable" (readable) publicly, while still being private / protected for writing.

- Basic operator overloading by using special names for methods:
  For example, to overload addition (+), create a method __add__.
*/

class Animal{
    private @peek string name;
    private @peek int age;
    
    static Animal new(string name, int age){
        // You can construct a class like a struct.
        // Only flaw in this encapsulation design is that you can build
        // a class without a constructor, so without security checks.
        return Animal{name, age};
    }
    
    virtual string to_string(){
        // "this" is a pointer to the object calling the method
        return format("%s : %d yo", this.name, this.age);
    }
}

// Child class of Animal
class Pet : Animal{
    uint owner_count;
    string* owners;
    
    /*
    * Variable arguments
    * Allocate extra stack memory for class
    */
    static Pet new(string name, int age, ...count) : @stack_alloc(sizeof(string) * count) {
        this.name = name;
        this.age = age;
        this.owner_count = count;
        this.owners = @stack_alloc;
        char** vargs = VARGS;
        for(int i = 0; i < count; i++)
            owners[i] = vargs[i];
    }
    
    virtual string to_string(){
        return super() + format(", %d owners", this.name, this.age);
    }
}

```
