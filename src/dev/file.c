#include "libs.h"
#include "types.h"

bool file_read(file_t* file){
    if(!file){
        HC_PRINT("FILE : Invalid file\n");
        return false;
    }
    HC_FILE fptr = HC_FOPEN_READ(file->file_name);
    if(!HC_GOOD_FILE(fptr)){
        HC_FILE_ERR("FILE : Failed to open file");
    }
    file->size = HC_FILE_SZ(fptr);
    file->data = HC_MALLOC(file->size + 2);
    if(!file->data){
        HC_PRINT("FILE : Failed to allocate %lu bytes\n",file->size);
        return false;
    }
    file->data[0] = '\0';
    if(!HC_GOOD_FREAD(fptr, file->data+1, file->size)){
        HC_PRINT("FILE : Failed to read file\n");
    }
    file->data[file->size] = '\0';
    return true;
}

void file_destroy(file_t* file){
    if(!file)
        HC_PRINT("FILE : Invalid file\n");

}
