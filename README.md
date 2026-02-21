<h1 align="center">
  <img width="32" height="32" alt="image" src="https://github.com/user-attachments/assets/2ae22b1a-0162-43c7-b522-c741fabbb9fb" />
  Redrose Linux
  
  [![Builds](https://img.shields.io/github/actions/workflow/status/redroselinux/redroselinux/makefile.yml?label=builds)](https://github.com/redroselinux/redroselinux/actions/workflows/makefile.yml)
  ![Stars](https://img.shields.io/github/stars/redroselinux/redroselinux?style=flat)
  ![GitHub downloads](https://img.shields.io/github/downloads/redroselinux/redroselinux/total?logo=github)
</h1>

Redrose Linux is an **independent, reproducible, EU-based and beatiful** Linux distribution. It targets the **x86_64 architecture**, has a custom installer and a custom desktop enviroment.

>[!CAUTION]
> Redrose Linux is under active development and is **not ready for daily use**.

- **Website**: https://redroselinux.is-a.software
- **My video about Redrose**: https://youtu.be/5E74TuwsnpI
- **Dev branch**: https://github.com/mostypc123/redroselinux

<div align="center">
  <img width="400" alt="image" src="https://github.com/user-attachments/assets/a24eb7f2-a3fd-41f2-ab44-f626b7108bda" />
  <img width="400" alt="image" src="https://github.com/user-attachments/assets/19af0ebe-0873-4101-ac63-075c7157fc24" />
</div>

Yes, the Makefile is fancy because I opened Cursor for fun. You guessed it

## Download

We made a launcher to launch Redrose in QEMU. To run it, paste this into your terminal:
```bash
curl -sSSL https://raw.githubusercontent.com/redroselinux/redroselinux/refs/heads/main/src/redrose-launcher/main.py | python3
```

This uses the latest **release**.

Otherwise, download from the Releases tab.

## Hardware Requirements

The installer can run on a potato, litterally, it needs ~131.200005M RAM. I did not do any tests for CPU.

## Development

When compiling, the Makefile copies your system libraries. You need to build them yourself if you do not want the system ones.

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

This does all the magic, and even runs it in a VM.

## Other components

- **Car** (package manager): https://github.com/redroselinux/car

## Contact

- **Email**: mostypc7@gmail.com

## Random stats no one reads
## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=redroselinux/redroselinux&type=date&legend=top-left)](https://www.star-history.com/#redroselinux/redroselinux&type=date&legend=top-left)
