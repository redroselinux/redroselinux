#include <stdio.h>
#include <unistd.h>
#include <sys/reboot.h>
#include "tui.c"
#include "postinstgen.c"

// this file is the main file of the installer.
// it exports the other functions from tui.c and
// backend.c. got nothing else to say
//
// was ai used in this file? no

void shutdown_computer() {
    sync(); // flush filesystem buffers
    reboot(RB_POWER_OFF);
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
        set_text_color(RED);
        printf("YOU MUST PICK A DRIVE!\n");
        set_text_color(RESET);
        drive = disk_header();
    }
    enter_continue();

    // user creation
    clear();
    char* username = user_creation();
    char* userpassword = user_password();
    if (userpassword[0] == '\n' || userpassword[0] == '\0') {
        set_text_color(RED);
        printf("REMEMBER THE DEFAULT PASSWORD ABOVE!\n");
        set_text_color(RESET);
    }

    char* rootpassword = root_password();
    if (rootpassword[0] == '\n' || rootpassword[0] == '\0') {
        set_text_color(RED);
        printf("REMEMBER THE DEFAULT PASSWORD ABOVE!\n");
        set_text_color(RESET);
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
    set_text_color(RED);
    printf("red");
    set_text_color(RESET);
    printf(" asterisk (*) next to them while others have a ");
    set_text_color(BLUE);
    printf("blue");
    set_text_color(RESET);
    printf(" one.\n");

    char confirm[4];
    fgets(confirm, sizeof(confirm), stdin);

    if (confirm[0] == 'y' || confirm[0] == '\n') {
        clear();
        installing_header();
        printf("\n");
        separator();
        printf("\n");

        set_text_color(RED);
        printf("* ");
        set_text_color(RESET);
        printf("Preparing the drive!\n");
        fflush(stdout);
        if (wipe_drive(drive) != 0) {
            install_failed();
            set_text_color(RED);
            printf("\nInstallation has failed. ");
            set_text_color(RESET);
            printf("Please report the error at our Github Issues: ");
            set_text_color(BLUE);
            printf("https://github.com/redroselinux/redroselinux/issues\n");
            set_text_color(RESET);
            printf("\n");
            enter_continue();
            shutdown_computer();
        }
        else {
            clear();
            installing_header();
            printf("\n");
            separator();
            printf("\n");
        }
        if (dd_drive(drive) != 0) {
            install_failed();
            set_text_color(RED);
            printf("\nInstallation has failed. ");
            set_text_color(RESET);
            printf("Please report the error at our Github Issues: ");
            set_text_color(BLUE);
            printf("https://github.com/redroselinux/redroselinux/issues\n");
            set_text_color(RESET);
            printf("\n");
            enter_continue();
            shutdown_computer();
        }
        else {
            clear();
            installing_header();
            printf("\n");
            separator();
            printf("\n");
        }
        clear();
        installing_header();
        printf("\n");
        separator();
        printf("\n");
        set_text_color(BLUE);
        printf("* ");
        set_text_color(RESET);
        printf("Generating post-installation scripts...\n");
        fflush(stdout);
        if (gen_postinst_scripts(
            drive,
            username,
            userpassword,
            rootpassword,
            host_name
        ) != 0) {
            install_failed();
            set_text_color(RED);
            printf("\nInstallation has failed. ");
            set_text_color(RESET);
            printf("Please report the error at our Github Issues: ");
            set_text_color(BLUE);
            printf("https://github.com/redroselinux/redroselinux/issues\n");
            set_text_color(RESET);
            printf("\n");
            enter_continue();
            shutdown_computer();
        }
        else {
            clear();
            installing_header();
            printf("\n");
            separator();
            printf("\n");
        }
    }
    installed_header();
    printf("Now, we will reboot the computer and run some post-installation scripts. These scripts are autogenerated and will set up your system based on your preferences.\n");
    printf("After the system powers off, turn it on after removing the installation media.\n");
    enter_continue();
    // finish and shutdown
    shutdown_computer();

    return 0;
}
