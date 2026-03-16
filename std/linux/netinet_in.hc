#define INADDR_ANY 0x0000
uint32 htonl(uint32 n){
    @asm("bswap %0\n\tmov [rbp+16], %0", n);
}

uint32 htons(uint16 n){
    @asm(ax, "mov ax, %0\n\txchg al, ah\t\nmov %0, ax", n);
}
