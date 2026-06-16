import os
import re
import subprocess

import fix_usr_local

"""
Bootstrap packages into rootfs/filesystem. Basically a very simple version of Car.
Requires Car to be installed and initialized.
Usage:
    echo "package" | python3 strap.py
Prints an error message and exits 1 if package is not found.
On success, prints the version of the package and adds it to rootfs/filesystem/etc/repro.car, then exits 0.
"""

packagelist = ""
try:
    packagelist = open("/etc/car/packagelist", "r").read()
except:
    print("  => Car not initialized, updating packagelist...")
    if (
        os.system(
            "sudo mkdir -p /etc/car && sudo curl -# -L -o /etc/car/packagelist https://github.com/redroselinux/car3-pkgs/raw/refs/heads/main/README"
        )
        != 0
    ):
        print("  => Failed to update packagelist")
        exit(1)
    else:
        try:
            packagelist = open("/etc/car/packagelist", "r").read()
        except:
            print("  => Still failed to read packagelist")
            exit(1)

currently_at_package = False
version = ""
install_to = "rootfs/filesystem"
package = input()
with open("rootfs/filesystem/etc/redrose-strap", "a", encoding="utf-8") as strap_log:
    strap_log.write(package + "\n")
if package == "":
    exit(0)
elif package.startswith("--"):
    exit(0)

compress = False
recompress = False
if ":" in package:
    parts = package.split(":")
    package = parts[0]
    install_to = parts[1]

    if package == "remove":
        package = re.sub(r'[^a-zA-Z0-9._+\-]', '', os.path.basename(parts[1]))
        if not package:
            print("  ==> Error: invalid package name")
            exit(1)
        print(f"=> Uninstalling {package}")

        # read the save file
        save = ""
        safe_save_path = os.path.join("rootfs/filesystem/etc/car/saves", package)
        with open(safe_save_path, "r") as f:
            save = f.read()

        # delete all the files
        for line in save.splitlines():
            if line == "car":
                continue  # skip file already deleted

            file_to_delete = "rootfs/filesystem/" + line
            os.remove(file_to_delete)
        exit()

    if len(parts) >= 3:
        if parts[2] == "compress-installed-folder":
            compress = True
        if parts[2] == "recompress":
            recompress = True

if not re.match(r'^[a-zA-Z0-9._+\-]+$', package):
    print("  ==> Error: invalid package name")
    exit(1)

os.makedirs("strap_packages", exist_ok=True)
os.makedirs(install_to, exist_ok=True)
os.makedirs(f"{install_to}/etc/car/saves", exist_ok=True)

for i in packagelist.splitlines():
    if i.startswith(f"{package} - "):
        print("=> Installing " + package)
        currently_at_package = True
        url = i.split(" - ")[1]
        tarball = "strap_packages/" + package + ".tar.zst"
        if not os.path.exists(tarball):
            print("  -> " + tarball)
            os.system("curl -# -L -o " + tarball + " " + url)

        if recompress:
            print("  ==> Recompressing " + package)
            os.system(f"zstd -d {tarball} -o /tmp/{package}.tar --force")
            print("  ==> Decompressed .zst to .tar")
            os.system(f"gzip -f /tmp/{package}.tar")
            print("  -> " + install_to + "/" + package + ".tar.gz")
            os.system(f"mv /tmp/{package}.tar.gz {install_to}/{package}.tar.gz")
            exit(0)

        save_path = install_to + "/etc/car/saves/" + package
        result = subprocess.run(
            f"tar -I 'zstd -T0' -xvf {tarball} -C {install_to} --strip-components=1 "
            f"| sed 's|^[^/]*/||' | grep -v '/$' > {save_path}",
            shell=True,
        )
        fix_usr_local.check_and_fix()
        if result.returncode != 0:
            print("  ==> Error: failed to unpack " + package)
            exit(1)
        if compress:
            print("  ==> Compressing " + package)
            os.system(f"tar -cf /tmp/{package}.tar -C {install_to} .")
            os.system(f"gzip -f /tmp/{package}.tar")
            print("  -> " + install_to + "/" + package + ".tar.gz")
            os.system(f"mv /tmp/{package}.tar.gz {install_to}/{package}.tar.gz")
            os.system(f"rm -rf {install_to}/usr")

    elif currently_at_package:
        if i.startswith("version "):
            version = i.split(" ")[1]
            with open("rootfs/filesystem/etc/repro.car", "a") as f:
                f.write(package + "=" + version + "\n")
        break

if not currently_at_package:
    print("  ==> Package not found")
    exit(1)

os.system(f"rm -f {install_to}/car")
