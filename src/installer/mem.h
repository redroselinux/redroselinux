#pragma once

#include <stdlib.h>

void* alloc(size_t size);
void* resize(void* mem, size_t new_size);
void free_arr(void *devs);

#define alloc_size(type) ((type *)alloc(sizeof(type)))
#define alloc_size_arr(type, n) ((type *)alloc(sizeof(type) * (n)))
#define resize_size(mem, type) ((type *)resize(mem, sizeof(type)))
#define resize_size_arr(mem, type, n) ((type *)resize(mem, sizeof(type) * (n)))
