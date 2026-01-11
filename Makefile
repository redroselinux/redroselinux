# Redrose Linux Makefile

FS_DIR = filesystem
INITRAMFS_DIR = initramfs
OUTPUT_DIR = .

INITRAMFS_CPIO = $(OUTPUT_DIR)/initramfs.cpio
INITRAMFS_GZ = $(OUTPUT_DIR)/initramfs.cpio.gz
ISO = $(OUTPUT_DIR)/redrose_linux.iso

all: clean installer initramfs iso vm

initramfs:
	@echo "[*] Building initramfs..."
	chmod +x $(INITRAMFS_DIR)/init
	cd $(INITRAMFS_DIR) && find . | cpio -H newc -o > ../$(INITRAMFS_CPIO)
	gzip $(INITRAMFS_CPIO)

iso:
	@echo "[*] Building ISO..."
	cp linuxImage $(FS_DIR)/boot/
	cp $(INITRAMFS_GZ) $(FS_DIR)/boot/
	grub-mkrescue -o $(ISO) $(FS_DIR)

installer:
	gcc src/installer/main.c -o initramfs/bin/install -static

run-installer:
	initramfs/bin/install

clean:
	@echo "[*] Cleaning..."
	rm -f $(INITRAMFS_CPIO) $(INITRAMFS_GZ) $(ISO)
	rm -f initramfs/bin/install filesystem/boot/initramfs.cpio.gz filesystem/boot/linuxImage

vm:
	@echo "[*] Running in VM..."
	qemu-system-x86_64 -cdrom $(ISO)

.PHONY: all initramfs iso clean vm
