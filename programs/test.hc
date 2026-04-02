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

variant msg {
    char* text;
    uint integer;
    float number;
    bool confirm;
}

test get_test(){
    @return.x = 10;
    @return.y = 5;
    @return.z = test2{"Diddy", "Blud"};

    // or
    //return test{10, 5, test2{"Diddy", "Blud"}};
}

void print_test(test t){
    println("test{%i, %i, test2{\"%s\", \"%s\"}}", t.x, t.y, t.z.msg1, t.z.msg2);
}

void print_msg(msg* m){
    if(m.type == msg.text)
        println("msg{\"%s\"}", m.text);
    else if(m.type == msg.integer)
        println("msg{%i}", m.integer);
    else if(m.type == msg.number)
        println("msg{%f}", m.number);
    else
        println("msg{%b}", m.confirm);
}

int main(uint argc, char** argv){
    double pi = PI;
    double almost_pi = 3.14153;

    if(pi ~= almost_pi)
        println("%*f ~= %*f ± %f", 10, pi, 10, almost_pi, FP_PRECISION);

    frame("Foo tierlist", "1. Foo", "2. Bar", "3. Foo-bar");

    test a = test{, 6, test2{"Hello world!", "Foo bar"}};
    print_test(a);
    print_test(get_test());

    msg m = msg.text{ "Hello world!" };
    print_msg(&m);
    m = msg.number{ 105.025 };
    print_msg(&m);
    m = msg.integer{ 12345 };
    print_msg(&m);
    m = msg.confirm{ true };
    print_msg(&m);
}
