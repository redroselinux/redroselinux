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

packagelist = ""
try:
    packagelist = open("/etc/car/packagelist", "r").read()
except:
    print("car was not initialized. manually updating packagelist...")
    if (
        os.system(
            "sudo mkdir -p /etc/car && sudo curl -# -L -o /etc/car/packagelist https://github.com/redroselinux/car3-pkgs/raw/refs/heads/main/README"
        )
        != 0
    ):
        print(
            "failed to manually update packagelist. install car and init it (you will need --force)."
        )
        exit(1)
    else:
        try:
            packagelist = open("/etc/car/packagelist", "r").read()
        except:
            print("still failed to read packagelist. error is fatal; exiting.")
            exit(1)

currently_at_package = False
version = ""
install_to = "rootfs/filesystem"
package = input()
open("rootfs/filesystem/etc/redrose-strap", "a").write(package + "\n")
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

    if len(parts) >= 3:
        if parts[2] == "compress-installed-folder":
            compress = True
        if parts[2] == "recompress":
            recompress = True

os.makedirs("strap_packages", exist_ok=True)
os.makedirs(install_to, exist_ok=True)
os.makedirs(f"{install_to}/etc/car/saves", exist_ok=True)

for i in packagelist.splitlines():
    if i.startswith(f"{package} - "):
        print("installing " + package)
        currently_at_package = True
        url = i.split(" - ")[1]
        print("downloading " + url)
        tarball = "strap_packages/" + package + ".tar.zst"
        if not os.path.exists(tarball):
            os.system("curl -# -L -o " + tarball + " " + url)

        if recompress:
            print("Recompressing package... (this may take a while)")
            os.system(f"zstd -d {tarball} -o /tmp/{package}.tar --force")
            print("Decompressed .zst to .tar")
            os.system(f"gzip -f /tmp/{package}.tar")
            print("Created compressed package.")
            os.system(f"mv /tmp/{package}.tar.gz {install_to}/{package}.tar.gz")
            print("Moved recompressed package.")
            exit(0)

        save_path = install_to + "/etc/car/saves/" + package
        result = subprocess.run(
            f"tar -I 'zstd -T0' -xvf {tarball} -C {install_to} --strip-components=1 "
            f"| sed 's|^[^/]*/||' | grep -v '/$' > {save_path}",
            shell=True,
        )
        if result.returncode != 0:
            print(f"error: failed to unpack {tarball}")
            exit(1)
        if compress:
            print("Compressing package... (this may take a while)")
            os.system(f"tar -cf /tmp/{package}.tar -C {install_to} .")
            print("Created uncompressed package.")
            os.system(f"gzip -f /tmp/{package}.tar")
            print("Created compressed package.")
            os.system(f"mv /tmp/{package}.tar.gz {install_to}/{package}.tar.gz")
            print("Moved compressed package.")
            os.system(f"rm -rf {install_to}/usr")

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

os.system(f"rm -f {install_to}/car")
