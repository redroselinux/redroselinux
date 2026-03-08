import os

# was ai used in this script? no

print(
    "We need root permissions to run this script. For that reason, we will run 'sudo true' right now and sudo will remember it."
)

os.system("sudo true")
os.system("sudo cp /usr/sbin/grub-install rootfs/filesystem/bin/")

if not os.path.exists("libcp"):
    print("Downloading libcp...")
    os.system(
        "curl -# -L -o libcp https://github.com/redroselinux/libcp/releases/download/v0.1/libcp"
    )
    os.system("chmod +x libcp")
else:
    print("libcp already exists, skipping download.")

os.system("sudo ./libcp rootfs/filesystem/bin/grub-install rootfs/filesystem")
os.system("sudo cp /usr/lib/grub rootfs/filesystem/lib/ -r")
os.system("sudo mkdir -p rootfs/filesystem/usr/lib/")
os.system("sudo cp /usr/lib/grub rootfs/filesystem/usr/lib/ -r")
