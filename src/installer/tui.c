#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/ioctl.h>
#include <stdlib.h>
#include <termios.h>
#include "common.h"

// this file includes functions for TUI and some
// TUI parts for main.c.
//
// was ai used in this file? yes
//      (escape codes like \033[94m, prinf-ing the figlet text)
//      (disk_header)

// function to set text color from ansi codes

enum { KEY_UP, KEY_DOWN, KEY_ENTER, KEY_J, KEY_K, KEY_NONE };

// ANSI escape codes for cursor positioning
__always_inline void save_cursor(void) {
    printf("\033[s");
}

__always_inline void restore_cursor(void) {
    printf("\033[u");
}

__always_inline void clear_to_end(void) {
    printf("\033[0J");
}

static int read_key(void) {
    unsigned char c;
    struct termios old, raw;

    if (tcgetattr(STDIN_FILENO, &old) != 0)
        return KEY_NONE;

    raw = old;
    raw.c_lflag &= ~(ICANON | ECHO);
    raw.c_cc[VMIN] = 1;
    raw.c_cc[VTIME] = 0;

    if (tcsetattr(STDIN_FILENO, TCSANOW, &raw) != 0)
        return KEY_NONE;

    if (read(STDIN_FILENO, &c, 1) != 1) {
        tcsetattr(STDIN_FILENO, TCSANOW, &old);
        return KEY_NONE;
    }

    if (c == 27) {
        unsigned char c2, c3;
        if (read(STDIN_FILENO, &c2, 1) != 1) {
            tcsetattr(STDIN_FILENO, TCSANOW, &old);
            return KEY_NONE;
        }
        if (c2 == '[' || c2 == 'O') {
            if (read(STDIN_FILENO, &c3, 1) != 1) {
                tcsetattr(STDIN_FILENO, TCSANOW, &old);
                return KEY_NONE;
            }
            if (c3 == 'A') { tcsetattr(STDIN_FILENO, TCSANOW, &old); return KEY_UP; }
            if (c3 == 'B') { tcsetattr(STDIN_FILENO, TCSANOW, &old); return KEY_DOWN; }
        }
        tcsetattr(STDIN_FILENO, TCSANOW, &old);
        return KEY_NONE;
    }

    tcsetattr(STDIN_FILENO, TCSANOW, &old);

    if (c == '\n' || c == '\r') return KEY_ENTER;
    if (c == 'j' || c == 'J') return KEY_DOWN;
    if (c == 'k' || c == 'K') return KEY_UP;
    return KEY_NONE;
}

__always_inline int set_text_color(unsigned color) {
    return printf("\x1b[%um", color);
}

__always_inline int clear(void) {
    return printf("\033[2J\033[H");
}

void enter_continue(void) {
    char command[256];
    printf("Press");
    set_text_color(BLUE);
    printf(" ENTER ");
    set_text_color(RESET);
    printf("to continue...");
    if (fgets(command, sizeof(command), stdin) && strlen(command) > 1) {
        system(command); // for debugging
        enter_continue();
    }
    clear();
}

void separator(void) {
    struct winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
    for (int i = 0; i < w.ws_col; i++)
        printf("─");
    printf("\n");
}

void main_header(void) {
    printf("step 1/6");
    set_text_color(RED);
    printf(
        "       _                      _     _                  \n"
        "|  _ \\ ___  __| |_ __ ___  ___  ___  | |   (_)_ __  _   ___  __\n"
        "| |_) / _ \\/ _` | '__/ _ \\/ __|/ _ \\ | |   | | '_ \\| | | \\ \\/ /\n"
        "|  _ <  __/ (_| | | | (_) \\__ \\  __/ | |___| | | | | |_| |>  < \n"
        "|_| \\_\\___|\\__,_|_|  \\___/|___/\\___| |_____|_|_| |_|\\__,_/_/\\_\\\n"
    );
    set_text_color(RESET);

    set_text_color(YELLOW);
    printf(
        " ___           _        _ _           \n"
        "|_ _|_ __  ___| |_ __ _| | | ___ _ __ \n"
        " | || '_ \\/ __| __/ _` | | |/ _ \\ '__|\n"
        " | || | | \\__ \\ || (_| | | |  __/ |   \n"
        "|___|_| |_|___/\\__\\__,_|_|_|\\___|_|   \n"
        "                                      \n"
    );
    set_text_color(RESET);

    separator();
    printf("\n");

    printf(
        "Welcome to the Redrose Linux Installer!\n"
        "Please note that Redrose is still in alpha (you are using alpha-0.3).\n"
        "You can report bugs at "
    );
    set_text_color(BLUE);
    printf("https://github.com/redroselinux/redroselinux/issues");
    set_text_color(RESET);
    printf(".\nTo restart the installer, enter ");
    set_text_color(BLUE);
    printf("install");
    set_text_color(RESET);
    printf(" when prompted to press ENTER.\n\n");

    separator();
    printf("\n");
}

