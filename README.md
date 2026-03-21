# The Holy Cow programming language
is a language inspired by the ***C Programming Language***, ***Rust*** and
***Holy C***, the legendary language created by *Terry A. Davis*. This is
an attempt at making a more programmer-friendly C-like programming language
without delving too much in complex concepts. A simpler and enjoyable C++
is close to what I aim for.
<br></br>
### Code Quality
*I know there are many parts in the compiler where I repeat the same similar code structure multiple times. Trust me, making a general solution for seemingly similar problems will make my compiler even less optimized and more complicated than it already is. That said, there is still a lot of room for improvement in readability and clarity. This is exceptionally true for the generator part of my compiler.*
<br></br>
# Requirements
For now, you can only use the language with **Linux**, but compatibility is an issue I'm willing to work on.
You will need *cmake*, *make*, *nasm* and *ld* to start compiling right away.
<br></br>
# Building
```
git clone https://github.com/DioDogHater/HolyCow
cd HolyCow
cmake -S . -B ./build
cmake --build ./build
```
You can then run `./build/hcc` or `.\build\hcc.exe`
<br></br>
# Language Docs
I am currently writing detailed documentation of my language. I will add it to the repository when it will be decent / complete enough.\
*For now, reading the example programs is good enough to learn most features of the language.*
<br></br>
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
- float (32 bit floating point number)
- double (64 bit floating point number)
- bool (boolean as a single byte, 1 = true, 0 = false)
- string, type provided by standard library
- pointer (type*), same as C syntax
*/

string x = "Hello world!";
int16 my_variable = 0;

// Preprocessor directives
// Source files end with .hc
// Header files end with .hhc
#include "header_file.hhc"

// Simple find & replace macro
#define twenty_five "twenty_five"

// Parametric macro
#macro test(x, y) (x * y)

// It is possible to create modules (namespaces)
module test{
    // Now to access greet() you must use test.greet()
    void greet(){
        println("Hello!");
    }
}

// Constant expression
// Evaluated at compile-time, isn't stored in an actual variable
constexpr float five_over_2 = 5 / 2;

// Functions can have default values.
// In fact, you can make default values use variables that will be
// defined in the scope where they are called, but that is not
// recommended.
void hello_world(string msg = "Default"){
    // Displays a string on screen (can have formats)
    // "ln" -> adds a new line after printing
    println("%s", msg.str);
    
    // Gets a value from stdin (input)
    // try ... except ... is a way to handle exceptions
    int64 value;
    try{
        scan("%i", &value);
    }except{
        // error() is a println() + exit(EXIT_FAILURE)
        error("Invalid integer value.");
    }
    
    // If statements
    if(value > 100){
        if(value < 150)
            @next;              // Goes to the next condition
        println("%s", msg + "Huh?");
    }else if(value == 0){       // <- @next will jump here
        println("Null.");
    }elif(value == 1){
        println("")
    }else{
        println("Bro...");
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
        // Logical operators &&, ||, ! can be written as "and", "or", "not"
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
- Structures and unions are like C structs and unions, except their members
  can have default values (peak feature imo) and they need a name.

- Variants are unions, but with a built-in member that provides which member
  is currently stored in the variant object.
*/
struct Color {
    uint8 r = 0;
    uint8 g = 0;
    uint8 b = 0;
    uint8 a = 0;
}

union Data {
    uint integer;
    double number;
    bool boolean;
    void* pointer;
}

// To construct a union:
// union.member{ value (or nothing if default value is used) }
Data data = Data.integer{ 50 };

/*
    The built-in member holding the currently stored member is
    named "type".
    
    Constants will be defined to represent each member as a unique
    value (like an enum) automatically.
    These constants are in the namespace of the variant type.
    For example, in the "Message" type, these constants
    are defined to represent each member:
    Message.text, Message.integer, Message.color
*/
variant Message {
    char text[256];
    uint integer;
    Color color;
}

// A variant is constructed like a union
Message msg = Message.color{ Color{255} }
// Now, msg.type = Message.color

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
    // Attributes "name" and "age" will be accessible as read-only
    // publicly, but writable privately.
    private @peek string name;
    private @peek int age;
    
    static Animal new(string name, int age){
        /*
            You can construct a class like a struct.
            Only flaw in this encapsulation design is that you can build
            a class without a constructor, so without security checks.
        */
        return Animal{name, age};
    }
    
    // virtual -> can be overriden by children and will work even if
    // object is stored as its parent's type.
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
    - Variable arguments are supported.
    
    - Allocate extra stack memory for class.
      It's a dream, might not ever work.
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
