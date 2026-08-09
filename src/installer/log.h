#pragma once

#include <stdio.h>

#define CREATE_LOG(name, color, symbol) \
  static inline void name(const char *msg) { \
    printf("\033[1m" color symbol "\033[0m %s\n", msg); \
  }

CREATE_LOG(error, "\033[91m", "x")
CREATE_LOG(warn, "\033[93m", "!")
CREATE_LOG(ok, "\033[92m", "→")
CREATE_LOG(done, "\033[32m", "→")
CREATE_LOG(info, "\033[94m", "→")
CREATE_LOG(verbose, "\033[1m", "|")
