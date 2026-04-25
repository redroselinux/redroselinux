#include <stdio.h>
#include <unistd.h>
#include <sys/reboot.h>
#include "common.h"
#include "tui.c"
#include "backend.c"

// this file is the main file of the installer.
// it exports the other functions from tui.c and
// backend.c. got nothing else to say
//
// was ai used in this file? yes (run_installation_step)

void shutdown_computer() {
    sync(); reboot(RB_AUTOBOOT);
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

int run_installation_step(int (*operation)(char*),
    char* arg,
    const char* step_name,
    int is_destructive) {
        set_text_color(is_destructive ? RED : GREEN);
        printf("* ");
        set_text_color(RESET);
        printf("\e[1m%s\e[0m\n", step_name);
        fflush(stdout);

        if (operation(arg) != 0) {
            install_failed();
            error();
            return -1;
        }

        fputs("\n", stdout);
        return 0;
}

int main() {
    // run checks
    printf("Running checks...\n");
    if (list_dev() == 0) {}

    // show main header
    clear();
    main_header();

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
    int propriertary = proprietary_enable();
    enter_continue();

    // ask for confirmation
    clear();
    installing_header();
    printf("\n");
    separator();
    printf("\nInstalling to %s. Are you sure? (Y/n): ", drive);

    char confirm[4];
    fgets(confirm, sizeof(confirm), stdin);

    if (confirm[0] == 'y' || confirm[0] == '\n') {
        clear();
        int success = 1;
        disable_echo();
        if (run_installation_step(wipe_drive, drive, "Erasing the drive!", 1) < 0) { success = 0; goto cleanup; }
        if (run_installation_step(makefs, drive, "Making filesystems!", 1) < 0) { success = 0; goto cleanup; }
        if (run_installation_step(copy_root, drive, "Copying root!", 1) < 0) { success = 0; goto cleanup; }
        set_text_color(GREEN);
        printf("* ");
        set_text_color(RESET);
        printf("\e[1mSetting up user accounts!\e[0m\n");
        fflush(stdout);
        if (create_users(username, userpassword, rootpassword) != 0) {
            install_failed();
            error();
            return -1;
        }
        fputs("\n", stdout);
        if (run_installation_step(install_grub, drive, "Installing GRUB!", 0) < 0) { success = 0; goto cleanup; }
        if (run_installation_step(patch, drive, "Running patches!", 0) < 0) { success = 0; goto cleanup; }
        if (propriertary == 0)
            if (run_installation_step(propriertary_, "", "Enabling propriertary software!", 0) < 0) { success = 0; goto cleanup; }
        if (run_installation_step(localhost, host_name, "Setting hostname!", 0) < 0) { success = 0; goto cleanup; }
        if (run_installation_step(init_car, "", "Initializing Car!", 0) < 0) { success = 0; goto cleanup; }
        if (run_installation_step(install_busybox, "", "Installing BusyBox!", 0) < 0) { success = 0; goto cleanup; }
cleanup:
        enable_echo();
        if (!success) return 0;
        if (run_installation_step(chroot_, "", "Choose an option!", 0) < 0) return 0; disable_echo();
        if (run_installation_step(umount_detach, "/mnt", "Unmounting root!", 0) < 0) { success = 0; goto cleanup2; }
cleanup2:
        enable_echo();
        if (!success) return 0;

        installed_header();
        printf("Thank you for installing the Redrose Linux alpha! Reboot to your new system.\n\n");
        printf("Please report errors on Github Issues: ");
        set_text_color(BLUE);
        printf("https://github.com/redroselinux/redroselinux/issues\n\n");
        set_text_color(RESET);
        printf("\n");
        set_text_color(YELLOW);
        printf(
            "If you are on a VM, after the VM restarts, pick \"Boot existing OS\"\n"
            "You can also remove the CD-ROM from the VM. If you see no such option,"
            " you can ignore this warning.\n\n"
        );
        set_text_color(RESET);
        separator();
        printf("\n");
        enter_continue();
        shutdown_computer();
    } else {
        printf("Restart installer? [Y/n]: ");

        char buf[8];
        if (fgets(buf, sizeof(buf), stdin)) {
        if (buf[0] == 'n' || buf[0] == 'N') {
            printf("Reboot or shutdown? [R/s]: ");
            if (fgets(buf, sizeof(buf), stdin)) {
                if (buf[0] == 's' || buf[0] == 'S') {
                    printf("Shutting down in 5 seconds...");
                    fflush(stdout);
                    sleep(5);
                    reboot(RB_POWER_OFF);
                } else {
                    printf("Rebooting in 5 seconds...");
                    fflush(stdout);
                    sleep(5);
                    reboot(RB_AUTOBOOT);
                }
            }
        } else {
            clear();
            execl("/bin/install", "install", NULL);
        }
    }

    }

    return 0;
}
