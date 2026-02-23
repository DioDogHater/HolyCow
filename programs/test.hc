#include "std/stdlib.hhc"

const float FP_PRECISION = 0.001;

// Prints a frame around lines of text (with a title)
void frame(char* title = "", ...count){
    // Variable arguments
    char** vargs = (char**) VARGS;

    // Length of longest string in frame
    uint max_len = strlen(title);

    // Measure each string's length
    uint i = 0;
    repeat(count){
        uint len = strlen((char*)vargs[i]);
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

struct test{
    int x = 0;
    int y = 0;
}

int main(uint argc, char** argv){
    float pi = PI;
    float almost_pi = 3.14155;

    if(pi ~= almost_pi){
        println("%*f ~= %*f ± %f", 10, pi, 10, almost_pi, FP_PRECISION);
    }

    frame("Foo tierlist", "1. Foo", "2. Bar", "3. Foo-bar");

    println("round(%f, FP_ROUND) = %f", pi, round(pi));
    println("round(%f, FP_FLOOR) = %f", pi, round(pi, FP_FLOOR));
    println("round(%f, FP_CEIL)  = %f", pi, round(pi, FP_CEIL));
    println("round(%f, FP_TRUNC) = %f", pi, round(pi, FP_TRUNC));
}
