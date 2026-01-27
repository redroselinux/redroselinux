<h1 align="center">
  <img width="32" height="32" alt="image" src="https://github.com/user-attachments/assets/2ae22b1a-0162-43c7-b522-c741fabbb9fb" />
  Redrose Linux
  
  [![Builds](https://img.shields.io/github/actions/workflow/status/redroselinux/redroselinux/makefile.yml?label=builds)](https://github.com/redroselinux/redroselinux/actions/workflows/makefile.yml)
  ![Stars](https://img.shields.io/github/stars/redroselinux/redroselinux?style=flat)
  ![GitHub downloads](https://img.shields.io/github/downloads/redroselinux/redroselinux/total?logo=github)
</h1>

The repositories for Car or the website are available to view on this Github organization.
This repo contains some prebuilts, as mentioned in below sections.

- Car: https://github.com/redroselinux/car
- Website: https://github.com/redroselinux/redroselinux.github.io

## Download

We made a launcher to launch Redrose in QEMU. To run it, paste this into your terminal:
```bash
curl -sSSL https://raw.githubusercontent.com/redroselinux/redroselinux/refs/heads/main/src/redrose-launcher/main.py | python3
```

Otherwise, download from the Releases tab.

## Development
*this repo uses busybox. **the linuxImage file is here solely for the CI***. This will be moved to the car-coreutils-repo and downloaded in the Makefile.

To build Redrose Linux, first build a Linux kernel.
- clone the source
- `make defconfig`
- `make -j$(nproc)`
- move the generated kernel image to ./linuxImage.
- this repo has a precompiled kernel image FOR THE CI.

You can use the prebuilt, but it is recommended to build it for yourself.

Now in the Redrose directory, run:

```
make
```

This does all the magic, and even runs it in a VM.

## Contact

- mostypc7@gmail.com
- [![Matrix Chat](https://img.shields.io/badge/Matrix-%23redrose__linux-green?logo=matrix&logoColor=white)](https://matrix.to/#/#redrose_linux:matrix.org) 
