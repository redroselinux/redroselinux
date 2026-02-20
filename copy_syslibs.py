import os

print(
    "Hello! This script copies system libraries to the source, so you can test the new installer "
    "before we build the binaries ourselves. This will get deleted after we build the binaries."
)

print(
    "We need root permissions to run this script. For that reason, we will run 'sudo true' right now and sudo will remember it."
)

os.system("sudo true")

os.system("mkdir -p rootfs/filesystem/lib")
os.system("mkdir -p rootfs/filesystem/lib64")
os.system("mkdir -p rootfs/filesystem/lib/x86_64-linux-gnu")
os.system("cp /lib/x86_64-linux-gnu/liblzma.so.5 rootfs/filesystem/lib")
os.system(
    "cp /lib/x86_64-linux-gnu/libdevmapper.so.1.02.1 rootfs/filesystem/lib/x86_64-linux-gnu/"
)
os.system(
    "cp /lib/x86_64-linux-gnu/libefivar.so.1 rootfs/filesystem/lib/x86_64-linux-gnu/"
)
os.system(
    "cp /lib/x86_64-linux-gnu/libefiboot.so.1 rootfs/filesystem/lib/x86_64-linux-gnu/"
)
os.system("cp /lib/x86_64-linux-gnu/libc.so.6 rootfs/filesystem/lib/x86_64-linux-gnu/")
os.system(
    "cp /lib/x86_64-linux-gnu/libselinux.so.1 rootfs/filesystem/lib/x86_64-linux-gnu/"
)
os.system(
    "cp /lib/x86_64-linux-gnu/libudev.so.1 rootfs/filesystem/lib/x86_64-linux-gnu/"
)
os.system("cp /lib/x86_64-linux-gnu/libm.so.6 rootfs/filesystem/lib/x86_64-linux-gnu/")
os.system("cp /lib64/ld-linux-x86-64.so.2 rootfs/filesystem/lib64/")
os.system(
    "cp /lib/x86_64-linux-gnu/libpcre2-8.so.0 rootfs/filesystem/lib/x86_64-linux-gnu/"
)
os.system(
    "cp /lib/x86_64-linux-gnu/libcap.so.2 rootfs/filesystem/lib/x86_64-linux-gnu/"
)
os.system("cp /usr/sbin/grub-install rootfs/filesystem/bin/")
os.system("cp /usr/lib")
