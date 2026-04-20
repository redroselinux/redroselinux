import os

packagelist = open("/etc/car/packagelist", "r").read()
package = input()
with open("rootfs/filesystem/etc/repro.car", "a") as f:
    f.write(package + "\n")
os.system("mkdir -p strap_packages")
for i in packagelist.splitlines():
    if i.startswith(f"{package} - "):
        url = i.split(" - ")[1]
        print("downloading " + url)
        if not os.path.exists("strap_packages/" + package + ".tar.zst"):
            os.system("curl -# -L -o strap_packages/" + package + ".tar.zst " + url)
        print("installing " + package)
        os.system(
            "tar -I zstd -xf strap_packages/"
            + package
            + ".tar.zst -C rootfs/filesystem --strip-components=1"
        )
        break

os.system("rm -f rootfs/filesystem/car")
