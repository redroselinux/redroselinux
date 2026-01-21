#include <stdio.h>

// this file generates post-installation scripts
// was ai used in this file? no

int gen_postinst_scripts(
    char* drive,
    char* username,
    char* userpassword,
    char* rootpassword,
    char* hostname) {
        if (!drive || !hostname) return -1;

        // first generate the script file
        char script[512];
        snprintf(script, sizeof(script),
            "#!/bin/sh\n"
            "touch /etc/os-release\n"
            "echo 'NAME=\"Redrose Linux\"' >> /etc/os-release\n"
            "echo 'ID=redroselinux' >> /etc/os-release\n"
            "echo 'PRETTY_NA    ME=\"Redrose Linux\"' >> /etc/os-release\n"
            "echo 'HOME_URL=\"https://redroselinux.is-a.software\"' >> /etc/os-release\n"
            "echo '%s' > /etc/hostname\n",
            hostname
        );

        // mount the target
        char mount_cmd[128];
        snprintf(mount_cmd, sizeof(mount_cmd), "mount %s /mnt", drive);
        if (system(mount_cmd) != 0) {
            fprintf(stderr, "Failed to mount %s\n", drive);
            return -1;
        }

        // write the script to the target
        FILE* f = fopen("/mnt/postinst.sh", "w");
        if (!f) {
            perror("fopen /mnt/postinst.sh");
            system("umount /mnt");
            return -1;
        }
        fputs(script, f);
        fclose(f);

        // make the script executable
        if (system("chmod +x /mnt/postinst.sh") != 0) {
            fprintf(stderr, "Failed to chmod /mnt/postinst.sh\n");
            system("umount /mnt");
            return -1;
        }

        // add to init
        FILE* init = fopen("/mnt/init", "a");
        if (init) {
            fputs("/postinst.sh\n", init);
            fclose(init);
        } else {
            perror("fopen /mnt/init");
            system("umount /mnt");
            return -1;
        }

        // unmount the target
        system("umount /mnt");

        return 0;
    }
