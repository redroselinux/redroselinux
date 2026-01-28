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
                printf("docs not implemented yet\n");
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

int dd_drive(char* drive) {
    fflush(stdout);
    char command[100]; // should be fine with 80, some space to make sure
    snprintf(command, sizeof(command), "dd if=redroselinux_rootfs.iso of=%s bs=4M status=progress", drive);
    printf("> %s", command);
    int exitcode = system(command);
    
    return exitcode;
}

// this will be replaced with postinstgen
// postinst wont need reboot and we will
// chroot into it for simplicity

// TODO: move all this into postinstgen.c
int drive_patch(char* drive) {
    /*
    // we have an issue with GRUB having the root setting
    // that is fine, but we need to patch the GRUB config for that.

    // first, we create a mount dir
    system("mkdir -p rootfs");

    drive[strcspn(drive, "\n")] = '\0';

    // now let's mount the drive
    char command[80]; // should be fine with MUCH less, some space to make sure
    snprintf(command, sizeof(command), "mount -t auto %s rootfs || mount -t auto %s1 rootfs", drive, drive);
    system(command);

    // let's edit the grub config
    const char* grub_path = "rootfs/boot/grub/grub.cfg";

    // open grub.cfg for reading
    FILE* grubcfg = fopen(grub_path, "r");
    if (!grubcfg) {
        perror("failed to open grub.cfg for reading");
        return -1;
    }

    // determine file size
    fseek(grubcfg, 0, SEEK_END);
    long size = ftell(grubcfg);
    fseek(grubcfg, 0, SEEK_SET);

    // read file into buffer
    char* buffer = malloc(size + 1);
    if (!buffer) {
        fclose(grubcfg);
        perror("failed to allocate memory for grub.cfg");
        return -1;
    }
    fread(buffer, 1, size, grubcfg);
    buffer[size] = '\0';
    fclose(grubcfg);

    // allocate new buffer for patched content
    char* new_buffer = malloc(size * 2); // generous size for replacements
    if (!new_buffer) {
        free(buffer);
        perror("failed to allocate memory for new buffer");
        return -1;
    }
    new_buffer[0] = '\0';

    // patch lines containing "linux " and "root=/dev/sda"
    char* line = strtok(buffer, "\n");
    while (line) {
        if (strstr(line, "linux ") && strstr(line, "root=/dev/sda")) {
            char patched_line[1024];
            snprintf(patched_line, sizeof(patched_line), "%.*sroot=%s%s",
                     (int)(strstr(line, "root=") - line), // copy up to 'root='
                     line, drive,
                     strchr(strstr(line, "root="), ' ') ? strchr(strstr(line, "root="), ' ') : "");
            strcat(new_buffer, patched_line);
        } else {
            strcat(new_buffer, line);
        }
        strcat(new_buffer, "\n");
        line = strtok(NULL, "\n");
    }

    // write back patched config
    grubcfg = fopen(grub_path, "w");
    if (!grubcfg) {
        perror("failed to open grub.cfg for writing");
        free(buffer);
        free(new_buffer);
        return -1;
    }

    fwrite(new_buffer, 1, strlen(new_buffer), grubcfg);
    fclose(grubcfg);

    // cleanup
    free(buffer);
    free(new_buffer);

    return 0;
    */
    printf("this function is disabled until we fix some issues with it\n");

    // todo: do not use .iso so we can patch grub properly
    return 0;
}
