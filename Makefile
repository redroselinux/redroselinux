FS_DIR = filesystem
INITRAMFS_DIR = initramfs
OUTPUT_DIR = .

INITRAMFS_CPIO = $(OUTPUT_DIR)/initramfs.cpio
INITRAMFS_GZ = $(OUTPUT_DIR)/initramfs.cpio.gz
ISO = $(OUTPUT_DIR)/redrose_linux.iso

all: clean installer rootfs-iso initramfs iso vm
no-vm: clean installer rootfs-iso initramfs iso

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
	@echo "\033[90m-----------------------------------------------------------------------\033[0m"

initramfs:
	@bash -c 'mkdir -p initramfs/{proc,sys}'
	@curl -s -L -o $(INITRAMFS_DIR)/bin/sgdisk https://github.com/redroselinux/car-coreutils-repo/raw/refs/heads/main/sgdisk-static-bin
	@echo "-> initramfs/bin/sgdisk"
	@chmod +x $(INITRAMFS_DIR)/bin/sgdisk
	@chmod +x $(INITRAMFS_DIR)/init
	@cd $(INITRAMFS_DIR) && find . | cpio -H newc -o > ../$(INITRAMFS_CPIO)
	@echo "-> $(INITRAMFS_CPIO)"
	@gzip -f $(INITRAMFS_CPIO)
	@echo "-> $(INITRAMFS_GZ)"

# TODO: replace with making a rootfs tarball
# problem: does not fit into the initramfs ._.
rootfs-iso:
	@bash -c 'mkdir -p rootfs/filesystem/{proc,sys}'
	@cp linuxImage rootfs/filesystem/boot/
	@grub-mkrescue -o initramfs/redroselinux_rootfs.iso rootfs/filesystem
	@echo "-> initramfs/redroselinux_rootfs.iso"

iso:
	@cp linuxImage $(FS_DIR)/boot/
	@cp $(INITRAMFS_GZ) $(FS_DIR)/boot/
	@grub-mkrescue -o $(ISO) $(FS_DIR)
	@cp linuxImage rootfs/filesystem/boot/
	@grub-mkrescue -o initramfs/redroselinux_rootfs.iso rootfs/filesystem
	@echo "-> $(ISO)"

installer:
	@gcc src/installer/main.c -o initramfs/bin/install -static
	@echo "-> initramfs/bin/install"

run-installer:
	initramfs/bin/install

clean:
	@rm -f $(INITRAMFS_CPIO) $(INITRAMFS_GZ) $(ISO)
	@rm -f initramfs/bin/install filesystem/boot/initramfs.cpio.gz filesystem/boot/linuxImage redrose_linux.qcow2
	@rm -f rootfs/filesystem/boot/initramfs_rootfs.cpio.gz rootfs/filesystem/boot/linuxImage
	@rm -f initramfs_rootfs.cpio.gz initramfs_rootfs.cpio
	@rm -f initramfs/redroselinux_rootfs.iso
clean-downloads:
	@rm -f $(INITRAMFS_DIR)/bin/sgdisk
	@rm -f $(INITRAMFS_DIR)/bin/dd

clean-all: clean clean-downloads 
bare-build: installer rootfs-iso initramfs iso
no-clean: installer rootfs-iso initramfs iso vm

installed-vm:
	@qemu-system-x86_64 -drive file=redrose_linux.qcow2,format=qcow2 -m 2048 -boot c -enable-kvm

vm:
	@qemu-img create -f qcow2 redrose_linux.qcow2 1G
	@qemu-system-x86_64 -cdrom $(ISO) -drive file=redrose_linux.qcow2,format=qcow2 -m 2048 -boot d -enable-kvm
	$(MAKE) installed-vm

.PHONY: all initramfs iso clean vms installer run-installer clean-downloads clean-all bare-build no-clean vm help installed-vm rootfs-iso