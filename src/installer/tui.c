#include <stdio.h>
#include "backend.c"
#include <unistd.h>
#include <sys/ioctl.h>

// this file includes functions for TUI and some
// TUI parts for main.c. The tui functions:
// blue_text, blue_text_end, red_text, red_text_end
// yellow_text, yellow_text_end, clear, separator,
// enter_continue. the other functions are tui but
// they are not like a libary or something
//
// was ai used in this file? yes, but only for minor assistance
//      (escape codes like \033[94m, prinf-ing the figlet text)

void blue_text() {
    printf("\033[94m");
    fflush(stdout);
}

void blue_text_end() {
    printf("\033[0m");
    fflush(stdout);
}

void red_text() {
    printf("\033[91m");
    fflush(stdout);
}

void red_text_end() {
    printf("\033[0m");
    fflush(stdout);
}

void yellow_text() {
    printf("\033[93m");
    fflush(stdout);
}

void yellow_text_end() {
    printf("\033[0m");
    fflush(stdout);
}

void clear() {
    printf("\033[2J\033[H");
}

void enter_continue() {
    printf("Press");
    blue_text();
    printf(" ENTER ");
    blue_text_end();
    printf("to continue...");
    getchar();
    clear();
}

void separator() {
    struct winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
    for (int i = 0; i < w.ws_col; i++) {
        printf("─");
    }
    printf("\n");
}

void main_header() {
    printf("step 1/6");
    red_text();
    printf(
    "       _                      _     _                  \n"
    "|  _ \\ ___  __| |_ __ ___  ___  ___  | |   (_)_ __  _   ___  __\n"
    "| |_) / _ \\/ _` | '__/ _ \\/ __|/ _ \\ | |   | | '_ \\| | | \\ \\/ /\n"
    "|  _ <  __/ (_| | | | (_) \\__ \\  __/ | |___| | | | | |_| |>  < \n"
    "|_| \\_\\___|\\__,_|_|  \\___/|___/\\___| |_____|_|_| |_|\\__,_/_/\\_\\\n"
    );
    red_text_end();
    yellow_text();
    printf(
    " ___           _        _ _           \n"
    "|_ _|_ __  ___| |_ __ _| | | ___ _ __ \n"
    " | || '_ \\/ __| __/ _` | | |/ _ \\ '__|\n"
    " | || | | \\__ \\ || (_| | | |  __/ |   \n"
    "|___|_| |_|___/\\__\\__,_|_|_|\\___|_|   \n"
    "                                      \n"
    );
    yellow_text_end();

    separator();
    printf("\n");

    printf("Welcome to the Redrose Linux Installer!\n");
    printf("Please note that Redrose is still in beta.\n");
    printf("You can report bugs at ");
    blue_text();
    printf("https://github.com/redroselinux/redroselinux/issues");
    blue_text_end();
    printf(".\n\n");

    separator();
    printf("\n");
}

char* localization_header() {
    printf("step 2/6");
    static char layout[100];  // static buffer, safe to return

    yellow_text();
    printf("              _ _          _   _\n");
    printf("| |    ___   ___ __ _| (_)______ _| |_(_) ___  _ __\n");
    printf("| |   / _ \\ / __/ _` | | |_  / _` | __| |/ _ \\| '_ \\\n");
    printf("| |__| (_) | (_| (_| | | |/ / (_| | |_| | (_) | | | |\n");
    printf("|_____\\___/ \\___\\__,_|_|_/___\\__,_|\\__|_|\\___/|_| |_|\n\n");
    yellow_text_end();

    separator();

    printf("\nPicking a keyboard layout or language would NOT change anything in\n");
    printf("the current live enviroment. They only affect the installed system.\n\n");

    separator();

    printf("\nKeyboard layout [us]: ");
    if (fgets(layout, sizeof(layout), stdin) == NULL) {
        layout[0] = 'us';  // fallback in case of input error
    } else {
        // remove newline if present
        layout[strcspn(layout, "\n")] = 0;
    }

    return layout;
}

char* language() {
    printf("Language [us]: ");
    static char lang[100];
    fgets(lang, sizeof(lang), stdin);
    return lang;
}

char* timezone() {
    printf("Timezone (enter name of your city or country or UTC+/-*) [UTC+0]: ");
    static char time[100];
    fgets(time, sizeof(time), stdin);
    return time;
}

char* disk_header() {
    printf("step 3/6");
    blue_text();
    printf("       _        _ _       _   _               ____       _\n"
    "|_ _|_ __  ___| |_ __ _| | | __ _| |_(_) ___  _ __   |  _ \\ _ __(_)_   _____\n"
    " | || '_ \\/ __| __/ _` | | |/ _` | __| |/ _ \\| '_ \\  | | | | '__| \\ \\ / / _ \\\n"
    " | || | | \\__ \\ || (_| | | | (_| | |_| | (_) | | | | | |_| | |  | |\\ V /  __/\n"
    "|___|_| |_|___/\\__\\__,_|_|_|\\__,_|\\__|_|\\___/|_| |_| |____/|_|  |_| \\_/ \\___|\n\n");
    blue_text_end();
    separator();
    printf("\nPlease be extremely careful with what you are picking\nright now. This operation is NOT reversible!\n");
    printf("\nChoices:\n");
    separator();
    list_dev();
    separator();
    printf("Your choice: ");
    static char drive[100];
    fgets(drive, sizeof(drive), stdin);
    return drive;
}

char* user_creation() {
    static char username[100];
    printf("step 4/6");
    yellow_text();
    printf(
    "                ____                _   _\n"
    "| | | |___  ___ _ __   / ___|_ __ ___  __ _| |_(_) ___  _ __\n"
    "| | | / __|/ _ \\ '__| | |   | '__/ _ \\/ _` | __| |/ _ \\| '_ \\\n"
    "| |_| \\__ \\  __/ |    | |___| | |  __/ (_| | |_| | (_) | | | |\n"
    " \\___/|___/\\___|_|     \\____|_|  \\___|\\__,_|\\__|_|\\___/|_| |_|\n\n"
    );
    yellow_text_end();
    separator();
    printf("\nSet up the user. Make a memorizable password or leave blank\n");
    printf("for the defaults.\n\n");
    separator();
    printf("Your username [redrose]: ");
    fgets(username, sizeof(username), stdin);
    return username;
}

char* user_password() {
    static char password[100];
    printf("Password to this account [redrose]: ");
    fgets(password, sizeof(password), stdin);
    return password;
}

char* root_password() {
    static char password[100];
    printf("Password to root [redrose]: ");
    fgets(password, sizeof(password), stdin);
    return password;
}

char* hostname() {
    static char password[100];
    printf("Hostname [iuseredrosebtw]: ");
    fgets(password, sizeof(password), stdin);
    return password;
}

char* propiertary_enable() {
    static char enable[4];
    printf("BTW, enable propiertary software? (y/n) [n]: ");
    fgets(enable, sizeof(enable), stdin);
    return enable;
}

void installing_header() {
    printf("step 5/6");
    red_text();
    printf("       _        _ _ _\n");
    printf("|_ _|_ __  ___| |_ __ _| | (_)_ __   __ _\n");
    printf(" | || '_ \\/ __| __/ _` | | | | '_ \\ / _` |\n");
    printf(" | || | | \\__ \\ || (_| | | | | | | | (_| |\n");
    printf("|___|_| |_|___/\\__\\__,_|_|_|_|_| |_|\\__, |\n");
    printf("                                    |___/\n");
    red_text_end();
}
