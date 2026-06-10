ROOTFS_DIR = rootfs
FS_DIR = filesystem
INITRAMFS_DIR = initramfs
OUTPUT_DIR = .
ROOTFS_FS_DIR = $(ROOTFS_DIR)/$(FS_DIR)

INITRAMFS_CPIO = $(OUTPUT_DIR)/initramfs.cpio
INITRAMFS_GZ = $(OUTPUT_DIR)/initramfs.cpio.gz
ISO = $(OUTPUT_DIR)/redrose_linux.iso
QCOW2_IMG = redrose_linux.qcow2

FEDORA := $(shell grep -q 'ID=fedora' /etc/os-release 2>/dev/null && echo 1 || echo 0)

GRUB := $(shell command -v grub2-mkrescue >/dev/null 2>&1 && echo grub2-mkrescue || echo grub-mkrescue)

all: dep clean installer install-packages strip-bins squash-root initramfs iso vm
no-vm: dep clean installer squash-root initramfs iso

help:
	@echo "=> Run 'make' to compile"

dep:
	@echo "=> Checking dependencies..."
	@mkdir -p $(ROOTFS_FS_DIR)/lib64
	@mkdir -p $(ROOTFS_FS_DIR)/lib
	@mkdir -p $(ROOTFS_FS_DIR)/usr/
	@mkdir -p $(ROOTFS_FS_DIR)/usr/lib
	@mkdir -p $(ROOTFS_FS_DIR)/usr/lib/grub
	@cp -p /lib64/ld-linux-x86-64.so.2 $(ROOTFS_FS_DIR)/lib64/
	@if [ "$(FEDORA)" = "1" ]; then \
		cmd_list="grub2-mkrescue curl bash gzip gcc qemu-img qemu-system-x86_64 python3 cpio fakeroot xorriso strip file"; \
	else \
		cmd_list="grub-mkrescue curl bash gzip gcc qemu-img qemu-system-x86_64 python3 cpio fakeroot xorriso"; \
	fi; \
	for cmd in $$cmd_list; do \
		if command -v $$cmd >/dev/null 2>&1; then \
			echo "  => Found $$cmd"; \
		else \
			if [ "$(FEDORA)" = "1" ]; then \
				echo "  => Missing $$cmd, installing..."; \
				sudo dnf install -y $$cmd || exit 1; \
			else \
				echo "  => Missing $$cmd"; \
				exit 1; \
			fi; \
		fi; \
	done
	@echo ""
	@echo "  => Running $(ROOTFS_DIR)/copy_syslibs.py"
	@python3 $(ROOTFS_DIR)/copy_syslibs.py

