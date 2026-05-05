import os
import subprocess

"""
Bootstrap packages into rootfs/filesystem. Basically a very simple version of Car.
Requires Car to be installed and initialized.
Usage:
    echo "package" | python3 strap.py
Prints an error message and exits 1 if package is not found.
On success, prints the version of the package and adds it to rootfs/filesystem/etc/repro.car, then exits 0.
"""

packagelist = open("/etc/car/packagelist", "r").read()
version = ""
package = input()
currently_at_package = False

os.makedirs("strap_packages", exist_ok=True)
os.makedirs("rootfs/filesystem/etc/car/saves", exist_ok=True)

for i in packagelist.splitlines():
    if i.startswith(f"{package} - "):
        print("installing " + package)
        currently_at_package = True
        url = i.split(" - ")[1]
        print("downloading " + url)
        tarball = "strap_packages/" + package + ".tar.zst"
        if not os.path.exists(tarball):
            os.system("curl -# -L -o " + tarball + " " + url)

        save_path = "rootfs/filesystem/etc/car/saves/" + package
        result = subprocess.run(
            f"tar -I 'zstd -T0' -xvf {tarball} -C rootfs/filesystem --strip-components=1 "
            f"| sed 's|^[^/]*/||' | grep -v '/$' > {save_path}",
            shell=True,
        )
        if result.returncode != 0:
            print(f"error: failed to unpack {tarball}")
            exit(1)

    elif currently_at_package:
        if i.startswith("version "):
            version = i.split(" ")[1]
            print("version " + version)
            with open("rootfs/filesystem/etc/repro.car", "a") as f:
                f.write(package + "=" + version + "\n")
        break

if not currently_at_package:
    print("package not found")
    exit(1)

os.system("rm -f rootfs/filesystem/car")
