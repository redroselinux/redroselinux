#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/sysmacros.h>

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

        printf("- %s\n", name);
        found = 1;
    }

    closedir(dir);

    if (!found)
        printf("No drives found!\n");
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