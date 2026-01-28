#include <stdio.h>

// this file generates post-installation scripts
// was ai used in this file? no

int gen_postinst_scripts(
    char* drive,
    char* username,
    char* userpassword,
    char* rootpassword,
    char* hostname) { // this func isnt finished
        printf("gen_postinst_scripts() is not finished. FYI that this ran\n");
        printf("this is because we have to switch from .iso for rootfs.\n");

        if (!drive ||
            !hostname ||
            !username ||
            !userpassword ||
            !rootpassword) {
                return -1;
        }

        // first generate the script file
        char script[512];
        snprintf(script, sizeof(script),
            "#!/bin/sh\n"
            "touch /etc/os-release\n"
            "echo 'NAME=\"Redrose Linux\"' >> /etc/os-release\n"
            "echo 'ID=redroselinux' >> /etc/os-release\n"
            "echo 'PRETTY_NAME=\"Redrose Linux\"' >> /etc/os-release\n"
            "echo 'HOME_URL=\"https://redroselinux.is-a.software\"' >> /etc/os-release\n"
            "echo '%s' > /etc/hostname\n",
            hostname
        );

        // TODO: we need car to install shadow to set up users

        return 0;
    }
