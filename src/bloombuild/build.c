#include "build.h"
#include "helpers.h"
#include <stdlib.h>

int build(const char* dir) {
  char* bloombuild_file = join_two_strings(dir, "/Bloombuild.manifest");

  free(bloombuild_file);
  return 0;
}
