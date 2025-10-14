int a = 0;
int b = 1;

for(int i = 0; i < 5; i++){
    int c = a + b;
    a = b;
    b = c;
}

print("Result = %d\n", b);
