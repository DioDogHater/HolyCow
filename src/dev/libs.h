#ifndef HCC_LIBS_H
#define HCC_LIBS_H

#define MIN(x, y) ((x) < (y) ? (x) : (y))
#define MIN3(x,y,z) (MIN(MIN(x,y),z))
#define MAX(x, y) ((x) > (y) ? (x) : (y))
#define MAX3(x,y,z) (MAX(MAX(x,y),z))
#define CLAMP(x,a,b) (MIN(MAX(x,a),b))

#define KB 1024
#define MB 1048576

// Disable standard libraries
#ifndef NO_STDLIBS

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>

#define HC_PRINT(fmt, ...) printf(fmt,##__VA_ARGS__)
#define HC_ERR(fmt, ...) printf(fmt,##__VA_ARGS__)
#define HC_DEBUG_PRINT(v,fmt) printf(#v " = " fmt "\n", v)
#define HC_MALLOC(sz) malloc((sz))
#define HC_REALLOC(ptr, sz) realloc((ptr),(sz))
#define HC_FREE(ptr) free(ptr)


// FILE SYSTEM
typedef FILE* HC_FILE;
#define HC_GOOD_FILE(fptr) ((fptr) != NULL)
#define HC_FILE_ERR(msg) perror((msg))
#define HC_FOPEN_READ(str) fopen((const char*)(str), "rb")
#define HC_FOPEN_WRITE(str) fopen((const char*)(str), "wb")
#define HC_FILE_SZ HC_file_sz
static size_t HC_file_sz(HC_FILE file){
    fseek(file, 0L, SEEK_END);
    size_t sz = ftell(file);
    rewind(file);
    return sz;
}
#define HC_FREAD(fptr, buff, sz) fread((buff), 1, (sz), (fptr))
#define HC_GOOD_FREAD(fptr, buff, sz) (sz == HC_FREAD((fptr),(buff),(sz)))
#define HC_FCLOSE(fptr) fclose((fptr))

#endif

#endif
