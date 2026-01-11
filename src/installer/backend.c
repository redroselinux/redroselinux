#include <stdio.h>
#include <dirent.h>
#include <string.h>

void list_dev(void) {
    DIR *dir = opendir("/dev");
    if (!dir) {
        perror("opendir /dev");
        return;
    }

    struct dirent *entry;
    while ((entry = readdir(dir)) != NULL) {
        const char *name = entry->d_name;

        // Only include real block devices (SATA/SCSI, NVMe, eMMC/SD)
        if (strncmp(name, "sd", 2) == 0 ||      // SATA/SCSI drives
            strncmp(name, "nvme", 4) == 0 ||    // NVMe drives
            strncmp(name, "mmcblk", 6) == 0) {  // eMMC/SD card
            printf("- %s\n", name);
        }
    }

    closedir(dir);
}
