#ifndef HCC_LIBS_H
#define HCC_LIBS_H

// Disable standard libraries
#ifndef NO_STDLIBS

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>

#include "style.h"

#define HC_PRINT(fmt, ...) printf(fmt,##__VA_ARGS__)
#define HC_WARN(fmt,...) printf(BOLD CYAN_FG "WARNING : " fmt RESET_ATTR "\n",##__VA_ARGS__)
#define HC_ERR(fmt, ...) printf(BOLD YELLOW_FG fmt RESET_ATTR "\n",##__VA_ARGS__)
#define HC_CONFIRM(fmt,...) printf(BOLD GREEN_FG fmt RESET_ATTR "\n",##__VA_ARGS__)
#define HC_DEBUG_PRINT(v,fmt) printf(#v " = " fmt "\n", v)
#define HC_MALLOC(sz) malloc((sz))
#define HC_REALLOC(ptr, sz) realloc((ptr),(sz))
#define HC_FREE(ptr) free(ptr)
#define HC_FAIL() exit(1)

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
#define HC_FPRINTF(fptr, fmt, ...) fprintf((fptr), (fmt),##__VA_ARGS__)
#define HC_FCLOSE(fptr) fclose((fptr))

#endif

#endif
