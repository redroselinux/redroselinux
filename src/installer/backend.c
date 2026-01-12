#include <stdio.h>
#include <dirent.h>
#include <string.h>

// this file will be later used as the main installer.
// currently, it has this function as its useful in
// both the outside and this one file, later.
//
// was ai used in this file? yes

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
