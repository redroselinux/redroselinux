#include <stdio.h>
#include <unistd.h>
#include <sys/reboot.h>
#include "tui.c"
#include "backend.c"
#include "postinstgen.c"

// this file is the main file of the installer.
// it exports the other functions from tui.c and
// backend.c. got nothing else to say
//
// was ai used in this file? yes (run_installation_step)

void shutdown_computer() {
    set_text_color(YELLOW);
    printf(
        "If you are on a VM, after the VM restarts, pick \"Boot existing OS\"\n"
        "You can also remove the CD-ROM from the VM.\n"
    );
    set_text_color(RESET);
    enter_continue();
    sync(); // flush filesystem buffers
    reboot(RB_AUTOBOOT);
}

void error() {
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

void print_step_header() {
    clear();
    installing_header();
    printf("\n");
    separator();
    printf("\n");
}

int run_installation_step(int (*operation)(char*),
    char* arg,
    const char* step_name,
    int is_destructive) {
        set_text_color(is_destructive ? RED : GREEN);
        printf("* ");
        set_text_color(RESET);
        printf("%s\n", step_name);
        fflush(stdout);

        if (operation(arg) != 0) {
            install_failed();
            error();
            return -1;
        }

        print_step_header();
        return 0;
}

int main() {
    // run checks
    printf("Running checks...\n");
    if (list_dev() == 0) {}

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
    if (!drive) {
        set_text_color(RED);
        printf("No drive selected. Exiting installer.\n");
        set_text_color(RESET);
        enter_continue();
        return 0;
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
    printf("\nDestructive operations have a ");
    set_text_color(RED);
    printf("red");
    set_text_color(RESET);
    printf(" asterisk (*) next to them while others have a ");
    set_text_color(BLUE);
    printf("blue");
    set_text_color(RESET);
    printf(" one.\n");
    printf("Installing to %s", drive);
    printf("\nAre you sure? (y/n) [y]: ");

    char confirm[4];
    fgets(confirm, sizeof(confirm), stdin);


    if (confirm[0] == 'y' || confirm[0] == '\n') {
        print_step_header();

        if (run_installation_step(wipe_drive, drive, "Erasing the drive!", 1) < 0) return 0;
        if (run_installation_step(makefs, drive, "Making filesystems!", 1) < 0) return 0;
        if (run_installation_step(copy_root, drive, "Copying root!", 1) < 0) return 0;
        if (run_installation_step(install_grub, drive, "Installing GRUB!", 0) < 0) return 0;
        if (run_installation_step(patch, drive, "Running patches!", 0) < 0) return 0;
        if (run_installation_step(localhost, host_name, "Setting hostname!", 0) < 0) return 0;

        print_step_header();
        if (gen_postinst_scripts(drive, username, userpassword, rootpassword, host_name) != 0) {
            install_failed();
            error();
        }
        else {
            print_step_header();
        }
    }
    installed_header();
    printf("Thank you for installing the Redrose Linux alpha! Reboot to your new system.\n\n");
    printf("Please report errors at our Github Issues: ");
    set_text_color(BLUE);
    printf("https://github.com/redroselinux/redroselinux/issues\n\n");
    set_text_color(RESET);
    separator();
    printf("\n");
    enter_continue();
    // finish and shutdown
    shutdown_computer();

    return 0;
}
