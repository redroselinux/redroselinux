import os

# was ai used in this script? no

os.system("cp /usr/sbin/grub-install rootfs/filesystem/bin/")

if not os.path.exists("libcp"):
    print("Downloading libcp...")
    os.system(
        "curl -# -L -o libcp https://github.com/redroselinux/libcp/releases/download/v0.1/libcp"
    )
    os.system("chmod +x libcp")
else:
    print("libcp already exists, skipping download.")

os.system("./libcp rootfs/filesystem/bin/grub-install rootfs/filesystem")
os.system("cp /usr/lib/grub rootfs/filesystem/lib/ -r")
os.system("mkdir -p rootfs/filesystem/usr/lib/")
os.system("cp /usr/lib/grub rootfs/filesystem/usr/lib/ -r")
