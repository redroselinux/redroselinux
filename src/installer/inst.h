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

int efi_or_bios();

int exec_no_shell_arr(char* const argv[]);
int exec_no_shell(const char* cmd_str);
int run_in_chroot_shell(const char* cmd_str);

InstallStepResult run_step(InstallStep* step);
InstallStepResult mkresult(int success, char* message);
void print_result(InstallStepResult* result);
void step(InstallStep* step);

InstallStepResult wipe_func(struct InstallStep* step);
InstallStepResult make_partitions_func(struct InstallStep* step);
InstallStepResult make_filesystems_func(struct InstallStep* step);
InstallStepResult mount_rootfs_func(struct InstallStep* step);
InstallStepResult copy_rootfs_func(struct InstallStep* step);
InstallStepResult install_coreutils_func(struct InstallStep* step);
InstallStepResult add_user_and_pwds_func(struct InstallStep* step);
InstallStepResult set_hostname_func(struct InstallStep* step);
InstallStepResult init_car_func(struct InstallStep* step);
InstallStepResult grub_install_func(struct InstallStep* step);

