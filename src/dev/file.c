#include "libs.h"
#include "types.h"

bool file_read(file_t* file){
    if(!file){
        HC_ERR("FILE : Invalid file\n");
        return false;
    }
    HC_FILE fptr = HC_FOPEN_READ(file->file_name);
    if(!HC_GOOD_FILE(fptr)){
        HC_FILE_ERR("FILE : Failed to open file");
        return false;
    }
    file->size = HC_FILE_SZ(fptr);
    file->data = HC_MALLOC(file->size + 2);
    if(!file->data){
        HC_ERR("FILE : Failed to allocate %lu bytes\n",file->size);
        return false;
    }
    file->data[0] = '\0';
    if(!HC_GOOD_FREAD(fptr, file->data+1, file->size)){
        HC_ERR("FILE : Failed to read file of size %lu bytes\n",file->size);
    }
    file->data[file->size] = '\0';
    HC_FCLOSE(fptr);
    return true;
}

void file_destroy(file_t* file){
    if(!file)
        HC_ERR("FILE : Invalid file\n");
    if(file->next){
        file_destroy(file->next);
        HC_FREE(file->next);
    }
    if(file->data)
        HC_FREE(file->data);
    file->size = 0;
}
