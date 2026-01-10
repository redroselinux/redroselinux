<small>This repo uses busybox.</small>

To build Redrose Linux, first build a Linux kernel.
- clone the source
- `make defconfig`
- `make -j$(nproc)`
- move the generated kernel image to ./linuxImage.

Now run:

```
make initramfs
```

and:

```
make iso
```