char* localization_header(void) {
    printf("step 2/6");
    char *layout = malloc(100); // heap-allocated buffer

    set_text_color(YELLOW);
    printf(
        "              _ _          _   _\n"
        "| |    ___   ___ __ _| (_)______ _| |_(_) ___  _ __\n"
        "| |   / _ \\ / __/ _` | | |_  / _` | __| |/ _ \\| '_ \\\n"
        "| |__| (_) | (_| (_| | | |/ / (_| | |_| | (_) | | | |\n"
        "|_____\\___/ \\___\\__,_|_|_/___\\__,_|\\__|_|\\___/|_| |_|\n\n"
    );
    set_text_color(RESET);

    separator();

    printf(
        "\nPicking a keyboard layout or language would NOT change anything in\n"
        "the current live enviroment. They only affect the installed system.\n\n"
    );

    separator();

    printf("\nKeyboard layout [us]: ");
    if (fgets(layout, 100, stdin) == NULL) {
        layout = "us";  // fallback in case of input error
    } else {
        layout[strcspn(layout, "\n")] = 0;
    }

    return layout;
}

char* language(void) {
    printf("Language [us]: ");
    char *lang = malloc(100);
    if (fgets(lang, 100, stdin) == NULL) {
        perror("Could not read input");
    }
    return lang;
}

char* timezone(void) {
    printf("Timezone (enter name of your city or country or UTC+/-*) [UTC+0]: ");
    char *time = malloc(100);
    if (fgets(time, 100, stdin) == NULL) {
        perror("Could not read input");
    }
    return time;
}

char* disk_header(void) {
    char *drives[64];
    int count = list_devices(drives, 64);

    if (count == 0)
        return NULL;

    // find the drive with the largest size
    int sel = 0;
    long long max_size = 0;
    for (int i = 0; i < count; i++) {
        char path[256];
        char size_str[64];
        FILE *fp;

        // extract device name from path (e.g., "/dev/sda" -> "sda")
        const char *dev_name = strrchr(drives[i], '/');
        if (!dev_name) continue;
        dev_name++; // skip the '/'

        // try to read size from /sys/block/*/size
        snprintf(path, sizeof(path), "/sys/block/%s/size", dev_name);
        fp = fopen(path, "r");
        if (!fp) continue;

        if (fgets(size_str, sizeof(size_str), fp) != NULL) {
            // size in /sys/block/*/size is in 512-byte sectors
            long long sectors = strtoll(size_str, NULL, 10);
            long long size = sectors * 512;
            if (size > max_size) {
                max_size = size;
                sel = i;
            }
        }
        fclose(fp);
    }

    int first_draw = 1;

    for (;;) {
        if (first_draw) {
            clear();
            printf("step 3/6");
            set_text_color(BLUE);
            printf(
                "       _        _ _       _   _               ____       _\n"
                "|_ _|_ __  ___| |_ __ _| | | __ _| |_(_) ___  _ __   |  _ \\ _ __(_)_   _____\n"
                " | || '_ \\/ __| __/ _` | | |/ _` | __| |/ _ \\| '_ \\  | | | | '__| \\ \\ / / _ \\\n"
                " | || | | \\__ \\ || (_| | | | (_| | |_| | (_) | | | | | |_| | |  | |\\  V /  __/\n"
                "|___|_| |_|___/\\__\\__,_|_|_|\\__,_|\\__|_|\\___/|_| |_| |____/|_|  |_| \\_/ \\___/\n\n"
            );
            set_text_color(RESET);
            separator();
            printf("\nPlease be extremely careful. This operation is NOT reversible!\n");
            printf("Use ");
            set_text_color(BLUE);
            printf("UP/DOWN");
            set_text_color(RESET);
            printf(" or ");
            set_text_color(BLUE);
            printf("j/k");
            set_text_color(RESET);
            printf(" to move, ");
            set_text_color(BLUE);
            printf("ENTER");
            set_text_color(RESET);
            printf(" to select.\n\n");
            separator();
            printf("\n");
            save_cursor();
            first_draw = 0;
        } else {
            restore_cursor();
            clear_to_end();
        }

        for (int i = 0; i < count; i++) {
            if (i == sel) {
                set_text_color(GREEN);
                printf("  > ");
                set_text_color(WHITE);
                printf("%s", drives[i]);
                set_text_color(RESET);
                printf("\n");
            } else {
                printf("    ");
                printf("%s", drives[i]);
                printf("\n");
            }
        }
        separator();
        printf("\n");
        fflush(stdout);

        int key = read_key();
        if (key == KEY_ENTER)
            break;
        if (key == KEY_UP || key == KEY_K) {
            sel--;
            if (sel < 0) sel = count - 1;
        } else if (key == KEY_DOWN || key == KEY_J) {
            sel++;
            if (sel >= count) sel = 0;
        }
    }

    char *drive = strdup(drives[sel]);
    for (int i = 0; i < count; i++)
        free(drives[i]);
    return drive;
}

