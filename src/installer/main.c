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

  print_installing(window);
  char* confirm = ask("Confirm installation? [Y/n]");
  if (!(confirm[0] == 'y' || confirm[0] == 'Y' || confirm[0] == '\0')) {
    error("Installation cancelled.");
    info("Press ENTER to restart installation");
    getchar();
    FREE_ALL();
    goto body;
  }

  print_installing(window);

  InstallStep wipe = {
    .message = "Wiping all contents of the selected drive!",
    .func = wipe_func,
    .args = (char*[]){drive, NULL},
  };

  auto result = run_step(&wipe);
  print_result(&result);

  free(user);
  free(drive);
  free(hostname);
  free(timezone);
  free(password);
  free(root_password);
  free(keyboard);

  (void)ask(NULL);

  print_installed(window);

  done("Installation finished. Press ENTER to reboot.");
  (void)getchar();

  sync();
  reboot(RB_AUTOBOOT);

  // not reached!
  return 0;
}
