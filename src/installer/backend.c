#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/sysmacros.h>
#include <stdlib.h>
#include "common.h"

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


int list_dev() {
    DIR *dir = opendir("/dev");
    if (!dir) {
        perror("opendir /dev");
        return 0;
    }

    struct stat st;
    unsigned int cur_maj = 0, cur_min = 0;
    if (stat(".", &st) == 0) {
        cur_maj = major(st.st_dev);
        cur_min = minor(st.st_dev);
    }

    char cur_dev[128] = {0};
    FILE *fp = fopen("/proc/self/mountinfo", "r");
    if (fp) {
        char line[512];
        while (fgets(line, sizeof(line), fp)) {
            unsigned int maj, min;
            char dev[128];

            if (sscanf(line,
                       "%*d %*d %u:%u %*s %*s %*[^-]- %127s",
                       &maj, &min, dev) == 3) {
                if (maj == cur_maj && min == cur_min) {
                    strncpy(cur_dev, dev, sizeof(cur_dev) - 1);
                    break;
                }
            }
        }
        fclose(fp);
    }

    struct dirent *entry;
    int found = 0;

    while ((entry = readdir(dir)) != NULL) {
        const char *name = entry->d_name;

        if (!(strncmp(name, "sd", 2) == 0 ||
              strncmp(name, "nvme", 4) == 0 ||
              strncmp(name, "mmcblk", 6) == 0))
            continue;

        if (cur_dev[0] && strstr(cur_dev, name))
            continue;
        if (strstr(name, "/dev/")) {
            printf("- %s\n", name);
        } else {
            printf("- /dev/%s\n", name);
        }
        found++;
    }

    closedir(dir);

    if (found == 0) {
        set_text_color(RED);
        printf("- no drives found!\n");
        set_text_color(RESET);
        printf("enter exit to remove this shell and bypass the warning. enter docs if you believe you do have a drive. otherwise, you can repair through commands.\n");
        while (1) {
            set_text_color(GREEN);
            printf("\n> ");
            set_text_color(RESET);
            char command[4096];

            if (!fgets(command, sizeof(command), stdin))
                break;

            command[strcspn(command, "\n")] = 0;

            if (strcmp(command, "exit") == 0) {
                break;
            } else if (strcmp(command, "docs") == 0) {
                printf("If you believe a drive is present, follow these steps:\n\n");

                printf("1) Firmware / BIOS checks:\n");
                printf("   - Reboot into firmware setup (BIOS/UEFI).\n");
                printf("   - Ensure the drive is detected by the firmware.\n");
                printf("   - Disable Intel RST / RAID / VMD and use AHCI mode.\n");
                printf("   - For NVMe systems, disable VMD if enabled.\n\n");

                printf("2) Virtual machines:\n");
                printf("   - Ensure a virtual disk is attached to the VM.\n");
            } else {
                system(command);
            }
        }
    } else {
        set_text_color(GREEN);
        printf("total %d\n", found);
        set_text_color(RESET);
    }
    return found;
}

int wipe_drive(char* drive) {
    char command[40]; // should be fine with 30, some space to make sure
    snprintf(command, sizeof(command), "sgdisk --zap-all %s", drive);
    printf("> %s", command);
    int exitcode = system(command);

    return exitcode;
}

int makefs(char* drive) {
    return 0;
}

int unsquash(char* drive) {
    char mountcmd[100];
    snprintf(mountcmd, sizeof(mountcmd), "mount %s /mnt/", drive);

    if (system(mountcmd) != 0)
        return 0;

    system("unsquashfs rootfs.sqsh -d /mnt/");
    sleep(10);
    return 1;
}

int install_grub(char* drive) {
    return 0;
}

