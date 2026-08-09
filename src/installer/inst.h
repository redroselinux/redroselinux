#pragma once

typedef struct InstallStepResult {
  int success;
  char* message;
} InstallStepResult;

typedef struct InstallStep {
  char* message;
  InstallStepResult (*func)(struct InstallStep*);
  char** args; // terminated with NULL!
} InstallStep;

InstallStepResult run_step(InstallStep* step);
InstallStepResult mkresult(int success, char* message);
void print_result(InstallStepResult* result);

InstallStepResult wipe_func(struct InstallStep* step);
