#include "std/stdlib.hhc"

const float FP_PRECISION = 0.001;

void table(char* title = "", ...count){
    char** vargs = (char**) VARGS;
    uint max_len = strlen(title);
    uint i = 0;
    repeat(count){
        uint len = strlen((char*)vargs[i]);
        if(len > max_len){ max_len = len; }
        ++i;
    }
    max_len += 4;
    println("+%[ %s %*C+", title, max_len, '-');
    repeat(count){
        println("|%[ %s%L|", *vargs, max_len);
        vargs += 8;
    }
    println("+%*c+", max_len, '-');
}

int main(uint argc, char** argv){
    float pi = 3.14150;
    float almost_pi = 3.14155;

    if(pi ~= almost_pi){
        println("%*f ~= %*f", 5, pi, 5, almost_pi);
    }

    table("Foo tierlist", "1. Foo", "2. Bar", "3. Foo-bar");

    println("round(%f, FP_ROUND) = %f", pi, round(pi));
    println("round(%f, FP_FLOOR) = %f", pi, round(pi, FP_FLOOR));
    println("round(%f, FP_CEIL)  = %f", pi, round(pi, FP_CEIL));
    println("round(%f, FP_TRUNC) = %f", pi, round(pi, FP_TRUNC));
}
