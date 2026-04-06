#include "../std/stdlib.hhc"

double FP_PRECISION = 0.0001;

// Prints a frame around lines of text (with a title)
void frame(char* title = "", ...count){
    // Variable arguments (should all be strings)
    char** vargs = (char**) VARGS;

    // Length of longest string in frame
    uint max_len = strlen(title);

    // Measure each string's length
    uint i = 0;
    repeat(count){
        uint len = strlen(vargs[i]);
        if(len > max_len){ max_len = len; }
        ++i;
    }

    // Add 4 characters of padding (2 on both sides)
    max_len += 4;

    // Print top of frame
    if(*title == 0)
        println("+%*c+", max_len, '-');
    // If there's a title, print it centered at the top
    else
        println("+%[ %s %*C+", title, max_len, '-');
    // Print each line of the frame
    repeat(count){
        println("|%[ %s%L|", *vargs, max_len);
        vargs += 8;
    }
    // Print bottom of the frame
    println("+%*c+", max_len, '-');
}

variant msg_data {
    char* text;
    int integer;
    float number;
    bool confirm;
}

class msg {
    // Can only be changed inside msg's methods
    // but can be read / pointed to from anywhere. (@peek)
    private @peek msg_data data = msg_data.integer{ 0 };

    // Setters
    void set_text(char* txt){
        this.data = msg_data.text{ txt };
    }
    void set_integer(int i){
        this.data = msg_data.integer{ i };
    }
    void set_number(float n){
        this.data = msg_data.number{ n };
    }
    void set_confirm(bool b){
        this.data = msg_data.confirm{ b };
    }

    void print(){
        // Members of a class can be accessed with the "this"
        // variable in its methods. "this" is a pointer to the
        // object calling the method.

        if(this.data.type == msg_data.text)
            println("msg{\"%s\"}", this.data.text);
        else if(this.data.type == msg_data.integer)
            println("msg{%i}", this.data.integer);
        else if(this.data.type == msg_data.number)
            println("msg{%f}", this.data.number);
        else if(this.data.type == msg_data.confirm)
            println("msg{%b}", this.data.confirm);
        else
            println("msg{INVALID}");
    }
}

struct test;

struct test2{
    char* msg1;
    char* msg2;
}

struct test{
    int x = 0;
    int y = 0;
    test2 z;
}

// More procedural approach to objects, while still
// retaining the organisation and encapsulation aspects of classes
module test {
    void greet(){
        println("Hello world!");
    }

    test get(){
        // When a function returns a struct,
        // @return is a pointer to the returned struct
        @return.x = 12345;
        @return.y = 256;
        @return.z = test2{ "Foo", "Bar" };
    }

    // Yes, modules support encapsulation.
    // Private and protected both make variables and functions
    // only accessible from within the module itself.
    private void print_test2(test2 t){
        print("test2{\"%s\", \"%s\"}", t.msg1, t.msg2);
    }

    void print(test t){
        print("test{%u, %u, ", t.x, t.y);
        test.print_test2(t.z);
        println("}");
    }
}

int main(uint argc, char** argv){
    double pi = PI;
    double almost_pi = 3.14153;

    if(pi ~= almost_pi)
        println("%*f ~= %*f ± %f", 10, pi, 10, almost_pi, FP_PRECISION);

    frame("Foo tierlist", "1. Foo", "2. Bar", "3. Foo-bar");

    test a = test{6, , test2{"Hello world!", "Foo bar"}};
    test.print(a);
    test.print(test.get());

    msg m = msg{};
    m.print();

    m.set_text("Hello world!");
    m.print();

    m.set_number(6.67);
    m.print();

    m.set_confirm(false);
    m.print();
}
