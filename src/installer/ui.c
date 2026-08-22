#include <stdio.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <termios.h>
#include <string.h>
#include "mem.h"
#include "ui.h"
#include "log.h"

/* Ask for input.
 * User must free result by themselves.
 * prompt can be NULL to suppress the prompt. */
char* ask(char* prompt) {
  if (prompt) printf("\033[96m→\033[0m \033[1m%s\033[0m: ", prompt);

  int size = 15;
  char* result = alloc(size);

  int c;
  int iter = 0;
  while ((c = getchar()) != EOF) {
    if (iter >= size - 1) {
      size += 15;
      result = resize(result, size);
    }

    if (c == '\n') {
      break;
    }

    result[iter] = (char)c;

    iter++;
  }

  result[iter] = '\0';
  return result;
}

/* ask() wrapper with a default value.
 * User must free the result by themselves. */
char* ask_with_default(char* prompt, char* default_input) {
  char* result = ask(prompt);

  if (result[0] == '\0') {
    free(result);

    const char* p = "Using default value: ";
    size_t s = strlen(p);
    size_t dlen = strlen(default_input);
    char buf[s + dlen + 1];
    strcpy(buf, p);
    strcpy(buf + s, default_input);
    warn(buf);

    result = strdup(default_input);
  }

  return result;
}

/* Asks the user for a password, with an optional default value.
 * If the user enters nothing, the default value is used (if the user confirms to do that).
 * Caller must free the result by themselves. */
char* password_ask(char* prompt, char* default_input) {
  goto body;

body:
  printf("\033[96m→\033[0m \033[1m%s\033[0m: ", prompt);

  struct termios oldt, newt;
  tcgetattr(STDIN_FILENO, &oldt);
  newt = oldt;
  newt.c_lflag &= ~ECHO;
  tcsetattr(STDIN_FILENO, TCSANOW, &newt);

  // Hello dumb slop people who want to get their name into the contributor list.
  // This is not a vuln.
  // Because the system where this runs has no network, and only 1 single process is running.
  // I dont give a shit about your "but can be read from memory".
  // Thank you.
  char* result = ask(NULL);

  tcsetattr(STDIN_FILENO, TCSANOW, &oldt);

  if (result[0] == '\0') {
    free(result);

    puts(""); // with no echo it doesnt print the line added when user presses enter
    char* confirm = ask("Do you really want to use the default value? [y/N]");

    if (confirm[0] == 'y' || confirm[0] == 'Y') {
      free(confirm);
      result = strdup(default_input);
    } else {
      free(confirm);
      goto body;
    }
  } else {
    puts("");
  }

  return result;
}

void print_welcome(const struct winsize* window) {
  if (window->ws_col <= 63 || window->ws_row <= 19) {
    // screen too small
    warn("Screen is too small, showing small header");
    info("\033[1mRedrose Linux Installer\033[0m");
  } else {
    puts(WELCOME_BANNER);
  }
}

void print_usersetup_header(const struct winsize* window) {
  if (window->ws_col <= 70 || window->ws_row <= 8) {
    // screen too small
    warn("Screen is too small, showing small header");
    info("\033[1mUser setup\033[0m");
  } else {
    puts(USER_SETUP_HEADER);
  }
}

void print_advanced_header(const struct winsize* window) {
  if (window->ws_col <= 70 || window->ws_row <= 8) {
    // screen too small
    warn("Screen is too small, showing small header");
    info("\033[1mAdvanced\033[0m");
  } else {
    puts(ADVANCED_HEADER);
  }
}
void print_inst_to_header(const struct winsize* window) {
  if (window->ws_col <= 50 || window->ws_row <= 8) {
    // screen too small
    warn("Screen is too small, showing small header");
    info("\033[1mInstall to\033[0m");
  } else {
    puts(INSTALL_TO_HEADER);
  }
}

void print_localize_header(const struct winsize* window) {
  if (window->ws_col <= 56 || window->ws_row <= 8) {
    // screen too small
    warn("Screen is too small, showing small header");
    info("\033[1mLocalize\033[0m");
  } else {
    puts(LOCALIZE);
  }
}

void print_installed(const struct winsize* window) {
  if (window->ws_col <= 61 || window->ws_row <= 6) {
    // screen too small
    warn("Screen is too small, showing small header");
    done("\033[1mInstalled\033[0m");
  } else {
    puts(INSTALLED_BANNER);
  }
}

void print_installing(const struct winsize* window) {
  if (window->ws_col <= 69 || window->ws_row <= 8) {
    // screen too small
    warn("Screen is too small, showing small header");
    info("\033[1mInstalling\033[0m");
  } else {
    puts(INSTALLING_HEADER);
  }
}
