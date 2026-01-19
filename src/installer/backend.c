#include <stdio.h>
#include <dirent.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

// backend for installer.
//
// was ai used in this file? yes (functions: list_dev, partition_drive, format_partitions)

char* get_partition(const char* drive, int partnum) {
    static char buf[64];
    if (strncmp(drive, "/dev/nvme", 9) == 0 || strncmp(drive, "/dev/mmcblk", 11) == 0) {
        snprintf(buf, sizeof(buf), "%sp%d", drive, partnum);
    } else {
        snprintf(buf, sizeof(buf), "%s%d", drive, partnum);
    }
    return buf;
}

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

int dd_drive(char* drive) {
    fflush(stdout);
    char command[100]; // should be fine with 80, some space to make sure
    snprintf(command, sizeof(command), "dd if=redroselinux_rootfs.iso of=%s bs=4M status=progress conv=fsync", drive);
    printf("> %s", command);
    int exitcode = system(command);
    
    return exitcode;
}