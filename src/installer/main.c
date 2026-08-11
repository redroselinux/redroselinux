#define _DEFAULT_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include "ui.h"
#include "log.h"
#include "drive.h"
#include "inst.h"
#include <sys/ioctl.h>
#include <sys/reboot.h>
#include <unistd.h>

#define FREE_ALL() do { \
  free(user); \
  free(drive); \
  free(hostname); \
  free(timezone); \
  free(password); \
  free(root_password); \
  free(keyboard); \
} while(0)

// rewriting, this time without memory leaks :fire: - mostypc123 on Aug 3 2026 20:54 UTC+2
// first segfault - Aug 3 2026 22:12
// second segfault - Aug 3 2026 ~21:20
// six segfaults so far - Aug 10 2026 0:24

int main() {
  goto body;

body:
  struct winsize window;
  ioctl(STDOUT_FILENO, TIOCGWINSZ, &window);

  print_welcome(window);

  puts("Welcome to the Redrose Linux alpha-0.7 installer! It was recently rewritten.");

  char* input = ask("Manual [m] or guided [g] installation? [default: g]");

  if (input[0] == 'm') {
    info("Replacing current process with /bin/sh");
    execv("/bin/sh", (char *const[]){"/bin/sh", NULL});
  }
  // no checks for g, cos g is default anyway and it does nothing in here

  free(input);

  print_settings_header(window);

  char* drive = ask_blkdev();
  char* timezone = ask_with_default("Timezone (Region/City) [Europe/London]", "Europe/London");
  char* keyboard = ask_with_default("Keyboard layout [us]", "us");
  char* hostname = ask_with_default("Hostname [iuseredrosebtw]", "iuseredrosebtw");
  char* user = ask_with_default("Username [redrose]", "redrose");
  char* password = password_ask("User password [redrose]", "redrose");
  char* root_password = password_ask("Root password [redrose]", "redrose");
  char* coreutils_type = ask_with_default("Coreutils to install? [gnu] (gnu/uutils/busybox)", "gnu");

  print_installing(window);
  char* confirm = ask("Confirm installation? [Y/n]");
  if (!(confirm[0] == 'y' || confirm[0] == 'Y' || confirm[0] == '\0')) {
    error("Installation cancelled.");
    info("Press ENTER to restart installation");
    getchar();
    FREE_ALL();
    goto body;
  }
  free(confirm);

  print_installing(window);

  {
    InstallStep wipe = {
      .message = "Wiping all contents of the selected drive!",
      .func = wipe_func,
      .args = (char*[]){drive, NULL},
    };
    step(&wipe);
  }

  {
    InstallStep make_partitions = {
      .message = "Creating partitions!",
      .func = make_partitions_func,
      .args = (char*[]){drive, NULL},
    };
    step(&make_partitions);
  }

  {
    InstallStep make_filesystems = {
      .message = "Creating filesystems!",
      .func = make_filesystems_func,
      .args = (char*[]){drive, NULL},
    };
    step(&make_filesystems);
  }

  {
    InstallStep mount_rootfs = {
      .message = "Mounting root!",
      .func = mount_rootfs_func,
      .args = (char*[]){drive, NULL},
    };
    step(&mount_rootfs);
  }

  {
    InstallStep copy_rootfs_tgz = {
      .message = "Extracting base system!",
      .func = copy_rootfs_func,
      .args = (char*[]){drive, NULL},
    };
    step(&copy_rootfs_tgz);
  }

  {
    InstallStep install_coreutils = {
      .message = "Installing coreutils!",
      .func = install_coreutils_func,
      .args = (char*[]){coreutils_type, NULL},
    };
    step(&install_coreutils);
  }

  {
    InstallStep add_user_and_pwds = {
      .message = "Adding user and setting passwords!",
      .func = add_user_and_pwds_func,
      .args = (char*[]){user, password, root_password, NULL},
    };
    step(&add_user_and_pwds);
  }

  {
    InstallStep set_hostname = {
      .message = "Setting hostname!",
      .func = set_hostname_func,
      .args = (char*[]){hostname, NULL},
    };
    step(&set_hostname);
  }

  {
    InstallStep install_grub = {
      .message = "Installing GRUB!",
      .func = grub_install_func,
      .args = (char*[]){drive, NULL},
    };
    step(&install_grub);
  }

  {
    InstallStep init_car = {
      .message = "Initializing Car!",
      .func = init_car_func,
      .args = (char*[]){NULL},
    };
    step(&init_car);
  }

  free(user);
  free(drive);
  free(hostname);
  free(timezone);
  free(password);
  free(root_password);
  free(keyboard);
  free(coreutils_type);

  (void)ask(NULL);

  print_installed(window);

  {
    char* confirm = ask_with_default("Do you want to chroot to the newly installed system? [y/N]", "N");

    if (confirm[0] == 'y' || confirm[0] == 'Y') {
      run_in_chroot_shell("/bin/sh"); 
    }

    free(confirm);
  }

  print_installed(window);

  done("Installation finished. Press ENTER to reboot.");
  (void)getchar();

  sync();
  reboot(RB_AUTOBOOT);

  // not reached!
  return 0;
}
