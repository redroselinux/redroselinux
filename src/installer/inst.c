#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include "inst.h"
#include "log.h"
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include "mem.h"

int exec_no_shell(const char* cmd_str) {
  char* cmd = strdup(cmd_str);
  int cap = 8, count = 0;
  char** argv = alloc_size_arr(char*, cap);
  char* saveptr;
  char* tok = strtok_r(cmd, " ", &saveptr);
  while (tok) {
    if (count + 1 >= cap) { cap *= 2; argv = resize_size_arr(argv, char*, cap); }
    argv[count++] = tok;
    tok = strtok_r(NULL, " ", &saveptr);
  }
  argv[count] = NULL;

  pid_t pid = fork();
  if (pid < 0) {
    error("Failed to fork!");
    free(argv);
    free(cmd);
    return -1;
  }

  if (pid == 0) {
    execvp(argv[0], argv);
    _exit(127);
  }

  int status;
  waitpid(pid, &status, 0);
  free(argv);
  free(cmd);
  return WIFEXITED(status) ? WEXITSTATUS(status) : -1;
}

InstallStepResult run_step(InstallStep* step) {
  char message[strlen(step->message) + 5];
  snprintf(message, sizeof(message), "\033[1m%s\033[0m", step->message);
  info(message);
  fputs("\033[0m", stdout);
  return step->func(step);
}

InstallStepResult mkresult(int success, char* message) {
  InstallStepResult result;
  result.success = success;
  result.message = message;
  return result;
}

void print_result(InstallStepResult* result) {
  if (result->success) {
    ok(result->message);
  } else {
    error(result->message);
  }
}

InstallStepResult wipe_func(struct InstallStep* step) {
  InstallStepResult result;
  (void)step;

  const char* prefix = "sgdisk --zap-all /dev/";
  char command[strlen(step->args[0]) + strlen(prefix) + 1];
  snprintf(command, sizeof(command), "%s%s", prefix, step->args[0]);

  result.success = exec_no_shell(command) == 0;
  result = mkresult(
    result.success,
    result.success ? "Wiped successfully!" : "Failed to wipe!"
  );

  return result;
}