initramfs: dep squash-root
	@echo "==> Building initramfs..."
	@mkdir -p $(INITRAMFS_DIR)/proc $(INITRAMFS_DIR)/sys $(INITRAMFS_DIR)/mnt
	@test -f $(INITRAMFS_DIR)/bin/sgdisk || ( \
		echo "  -> $(INITRAMFS_DIR)/bin/sgdisk" && \
		curl -s -L -o $(INITRAMFS_DIR)/bin/sgdisk https://github.com/redroselinux/car-coreutils-repo/raw/refs/heads/main/sgdisk-static-bin && \
		chmod +x $(INITRAMFS_DIR)/bin/sgdisk \
	)
	@test -f $(INITRAMFS_DIR)/bin/mkfs.vfat || ( \
		echo "  -> $(INITRAMFS_DIR)/bin/mkfs.vfat" && \
		curl -s -L -o $(INITRAMFS_DIR)/bin/mkfs.vfat https://github.com/redroselinux/car-coreutils-repo/raw/refs/heads/main/mkfs.fat && \
		chmod +x $(INITRAMFS_DIR)/bin/mkfs.vfat \
	)
	@chmod +x $(INITRAMFS_DIR)/bin/init
	@ln -sf bin/init $(INITRAMFS_DIR)/init
	@chmod +x $(INITRAMFS_DIR)/bin/*
	@chmod +x $(ROOTFS_FS_DIR)/bin/*
	@chmod +x $(ROOTFS_FS_DIR)/bin/sh
	@test -f $(ROOTFS_FS_DIR)/bin/adduser && chmod +x $(ROOTFS_FS_DIR)/bin/adduser || true
	@chmod +x $(INITRAMFS_DIR)/init
	@cd $(INITRAMFS_DIR) && find . -print0 | cpio --null -o -H newc > ../$(INITRAMFS_CPIO)
	@gzip -f $(INITRAMFS_CPIO)
	@echo "  -> $(INITRAMFS_GZ)"

strip-bins: dep install-packages
	@echo "==> Stripping binaries..."
	@find $(ROOTFS_FS_DIR)/bin $(ROOTFS_FS_DIR)/*/bin $(ROOTFS_FS_DIR)/*/lib* -type f -exec file {} \; | \
	grep -E 'ELF .* (executable|shared object)' | \
	cut -d: -f1 | \
	while read -r f; do \
		echo "  => $$f"; \
		strip --strip-unneeded "$$f" || true; \
	done

install-packages: dep
	@echo "==> Installing packages..."
	@rm -f $(ROOTFS_FS_DIR)/etc/redrose-strap
	@while IFS= read -r line; do \
	    echo "$$line" | python3 $(ROOTFS_DIR)/strap.py; \
	done < $(ROOTFS_DIR)/rootfs_strap_packages
	@echo "  -> $(ROOTFS_FS_DIR)/etc/repro.car"

squash-root: dep
	@echo "=> Merging /usr paths"
	@mkdir -p $(ROOTFS_FS_DIR)/usr/bin $(ROOTFS_FS_DIR)/usr/sbin $(ROOTFS_FS_DIR)/usr/lib $(ROOTFS_FS_DIR)/usr/lib64
	@echo "  ==> Copying /bin"
	@[ -d $(ROOTFS_FS_DIR)/bin ]   && cp -a $(ROOTFS_FS_DIR)/bin/* $(ROOTFS_FS_DIR)/usr/bin/ >/dev/null 2>&1 || true
	@echo "  ==> Copying /sbin"
	@[ -d $(ROOTFS_FS_DIR)/sbin ]  && cp -a $(ROOTFS_FS_DIR)/sbin/* $(ROOTFS_FS_DIR)/usr/sbin/ >/dev/null 2>&1 || true
	@echo "  ==> Copying /lib"
	@[ -d $(ROOTFS_FS_DIR)/lib ]   && cp -a $(ROOTFS_FS_DIR)/lib/* $(ROOTFS_FS_DIR)/usr/lib/ >/dev/null 2>&1 || true
	@echo "  ==> Copying /lib64"
	@[ -d $(ROOTFS_FS_DIR)/lib64 ] && cp -a $(ROOTFS_FS_DIR)/lib64/* $(ROOTFS_FS_DIR)/usr/lib64/ >/dev/null 2>&1 || true
	@echo "  ==> Removing original / paths"
	@rm -rf $(ROOTFS_FS_DIR)/bin $(ROOTFS_FS_DIR)/sbin $(ROOTFS_FS_DIR)/lib $(ROOTFS_FS_DIR)/lib64
	@echo "  ==> Symlinking new /usr paths"
	@ln -s usr/bin   $(ROOTFS_FS_DIR)/bin
	@ln -s usr/sbin  $(ROOTFS_FS_DIR)/sbin
	@ln -s usr/lib   $(ROOTFS_FS_DIR)/lib
	@ln -s usr/lib64 $(ROOTFS_FS_DIR)/lib64
	@echo "=> Symlinking /proc/mounts to /etc/mtab"
	@ln -sf /proc/mounts $(ROOTFS_FS_DIR)/etc/mtab
	@echo "=> Installing car"
	@test -f $(ROOTFS_FS_DIR)/bin/car || ( \
		echo "  -> $(ROOTFS_FS_DIR)/bin/car" && \
		curl -s -L -o $(ROOTFS_FS_DIR)/bin/car https://github.com/redroselinux/car/releases/latest/download/car && \
		chmod +x $(ROOTFS_FS_DIR)/bin/car \
	)
	@chmod +x $(ROOTFS_FS_DIR)/sbin/reload-hostname-daemon
	@mkdir -p $(ROOTFS_FS_DIR)/lib64
	@mkdir -p $(ROOTFS_FS_DIR)/lib
	@mkdir -p $(ROOTFS_FS_DIR)/usr/
	@mkdir -p $(ROOTFS_FS_DIR)/usr/lib
	@mkdir -p $(ROOTFS_FS_DIR)/usr/lib/grub
	@echo "=> Running ldconfig"
	@ldconfig -r rootfs/filesystem
	@echo "=> Creating rootfs tgz..."
	@echo "  ==> Creating uncompressed rootfs.tar"
	@fakeroot tar -cpf $(INITRAMFS_DIR)/rootfs.tar -C $(ROOTFS_DIR) $(FS_DIR)
	@echo "  ==> Compressing rootfs.tar"
	@gzip -f $(INITRAMFS_DIR)/rootfs.tar
	@rm -f $(INITRAMFS_DIR)/rootfs.tar
	@echo "  -> $(INITRAMFS_DIR)/rootfs.tar.gz"

iso: squash-root initramfs
	@echo "=> Building ISO..."
	@echo "  ==> Copying initramfs"
	@cp $(INITRAMFS_GZ) $(FS_DIR)/boot/
	@echo "  ==> Creating ISO with grub-mkrescue"
	@$(GRUB) -o $(ISO) $(FS_DIR) --xorriso /usr/bin/xorriso >/dev/null
	@echo "  -> $(ISO)"

installer: dep
	@$(CC) src/installer/main.c src/installer/tui.c src/installer/backend.c -o $(INITRAMFS_DIR)/bin/install -static 2>&1
	@echo "  -> $(INITRAMFS_DIR)/bin/install"
	@test -f src/welcome/main.c && $(CC) src/welcome/main.c -o $(ROOTFS_FS_DIR)/bin/welcome && echo "  -> $(ROOTFS_FS_DIR)/bin/welcome" || true

run-installer:
	@echo "=> Running installer..."
	$(INITRAMFS_DIR)/bin/install

clean:
	@echo "=> Cleaning..."
	@rm -f $(ROOTFS_FS_DIR)/etc/repro.car
	@rm -f $(INITRAMFS_CPIO) $(INITRAMFS_GZ) $(ISO)
	@rm -f $(INITRAMFS_DIR)/bin/install $(FS_DIR)/boot/initramfs.cpio.gz $(FS_DIR)/boot/vmlinuz-* $(QCOW2_IMG)
	@rm -f $(ROOTFS_FS_DIR)/boot/initramfs_rootfs.cpio.gz $(ROOTFS_FS_DIR)/boot/vmlinuz-*
	@rm -f initramfs_rootfs.cpio.gz initramfs_rootfs.cpio $(INITRAMFS_DIR)/rootfs.sqsh.
	@echo "  => Done"

clean-downloads:
	@echo "=> Cleaning downloads..."
	@rm -f $(INITRAMFS_DIR)/bin/sgdisk

clean-all: clean clean-downloads
bare-build: installer squash-root initramfs iso
no-clean: installer squash-root initramfs iso vm
short-build: installer squash-root initramfs iso vm
no-strip: dep clean installer install-packages strip-bins squash-root initramfs iso vm

installed-vm: $(QCOW2_IMG)
	@echo "=> Starting VM from disk..."
	@qemu-system-x86_64 -drive file=$(QCOW2_IMG),format=qcow2 -m 2048 -boot c -enable-kvm -smp $$(nproc) -display gtk

vm: $(ISO)
	@echo "  -> $(QCOW2_IMG)"
	@qemu-img create -f qcow2 $(QCOW2_IMG) 1G
	@echo "  => Starting VM from ISO..."
	@qemu-system-x86_64 -cdrom $(ISO) -drive file=$(QCOW2_IMG),format=qcow2 -m 2048 -boot d -enable-kvm -smp $$(nproc) -display gtk

.PHONY: all initramfs iso clean vms installer run-installer clean-downloads clean-all bare-build no-clean vm help installed-vm squash-root dep
