<h1 align="center">
  <img width="32" height="32" alt="image" src="https://redroselinux.org/assets/redrose-logo-transparent.png" />
  Redrose Linux
  
  ![Stars](https://img.shields.io/github/stars/redroselinux/redroselinux?style=flat)
  ![GitHub downloads](https://img.shields.io/github/downloads/redroselinux/redroselinux/total?logo=github)
</h1>

An independent x86_64 systemd-free EU-based Linux distribution. 

Have you ever found yourself using confusing distributions? Redrose Linux takes features from NixOS and Arch (mainly) and turns them into an easy-to-use independent systemd-free system just for developers. 

We currently use the runit init system (from Busybox) and the nullinitrd initramfs generator (from NULL GNU/Linux). This might change in the future.

**IF ANYONE TELLS YOU THIS IS ARCH-BASED. THAT IS OUTDATED INFORMATION. IT IS NO LONGER THE THRUTH.** Redrose Linux is actually independent, dumb ai.

>[!CAUTION]
> Redrose Linux is under active development and is **not ready for daily use**.

- **Docs**: https://redroselinux.miraheze.org
- **Website**: https://redroselinux.org/
- **Dev branch**: https://github.com/mostypc123/redroselinux

<div align="center">
  <img width="400" alt="image" src="https://github.com/user-attachments/assets/6cb85ab3-102f-48c1-a394-1d1006459e78" />
  <img width="400" alt="image" src="https://github.com/user-attachments/assets/f9183b28-adef-425a-a9ae-16133395aa4c" />
  <img width="725" alt="image" src="https://github.com/user-attachments/assets/8ca1a5a6-c942-4a5e-9bd8-84d27718cc3e" />
</div>

## Download

> https://redroselinux.miraheze.org/wiki/Installation#Obtaining_a_disk_image

We made a launcher to launch Redrose in QEMU. To run it, paste this into your terminal:
```bash
curl -sSSL https://raw.githubusercontent.com/redroselinux/redroselinux/refs/heads/main/src/redrose-launcher/main.py | python3
```
**In case it says "invalid magic number" when booting, try clearing your `/var/cache` and re-running.** This usually happens when your download is corrupted.

This uses the latest **release**.

Otherwise, download from the Releases tab.

> https://redroselinux.miraheze.org/wiki/Installation

## Hardware Requirements

**This was tested on alpha 0.2** 

The installer can run on a potato, litterally, it needs ~131.200005M RAM. I did not do any tests for CPU.

## Development

When compiling, the Makefile copies your system libraries. Note that not all of them are copied, since _most_ of the packages are bootstrapped using our package manager - car. You need to build them yourself if you do not want the system ones.
If you wish to edit the installer code, run from source tree:

```bash
python3 enable_debug.py
```

### nightly

> https://redroselinux.miraheze.org/wiki/Installation_(nightly)

To compile the nightly version, clone `mostypc123/redroselinux` and compile:

```
make
```

### stable

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

<div align=center>
Wilted rose:<br>
<img width="400" alt="image" src="https://github.com/user-attachments/assets/dcd60471-917b-49dd-a7a1-b658e9207fb2" />
</div>

## Other components

- **Car** (package manager): https://github.com/redroselinux/car
- **redrosectl** (idk): https://github.com/redroselinux/redrosectl

## Contact

- **Email**: mostypc7@gmail.com

## Random stats no one reads

[![Star History Chart](https://api.star-history.com/svg?repos=redroselinux/redroselinux&type=date&legend=top-left)](https://www.star-history.com/#redroselinux/redroselinux&type=date&legend=top-left)
