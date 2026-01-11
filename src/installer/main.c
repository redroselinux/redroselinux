#include <stdio.h>
#include <unistd.h>
#include <sys/reboot.h>
#include "tui.c"

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

    // finish and shutdown
    shutdown_computer();

    return 0;
}
