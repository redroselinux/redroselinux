#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <sys/stat.h>
#include <sys/sysmacros.h>
#include <sys/mount.h>

#include "common.h"
#include "drive_uuid.h"
#include <unistd.h>

// backend for installer.
//
// was ai used in this file? yes
//    (functions: list_dev, partition_drive, format_partitions, no_drives_repl, makefs)

// get the partition device file from the drive
// takes the drive and partition number, returns the partition device file
char* get_partition(const char* drive, int partnum) {
    static char buf[64];
    if (strncmp(drive, "/dev/nvme", 9) == 0 || strncmp(drive, "/dev/mmcblk", 11) == 0) {
        snprintf(buf, sizeof(buf), "%sp%d", drive, partnum);
    } else {
        snprintf(buf, sizeof(buf), "%s%d", drive, partnum);
    }
    return buf;
}

// runs when no drive found
static inline void no_drives_repl(void) {
    set_text_color(RED);
    printf("- no drives found! ");
    set_text_color(RESET);
    printf("starting a recovery shell");
    system("/bin/sh");
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

// check if the computer is booted in BIOS or EFI mode
// returns 64 on EFI and 32 on BIOS
//
// if /sys/firmware/efi exists, we are booted in efi
// this is inspired by the archwiki where you check
// this by uefi bitness, and it was 64 and 32. so i
// put it in here because it looks super cool lmfao
//
// https://wiki.archlinux.org/title/Installation_guide#Verify_the_boot_mode
int detect_efi() {
    int boot_mode;

    if (access("/sys/firmware/efi", F_OK) == 0) {
        return 64;
    } else {
        return 32;
    }
}

// sanitize input for functions running a shell
int sanitize_input(char* input) {
    char *p = input;
    while (*p) {
        if (*p == '$' || *p == '(' || *p == ')' || *p == ';' || *p == '\'') {
            *p = '_';
        }
        p++;
    }
    return 0;
}

// lists devices, returns the number of them
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
    char command[256];
    snprintf(command, sizeof(command), "sgdisk --zap-all %s", drive);
    printf("> %s\n", command);
    fflush(stdout);
    return system(command);
}

// creates filesystems and partitions
// uses detect_efi() to create the boot partition (BIOS boot/ESP)
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
            "sgdisk -n 2:0:+512M -t 2:ef00 -c 1:\"EFI System\" %s", drive
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

    snprintf(command, sizeof(command), "busybox mke2fs -F %s", root_part);
    printf("> %s\n", command);
    fflush(stdout);
    return system(command);
}

// mounts the installation drive and copies the root files to there
int copy_root(char* drive) {
    printf("  Mounting %s\n", get_partition(drive, 3));
    mount(get_partition(drive, 3), "/mnt", "ext2", 0, 0);
    printf("  Extracting /rootfs.tar.gz to /mnt. This may take a while...\n");
    return system("busybox gzip -dc rootfs.tar.gz | busybox tar -xf - -C /mnt --strip-components=1");
}

// create users, set root password
int create_users(char *username, char *password, char *root_password) {
    username[strcspn(username, "\n")] = '\0';
    if (username[0] == '\0') {
        strcpy(username, "redrose");
    }

    password[strcspn(password, "\n")] = '\0';
    if (password[0] == '\0') {
        strcpy(password, "redrose");
    }

    mkdir("/mnt/root", 0755);
    root_password[strcspn(root_password, "\n")] = '\0';
    if (root_password[0] == '\0') {
        strcpy(root_password, "redrose");
    }

    char useradd_cmd[256];
    mkdir("/mnt/home", 0755);
    char home_dir[50];
    snprintf(home_dir, sizeof(home_dir), "/mnt/home/%s", username);
    mkdir(home_dir, 0755);

    snprintf(useradd_cmd, sizeof(useradd_cmd),
        "busybox chroot /mnt /bin/adduser -D -h /home/%s %s",
        username, username);

    if (system(useradd_cmd) != 0) {
        return 1;
    }

    printf("adduser: created user '%s'\n", username);

    char sanitized[128];
    strncpy(sanitized, password, sizeof(sanitized) - 1);
    sanitized[sizeof(sanitized) - 1] = '\0';
    sanitize_input(sanitized);

    char command[256];
    snprintf(command, sizeof(command),
        "busybox chroot /mnt /bin/sh -c 'echo \"%s:%s\" | busybox chpasswd'",
        username, sanitized);

    if (system(command) != 0) {
        return 1;
    }

    strncpy(sanitized, root_password, sizeof(sanitized) - 1);
    sanitized[sizeof(sanitized) - 1] = '\0';
    sanitize_input(sanitized);

    snprintf(command, sizeof(command),
        "busybox chroot /mnt /bin/sh -c 'echo \"root:%s\" | busybox chpasswd'",
        sanitized);

    return system(command);
}

