#include "std/stdlib.hhc"

const float FP_PRECISION = 0.001;

int main(uint argc, char** argv){
    float pi = 3.1415;
    println("round(%f, FP_NEAREST)  = %f", pi, round(pi));
    println("round(%f, FP_DOWN)     = %f", pi, round(pi, FP_DOWN));
    println("round(%f, FP_UP)       = %f", pi, round(pi, FP_UP));
    println("round(%f, FP_ZERO)     = %f", pi, round(pi, FP_ZERO));
}
