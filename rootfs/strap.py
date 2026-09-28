import os
import subprocess
import sys

"""
Bootstrap packages into rootfs/filesystem. Basically a very simple version of Car.
Requires Car to be installed and initialized for the packagelist.
A package already present in strap_packages/ is installed without needing a
packagelist entry; the packagelist is only used to fetch missing tarballs and
to record versions in rootfs/filesystem/etc/repro.car. For packages that are not
in the packagelist, the version is read from the /car manifest shipped in the
package itself.
Usage:
  echo "package" | python3 strap.py
Prints an error message and exits 1 if package is neither in strap_packages/
nor found in the packagelist.
On success, prints the version of the package and adds it to rootfs/filesystem/etc/repro.car, then exits 0.
"""

def exec(command, shell=True, capture=False, exit_on_error=True):
  """
  Execute a command with subprocess.

  Args:
    command: Command string or list
    shell: Run through shell if True (default True)
    capture: Return output if True, else print to stdout/stderr (default False)
    exit_on_error: Exit on non-zero return code (default True)

  Returns:
    CompletedProcess object if capture=True, else None
  """
  try:
    result = subprocess.run(command, shell=shell, capture_output=capture, text=True)

    if result.returncode != 0:
      if capture:
        print(result.stderr or result.stdout, file=sys.stderr)
      if exit_on_error:
        sys.exit(result.returncode)

    if capture:
      return result

    return result.returncode
  except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    if exit_on_error:
      sys.exit(1)
    return None


def read_car_manifest_version(car_manifest):
  """
  Read the version out of a package's /car manifest (e.g. rootfs/base-fs/car).
  Used for packages that are not in the packagelist, since the manifest
  shipped in the package itself is the only place recording the version.

  Args:
    car_manifest: Path to the manifest file

  Returns:
    The version as a string, or "" if the manifest is unreadable
    or has no version field
  """
  try:
    with open(car_manifest, "r", encoding="utf-8") as f:
      for line in f:
        fields = line.split()
        if len(fields) >= 2 and fields[0] == "version":
          return fields[1]
  except OSError:
    pass
  return ""


packagelist = ""
try:
  packagelist = open("/etc/car/packagelist", "r").read()
except FileNotFoundError, OSError, IOError:
  print("  => Car not initialized, updating packagelist...")
  escalate = os.getenv("ESCALATE_PROG", "sudo")
  if (
    exec(
      f"{escalate} mkdir -p /etc/car && {escalate} curl -# -L -o /etc/car/packagelist https://github.com/redroselinux/car3-pkgs/raw/refs/heads/main/README",
      shell=True,
    )
    != 0
  ):
    print("  => Failed to update packagelist")
    exit(1)
  else:
    try:
      packagelist = open("/etc/car/packagelist", "r").read()
    except Exception:
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
    package = parts[1]
    print(f"=> Uninstalling {package}")

    if len(parts) == 3:
      install_to = parts[2]

    # read the save file
    save = ""
    with open(f"{install_to}/etc/car/saves/{package}", "r") as f:
      save = f.read()

    # delete all the files
    for line in save.splitlines():
      if line == "car":
        continue  # skip file already deleted

      file_to_delete = f"{install_to}/{line}"
      os.remove(file_to_delete)
    exit()

  if len(parts) >= 3:
    if parts[2] == "compress-installed-folder":
      compress = True
    if parts[2] == "recompress":
      recompress = True

os.makedirs("strap_packages", exist_ok=True)
os.makedirs(install_to, exist_ok=True)
os.makedirs(f"{install_to}/etc/car/saves", exist_ok=True)

tarball = "strap_packages/" + package + ".tar.zst"
url = ""
version = ""

lines = packagelist.splitlines()
for index, i in enumerate(lines):
  if i.startswith(f"{package} - "):
    currently_at_package = True
    url = i.split(" - ")[1]
    for next_line in lines[index + 1:]:
      if next_line.startswith("version "):
        version = next_line.split(" ")[1]
        break
    break

if not currently_at_package and not os.path.exists(tarball):
  print(f"=x Package {package} not found")
  exit(1)

print("=> Installing " + package)
if not os.path.exists(tarball):
  print("  -> " + tarball)
  exec("curl -# -L -o " + tarball + " " + url)

if recompress:
  print("  ==> Recompressing " + package)
  exec(f"zstd -d {tarball} -o /tmp/{package}.tar --force")
  print("  ==> Decompressed .zst to .tar")
  exec(f"{os.getenv("GZIP_PATH", "gzip")} -f /tmp/{package}.tar")
  print("  -> " + install_to + "/" + package + ".tar.gz")
  exec(f"mv /tmp/{package}.tar.gz {install_to}/{package}.tar.gz")
  exit(0)

save_path = install_to + "/etc/car/saves/" + package
result = subprocess.run(
  f"tar -I 'zstd -T0' -xvf {tarball} -C {install_to} --strip-components=1 "
  f"| sed 's|^[^/]*/||' | grep -v '/$' > {save_path}",
  shell=True,
)
if result.returncode != 0:
  print("  ==> Error: failed to unpack " + package)
  exit(1)
if compress:
  print("  ==> Compressing " + package)
  exec(f"tar -cf /tmp/{package}.tar -C {install_to} .")
  exec(f"{os.getenv("GZIP_PATH", "gzip")} -f /tmp/{package}.tar")
  print("  -> " + install_to + "/" + package + ".tar.gz")
  exec(f"mv /tmp/{package}.tar.gz {install_to}/{package}.tar.gz")
  os.removedirs(f"rm -rf {install_to}/usr")

if not version:
  version = read_car_manifest_version(f"{install_to}/car")

if version:
  with open("rootfs/filesystem/etc/repro.car", "a") as f:
    f.write(package + "=" + version + "\n")

car_file = f"{install_to}/car"
if os.path.exists(car_file):
  os.remove(car_file)
