#include "std/stdlib.hhc"

// Recursive solution (really slow)
// My function calling system sucks performance wise for now
// Might not help that this recursive algorithm is already unoptimized
uint fibo_recursive(int n){
    if(n == 0){
        return 0;
    }else if(n == 1){
        return 1;
    }
    return fibo_recursive(n-1) + fibo_recursive(n-2);
}

// Iterative solution (way faster)
uint fibo_iterative(int n){
    if(n == 0){
        return 0;
    }
    uint a = 0;
    uint b = 1;
    uint tmp = 0;
    repeat(n - 1){
        tmp = a + b;
        a = b;
        b = tmp;
    }
    return b;
}

int main(uint argc, char** argv){
    char buffer[32];
    print_str("This program calculates the nth fibonacci number.\nPlease enter n: ");
    uint len = input(buffer, 32);
    int n = string_to_int(buffer, len);
    if(n < 0){
        print_str("n must be >= 0\n");
        return;
    }
    println("The %ith fibonacci number is %u", n, fibo_iterative(n));
}
