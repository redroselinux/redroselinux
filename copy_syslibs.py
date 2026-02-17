import os

from rich.progress import Progress

print(
    "Hello! This script copies system libraries to the source, so you can test the new installer "
    "before we build the binaries ourselves. This will get deleted after we build the binaries."
)

print(
    "We need root permissions to run this script. For that reason, we will run 'sudo true' right now."
)

os.system("sudo true")

copy_files = [
    "/lib/x86_64-linux-gnu/liblzma.so.5",
    "/lib/x86_64-linux-gnu/libdevmapper.so.1.02.1",
    "/lib/x86_64-linux-gnu/libefivar.so.1",
    "/lib/x86_64-linux-gnu/libefiboot.so.1",
    "/lib/x86_64-linux-gnu/libc.so.6",
    "/lib/x86_64-linux-gnu/libselinux.so.1",
    "/lib/x86_64-linux-gnu/libudev.so.1",
    "/lib/x86_64-linux-gnu/libm.so.6",
    "/lib64/ld-linux-x86-64.so.2",
    "/lib/x86_64-linux-gnu/libpcre2-8.so.0",
    "/lib/x86_64-linux-gnu/libcap.so.2",
    "/usr/lib/grub",
]

with Progress() as progress:
    task = progress.add_task("[cyan]Copying...", total=len(copy_files) + 1)

    os.system("mkdir -p rootfs/filesystem/lib64")
    os.system("mkdir -p rootfs/filesystem/lib")
    os.system("mkdir -p rootfs/filesystem/usr")
    os.system("mkdir -p rootfs/filesystem/usr/lib")

    for file in copy_files:
        os.system(f"sudo cp --parents -r {file} rootfs/filesystem")
        progress.advance(task)

    os.system("mv rootfs/filesystem/grub rootfs/filesystem/usr/lib")
    progress.advance(task)

print("Done!")