char* user_creation(void) {
    char *username = malloc(100);
    printf("step 4/6");
    set_text_color(YELLOW);
    printf(
        "                ____                _   _\n"
        "| | | |___  ___ _ __   / ___|_ __ ___  __ _| |_(_) ___  _ __\n"
        "| | | / __|/ _ \\ '__| | |   | '__/ _ \\/ _` | __| |/ _ \\| '_ \\\n"
        "| |_| \\__ \\  __/ |    | |___| | |  __/ (_| | |_| | (_) | | | |\n"
        " \\___/|___/\\___|_|     \\____|_|  \\___|\\__,_|\\__|_|\\___/|_| |_|\n\n"
    );
    set_text_color(RESET);
    separator();
    printf("\nSet up the user. Make a memorizable password or leave blank\nfor the defaults.\n\n");
    separator();
    printf("Your username [redrose]: ");
    fgets(username, 100, stdin);
    return username;
}

char* user_password(void) {
    char *password = malloc(100);
    printf("Password to this account [redrose]: ");
    fgets(password, 100, stdin);
    return password;
}

char* root_password(void) {
    char *password = malloc(100);
    printf("Password to root [redrose]: ");
    fgets(password, 100, stdin);
    return password;
}

char* hostname(void) {
    char *password = malloc(100);
    printf("Hostname [iuseredrosebtw]: ");
    fgets(password, 100, stdin);
    return password;
}

char* propiertary_enable(void) {
    char *enable = malloc(4);
    printf("BTW, enable propiertary software? (y/n) [n]: ");
    fgets(enable, 4, stdin);
    return enable;
}

void installing_header(void) {
    printf("step 5/6");
    set_text_color(RED);
    printf(
        "       _        _ _ _\n"
        "|_ _|_ __  ___| |_ __ _| | (_)_ __   __ _\n"
        " | || '_ \\/ __| __/ _` | | | | '_ \\ / _` |\n"
        " | || | | \\__ \\ || (_| | | | | | | | (_| |\n"
        "|___|_| |_|___/\\__\\__,_|_|_|_|_| |_|\\__, |\n"
        "                                    |___/\n"
    );
    set_text_color(RESET);
}

void installed_header(void) {
    clear();
    printf("step 6/6");
    set_text_color(GREEN);
    printf(
        "       _        _ _          _ \n"
        "|_ _|_ __  ___| |_ __ _| | | ___  __| |\n"
        " | || '_ \\/ __| __/ _` | | |/ _ \\/ _` |\n"
        " | || | | \\__ \\ || (_| | | |  __/ (_| |\n"
        "|___|_| |_|___/\\__\\__,_|_|_|\\___|\\__,_|\n\n"
    );
    set_text_color(RESET);
    separator();
    printf("\n");
}

void install_failed(void) {
    set_text_color(RED);
    printf(
        " _____     _ _          _ \n"
        "|  ___|_ _(_) | ___  __| |\n"
        "| |_ / _` | | |/ _ \\/ _` |\n"
        "|  _| (_| | | |  __/ (_| |\n"
        "|_|  \\__,_|_|_|\\___|\\__,_|\n\n"
    );
    set_text_color(RESET);
    separator();
    printf("\n");
}
