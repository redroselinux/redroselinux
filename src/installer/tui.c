#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/ioctl.h>
#include <stdlib.h>
#include "common.h"

// this file includes functions for TUI and some
// TUI parts for main.c.
//
// was ai used in this file? yes, but only for minor assistance
//      (escape codes like \033[94m, prinf-ing the figlet text)

// function to set text color from ansi codes
// that are defined above (lines 12-17)
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
        "Please note that Redrose is still in alpha (you are using alpha-0.2).\n"
        "You can report bugs at "
    );
    set_text_color(BLUE);
    printf("https://github.com/redroselinux/redroselinux/issues");
    set_text_color(RESET);
    printf(".\n\n");

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
    printf("\nPlease be extremely careful with what you are picking\nright now. This operation is NOT reversible!\n\nChoices:\n");
    separator();
    list_dev();
    separator();
    printf("Your choice: ");
    char *drive = malloc(100);
    if (fgets(drive, 100, stdin) == NULL) {
        perror("Could not read input");
    }
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
