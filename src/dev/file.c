#include "libs.h"
#include "types.h"

bool file_read(file_t* file){
    if(!file){
        HC_ERR("FILE : Invalid file");
        return false;
    }
    HC_FILE fptr = HC_FOPEN_READ(file->file_name);
    if(!HC_GOOD_FILE(fptr)){
        HC_ERR("FILE : Failed to open file \"%s\"",file->file_name);
        HC_FILE_ERR("=> ");
        return false;
    }
    file->size = HC_FILE_SZ(fptr);
    file->data = HC_MALLOC(file->size + 2 + sizeof(const uint8_t*)) + 1 + sizeof(const uint8_t*);
    if(!file->data){
        HC_ERR("FILE : Failed to allocate %lu bytes",file->size);
        return false;
    }
    *(file->data - 1) = '\0';
    if(!HC_GOOD_FREAD(fptr, file->data, file->size)){
        HC_ERR("FILE : Failed to read file of size %lu bytes",file->size);
    }
    file->data[file->size - 1] = '\0';
    GET_FILENAME(file->data - 1) = file->file_name;
    HC_FCLOSE(fptr);
    return true;
}

void file_destroy(file_t* file){
    if(!file)
        HC_ERR("FILE : Invalid file");
    if(file->next)
        file_destroy(file->next);
    if(file->data)
        HC_FREE(file->data - 1 - sizeof(const uint8_t*));
    file->size = 0;
}
