FS_DIR = filesystem
INITRAMFS_DIR = initramfs
OUTPUT_DIR = .

INITRAMFS_CPIO = $(OUTPUT_DIR)/initramfs.cpio
INITRAMFS_GZ = $(OUTPUT_DIR)/initramfs.cpio.gz
ISO = $(OUTPUT_DIR)/redrose_linux.iso

all: clean installer initramfs iso vm
no-vm: clean installer initramfs iso
help:
	@echo "\033[90m-----------------------------------------------------------------------\033[0m"
	@echo "\033[90m|\033[0m  - \033[33mMakefile targets\033[0m                                                  \033[90m|\033[0m"
	@echo "\033[90m-----------------------------------------------------------------------\033[0m "
	@echo "\033[90m|\033[0m  all        \033[90m|\033[0m Build everything and run in VM                         \033[90m|\033[0m  "
	@echo "\033[90m|\033[0m  no-vm      \033[90m|\033[0m Build everything without running in VM                 \033[90m|\033[0m  "
	@echo "\033[90m-----------------------------------------------------------------------\033[0m "
	@echo "\033[90m|\033[0m  installer  \033[90m|\033[0m Build the installer binary                             \033[90m|\033[0m  "
	@echo "\033[90m|\033[0m  initramfs  \033[90m|\033[0m Build the initramfs images                             \033[90m|\033[0m  "
	@echo "\033[90m|\033[0m  iso        \033[90m|\033[0m Build the ISO image                                    \033[90m|\033[0m  "
	@echo "\033[90m|\033[0m  clean      \033[90m|\033[0m Clean up build artifacts                               \033[90m|\033[0m  "
	@echo "\033[90m|\033[0m  vm         \033[90m|\033[0m Run the built ISO in a QEMU VM                         \033[90m|\033[0m  "
	@echo "\033[90m-----------------------------------------------------------------------\033[0m "

initramfs:
	@echo "[*] Downloading sgdisk"
	curl -s -L -o $(INITRAMFS_DIR)/bin/sgdisk https://github.com/redroselinux/car-coreutils-repo/raw/refs/heads/main/sgdisk-static-bin
	chmod +x $(INITRAMFS_DIR)/bin/sgdisk
	@echo "[*] Building installer initramfs..."
	chmod +x $(INITRAMFS_DIR)/init
	cd $(INITRAMFS_DIR) && find . | cpio -H newc -o > ../$(INITRAMFS_CPIO)
	gzip -f $(INITRAMFS_CPIO)

	@echo "[*] Building rootfs initramfs..."
	cd rootfs/initramfs && find . -print | cpio -H newc -o > ../../initramfs_rootfs.cpio
	gzip -f initramfs_rootfs.cpio
	cp initramfs_rootfs.cpio.gz rootfs/filesystem/boot/

iso:
	@echo "[*] Building ISO..."
	@cp linuxImage rootfs/filesystem/boot/
	@cp initramfs_rootfs.cpio.gz rootfs/filesystem/boot/
	grub-mkrescue -o initramfs/redroselinux_rootfs.iso rootfs/filesystem
	@cp linuxImage $(FS_DIR)/boot/
	@cp $(INITRAMFS_GZ) $(FS_DIR)/boot/
	grub-mkrescue -o $(ISO) $(FS_DIR)
	@cp linuxImage rootfs/filesystem/boot/
	@cp initramfs_rootfs.cpio.gz rootfs/filesystem/boot/
	grub-mkrescue -o initramfs/redroselinux_rootfs.iso rootfs/filesystem

installer:
	gcc src/installer/main.c -o initramfs/bin/install -static

run-installer:
	initramfs/bin/install

clean:
	@rm -f $(INITRAMFS_CPIO) $(INITRAMFS_GZ) $(ISO)
	@rm -f initramfs/bin/install filesystem/boot/initramfs.cpio.gz filesystem/boot/linuxImage initramfs/bin/sgdisk redrose_linux.qcow2
	@rm -f rootfs/filesystem/boot/initramfs_rootfs.cpio.gz rootfs/filesystem/boot/linuxImage
	@rm -f initramfs_rootfs.cpio.gz initramfs_rootfs.cpio

vm:
	@echo "[*] Running in VM..."
	qemu-img create -f qcow2 redrose_linux.qcow2 1G
	qemu-system-x86_64 -cdrom $(ISO) -drive file=redrose_linux.qcow2,format=qcow2 -m 2048 -boot d -enable-kvm

.PHONY: all initramfs iso clean vm
