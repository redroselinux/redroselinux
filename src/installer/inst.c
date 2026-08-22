#define _POSIX_C_SOURCE 200809L
#define _DEFAULT_SOURCE

#include <stdio.h>
#include <sys/reboot.h>
#include <sys/stat.h>
#include "inst.h"
#include "log.h"
#include "ui.h"
#include "drive.h"
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/mount.h>
#include <errno.h>
#include "mem.h"

// Set to 0 if you do not want exec_* functions to write the command to be exec'd
static int exec_funcs_print_command = 1;

/* Wrapper of system() that also prints the command to run. */
int exec_shell(const char* cmd_str) {
  if (exec_funcs_print_command)
    printf(" \033[2m→ %s\033[0m\n", cmd_str);
  return system(cmd_str);
}

/* Execute a comand without a shell wihout the mess of fork and arrays for argv. */
int exec_no_shell(const char* cmd_str) {
  if (exec_funcs_print_command)
    printf(" \033[2m→ %s\033[0m\n", cmd_str);

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

/* The same function as above but it takes a NULL terminated array. */
int exec_no_shell_arr(char* const argv[]) {
  if (exec_funcs_print_command) {
    printf(" \033[2m→");
    int one_disable = 0;
    for (int i = 0; argv[i]; i++) {
      if (!strcmp(argv[i], "/bin/sh") || !strcmp(argv[i], "chroot")) {
        one_disable = 1; // skip -c
        continue;
      }

      if (
        strcmp(argv[i], "busybox") != 0 &&
        !one_disable
      )
        printf(" %s", argv[i]);

      if (one_disable) one_disable = 0;
    }
    printf("\033[0m\n");
  }

  pid_t pid = fork();
  if (pid < 0) {
    error("Failed to fork!");
    return -1;
  }

  if (pid == 0) {
    execvp(argv[0], argv);
    _exit(127);
  }

  int status;
  waitpid(pid, &status, 0);
  return WIFEXITED(status) ? WEXITSTATUS(status) : -1;
}

InstallStepResult run_step(InstallStep* step) {
  printf("\033[94m→\033[0m \033[1m%s\033[0m\n", step->message);
  return step->func(step);
}

/* Simple helper to return an InstallStepResult with values. */
InstallStepResult mkresult(int success, char* message) {
  InstallStepResult result;
  result.success = success;
  result.message = message;
  return result;
}

/* Print data from an InstallStepResult.
 * Takes a pointer; prefix the argument with &.
 */
void print_result(InstallStepResult* result) {
  if (result->success) {
    if (result->message)
      printf("\033[92m→\033[0m \033[1m%s\033[0m\n\n", result->message);
  } else {
    if (result->message)
      printf("\033[91mx\033[0m \033[1m%s\033[0m\n", result->message);
    char* confirm = ask_with_default("Do you want to continue to the next step anyway? [y/N]", "N");
    if (confirm[0] == 'N' || confirm[0] == 'n') {
      info("Press ENTER to reboot");
      (void)getchar();

      sync();
      reboot(RB_AUTOBOOT);
    }
    free(confirm);
  }
}

void step(InstallStep* step) {
  auto result = run_step(step);
  print_result(&result);
}

/* Wipe the drive. To be used with an InstallStep.
 * InstallStep args:
 *   0: drive, for example sda
 */
InstallStepResult wipe_func(struct InstallStep* step) {
  InstallStepResult result;

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

/* returns 1 if EFI, 0 if BIOS */
int efi_or_bios() {
  return access("/sys/firmware/efi", F_OK) == 0;
}

/* Create partitions. To be used with an InstallStep.
 * InstallStep args:
 *   0: drive, for example sda
 */
InstallStepResult make_partitions_func(struct InstallStep* step) {
  InstallStepResult result;

  // Unlike the old installer, we will now use a sane partitioning scheme:
  // /dev/...1: Root partition
  // /dev/...2: EFI/BIOS boot partition

  if (efi_or_bios()) {
    const char* prefix = "sgdisk --new=2:0:+512M -t 2:ef01 /dev/";
    char command[strlen(step->args[0]) + strlen(prefix) + 1];
    snprintf(command, sizeof(command), "%s%s", prefix, step->args[0]);
    if (exec_no_shell(command) != 0) {
      return mkresult(0, "Failed to create EFI boot partition!");
    }
  } else {
    const char* prefix = "sgdisk --new=2:0:+1M -t 2:ef02 /dev/";
    char command[strlen(step->args[0]) + strlen(prefix) + 1];
    snprintf(command, sizeof(command), "%s%s", prefix, step->args[0]);
    if (exec_no_shell(command) != 0) {
      return mkresult(0, "Failed to create BIOS boot partition!");
    }
  }

  /* root partition */ {
    const char* prefix = "sgdisk -n 1:0:0 -t 1:8300 /dev/";
    char command[strlen(step->args[0]) + strlen(prefix) + 1];
    snprintf(command, sizeof(command), "%s%s", prefix, step->args[0]);
    if (exec_no_shell(command) != 0) {
      return mkresult(0, "Failed to create root partition!");
    }
  }

  /* probe parts */ {
    if (exec_no_shell("busybox partprobe") != 0) {
      return mkresult(0, "Failed to probe partitions!");
    }
  }

  result = mkresult(1, "Partitions created successfully!");

  return result;
}

/* Create filesystems. To be used with an InstallStep.
 * InstallStep args:
 *   0: drive, for example sda
 */
InstallStepResult make_filesystems_func(struct InstallStep* step) {
  InstallStepResult result;

  // step->args[0] does not include /dev/
  const char sdev[] = "/dev/";
  char full_dev[strlen(sdev) + strlen(step->args[0]) + 1];
  snprintf(full_dev, sizeof(full_dev), "%s%s", sdev, step->args[0]);

  char root[64], bios_efi[64];
  strcpy(root, get_partition(full_dev, 1));
  strcpy(bios_efi, get_partition(full_dev, 2));

  /* ESP */ if (efi_or_bios()) {
    const char* prefix = "mkfs.vfat -F 32 ";
    char command[strlen(prefix) + strlen(bios_efi) + 1];
    snprintf(command, sizeof(command), "%s%s", prefix, bios_efi);
    if (exec_no_shell(command) != 0) {
      return mkresult(0, "Failed to create EFI/BIOS boot partition!");
    }
  }

  /* root partition */ {
    const char* prefix = "mkfs.ext4 -F ";
    char command[strlen(prefix) + strlen(root) + 1];
    snprintf(command, sizeof(command), "%s%s", prefix, root);
    fflush(stdout);
    if (exec_no_shell(command) != 0) {
      return mkresult(0, "Failed to create root partition!");
    }
  }

  result = mkresult(1, "Filesystems created successfully!");

  return result;
}

/* Mount the root filesystem. To be used with an InstallStep.
 * InstallStep args:
 *   0: drive, for example sda
 */
InstallStepResult mount_rootfs_func(struct InstallStep* step) {
  InstallStepResult result;

  const char* part = get_partition(step->args[0], 1);
  const char sdev[] = "/dev/";
  char full_dev[strlen(sdev) + strlen(part) + 1];
  snprintf(full_dev, sizeof(full_dev), "%s%s", sdev, part);

  if (mount(full_dev, "/mnt", "ext4", 0, NULL) != 0) {
    result.success = 0;
    result.message = "Failed to mount root!";
    perror("mount");
  } else {
    result.success = 1;
    result.message = "Root mounted successfully!";
  }

  return result;
}

/* Copy the root filesystem. To be used with an InstallStep.
 * InstallStep args:
 *   0: drive, for example sda
 */
InstallStepResult copy_rootfs_func(struct InstallStep* step) {
  InstallStepResult result;
  (void)step;

  puts(" This can take some time...");
  result.success = exec_no_shell(
    "busybox tar -zxf rootfs.tar.gz -C /mnt --strip-components=1"
  ) == 0;

  result = mkresult(
    result.success,
    result.success ?
      "Rootfs copied successfully!" :
      "Failed to copy rootfs!"
  );

  return result;
}

/* Simple helper to run a shell command in a chroot to /mnt. */
int run_in_chroot_shell(const char* cmd_str) {
  if (exec_funcs_print_command)
    fputs(" \033[33mchroot\033[0m", stdout);

  return exec_no_shell_arr(
    (char* const[]){"busybox", "chroot", "/mnt",
    "/bin/sh", "-c", (char*)cmd_str, NULL}
  );
}

/* Simple wrapper of run_in_chroot_shell with bind mounts. */
int run_in_chroot_shell_with_bind_mnt(const char* cmd_str) {
  int print_command = 1;
  if (!exec_funcs_print_command) {
    print_command = 0;
  }

  if (print_command) {
    printf(" \033[93mbmnt chroot\033[0m \033[2m→ %s\033[0m\n", cmd_str);
  }

  const char* bind_mount_commands =
    "busybox mkdir -p /mnt/proc && mount --bind /proc /mnt/proc && "
    "busybox mkdir -p /mnt/sys  && mount --bind /sys /mnt/sys && "
    "busybox mkdir -p /mnt/dev  && mount --bind /dev /mnt/dev";
  if (system(bind_mount_commands) != 0) {
    error("Failed to bind-mount /proc, /sys and /dev.");
    return -1;
  }

  // supress the print of the whole, huge command.
  exec_funcs_print_command = 0;
  int result = run_in_chroot_shell(cmd_str);
  exec_funcs_print_command = print_command; //old value

  const char* binds_umount_commands =
    "busybox umount /mnt/dev && "
    "busybox umount /mnt/sys && "
    "busybox umount /mnt/proc";
  if (system(binds_umount_commands) != 0) {
    error("Failed to umount /mnt/proc, /mnt/sys and /mnt/dev.");
    return -1;
  }

  return result;
}

/* Install coreutils from one of the tarballs. To be used with an InstallStep. */
InstallStepResult install_coreutils_func(struct InstallStep* step) {
  InstallStepResult result;

  // TODO: redrose currently requires busybox regardless of what you slap on top
  // TODO: in alpha-0.9, we will remove ALL busybox unless user selects it here
  if (run_in_chroot_shell("/bin/busybox --install") != 0) {
    result = mkresult(0, "Failed to install busybox!");
    return result;
  }

  if (!strcmp(step->args[0], "gnu")) {
    puts(" This can take some time...");
    result.success = exec_shell(
      "busybox tar -xf /coreutils-gnu/coreutils.tar.gz -C /mnt --strip-components=1 &&"
      "busybox tar -xf /coreutils-gnu/findutils.tar.gz -C /mnt --strip-components=1"
    ) == 0;
  } else if (!strcmp(step->args[0], "uutils")) {
    puts(" This can take some time...");
    result.success = exec_shell(
      "busybox tar -xf /coreutils-uutils/uu-coreutils.tar.gz -C /mnt --strip-components=1 &&"
      "busybox tar -xf /coreutils-uutils/uu-findutils.tar.gz -C /mnt --strip-components=1"
    ) == 0;
  } else {
    result.success = 1; // busybox is already installed
  }

  result = mkresult(
    result.success,
    result.success ?
      "Coreutils installed successfully!" :
      "Failed to install coreutils!"
  );

  return result;
}

int create_file(const char* path, const char* content) {
  FILE* file = fopen(path, "w");
  if (file == NULL) {
    perror("fopen");
    return -1;
  }
  fputs(content, file);
  fclose(file);
  return 0;
}

void sanitize_shell_chars(char *s) {
  static const char *metachars = ";&|()<>$`\\\"'*?[]{}~#!\n";
  for (char *p = s; *p; p++) {
    if (strchr(metachars, *p)) {
      *p = '.';
      warn("Replacing shell metacharacter with '.'!");
    }
  }
}

InstallStepResult add_user_and_pwds_func(struct InstallStep* step) {
  char* user = step->args[0];
  char* password = step->args[1];
  char* root_password = step->args[2];

  sanitize_shell_chars(user);
  sanitize_shell_chars(password);
  sanitize_shell_chars(root_password);

  const _Bool create_user = strcmp(user, "__.do_not_create_user.__");

  if (create_file("/mnt/etc/group", "") != 0) {
    return mkresult(0, "Failed to create /etc/group");
  }

  char command[1024];

  // create dirs
  if (mkdir("/mnt/home", 0755) != 0) {
    if (errno != EEXIST) {
      perror("mkdir");
      return mkresult(0, "Failed to create home directory!");
    }
  }

  if (mkdir("/mnt/root", 0755) != 0) {
    if (errno != EEXIST) {
      perror("mkdir");
      return mkresult(0, "Failed to create root directory!");
    }
  }

  if (create_user) {
    // why not reuse the buffer for the home dir :fire:
    snprintf(command, sizeof(command), "/mnt/home/%s", user);
    if (mkdir(command, 0755) != 0) {
      if (errno != EEXIST) {
        perror("mkdir");
        return mkresult(0, "Failed to create home directory for user!");
      }
    }

    snprintf(command, sizeof(command), "adduser -D %s", user);
    if (run_in_chroot_shell(command) != 0) {
      return mkresult(0, "Failed to add user!");
    }
  } else {
    warn("Not creating user other than root!");
  }

  warn("Not printing commands that are ran to set password for security!");
  // you can delete the below line for debugging the commnds
  exec_funcs_print_command = 0;

  if (create_user) {
    snprintf(command, sizeof(command), "echo '%s:%s' | chpasswd", user, password);
    if (run_in_chroot_shell(command) != 0) {
      return mkresult(0, "Failed to set password for user!");
    }
  }

  snprintf(command, sizeof(command), "echo 'root:%s' | chpasswd", root_password);
  if (run_in_chroot_shell(command) != 0) {
    return mkresult(0, "Failed to set root password!");
  }

  exec_funcs_print_command = 1;

  return mkresult(1, "User and passwords set successfully!");
}

InstallStepResult set_hostname_func(struct InstallStep* step) {
  if (create_file("/mnt/etc/hostname", step->args[0]) != 0) {
    return mkresult(0, "Failed to set hostname");
  }
  return mkresult(1, "Set hostname successfully!");
}

InstallStepResult init_car_func(struct InstallStep* step) {
  InstallStepResult result;
  (void)step;

  result.success = run_in_chroot_shell("car installer-init") == 0;

  char* confirm = ask_with_default("Do you want to disable SHA256 checks in Car? [N/y]", "N");
  if (!(confirm[0] == 'y' || confirm[0] == 'Y')) {
    if (create_file("/mnt/etc/car/sha256-enable", "") != 0) {
      return mkresult(0, "Failed to create /mnt/etc/car/sha256-enable.");
    }
  }
  free(confirm);

  result = mkresult(
    result.success,
    result.success ? "Initialized Car succesfully!" : "Failed to initialize Car!"
  );

  return result;
}

/* Helper to install grub. To be used with an InstallStep.
 * InstallStep args:
 *   0: drive
 */
InstallStepResult grub_install_func(struct InstallStep* step) {
  // grub sucks; i had to do this
  // symlinks vmlinuz to vmlinuz-linux and initrd.img to initramfs-linux.img
  // so that it detects 'linux' as a version and we do not have to fight
  // grub-mkconfig. kernel-switch handles kernel switching so nothing is
  // required to be done about kernel switching in grub itself.
  info("Symlinking kernel and initramfs so GRUB works");
  int symlink_result = run_in_chroot_shell(
    "ln -sf /boot/vmlinuz /boot/vmlinuz-linux && "
    "ln -sf /boot/initrd.img /boot/initramfs-linux.img"
  );
  if (symlink_result != 0)
    return mkresult(0, "Failed to symlink for GRUB compatibility!");
  // fun fact: grub made me go insane - mostypc123 at august 14th 2026 20:18

  const char* drive = step->args[0];
  const char sdev[] = "/dev/";
  char full_dev[strlen(sdev) + strlen(drive) + 1];
  snprintf(full_dev, sizeof(full_dev), "%s%s", sdev, drive);

  const char* prefix = "grub-install ";
  char command[strlen(prefix) + strlen(full_dev) + 1];
  snprintf(command, sizeof(command), "%s%s", prefix, full_dev);

  sanitize_shell_chars(full_dev);

  int grub_result = run_in_chroot_shell_with_bind_mnt(command);
  if (grub_result == -1) {
    return mkresult(0, NULL);
  } else if (grub_result != 0) {
    return mkresult(0, "Failed to execute command to install GRUB.");
  }

  grub_result = run_in_chroot_shell_with_bind_mnt("grub-mkconfig -o /boot/grub/grub.cfg");
  if (grub_result != 0) {
    return mkresult(0, "Failed to create GRUB config.");
  }

  return mkresult(1, "Successfully installed GRUB.");
}

InstallStepResult nullinitrd_regen_func(InstallStep* step) {
  InstallStepResult result;
  (void)step;

  result.success = run_in_chroot_shell_with_bind_mnt(
    "nullinitrd"
  ) == 0;
  result = mkresult(
    result.success,
    result.success ?
      "Succesfully generated initramfs!" :
      "Failed to generate initramfs!"    
  );

  return result;
} 

InstallStepResult mkfstab_regen_func(InstallStep* step) {
  InstallStepResult result;
  (void)step;

  result.success = run_in_chroot_shell_with_bind_mnt("mkfstab /") == 0;
  result = mkresult(
    result.success,
    result.success ? "Generated fstab!" : "Failed to generate fstab!"    
  );

  return result;
}

InstallStepResult dbus_setup_func(struct InstallStep* step) {
  InstallStepResult result;
  (void)step;

  result.success = run_in_chroot_shell(
    "addgroup -S nogroup && "
    "addgroup -S messagebus && "
    "adduser -S -H -s /usr/bin/nologin -G messagebus messagebus && "
    "chown root:messagebus /usr/libexec/dbus-daemon-launch-helper && "
    "chmod 4750 /usr/libexec/dbus-daemon-launch-helper"
  ) == 0;
  result = mkresult(
    result.success,
    result.success ?
      "Succesfully set up D-Bus!" :
      "Failed to set up D-Bus!"    
  );

  return result;
}

