#include <stdio.h>
#include <dirent.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

// backend for installer.
//
// was ai used in this file? yes (functions: list_dev, partition_drive)

void list_dev(void) {
    DIR *dir = opendir("/dev");
    if (!dir) {
        perror("opendir /dev");
        return;
    }

    struct dirent *entry;
    int found = 0;

    while ((entry = readdir(dir)) != NULL) {
        const char *name = entry->d_name;

        // Only include real block devices (SATA/SCSI, NVMe, eMMC/SD)
        if (strncmp(name, "sd", 2) == 0 ||      // SATA/SCSI drives
            strncmp(name, "nvme", 4) == 0 ||    // NVMe drives
            strncmp(name, "mmcblk", 6) == 0) {  // eMMC/SD card
            printf("- %s\n", name);
            found = 1;
        }
    }

    closedir(dir);

    if (!found) {
        printf("No drives found!\n");
    }
}

int wipe_drive(char* drive) {
    char command[40]; // should be fine with 30, some space to make sure
    snprintf(command, sizeof(command), "sgdisk --zap-all %s", drive);
    printf("> %s", command);
    int exitcode = system(command);
    
    return exitcode;
}

int partition_drive(const char* drive) {
    int exitcode;

    // EFI System partition, 512 MB
    char cmd1[100];
    snprintf(cmd1, sizeof(cmd1), "sgdisk -n 1:0:+512M -t 1:EF00 %s", drive);
    printf("> %s\n", cmd1);
    exitcode = system(cmd1);
    if (exitcode != 0) return exitcode;

    // BIOS Boot partition, 2 MB
    char cmd2[100];
    snprintf(cmd2, sizeof(cmd2), "sgdisk -n 2:0:+2M -t 2:EF02 %s", drive);
    printf("> %s\n", cmd2);
    exitcode = system(cmd2);
    if (exitcode != 0) return exitcode;

    // Root partition, rest of disk
    char cmd3[100];
    snprintf(cmd3, sizeof(cmd3), "sgdisk -n 3:0:0 -t 3:8300 %s", drive);
    printf("> %s\n", cmd3);
    exitcode = system(cmd3);
    if (exitcode != 0) return exitcode;

    sync();

    return 0;
}