#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* join_two_strings(const char* s1, const char* s2) {
  const size_t size = strlen(s1) + strlen(s2) + 1;
  char* result = malloc(size);
  snprintf(result, size, "%s%s", s1, s2);

  return result;
}
