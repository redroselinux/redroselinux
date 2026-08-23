#include <stdlib.h>
#include <unistd.h>
#include "log.h"
#include "mem.h"

/* Allocate memory with a NULL check for safety. */
void* alloc(size_t size) {
  void* result = malloc(size);
  if (result == NULL) {
    error("Failed to allocate memory! Dropping to infinite sleep.");
    for (;;) sleep(5000);
  }

  return result;
}

/* Resize memory with a NULL check for safety. */
void* resize(void* mem, size_t new_size) {
  void* result = realloc(mem, new_size);
  if (result == NULL) {
    error("Failed to allocate memory! Dropping to infinite sleep.");
    for (;;) sleep(5000);
  }

  return result;
}

/* Helper to free all pointers inside an array.
 * It loops until it finds NULL, otherwise you get a segfault. */
void free_arr(void *arr) {
  if (!arr)
    return;

  void **devs = arr;

  for (int i = 0; devs[i] != NULL; i++)
    free(devs[i]);

  free(devs);
}
