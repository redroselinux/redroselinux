#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <sys/stat.h>
#include <sys/sysmacros.h>
#include <sys/mount.h>

#include "common.h"

// backend for installer.
//
// was ai used in this file? yes
//    (functions: list_dev, partition_drive, format_partitions, no_drives_repl, makefs)

char* get_partition(const char* drive, int partnum) {
    static char buf[64];
    if (strncmp(drive, "/dev/nvme", 9) == 0 || strncmp(drive, "/dev/mmcblk", 11) == 0) {
        snprintf(buf, sizeof(buf), "%sp%d", drive, partnum);
    } else {
        snprintf(buf, sizeof(buf), "%s%d", drive, partnum);
    }
    return buf;
}

static void no_drives_repl(void) {
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
}

int list_devices(char *drives[64], int max) {
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

    int count = 0;
    struct dirent *entry;

    while (count < max && (entry = readdir(dir)) != NULL) {
        const char *name = entry->d_name;

        if (!(strncmp(name, "sd", 2) == 0 ||
              strncmp(name, "nvme", 4) == 0 ||
              strncmp(name, "mmcblk", 6) == 0))
            continue;

        if (cur_dev[0] && strstr(cur_dev, name))
            continue;

        char *path = malloc(32);
        if (!path)
            break;
        snprintf(path, 32, "/dev/%s", name);
        drives[count++] = path;
    }

    closedir(dir);

    if (count == 0)
        no_drives_repl();

    return count;
}

int list_dev() {
    char *drives[64];
    int count = list_devices(drives, 64);

    if (count == 0) {
        return 0;
    }

    for (int i = 0; i < count; i++) {
        printf("- %s\n", drives[i]);
        free(drives[i]);
    }

    set_text_color(GREEN);
    printf("total %d\n", count);
    set_text_color(RESET);
    return count;
}

int wipe_drive(char* drive) {
    char command[40]; // should be fine with 30, some space to make sure
    snprintf(command, sizeof(command), "sgdisk --zap-all %s", drive);
    printf("> %s\n", command);
    fflush(stdout);
    return system(command);
}

int detect_efi() {
    int boot_mode;

    // if /sys/firmware/efi exists, we are booted in efi
    // this is inspired by the archwiki where you check
    // this by uefi bitness, and it was 64 and 32. so i
    // put it in here because it looks super cool lmfao
    //
    // https://wiki.archlinux.org/title/Installation_guide#Verify_the_boot_mode

    if (access("/sys/firmware/efi", F_OK) == 0) {
        // 64 means uefi mode
        return 64;
    } else {
        // 32 means bios mode
        return 32;
    }
}

int makefs(char* drive) {
    char command[256];

    if (detect_efi() == 32) {
        snprintf(command, sizeof(command),
            "sgdisk -n 1:1M:+1M -t 1:ef02 -c 1:\"BIOS boot\" %s", drive
        );
        printf("> %s\n", command);
        fflush(stdout);
        if (system(command) != 0)
            return 1;
    } else {
        snprintf(command, sizeof(command),
            "sgdisk -n 2:0:+512M -t 2:ef00 -c 2:\"EFI System\" %s", drive
        );
        printf("> %s\n", command);
        fflush(stdout);
        if (system(command) != 0)
            return 1;
    }

    snprintf(command, sizeof(command),
        "sgdisk -n 3:0:0 -t 3:8300 -c 3:\"Redrose Linux\" %s", drive
    );
    printf("> %s\n", command);
    fflush(stdout);
    if (system(command) != 0)
        return 1;

    clear();
    installing_header();
    printf("\n");
    separator();
    printf("\n");

    snprintf(command, sizeof(command), "busybox partprobe %s", drive);
    printf("> %s\n", command);
    fflush(stdout);
    if (system(command) != 0)
        return 1;

    char *efi_part = get_partition(drive, 2);
    char *root_part = get_partition(drive, 3);

    snprintf(command, sizeof(command), "mkfs.vfat -F32 %s", efi_part);
    printf("> %s\n", command);
    fflush(stdout);
    if (system(command) != 0)
        return 1;

    clear();
    installing_header();
    printf("\n");
    separator();
    printf("\n");
    snprintf(command, sizeof(command), "busybox mke2fs -F %s", root_part);
    printf("> %s\n", command);
    fflush(stdout);
    return system(command);
}

int copy_root(char* drive) {
    printf("mounting root\n");
    mount(get_partition(drive, 3), "/mnt", "ext2", 0, 0);
    printf("> tar -xf rootfs.tar -C /mnt --strip-components=1\n");
    return system("tar -xf rootfs.tar -C /mnt --strip-components=1");
}

int install_grub(char* drive) {
    char command[256];
    char grub_install[] = "chroot /mnt /bin/sh -c '"
        "mkdir -p /proc &&mount -t proc proc /proc && "
        "mkdir -p /sys &&mount -t sysfs sys /sys && "
        "mkdir -p /dev &&mount -t devtmpfs dev /dev && "
        "grub-install";
    // craft a command to install grub for specifications.
    if (detect_efi() == 64) {
        printf("Mounting ESP\n");
        mount(get_partition(drive, 2), "/boot/efi", "vfat", 0, 0);
        snprintf(command, sizeof(command),
            "%s --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck %s --directory=/lib/grub/x86_64-efi'",
            grub_install, drive
        );
    } else {
        snprintf(command, sizeof(command),
            "%s --target=i386-pc --recheck %s' --directory=/lib/grub/i386-pc", grub_install, drive
        );
    }
    return system(command);
}

int patch(char* drive) {
    return 0;
    // TODO
}

int localhost(char* name) {
    char command[256];
    if (name[0] == '\n') {
        snprintf(command, sizeof(command), "busybox chroot /mnt /bin/sh -c 'mkdir -p /etc &&echo iuseredrosebtw > /etc/hostname'");
    } else {
        name[strcspn(name, "\n")] = 0;
        snprintf(command, sizeof(command), "busybox chroot /mnt /bin/sh -c 'mkdir -p /etc &&echo %s > /etc/hostname'", name);
    }
    return system(command);
}