// installs GRUB, checks for EFI/BIOS using detect_efi()
// * https://man.voidlinux.org/grub-install
int install_grub(char* drive) {
    char command[1024];
    char grub_install[] = "busybox chroot /mnt /bin/sh -c '"
        "export LD_LIBRARY_PATH=/usr/lib:/lib:/usr/lib64:/lib64 &&"
        "busybox mkdir -p /proc &&mount -t proc proc /proc && "
        "busybox mkdir -p /sys &&mount -t sysfs sys /sys && "
        "busybox mkdir -p /dev &&mount -t devtmpfs dev /dev && "
        "grub-install";
    if (detect_efi() == 64) {
        printf("Mounting ESP\n");
        system("busybox mkdir -p /boot/");
        system("busybox mkdir -p /boot/efi");
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

// enables propriertary software repo in car
// * https://redroselinux.miraheze.org/wiki/Car_Package_Manager#Updating_the_system
int propriertary_(char*) {
    FILE *file = fopen("/mnt/etc/car_propiertary.lock", "w");
    if (file == NULL) {
        printf("Enabling propriertary software failed");
        return 1;
    }
    fclose(file);
    return 0;
}

// sanitizes and sets the hostname of the newly installed system
// writes to /etc/hostname; init sets it in /proc automatically
// * rootfs/filesystem/sbin/init
int localhost(char *name) {
    const char *default_name = "iuseredrosebtw";
    char *hostname = name;
    if (name[0] == '\n' || name[0] == '\0') {
        hostname = (char *)default_name;
    } else {
        int issues = 0;
        char *cursor = name;
        while (*cursor) {
            if (*cursor == '.') {
                set_text_color(YELLOW);
                printf("  No dots are allowed in a hostname. Changing to -.\n");
                set_text_color(RESET);
                issues++;
                *cursor = '-';
            } else if (cursor == name && *cursor == '-') {
                set_text_color(YELLOW);
                printf("  A hostname cannot start with '-'.\n");
                set_text_color(RESET);
                memmove(name, name + 1, strlen(name));
                issues++;
            } else if (*(cursor + 2) == '\0' && *cursor == '-') {
                set_text_color(YELLOW);
                printf("  A hostname cannot end with '-'.\n");
                set_text_color(RESET);
                *cursor = '\0';
                issues++;
                break;
            } else if (*cursor == '_') {
                set_text_color(YELLOW);
                printf("  Underscores are not allowed. Changing to -.\n");
                set_text_color(RESET);
                *cursor = '-';
                issues++;
            } else if (*cursor == '!' || *cursor == '@' || *cursor == '#' || *cursor == '$' ||
                       *cursor == '%' || *cursor == '^' || *cursor == '&' || *cursor == '*' ||
                       *cursor == '(' || *cursor == ')' || *cursor == '_' || *cursor == '=' ||
                       *cursor == '+' || *cursor == '[' || *cursor == ']' || *cursor == '{' ||
                       *cursor == '}' || *cursor == '|' || *cursor == '\\' || *cursor == ':' ||
                       *cursor == ';' || *cursor == '"' || *cursor == '\'' || *cursor == '<' ||
                       *cursor == '>' || *cursor == ',' || *cursor == '?' || *cursor == '/' ||
                       *cursor == '`' || *cursor == '~') {
                set_text_color(YELLOW);
                printf("  A hostname cannot contain special characters as %c. Changing to -.\n", *cursor);
                set_text_color(RESET);
                issues++;
                *cursor = '-';
            }
            cursor++;
        }
        if (issues > 0) {
            printf("  The installer had to alter your hostname to fix %d issues.\n  This is the result: %s\n"
                   "\e[91m*\e[0m Press ENTER to continue..."
                   , issues, hostname);
            getchar();
        }
        hostname[strcspn(hostname, "\n")] = '\0';
    }
    FILE *f = fopen("/mnt/etc/hostname", "w");
    if (!f) {
        perror("fopen");
        return -1;
    }
    fprintf(f, "%s\n", hostname);
    fclose(f);
    return 0;
}

// initialize car. since we do not have an internet connection, expect failure
int init_car(char*) {
    set_text_color(YELLOW);
    printf("THIS IS SUPPOSED TO FAIL. DO NOT MIND THE ERROR MESSAGES.\n");
    set_text_color(RESET);
    system("busybox yes 1 | busybox chroot /mnt /bin/sh -c '/bin/car init'");
    return 0;
}

int install_utils(char*) {
    clear();
    int sel = install_utils_ui();
    mkdir("/mnt/sbin", 0755);
    // TODO: completely eliminate busybox; currently redrose requires it
    if (system("busybox chroot /mnt /bin/sh -c '/bin/busybox --install'") != 0) {
        return 1;
    }
    if (sel == 0) {
        if (system("busybox sh -c 'busybox tar -xf /coreutils-gnu/coreutils.tar.gz -C /mnt --strip-components=1'") != 0)
            return 1;
        if (system("busybox sh -c 'busybox tar -xf /coreutils-gnu/findutils.tar.gz -C /mnt --strip-components=1'") != 0)
            return 1;
    } else if (sel == 1) {
        // TODO: after removing needed busybox the install busybox branch goes here
        return 0;
    } else if (sel == 2) {
        if (system("busybox sh -c 'busybox tar -xf /coreutils-uutils/uu-coreutils.tar.gz -C /mnt --strip-components=1'") != 0)
            return 1;
        if (system("busybox sh -c 'busybox tar -xf /coreutils-uutils/uu-findutils.tar.gz -C /mnt --strip-components=1'") != 0)
            return 1;
    } else {
        return 1;
    }
    clear();
    return 0;
}

// regenerate initramfs (nullinitrd) and fstab (mkfstab)
// * src/mkfstab/src/generate.rs
// * https://github.com/NULL-GNU-Linux/nullinitrd
int regenerate_initramfs_fstab(char*) {
    return system(
        "mount --bind /proc /mnt/proc && "
        "mount --bind /sys /mnt/sys && "
        "mount --bind /dev /mnt/dev && "
        "busybox mkdir -p /mnt/tmp && "
        "mount -t tmpfs tmp /mnt/tmp && "
        "busybox chroot /mnt /bin/sh -c "
            "'export LD_LIBRARY_PATH=/usr/lib:/lib:/lib64:/usr/local/lib && "
            "export PATH=/usr/bin:/bin:/sbin && "
            "/usr/bin/nullinitrd && /usr/bin/mkfstab /' ; "
        "busybox umount /mnt/dev ; "
        "busybox umount /mnt/sys ; "
        "busybox umount /mnt/proc ; "
        "busybox umount /mnt/tmp"
    );
}

// patches and fixes
// currently does:
// - fixes perms
// - edits grub config
int patch(char* drive) {
    printf("  Fixing permissions for some files\n");
    chmod("/mnt/etc/init.d/rcS", 0755);
    chmod("/mnt/bin/su", 4755);
    chmod("/mnt/bin/busybox", 4755);

    printf("  Patching GRUB config to change root= entry\n");
    printf("  not finished - for now uses drive instead of uuid\n");
    // not finished - for now uses drive instead of uuid
    /* char uuid_cmd[256];
    char uuid[64] = {0};
    char *drive_ = get_partition(drive, 3);

    snprintf(uuid_cmd, sizeof(uuid_cmd),
        "/bin/busybox blkid %s | /bin/busybox grep -o 'UUID=\"[^\"]*\"' | /bin/busybox cut -d'\"' -f2",
        drive_);
    printf("Running: %s\n", uuid_cmd);

    FILE *fp = popen(uuid_cmd, "r");
    if (!fp) { printf("popen failed\n"); return 1; }
    if (!fgets(uuid, sizeof(uuid), fp)) { printf("blkid returned nothing\n"); pclose(fp); return 1; }
    pclose(fp);
    uuid[strcspn(uuid, "\n")] = 0;
    printf("UUID: '%s'\n", uuid);
    */
    char sed_cmd[512];
    snprintf(sed_cmd, sizeof(sed_cmd),
        "/bin/busybox sed -i 's|root=/dev/sda3|root=%s|g' /mnt/boot/grub/grub.cfg",
        get_partition(drive, 3));
    if (DEBUG == 1)
        printf("  Running: %s\n", sed_cmd);
    int r = system(sed_cmd);
    if (DEBUG == 1)
        printf("  sed exit: %d\n", r);
    return r;
}

// lets the user chroot into the newly installed system or run a shell in the live system
int chroot_(char *h) {
    clear();
    installed_header();
    printf("Your Redrose Linux system was installed. You can chroot into it or continue to unmount /mnt.\n\n");
    separator();
    printf("\n");

    char buf[8];
    printf("Do you wish to chroot into the mounted system before it's unmounted? [N/y] ");
    if (fgets(buf, sizeof(buf), stdin)) {
        if (buf[0] == 'y' || buf[0] == 'Y') {
            system("busybox chroot /mnt /bin/sh");
        }
    }

    printf("Do you wish to run /bin/sh in this live enviroment? [N/y] ");
    if (fgets(buf, sizeof(buf), stdin)) {
        if (buf[0] == 'y' || buf[0] == 'Y') {
            system("/bin/sh");
        }
    }

    return 0;
}

// helper to unmount the root in main.c
static int umount_detach(char *path) {
    sync();
    if (umount2(path, MNT_DETACH) != 0) {
        return -1;
    }
    return 0;
}
