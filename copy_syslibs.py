import os

print(
    "We need root permissions to run this script. For that reason, we will run 'sudo true' right now and sudo will remember it."
)

os.system("sudo true")

print("Downloading libcp")
os.system(
    "curl -L -o libcp https://github.com/redroselinux/libcp/releases/download/v0.1/libcp &&chmod +x libcp"
)
os.system("sudo ./libcp rootfs/filesystem/bin/grub-install rootfs/filesystem")
