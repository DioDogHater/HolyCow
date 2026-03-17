#include "../std/stdlib.hhc"

float FP_PRECISION = 0.0001;

// Prints a frame around lines of text (with a title)
void frame(char* title = "", ...count){
    // Variable arguments
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

    // Add 4 characters of padding
    max_len += 4;

    // Print top of frame
    if(!*title){ println("+%*c+", max_len, '-'); }
    // If there's a title, print it centered at the top
    else{ println("+%[ %s %*C+", title, max_len, '-'); }
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

union msg_contents {
    char* text;
    uint integer;
    float number;
    bool confirm;
}

#define MSG_TEXT    0
#define MSG_INT     1
#define MSG_NUMBER  2
#define MSG_CONFIRM 3
struct msg {
    uint type;
    msg_contents contents;
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
    if(m.type == MSG_TEXT)
        println("msg{%u, \"%s\"}", m.type, m.contents.text);
    else if(m.type == MSG_INT)
        println("msg{%u, %i}", m.type, m.contents.integer);
    else if(m.type == MSG_NUMBER)
        println("msg{%u, %f}", m.type, m.contents.number);
    else
        println("msg{%u, %b}", m.type, m.contents.confirm);
}

int main(uint argc, char** argv){
    float pi = PI;
    float almost_pi = 3.14153;

    if(pi ~= almost_pi){
        println("%*f ~= %*f ± %f", 10, pi, 10, almost_pi, FP_PRECISION);
    }

    frame("Foo tierlist", "1. Foo", "2. Bar", "3. Foo-bar");

    test a = test{, 6, test2{"Hello world!", "Foo bar"}};
    print_test(a);
    print_test(get_test());

    msg m = msg{MSG_TEXT, msg_contents.text{"Hello world!"}};
    print_msg(&m);
}
