# was ai used in this file? yes (ansi output, minor assistance)

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
	@echo -n "$(C_CYAN)$(C_BOLD)-> Checking dependencies $(C_RESET)"; \
	for cmd in grub-mkrescue curl bash gzip gcc qemu-img qemu-system-x86_64 python3; do \
		if command -v $$cmd >/dev/null 2>&1; then \
			echo -n "✓ $$cmd  "; \
		else \
			echo -n "✗ $$cmd missing  "; \
			exit 1; \
		fi; \
	done;
	@python3 copy_syslibs.py

initramfs:
	@bash -c 'mkdir -p initramfs/{proc,sys,mnt}'
	@test -f $(INITRAMFS_DIR)/bin/sgdisk || ( \
		curl -s -L -o $(INITRAMFS_DIR)/bin/sgdisk https://github.com/redroselinux/car-coreutils-repo/raw/refs/heads/main/sgdisk-static-bin && \
		chmod +x $(INITRAMFS_DIR)/bin/sgdisk && \
		echo "  $(C_DIM)↓$(C_RESET) initramfs/bin/sgdisk $(C_YELLOW)(redroselinux/car-coreutils-repo)$(C_RESET)" \
	)
	@test -f initramfs/bin/mkfs.vfat || ( \
		curl -s -L -o initramfs/bin/mkfs.vfat https://github.com/redroselinux/car-coreutils-repo/raw/refs/heads/main/mkfs.fat && \
		chmod +x initramfs/bin/mkfs.vfat && \
		echo "  $(C_DIM)↓$(C_RESET) initramfs/bin/mkfs.vfat $(C_YELLOW)(redroselinux/car-coreutils-repo)$(C_RESET)" \
	)
	@chmod +x $(INITRAMFS_DIR)/init
	@echo "\n$(C_CYAN)$(C_BOLD)-> Building initramfs$(C_RESET)"
	@echo "$(C_DIM)"
	@cd $(INITRAMFS_DIR) && find . | cpio -H newc -o > ../$(INITRAMFS_CPIO)
	@gzip -f $(INITRAMFS_CPIO)
	@echo "  $(C_GREEN)✓$(C_RESET) $(INITRAMFS_CPIO)"
	@echo "  $(C_GREEN)✓$(C_RESET) $(INITRAMFS_GZ)"
	@echo "$(C_RESET)"

squash-root:
	@echo
	@cp linuxImage rootfs/filesystem/boot/linuxImage && \
	echo -n "$(C_CYAN)$(C_BOLD)-> Creating rootfs tar $(C_RESET)" && \
	tar -cpf initramfs/rootfs.tar -C rootfs filesystem && \
	echo "  $(C_GREEN)✓$(C_RESET) initramfs/rootfs/rootfs.tar"

iso:
	@echo "$(C_CYAN)$(C_BOLD)-> Building ISO$(C_RESET)"
	@cp linuxImage $(FS_DIR)/boot/
	@cp $(INITRAMFS_GZ) $(FS_DIR)/boot/
	@echo "$(C_DIM)"
	@grub-mkrescue -o $(ISO) $(FS_DIR)
	@echo "$(C_RESET)  $(C_GREEN)✓$(C_RESET) $(ISO)"

installer:
	@echo ""
	@echo "$(C_CYAN)$(C_BOLD)-> Building installer$(C_RESET)"
	@echo "$(C_DIM)"
	@GCC_COLORS= $(CC) src/installer/main.c -o initramfs/bin/install -static 2>&1
	@echo "$(C_RESET)"
	@echo "  $(C_GREEN)✓$(C_RESET) initramfs/bin/install"

run-installer:
	initramfs/bin/install

clean:
	@rm -f $(INITRAMFS_CPIO) $(INITRAMFS_GZ) $(ISO)
	@rm -f initramfs/bin/install filesystem/boot/initramfs.cpio.gz filesystem/boot/linuxImage redrose_linux.qcow2
	@rm -f rootfs/filesystem/boot/initramfs_rootfs.cpio.gz rootfs/filesystem/boot/linuxImage
	@rm -f initramfs_rootfs.cpio.gz initramfs_rootfs.cpio initramfs/rootfs.sqsh.
clean-downloads:
	@rm -f $(INITRAMFS_DIR)/bin/sgdisk

clean-all: clean clean-downloads
bare-build: installer squash-root initramfs iso
no-clean: installer squash-root initramfs iso vm

installed-vm:
	@qemu-system-x86_64 -drive file=redrose_linux.qcow2,format=qcow2 -m 2048 -boot c -enable-kvm 2>/dev/null

vm:
	@echo ""
	@echo "$(C_CYAN)$(C_BOLD)-> Starting QEMU VM$(C_RESET)"
	@@qemu-img create -f qcow2 redrose_linux.qcow2 1G >/dev/null 2>&1
	@qemu-system-x86_64 -cdrom $(ISO) -drive file=redrose_linux.qcow2,format=qcow2 -m 2048 -boot d -enable-kvm 2>/dev/null

.PHONY: all initramfs iso clean vms installer run-installer clean-downloads clean-all bare-build no-clean vm help installed-vm squash-root dep
