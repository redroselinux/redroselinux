# Redrose Linux

The repositories for Car or the website are available to view on this Github organization.
This repo contains some prebuilds, as mentioned in below sections.

## Development
*this repo uses busybox. **the linuxImage file is here solely for the CI***

To build Redrose Linux, first build a Linux kernel.
- clone the source
- `make defconfig`
- `make -j$(nproc)`
- move the generated kernel image to ./linuxImage.
- this repo has a precompiled kernel image FOR THE CI.

Now run:

```
make initramfs
```

and:

```
make iso
```
