FS_DIR = filesystem
INITRAMFS_DIR = initramfs
OUTPUT_DIR = .

INITRAMFS_CPIO = $(OUTPUT_DIR)/initramfs.cpio
INITRAMFS_GZ = $(OUTPUT_DIR)/initramfs.cpio.gz
ISO = $(OUTPUT_DIR)/redrose_linux.iso

all: dep clean installer squash-root initramfs iso vm
no-vm: clean installer squash-root initramfs iso

help:
	@echo "\033[90m-----------------------------------------------------------------------\033[0m"
	@echo "\033[90m|\033[0m  - \033[33mMakefile targets\033[0m                                                  \033[90m|\033[0m"
	@echo "\033[90m-----------------------------------------------------------------------\033[0m"
	@echo "\033[90m|\033[0m  all            \033[90m|\033[0m Build everything and run in VM                     \033[90m|\033[0m"
	@echo "\033[90m|\033[0m  no-vm          \033[90m|\033[0m Build everything without running in VM             \033[90m|\033[0m"
	@echo "\033[90m|\033[0m  installer      \033[90m|\033[0m Build the installer binary                         \033[90m|\033[0m"
	@echo "\033[90m|\033[0m  run-installer  \033[90m|\033[0m Run the installer from initramfs                   \033[90m|\033[0m"
	@echo "\033[90m|\033[0m  initramfs      \033[90m|\033[0m Build the initramfs images                         \033[90m|\033[0m"
	@echo "\033[90m|\033[0m  iso            \033[90m|\033[0m Build the ISO image                                \033[90m|\033[0m"
	@echo "\033[90m|\033[0m  clean          \033[90m|\033[0m Clean build artifacts                              \033[90m|\033[0m"
	@echo "\033[90m|\033[0m  clean-downloads\033[90m|\033[0m Remove downloaded binaries (sgdisk, dd)            \033[90m|\033[0m"
	@echo "\033[90m|\033[0m  clean-all      \033[90m|\033[0m Run both clean and clean-downloads                 \033[90m|\033[0m"
	@echo "\033[90m|\033[0m  vm             \033[90m|\033[0m Run the built ISO in a QEMU VM                     \033[90m|\033[0m"
	@echo "\033[90m|\033[0m  dep            \033[90m|\033[0m Check for dependencies                             \033[90m|\033[0m"
	@echo "\033[90m-----------------------------------------------------------------------\033[0m"

dep:
	@echo "→ if the command fails before the next line with '→', you have to install the dependency that is missing."
	@echo "\033[90m"
	which grub-mkrescue
	which curl
	which bash
	which mksquashfs
	which gzip
	@echo "\033[0m"
	@echo "→ \033[33mif the command fails after this, run with 'make no-vm' to compile anyway or install QEMU\033[0m"
	@echo "\033[90m"
	which qemu-img
	which qemu-system-x86_64
	@echo "\033[0m"
	@echo "→ \033[32meverything is installed\033[0m"

initramfs:
	@bash -c 'mkdir -p initramfs/{proc,sys,mnt}'
	@curl -s -L -o $(INITRAMFS_DIR)/bin/sgdisk https://github.com/redroselinux/car-coreutils-repo/raw/refs/heads/main/sgdisk-static-bin
	@echo "↓ initramfs/bin/sgdisk"
	@curl -s -L -o initramfs/bin/mkfs.vfat https://github.com/redroselinux/car-coreutils-repo/raw/refs/heads/main/mkfs.fat
	@chmod +x initramfs/bin/mkfs.vfat
	@echo "↓ initramfs/bin/mkfs.vfat"
	@chmod +x $(INITRAMFS_DIR)/bin/sgdisk
	@echo "\033[33mThe current binary being downloaded is not built by us, thanks to https://github.com/VHSgunzo/squashfs-tools-static for providing static squashfs-tools. Downloading unsquashfs.\033[0m"
	@curl -s -L -o initramfs/bin/unsquashfs https://github.com/VHSgunzo/squashfs-tools-static/releases/download/v4.7.2/unsquashfs-x86_64
	@echo "↓ initramfs/bin/unsquashfs"
	@chmod +x initramfs/bin/unsquashfs
	@chmod +x $(INITRAMFS_DIR)/init
	@echo "\033[90m"
	@cd $(INITRAMFS_DIR) && find . | cpio -H newc -o > ../$(INITRAMFS_CPIO)
	@echo "\033[0m"
	@echo "→ $(INITRAMFS_CPIO)"
	@gzip -f $(INITRAMFS_CPIO)
	@echo "→ $(INITRAMFS_GZ)"

# currently being replaced with squashfs
# originally named rootfs-iso
# TODO: finish this migration
squash-root:
	@echo "\033[90m"
	@bash -c 'mkdir -p rootfs/filesystem/{proc,sys}'
	@mksquashfs rootfs/filesystem initramfs/rootfs.sqsh
	@echo "\033[0m"
	@echo "→ initramfs/rootfs.sqsh\n"

iso:
	@cp linuxImage $(FS_DIR)/boot/
	@cp $(INITRAMFS_GZ) $(FS_DIR)/boot/
	@echo "\033[90m"
	@grub-mkrescue -o $(ISO) $(FS_DIR)
	@echo "\033[0m"
	@echo "→ $(ISO)"

installer:
	@echo "\033[90m"
	@GCC_COLORS= \
	$(CC) src/installer/main.c -o initramfs/bin/install -static 2>&1
	@echo "\n\033[0m→ initramfs/bin/install\033[0m"

run-installer:
	initramfs/bin/install

clean:
	@rm -f $(INITRAMFS_CPIO) $(INITRAMFS_GZ) $(ISO)
	@rm -f initramfs/bin/install filesystem/boot/initramfs.cpio.gz filesystem/boot/linuxImage redrose_linux.qcow2
	@rm -f rootfs/filesystem/boot/initramfs_rootfs.cpio.gz rootfs/filesystem/boot/linuxImage
	@rm -f initramfs_rootfs.cpio.gz initramfs_rootfs.cpio initramfs/rootfs.sqsh 
clean-downloads:
	@rm -f $(INITRAMFS_DIR)/bin/sgdisk
	@rm -f $(INITRAMFS_DIR)/bin/dd
	@rm -f $(INITRAMFS_DIR)/bin/unsquashfs

clean-all: clean clean-downloads 
bare-build: installer squash-root initramfs iso
no-clean: installer squash-root initramfs iso vm

installed-vm:
	@qemu-system-x86_64 -drive file=redrose_linux.qcow2,format=qcow2 -m 2048 -boot c -enable-kvm

vm:
	@echo "\033[90m"
	@qemu-img create -f qcow2 redrose_linux.qcow2 1G
	@qemu-system-x86_64 -cdrom $(ISO) -drive file=redrose_linux.qcow2,format=qcow2 -m 2048 -boot d -enable-kvm
	@echo "\033[0m"

.PHONY: all initramfs iso clean vms installer run-installer clean-downloads clean-all bare-build no-clean vm help installed-vm squash-root dep
