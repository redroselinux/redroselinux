#include "log.h"
#include "build.h"

#include <string.h>

#define __ARGC_CHECK(req) \
  if (argc == req) { \
    error("Not enough arguments provided."); \
    return 2; \
  }

int main(int argc, char** argv) {
  __ARGC_CHECK(1);

  if (!strcmp("build", argv[1])) {
    __ARGC_CHECK(2);
    return build(argv[3]);
  }
}
