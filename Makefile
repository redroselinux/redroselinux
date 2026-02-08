FS_DIR = filesystem
INITRAMFS_DIR = initramfs
OUTPUT_DIR = .

INITRAMFS_CPIO = $(OUTPUT_DIR)/initramfs.cpio
INITRAMFS_GZ = $(OUTPUT_DIR)/initramfs.cpio.gz
ISO = $(OUTPUT_DIR)/redrose_linux.iso

# ANSI colors for pretty output
C_DIM = \033[90m
C_RESET = \033[0m
C_YELLOW = \033[33m
C_GREEN = \033[32m
C_CYAN = \033[36m
C_BOLD = \033[1m

all: dep clean installer squash-root initramfs iso vm
no-vm: clean installer squash-root initramfs iso

help:
	@echo ""
	@echo "$(C_DIM)╭──────────────────────────────────────────────────────────────────────╮$(C_RESET)"
	@echo "$(C_DIM)│$(C_RESET)  $(C_BOLD)$(C_YELLOW)Redrose Linux$(C_RESET) - Makefile targets                                    $(C_DIM)│$(C_RESET)"
	@echo "$(C_DIM)├──────────────────────────────────────────────────────────────────────┤$(C_RESET)"
	@echo "$(C_DIM)│$(C_RESET)  $(C_CYAN)all$(C_RESET)            $(C_DIM)│$(C_RESET) Build everything and run in VM                     $(C_DIM)│$(C_RESET)"
	@echo "$(C_DIM)│$(C_RESET)  $(C_CYAN)no-vm$(C_RESET)          $(C_DIM)│$(C_RESET) Build everything without running in VM             $(C_DIM)│$(C_RESET)"
	@echo "$(C_DIM)│$(C_RESET)  $(C_CYAN)installer$(C_RESET)      $(C_DIM)│$(C_RESET) Build the installer binary                         $(C_DIM)│$(C_RESET)"
	@echo "$(C_DIM)│$(C_RESET)  $(C_CYAN)run-installer$(C_RESET)  $(C_DIM)│$(C_RESET) Run the installer from initramfs                   $(C_DIM)│$(C_RESET)"
	@echo "$(C_DIM)│$(C_RESET)  $(C_CYAN)initramfs$(C_RESET)      $(C_DIM)│$(C_RESET) Build the initramfs images                         $(C_DIM)│$(C_RESET)"
	@echo "$(C_DIM)│$(C_RESET)  $(C_CYAN)iso$(C_RESET)            $(C_DIM)│$(C_RESET) Build the ISO image                                $(C_DIM)│$(C_RESET)"
	@echo "$(C_DIM)│$(C_RESET)  $(C_CYAN)clean$(C_RESET)          $(C_DIM)│$(C_RESET) Clean build artifacts                              $(C_DIM)│$(C_RESET)"
	@echo "$(C_DIM)│$(C_RESET)  $(C_CYAN)clean-downloads$(C_RESET)$(C_DIM)│$(C_RESET) Remove downloaded binaries (sgdisk, dd)            $(C_DIM)│$(C_RESET)"
	@echo "$(C_DIM)│$(C_RESET)  $(C_CYAN)clean-all$(C_RESET)      $(C_DIM)│$(C_RESET) Run both clean and clean-downloads                 $(C_DIM)│$(C_RESET)"
	@echo "$(C_DIM)│$(C_RESET)  $(C_CYAN)vm$(C_RESET)             $(C_DIM)│$(C_RESET) Run the built ISO in a QEMU VM                     $(C_DIM)│$(C_RESET)"
	@echo "$(C_DIM)│$(C_RESET)  $(C_CYAN)dep$(C_RESET)            $(C_DIM)│$(C_RESET) Check for dependencies                             $(C_DIM)│$(C_RESET)"
	@echo "$(C_DIM)╰──────────────────────────────────────────────────────────────────────╯$(C_RESET)"
	@echo ""

dep:
	@echo "$(C_CYAN)$(C_BOLD)▸ Checking dependencies$(C_RESET)"
	@which grub-mkrescue >/dev/null 2>&1 && echo "  ✓ grub-mkrescue" || (echo "  ✗ grub-mkrescue missing"; exit 1)
	@which curl >/dev/null 2>&1 && echo "  ✓ curl" || (echo "  ✗ curl missing"; exit 1)
	@which bash >/dev/null 2>&1 && echo "  ✓ bash" || (echo "  ✗ bash missing"; exit 1)
	@which mksquashfs >/dev/null 2>&1 && echo "  ✓ mksquashfs" || (echo "  ✗ mksquashfs missing"; exit 1)
	@which gzip >/dev/null 2>&1 && echo "  ✓ gzip" || (echo "  ✗ gzip missing"; exit 1)
	@which qemu-img >/dev/null 2>&1 && echo "  ✓ qemu-img" || (echo "  ✗ qemu-img missing"; exit 1)
	@which qemu-system-x86_64 >/dev/null 2>&1 && echo "  ✓ qemu-system-x86_64" || (echo "  ✗ qemu-system-x86_64 missing"; exit 1)
	@echo "$(C_RESET)"
	@echo "$(C_GREEN)▸ $(C_BOLD)All dependencies satisfied$(C_RESET)"
	@echo ""

initramfs:
	@bash -c 'mkdir -p initramfs/{proc,sys,mnt}'
	@curl -s -L -o $(INITRAMFS_DIR)/bin/sgdisk https://github.com/redroselinux/car-coreutils-repo/raw/refs/heads/main/sgdisk-static-bin
	@chmod +x $(INITRAMFS_DIR)/bin/sgdisk
	@echo "  $(C_DIM)↓$(C_RESET) initramfs/bin/sgdisk $(C_YELLOW)(redroselinux/car-coreutils-repo)$(C_RESET)"
	@curl -s -L -o initramfs/bin/mkfs.vfat https://github.com/redroselinux/car-coreutils-repo/raw/refs/heads/main/mkfs.fat
	@chmod +x initramfs/bin/mkfs.vfat
	@echo "  $(C_DIM)↓$(C_RESET) initramfs/bin/mkfs.vfat $(C_YELLOW)(redroselinux/car-coreutils-repo)$(C_RESET)"
	@curl -s -L -o initramfs/bin/unsquashfs https://github.com/VHSgunzo/squashfs-tools-static/releases/download/v4.7.2/unsquashfs-x86_64
	@chmod +x initramfs/bin/unsquashfs
	@echo "  $(C_DIM)↓$(C_RESET) initramfs/bin/unsquashfs $(C_YELLOW)(VHSgunzo/squashfs-tools-static)$(C_RESET)"
	@chmod +x $(INITRAMFS_DIR)/init
	@echo "\n$(C_CYAN)$(C_BOLD)▸ Building initramfs$(C_RESET)"
	@echo "$(C_DIM)"
	@cd $(INITRAMFS_DIR) && find . | cpio -H newc -o > ../$(INITRAMFS_CPIO)
	@gzip -f $(INITRAMFS_CPIO)
	@echo "  $(C_GREEN)✓$(C_RESET) $(INITRAMFS_CPIO)"
	@echo "  $(C_GREEN)✓$(C_RESET) $(INITRAMFS_GZ)"
	@echo "$(C_RESET)"

# currently being replaced with squashfs
# originally named rootfs-iso
# TODO: finish this migration
squash-root:
	@echo ""
	@echo "$(C_CYAN)$(C_BOLD)▸ Squashing rootfs$(C_RESET)"
	@bash -c 'mkdir -p rootfs/filesystem/{proc,sys}'
	@echo "$(C_DIM)"
	@mksquashfs rootfs/filesystem initramfs/rootfs.sqsh
	@echo "$(C_RESET)"
	@echo "  $(C_GREEN)✓$(C_RESET) initramfs/rootfs.sqsh"
	@echo ""

iso:
	@echo ""
	@echo "$(C_CYAN)$(C_BOLD)▸ Building ISO$(C_RESET)"
	@cp linuxImage $(FS_DIR)/boot/
	@cp $(INITRAMFS_GZ) $(FS_DIR)/boot/
	@echo "$(C_DIM)"
	@grub-mkrescue -o $(ISO) $(FS_DIR)
	@echo "$(C_RESET)"
	@echo "  $(C_GREEN)✓$(C_RESET) $(ISO)"
	@echo ""

installer:
	@echo ""
	@echo "$(C_CYAN)$(C_BOLD)▸ Building installer$(C_RESET)"
	@echo "$(C_DIM)"
	@GCC_COLORS= $(CC) src/installer/main.c -o initramfs/bin/install -static 2>&1
	@echo "$(C_RESET)"
	@echo "  $(C_GREEN)✓$(C_RESET) initramfs/bin/install"
	@echo ""

run-installer:
	initramfs/bin/install

clean:
	@echo ""
	@echo "$(C_CYAN)$(C_BOLD)▸ Cleaning build artifacts$(C_RESET)"
	@rm -f $(INITRAMFS_CPIO) $(INITRAMFS_GZ) $(ISO)
	@rm -f initramfs/bin/install filesystem/boot/initramfs.cpio.gz filesystem/boot/linuxImage redrose_linux.qcow2
	@rm -f rootfs/filesystem/boot/initramfs_rootfs.cpio.gz rootfs/filesystem/boot/linuxImage
	@rm -f initramfs_rootfs.cpio.gz initramfs_rootfs.cpio initramfs/rootfs.sqsh
	@echo "  $(C_GREEN)✓$(C_RESET) Clean complete"
	@echo ""
clean-downloads:
	@echo ""
	@echo "$(C_CYAN)$(C_BOLD)▸ Removing downloaded binaries$(C_RESET)"
	@rm -f $(INITRAMFS_DIR)/bin/sgdisk
	@rm -f $(INITRAMFS_DIR)/bin/dd
	@rm -f $(INITRAMFS_DIR)/bin/unsquashfs
	@echo "  $(C_GREEN)✓$(C_RESET) Downloads cleaned"
	@echo ""

clean-all: clean clean-downloads 
bare-build: installer squash-root initramfs iso
no-clean: installer squash-root initramfs iso vm

installed-vm:
	@qemu-system-x86_64 -drive file=redrose_linux.qcow2,format=qcow2 -m 2048 -boot c -enable-kvm 2>/dev/null

vm:
	@echo ""
	@echo "$(C_CYAN)$(C_BOLD)▸ Starting QEMU VM$(C_RESET)"
	@echo "  $(C_DIM)Creating disk image...$(C_RESET)"
	@qemu-img create -f qcow2 redrose_linux.qcow2 1G 2>/dev/null 2>/dev/null
	@echo "  $(C_GREEN)✓$(C_RESET) redrose_linux.qcow2"
	@echo "  $(C_DIM)Booting from $(ISO)$(C_RESET)"
	@echo ""
	@qemu-system-x86_64 -cdrom $(ISO) -drive file=redrose_linux.qcow2,format=qcow2 -m 2048 -boot d -enable-kvm 2>/dev/null
	@echo ""

.PHONY: all initramfs iso clean vms installer run-installer clean-downloads clean-all bare-build no-clean vm help installed-vm squash-root dep
