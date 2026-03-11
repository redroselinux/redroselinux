import os

packagelist = open("/etc/car/packagelist", "r").read()
package = input()
for i in packagelist.splitlines():
    if i.startswith(f"{package} - "):
        url = i.split(" - ")[1]
        print("downloading " + url)
        if not os.path.exists(package + ".tar.zst"):
            os.system("curl -# -L -o " + package + ".tar.zst " + url)
        print("installing " + package)
        os.system("tar -I zstd -xf " + package + ".tar.zst -C rootfs/filesystem --strip-components=1")
        break

os.system("rm -f rootfs/filesystem/car")