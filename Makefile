FS_DIR = filesystem
INITRAMFS_DIR = initramfs
OUTPUT_DIR = .

INITRAMFS_CPIO = $(OUTPUT_DIR)/initramfs.cpio
INITRAMFS_GZ = $(OUTPUT_DIR)/initramfs.cpio.gz
ISO = $(OUTPUT_DIR)/redrose_linux.iso

all: dep clean installer squash-root initramfs iso vm
no-vm: dep clean installer squash-root initramfs iso

help:
	@echo "run 'make' to compile"
	@echo "on fedora, run 'make -f Makefile-fedora'"

dep:
	mkdir -p rootfs/filesystem/lib64
	mkdir -p rootfs/filesystem/lib
	mkdir -p rootfs/filesystem/usr/
	mkdir -p rootfs/filesystem/usr/lib
	mkdir -p rootfs/filesystem/usr/lib/grub
	 cp -p /lib64/ld-linux-x86-64.so.2 rootfs/filesystem/lib64/
	for cmd in grub-mkrescue curl bash gzip gcc qemu-img qemu-system-x86_64 python3 cpio fakeroot xorriso; do \
		if command -v $$cmd >/dev/null 2>&1; then \
			echo -n "✓ $$cmd  "; \
		else \
			echo -n "✗ $$cmd missing  "; \
			exit 1; \
		fi; \
	done;
	 python3 copy_syslibs.py

initramfs: dep squash-root
	bash -c 'mkdir -p initramfs/{proc,sys,mnt}'
	test -f $(INITRAMFS_DIR)/bin/sgdisk || ( \
		curl -s -L -o $(INITRAMFS_DIR)/bin/sgdisk https://github.com/redroselinux/car-coreutils-repo/raw/refs/heads/main/sgdisk-static-bin && \
		chmod +x $(INITRAMFS_DIR)/bin/sgdisk \
	)
	test -f initramfs/bin/mkfs.vfat || ( \
		curl -s -L -o initramfs/bin/mkfs.vfat https://github.com/redroselinux/car-coreutils-repo/raw/refs/heads/main/mkfs.fat && \
		chmod +x initramfs/bin/mkfs.vfat \
	)
	chmod +x $(INITRAMFS_DIR)/bin/init
	ln -sf bin/init $(INITRAMFS_DIR)/init
	chmod +x $(INITRAMFS_DIR)/bin/*
	chmod +x rootfs/filesystem/bin/*
	@echo "this is making sure :)"
	chmod +x rootfs/filesystem/bin/sh
	chmod +x rootfs/filesystem/bin/adduser
	chmod +x $(INITRAMFS_DIR)/init
	cd $(INITRAMFS_DIR) && find . -print0 | cpio --null -ov -H newc > ../$(INITRAMFS_CPIO)
	gzip -f $(INITRAMFS_CPIO)

strip-bins: dep install-packages
	find rootfs/filesystem/bin rootfs/filesystem/*/bin rootfs/filesystem/*/lib* -type f -exec file {} \; | \
	grep -E 'ELF .* (executable|shared object)' | \
	cut -d: -f1 | \
	while read -r f; do \
		echo "stripping $$f"; \
		strip --strip-unneeded "$$f" || true; \
	done

install-packages: dep
	while IFS= read -r line; do \
	    echo "$$line" | python3 strap.py; \
	done < rootfs/rootfs_strap_packages

squash-root: strip-bins install-packages dep
	# TODO: symlink full /usr paths
	ln -sf rootfs/filesystem/bin/tar rootfs/filesystem/usr/bin/tar
	ln -sf /proc/mounts rootfs/filesystem/etc/mtab
	test -f rootfs/filesystem/bin/car || ( \
		curl -s -L -o rootfs/filesystem/bin/car https://github.com/redroselinux/car/releases/latest/download/car && \
		chmod +x rootfs/filesystem/bin/car \
	)
	chmod +x rootfs/filesystem/sbin/reload-hostname-daemon
	mkdir -p rootfs/filesystem/lib64
	mkdir -p rootfs/filesystem/lib
	mkdir -p rootfs/filesystem/usr/
	mkdir -p rootfs/filesystem/usr/lib
	mkdir -p rootfs/filesystem/usr/lib/grub
	cp linux-7.0.3 rootfs/filesystem/boot/vmlinuz-7.0.3
	ln -sf vmlinuz-7.0.3 rootfs/filesystem/boot/vmlinuz
	cp linux-7.0.3 filesystem/boot/vmlinuz-7.0.3
	ln -sf vmlinuz-7.0.3 filesystem/boot/vmlinuz
	fakeroot tar -cpf initramfs/rootfs.tar -C rootfs filesystem
	 gzip -f initramfs/rootfs.tar
	 rm -f initramfs/rootfs.tar

iso: squash-root initramfs
	cp $(INITRAMFS_GZ) $(FS_DIR)/boot/
	grub-mkrescue -o $(ISO) $(FS_DIR) --xorriso /usr/bin/xorriso

installer: dep
	$(CC) src/installer/main.c -o initramfs/bin/install -static 2>&1

run-installer:
	initramfs/bin/install

clean:
	rm -f rootfs/filesystem/etc/repro.car
	rm -f $(INITRAMFS_CPIO) $(INITRAMFS_GZ) $(ISO)
	rm -f initramfs/bin/install filesystem/boot/initramfs.cpio.gz filesystem/boot/vmlinuz-7.0.3 redrose_linux.qcow2
	rm -f rootfs/filesystem/boot/initramfs_rootfs.cpio.gz rootfs/filesystem/boot/vmlinuz-7.0.3
	rm -f initramfs_rootfs.cpio.gz initramfs_rootfs.cpio initramfs/rootfs.sqsh.
clean-downloads:
	rm -f $(INITRAMFS_DIR)/bin/sgdisk

clean-all: clean clean-downloads
bare-build: installer squash-root initramfs iso
no-clean: installer squash-root initramfs iso vm

installed-vm: ./redrose_linux.qcow2
	qemu-system-x86_64 -drive file=redrose_linux.qcow2,format=qcow2 -m 2048 -boot c -enable-kvm -smp $$(nproc) -display gtk

vm: ./redrose_linux.iso
	qemu-img create -f qcow2 redrose_linux.qcow2 1G
	qemu-system-x86_64 -cdrom $(ISO) -drive file=redrose_linux.qcow2,format=qcow2 -m 2048 -boot d -enable-kvm -smp $$(nproc) -display gtk

.PHONY: all initramfs iso clean vms installer run-installer clean-downloads clean-all bare-build no-clean vm help installed-vm squash-root dep
