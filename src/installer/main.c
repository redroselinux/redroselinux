#include <stdio.h>
#include <unistd.h>
#include <sys/reboot.h>
#include "tui.c"

// this file is the main file of the installer.
// it exports the other functions from tui.c and
// backend.c. got nothing else to say
//
// was ai used in this file? no

void shutdown_computer() {
    sync(); // flush filesystem buffers
    reboot(RB_POWER_OFF); // power off
}

int main() {
    // show main header
    clear();
    main_header();
    enter_continue();

    // localization
    clear();
    char* keyboard = localization_header();
    char* lang = language();
    char* time = timezone();
    enter_continue();

    // disk
    clear();
    char* drive = disk_header();
    while (drive[0] == '\n') {  // check if first character is newline
        clear();
        red_text();
        printf("YOU MUST PICK A DRIVE!\n");
        red_text_end();
        drive = disk_header();
    }
    enter_continue();

    // user creation
    clear();
    char* username = user_creation();
    char* userpassword = user_password();
    if (userpassword[0] == '\n' || userpassword[0] == '\0') {
        red_text();
        printf("REMEMBER THE DEFAULT PASSWORD ABOVE!\n");
        red_text_end();
    }

    char* rootpassword = root_password();
    if (rootpassword[0] == '\n' || rootpassword[0] == '\0') {
        red_text();
        printf("REMEMBER THE DEFAULT PASSWORD ABOVE!\n");
        red_text_end();
    }

    char* host_name = hostname();
    char* propiertary = propiertary_enable();
    enter_continue();

    // ask for confirmation
    clear();
    installing_header();
    printf("\n");
    separator();
    printf("\nAre you sure? (y/n) [y]: ");

    // todo: improve the color functions. we could do %s and for example:
    // printf("this is%s red%s", red, red);
    // or something similar to that.
    printf("\nDestructive operations have a ");
    red_text();
    printf("red");
    red_text_end();
    printf(" asterisk (*) next to them while others have a ");
    blue_text();
    printf("blue");
    blue_text_end();
    printf(" one.\n");

    char confirm[4];
    fgets(confirm, sizeof(confirm), stdin);

    if (confirm[0] == 'y' || confirm[0] == '\n') {
        clear();
        installing_header();
        printf("\n");
        separator();
        printf("\n");

        red_text();
        printf("* ");
        red_text_end();
        printf("Wiping the drive!\n");
        fflush(stdout);
        if (wipe_drive(drive) != 0) {
            red_text();
            printf("\nInstallation has failed. ");
            red_text_end();
            printf("Please report the error at our Github Issues: ");
            blue_text();
            printf("https://github.com/redroselinux/redroselinux/issues\n");
            blue_text_end();
            printf("\n");
            enter_continue();
            shutdown_computer();
        }

        printf("\nInstallation complete! The computer will now reboot.\n");
        enter_continue();
    }

    // finish and shutdown
    shutdown_computer();

    return 0;
}
