# The Holy Cow programming language
is a language inspire by ***Holy C***, the legendary language created by **Terry A. Davis*,
one of the greatest programmers of all time. This is not a copy or an attempt to remake it,
only a language that draws some features from it, with compatibility outside of **TempleOS**.

# Requirements
For now, you can only use the language with **Linux**, but compatibility is an issue I'm willing to work on.
You will need the *cmake* build platform and a C compiler.

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
- void (only for pointers and functions)
- u8 or char, i8
- u16, i16
- u32, i32
- u64, i64
- f64 (floating point number)
- bit or flag (a bit / flag is a boolean that occupies a single bit, only efficient if you need 4 or more of them, they have names though)
- bool (same as u8, but with extra features)
- string (same as char*), but cleaner and more features
- pointer (type*), same as C syntax
*/

string x = "Hello world!\n";
i16 my_variable = 0;

// Macros
#define twenty_five = "twenty_five"

// Constant expression
#const f32 five_over_2 = 5 / 2;

// Functions can have default values
void hello_world(string msg = x){
    // Displays a string on screen
    printf(x);
    
    // Gets a value from stdin (input)
    i64 value;
    if(!getf("%d",&value))
        fail("Invalid integer value.");
    
    // Switch statements
    switch(value){
    case 0 .. 5:
        printf("Between 0 and 5\n");
    case 6 || 7:
        printf("6... 7?")
    default:
        printf("Value: %d\n",value);
    }
    
    // While loop
    while(true){
        
    }
}

```
