<h1 align="center">
  <img width="32" height="32" alt="image" src="https://github.com/user-attachments/assets/2ae22b1a-0162-43c7-b522-c741fabbb9fb" />
  Redrose Linux
  
  ![Stars](https://img.shields.io/github/stars/redroselinux/redroselinux?style=flat)
  ![GitHub downloads](https://img.shields.io/github/downloads/redroselinux/redroselinux/total?logo=github)
</h1>

Redrose Linux is an **independent, reproducible, EU-based and beatiful** Linux distribution. It targets the **x86_64 architecture**, has a custom installer and a custom desktop enviroment.

**IF ANYONE TELLS YOU THIS IS ARCH-BASED. THAT IS OUTDATED INFORMATION. IT IS NO LONGER THE THRUTH.**

>[!CAUTION]
> Redrose Linux is under active development and is **not ready for daily use**.

- **Website**: https://redroselinux.is-a.software
- **My video about Redrose**: https://youtu.be/5E74TuwsnpI
- **Dev branch**: https://github.com/mostypc123/redroselinux

<div align="center">
  <img width="400" alt="image" src="https://github.com/user-attachments/assets/ddcd994a-e02b-48fc-9541-54c9065cd6df" />
  <img width="400" alt="image" src="https://github.com/user-attachments/assets/f9183b28-adef-425a-a9ae-16133395aa4c" />
  <img width="400" alt="image" src="https://github.com/user-attachments/assets/1e1a3188-70ab-4609-8f22-9c25b5df1521" />
  <img width="400" alt="image" src="https://github.com/user-attachments/assets/16c96925-fa6a-49f6-a8a0-fcaf98e21e0e" />
  <img width="600" alt="image" src="https://github.com/user-attachments/assets/a3e11b9a-d2a4-4345-a91b-c8fed8bfd170" />
</div>

## Download

We made a launcher to launch Redrose in QEMU. To run it, paste this into your terminal:
```bash
curl -sSSL https://raw.githubusercontent.com/redroselinux/redroselinux/refs/heads/main/src/redrose-launcher/main.py | python3
```
**In case it says "invalid magic number" when booting, try clearing your `/tmp` and re-running.** This usually happens when your download is corrupted.

This uses the latest **release**.

Otherwise, download from the Releases tab.

## Hardware Requirements

The installer can run on a potato, litterally, it needs ~131.200005M RAM. I did not do any tests for CPU.

## Development

When compiling, the Makefile copies your system libraries. You need to build them yourself if you do not want the system ones.
If you wish to edit the installer code, run from source tree:

```bash
python3 enable_debug.py
```

### nightly
To compile the nightly version, clone `mostypc123/redroselinux` and compile:

```
make
```

### stable
*this repo uses busybox. **the linuxImage file is here solely for the CI***. This will be moved to the `car-coreutils-repo` and downloaded in the `Makefile`.

To build Redrose Linux, first build a Linux kernel.
- clone the source
- `make defconfig`
- `make -j$(nproc)`
- move the generated kernel image to ./linuxImage.
- this repo has a precompiled kernel image FOR THE CI.

**You can use the prebuilt**, but it is recommended to build it for yourself. On my PC with 12 cores, it takes about 3 minutes.

Now in the Redrose directory, run:

```
make
```

or on Fedora:

```
make -f Makefile-fedora
```

This does all the magic, and even runs it in a VM.

## Other components

- **Car** (package manager): https://github.com/redroselinux/car
- **redrosectl** (idk): https://github.com/redroselinux/redrosectl

## Contact

- **Email**: mostypc7@gmail.com

## Random stats no one reads
## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=redroselinux/redroselinux&type=date&legend=top-left)](https://www.star-history.com/#redroselinux/redroselinux&type=date&legend=top-left)
