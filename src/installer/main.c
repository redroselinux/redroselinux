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
    disk_header();
    enter_continue();

    // user creation
    clear();
    char* username = user_creation();
    char* userpassword = user_password();
    char* rootpassword = root_password();
    char* host_name = hostname();
    char* propiertary = propiertary_enable();
    enter_continue();

    // ask for confirmation
    clear();
    installing_header();
    printf("\n");
    separator();
    printf("\nAre you sure? (y/n) [y]: ");
    char confirm[4];
    fgets(confirm, sizeof(confirm), stdin);

    if (confirm[0] == 'y' || confirm[0] == '\n') {
        clear();
        installing_header();
        printf("\n");
        separator();
        printf("\n");

        printf("Installing... (this is all a placeholder!)\n");
        fflush(stdout);
        sleep(1);

        printf("Preparing system image...\n");
        fflush(stdout);
        sleep(2);

        printf("Setting up user...\n");
        fflush(stdout);
        sleep(1);

        printf("Setting up timezone, language and keyboard...\n");
        fflush(stdout);
        sleep(1);

        printf("Preparing to install desktop, etc...\n");
        fflush(stdout);
        sleep(1);

        clear();
        installing_header();
        printf("\n");
        separator();
        printf("\n");

        printf("Setting up bootloader...\n");
        fflush(stdout);
        sleep(4);

        printf("Installing packages [i3, i4dots, polybar, i4settings, xorg]...\n");
        fflush(stdout);
        sleep(7);

        printf("Setting up login screen...\n");
        fflush(stdout);
        sleep(4);

        printf("\nInstallation complete! The computer will now reboot.\n");
        enter_continue();
    }

    // finish and shutdown
    shutdown_computer();

    return 0;
}
