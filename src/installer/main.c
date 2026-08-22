#define _DEFAULT_SOURCE

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "ui.h"
#include "mem.h"
#include "log.h"
#include "drive.h"
#include "inst.h"
#include <sys/ioctl.h>
#include <sys/reboot.h>
#include <unistd.h>

#define FREE_ALL() do { \
  if (free_user) free(user); \
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
// back from a trip, almost done - Aug 22 2026 14:37
// eight segfaults so far - Aug 22 2026 18:37

int main() {
  goto body;

body:
  struct winsize window;
  ioctl(STDOUT_FILENO, TIOCGWINSZ, &window);

  print_welcome(&window);

  puts("Welcome to the Redrose Linux alpha-0.7 installer! It was recently rewritten.");

  char* input = ask("Manual [m] or guided [g] installation? [default: g]");

  if (input[0] == 'm') {
    info("Replacing current process with /bin/sh");
    execv("/bin/sh", (char *const[]){"/bin/sh", NULL});
  }
  // no checks for g, cos g is default anyway and it does nothing in here

  free(input);

  print_inst_to_header(&window);
  char* drive = ask_blkdev();
  
  print_localize_header(&window);
  char* timezone = ask_with_default("Timezone (Region/City) [Europe/London]", "Europe/London");
  char* keyboard = ask_with_default("Keyboard layout [us]", "us");
  
  print_usersetup_header(&window);

  char* user;
  _Bool free_user = 1;
  do {
    user = ask_with_default("Username [redrose]", "redrose");
    if (!strcmp(user, "root")) {
      warn("Your username cannot be 'root'.");
      char* confirm = ask_with_default("Do you only want to use the root account? [y/N]", "N");

      if (confirm[0] == 'y' || confirm[0] == 'Y') {
        free(user);
        user = (char*)"__.do_not_create_user.__";
        free_user = 0;
        // it was meant to be <--__.!__do__not__create__user__!.__--> this aint that bad
      } else {
        free(user);
        user = NULL;
      }

      free(confirm);
    }

    const size_t user_len = user ? strlen(user) : 0;
    if (user_len > 32 && user_len < 256) {
      warn("Username is longer than 32 characters, which many utilities cannot handle.");
      warn("You should set the username to a shorter one, or retype it if you're sure.");
      free(user);
      user = NULL;
    } else if (user_len > 256) {
      error("Usernames cannot be longer than 256 characters.");
      free(user);
      user = NULL;
    }
    
  } while (user == NULL);

  if (!strcmp("lea", user)) {
    puts("hi :3");
  } else if (!strcmp("mostypc123", user)) {
    puts("am i insane to write code that greets myself?");
  } else if (!strcmp("neo", user)) {
    puts("yo if you see this tell me lol :3");
  } 

  char* password = alloc(1); password[0] = '\0'; 
  if (free_user) {
    free(password);
    password = password_ask("User password [redrose]", "redrose");
  }
  char* root_password = password_ask("Root password [redrose]", "redrose");
  char* hostname = ask_with_default("Hostname [iuseredrosebtw]", "iuseredrosebtw");

  print_advanced_header(&window);
  char* coreutils_type = ask_with_default("Coreutils to install? [gnu] (gnu/uutils/busybox)", "gnu");
  
  int8_t install_grub = 1; // 2 if user used ? to ask what this question means
  do {
    char* confirm = ask_with_default("Do you want to install GRUB? [Y/n/?]", "Y");

    if (confirm[0] == 'N' || confirm[0] == 'n') {
      install_grub = 0;
    } else if (confirm[0] == 'y' || confirm[0] == 'Y') {
      install_grub = 1; // the var is already initialized, but this is used in
                        // case the user entered ? so we dont loop forever
    } else if (confirm[0] == '?') {
      install_grub = 2;

      info("You should only choose not to install GRUB if you are dual-booting and");
      info("you want the other operating system to handle booting Redrose Linux.");
      puts("");
      info("However, you should only do this if you know what you are doing. You");
      info("probably want to install GRUB if you do not know what this all means.");
    }

    free(confirm);
  } while (install_grub == 2);

  _Bool debug = 0;
  
  {
    char* confirm = ask_with_default("Do you want to use development mode? [y/N]", "N");

    if (confirm[0] == 'Y' || confirm[0] == 'y') {
      debug = 1;
    }

    free(confirm);
  }

  print_installing(&window);
  char* confirm = ask("Confirm installation? [Y/n]");
  if (!(confirm[0] == 'y' || confirm[0] == 'Y' || confirm[0] == '\0')) {
    error("Installation cancelled.");
    info("Press ENTER to restart installation");
    getchar();
    FREE_ALL();
    goto body;
  }
  free(confirm);

  print_installing(&window);

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
    InstallStep init_car = {
      .message = "Initializing Car!",
      .func = init_car_func,
      .args = (char*[]){NULL},
    };
    step(&init_car);
  }

  {
    InstallStep regen_initramfs = {
      .message = "Generating initramfs!",
      .func = nullinitrd_regen_func,
      .args = (char*[]){NULL}, 
    };
    step(&regen_initramfs);
  }

  if (install_grub) {
    InstallStep install_grub = {
      .message = "Installing GRUB!",
      .func = grub_install_func,
      .args = (char*[]){drive, NULL},
    };
    step(&install_grub);
  } else {
    puts("");
    warn("Not installing GRUB as of user's preference!");
    puts("");
  }

  {
    InstallStep regen_fstab = {
      .message = "Generating fstab!",
      .func = mkfstab_regen_func,
      .args = (char*[]){NULL},
    };
    step(&regen_fstab);
  }

  puts(
    "This step is temporary until alpha-0.8 where the ISO builder will be rewritten"
  ); {
    InstallStep dbus_user_setup = {
      .message = "Setting up D-Bus!",
      .func = dbus_setup_func,
      .args = (char*[]){NULL},
    };
    step(&dbus_user_setup);
  }

  if (free_user) free(user);
  free(drive);
  free(hostname);
  free(timezone);
  free(password);
  free(root_password);
  free(keyboard);
  free(coreutils_type);

  if (debug) (void)getchar();

  print_installed(&window);

  {
    char* confirm = ask_with_default("Do you want to chroot to the newly installed system? [y/N]", "N");

    if (confirm[0] == 'y' || confirm[0] == 'Y') {
      run_in_chroot_shell_with_bind_mnt("/bin/sh"); 
    }

    free(confirm);
  }

  {
    char* confirm = ask_with_default("Do you want to run a shell in the live enviroment? [y/N]", "N");

    if (confirm[0] == 'y' || confirm[0] == 'Y') {
      exec_no_shell_arr((char* const[]){"sh", NULL});
    }

    free(confirm);
  }

  print_installed(&window);

  done("Installation finished. Press ENTER to reboot.");
  (void)getchar();

  sync();
  reboot(RB_AUTOBOOT);

  // not reached!
  return 0;
}
